/******************************************************************************************
DATOS GENERALES	
* Descripcion			    :	Verificar si existe el usuario en el Servidor SQL
* Ejecucion en				:	Lima y unidades

PARAMETROS 	
* @Tipo				   :	Id Tipo (1 = Usuario Existe en Servidor Principal / 2 = Usuario Existe en Base Datos / 3 = Validacion FrameWork )
* @IdServidor		   :	Id del servidor
* @BaseDatos		   :    Id de la Base Datos
* @CodigoUsuario       :	Código de usuario 
* @TipoUsuario		   :	Tipo de usuario    
* @Retorno		       :	Variable de Retorno 

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		25/06/2019	   Versión Inicial
1.1			Hugo Chuquitaype		02/12/2019	   Cambior tipo de dato Variable @Retorno
1.2			Walther Rodriguez		06/02/2020	   Verificar Login 
1.3			Hugo Chuquitaype		16/04/2020	   Verificar Existencia del @CodigoLogin  (cambio @CodigoUsuario)
1.4			Hugo Chuquitaype		15/07/2020	   Verificar usuario de Perfil Consulta y Diferente (Security y Sysadmin)
1.5			Walther Rodriguez		21/09/2020	   Verificar Estado de usuario 
1.6			Walther Rodriguez		03/11/2020	   Utilizar tipo login , considera dominio al validar usuario U
1.7			Walther Rodriguez		04/11/2020	   Obtener codigo usuario en tipo 2 
												   Tomar tipologin solo en tipo <>3
1.8			Walther Rodriguez		09/02/2021	   Identificar el correcto tipo login - siempre debe ser SQL SERVER
1.9			Walther Rodriguez		06/10/2022	   Validar que exista el Login
2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Validar
		@Tipo				TinyInt 
	   --2.0 ET ,@IdServidor			TinyInt
	   ,@BaseDatos			varchar(100) 
       ,@CodigoUsuario		varchar(20)		--En 3 es Login
	   ,@TipoUsuario		Char(1)			--En 3 NO es tipoLogin
	   ,@Retorno			SmallInt OUTPUT   --ver 1.1 hch
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare	 @CodigoLogin			varchar(20)
	Declare  @Retorno_sql			SmallInt	
	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	Declare  @From					Varchar(100)
	Declare  @QuerySelect			nvarchar(max) 
	Declare  @IdApliParametro       SmallInt	
	Declare	 @PerfilAcceso			Varchar(50)
	Declare	 @TipoLogin				Varchar(1)
	Declare	 @ExisteLogin			Bit

	BEGIN TRY

		Set @ExisteLogin=1

		if @Tipo=3		-- WRZ 1.6
		Begin

			Select @CodigoLogin = @CodigoUsuario	--WRZ 1.7	

			Select @QuerySelect= SEGURIDAD.ufn_LoginUsuario(@CodigoLogin) --2.0 ET,@idServidor)
			execute sp_executeSql   @QuerySelect,  N'@CodigoUsuario VarChar(20) OUTPUT',  @CodigoUsuario = @CodigoUsuario  OUTPUT 	

		End

		--Obtener Tipo Login Actual
		Select @QuerySelect= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario) --2.0 ET,@idServidor)
		execute sp_executeSql   @QuerySelect,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLogin  OUTPUT 

		
		If Len(ISNULL(@CodigoLogin,''))<2
			Set @ExisteLogin=0

		IF @ExisteLogin>0 --1.9	 wrz 
		BEGIN

				if  @Tipo<>3	--WRZ 1.7	NO tomar el login activo, tomar siempre el que viene por parametro
					Set @TipoLogin=@TipoUsuario

				If @TipoLogin='U'			--WRZ 1.8	 siempre debe ser SQL SERVER
					Set @TipoLogin='S'

				Select @nombreLinkedServer		= IsNull(nombreLinkedServer,'') ,
						@nombreServidor			= NombreServidor
				from seguridad.Servidor WITH (NOLOCK) where idServidor = 7 --2.0 ET @idServidor 

				SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad';
				Select  @PerfilAcceso=ValorCadena From FrameWork.ParametroAplicacion  WITH ( NOLOCK) where IdAplicacion=@IdApliParametro and NivelConfiguracion='C' and Nombre='Perfil acceso a usuario';
		
				Set @Retorno	=	1

				IF @Tipo=1 
				Begin
					IF @nombreServidor =  @@SERVERNAME
						Set @From	=	'from sys.server_principals WITH (NOLOCK) '
					ELSE
					BEGIN
						if  exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
							Set @From	=	'from sys.server_principals WITH (NOLOCK) ' --2.0 ET['+@nombreLinkedServer+'].[BVN_seguridad].sys.server_principals WITH (NOLOCK) '
						else
							Set @Retorno=-1
					END
				End

				ELSE IF @Tipo=2
				Begin
					IF @nombreServidor =  @@SERVERNAME
						Set @From	=	'from ' + @BaseDatos + '.sys.database_principals WITH (NOLOCK) '
					ELSE
					BEGIN
						if  exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
							Set @From	=	'from  ['+@nombreLinkedServer+'].' + QuoteName(@BaseDatos) + '.sys.database_principals WITH (NOLOCK) '
						else
							Set @Retorno=-1
					END
	
				END
		
			
				ELSE IF @Tipo=3
				Begin
				 IF  (@TipoUsuario = 'S')
					BEGIN
						if EXISTS(SELECT  1
								FROM    sys.server_principals p WITH (NOLOCK)
										JOIN sys.syslogins s WITH (NOLOCK) ON p.sid = s.sid
								WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
										-- Logins that are not process logins
										AND p.name NOT LIKE '##%'
										-- Logins that are sysadmins
										AND ( s.sysadmin = 1 OR s.securityadmin = 1 )
										AND p.name = @CodigoLogin)
						Begin
								IF (SELECT  IS_SRVROLEMEMBER('sysadmin' , @CodigoLogin)) = 1
									Set @Retorno=1	--SysAdmin
								ELSE
									Set @Retorno=2	--SecurityAdmin
						End 
						else
						Begin  -- 1.4	HC
							 Select @PerfilAcceso=IsNull(@PerfilAcceso,'')

							 IF EXISTS (select 1
									from    Seguridad.Perfil p WITH ( NOLOCK)
									inner join 	Seguridad.UsuarioPerfil up WITH ( NOLOCK)  
										on p.IdAplicacion = up.IdAplicacion and
											p.IdPerfil  = up.IdPerfil 
									inner join seguridad.Aplicacion ap  WITH ( NOLOCK)
										on up.IdAplicacion = ap.IdAplicacion
									Where up.codigousuario		= @CodigoUsuario
										and ap.EstadoAplicacion ='S'
										and up.registroActivo   = 1
										and ap.IdAplicacion     = @IdApliParametro
										and p.NombrePerfil	    = @PerfilAcceso )
									Set @Retorno=3		--Usuario "normal" con peril de acceso
								else
									Set @Retorno=-1		--Usuario "normal" 
						End
					END
					ELSE		
					BEGIN
							/* Valida que el Login este activo en seguridad */

							/* Paso 1, Valida que el Login este asignado al usuario */
							IF NOT EXISTS( SELECT 
											1
										FROM 
											 Seguridad.UsuarioLogin WITH(NOLOCK)
										WHERE
											CodigoLogin = @CodigoLogin and TipoLogin = @TipoLogin and Estado=1 ) -- WRZ 1.6	
								Set @Retorno=-1
							else
							Begin
								/* Paso 3, Valida que el usuario este Activo en la BD de seguridad */ -- WRZ 1.5	
								IF NOT EXISTS( SELECT 
											1
										FROM 
											 Seguridad.Usuario WITH(NOLOCK)
										WHERE
											CodigoUsuario = @CodigoUsuario and Estado='A')
								Set @Retorno=-1
							End
		
					END	
			 
					Set @Retorno_sql = @Retorno

				End
		

				If	@Tipo=1 or @Tipo=2   
				Begin
					---ver 1.3 hch
					/* Valida si Existe Login en Servidor */
					SET @QuerySelect  = N'SELECT @Cantidad=COUNT(1) ' + @From	+  ' where name = ''' + @CodigoLogin + ''' and type=''' + @TipoLogin + ''''  
					print @QuerySelect
					EXEC SP_EXECUTESQL @QuerySelect, N'@Cantidad Int OUTPUT', @Retorno_sql OUTPUT     
				End
		END
		ELSE
		BEGIN
			Set @Retorno_sql=-1
		END

		Select @Retorno=@Retorno_sql  

	END TRY



	BEGIN CATCH
		DECLARE   @ErrorSeverity  TINYINT
                    , @ErrorState   TINYINT
                    , @ErrorNumber  INTEGER
                    , @MensajeError VARCHAR(4096) 

          SELECT
               @MensajeError = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER();
      
          SELECT @MensajeError = Framework.ufn_ObtenerMensajeDuplicidad(@MensajeError,@ErrorNumber)
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
	END CATCH

	SET LANGUAGE ENGLISH;

	
END;

