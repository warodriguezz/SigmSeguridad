/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Insertar  registro de Usuario

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @Cip					:	Código id externo 
*  @Nombre				:   Nombre
*  @ApellidoPaterno		:	Apellido Paterno
*  @ApellidoMaterno		:	Apellido Materno	
*  @NumeroDocumento		:	NumeroDocumento	
*  @TipoCorporativo		:   Tipo Corporativo S corporativo N tercero
*  @Estado				:	Estado del usuario (A)ctivo o (I)nactivo
*  @LoginActivo			:   Login Activo
*  @CodigoLogin			:	CodigoLogin 
*  @TipoLogin			:   Tipo de Login (S: SQL y A: Active Directory)
*  @Fechacaducidadcuenta:	Fecha de cadudcidad de la cuenta
*  @FechaAlta			:   fecha de ingreso
*  @FechaBaja			:   Fecha de vencimiento
*  @UsuarioSistema      :   Usuario Sistema que inserta o actualiza el registro
*  @IdServidor			:   Id servidor	
*  @FechaAltaUsuario	:	Fecha de alta
*  @FechaBajaUsuario	:	Fecha de baja

CONTROL DE VERSION
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		14/05/2019	   Versión Inicial
1.1			Walther Rodriguez		24/10/2019	   Permitir valores NULOS para tipo SERVICIO
1.2			Hugo Chuquitaype		13/01/2020	   Permitir crear usuarios con caracter especial y número
1.3			Walther Rodriguez		28/01/2020	   Crear clave de usuario inical en minuscula
1.4			Hugo Chuquitaype		03/04/2020	   Cambio TipoAcceso por LoginActivo (1:SQL ; 2:AD ; 3:Otros) 
1.5			Walther Rodriguez		28/05/2020	   Utiliza usp_UsuarioLogin_Actual
1.6			Walther Rodriguez		28/05/2020	   Rollback si no se crea Login
1.7			Hugo Chuquitaype		08/06/2020	   Asignación de Max CodigoUsuario
1.8			Walther Rodriguez		24/09/2020	   SET XACT_ABORT ON , Longitud numero documento
1.9			Walther Rodriguez		03/12/2020	   Regenerar o reiniciar la clave segun tipo login
1.10		Hugo Chuquitaype		27/01/2021	   Crear ambos Tipos (U,S) para Nuevo Usuario
1.11		Walther Rodriguez		27/10/2021	   Incluir Fecha de alta y baja de usuario
1.12		Walther Rodriguez		22/07/2022 	   Correcion Fecha alta usuario
2.0			Pedro Torres			20/05/2024	   Commit si la creación de usuario ha tenido éxito
3.0			Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Insert (
     @CodigoUsuario			VARCHAR(20)
	,@Cip					VARCHAR(12)	
	,@Nombre				VARCHAR(30)
	,@ApellidoPaterno		VARCHAR(30)
	,@ApellidoMaterno		VARCHAR(30)	
	,@NumeroDocumento		VARCHAR(15)
	,@TipoCorporativo		VARCHAR(1)
	,@Estado				CHAR(1)
	,@LoginActivo			TINYINT      	     ---ver 1.4 hch   enlace con el tipo  (1,2,3)
	,@CodigoLogin			VARCHAR(20)			--ver 1.4 hch nuevo campo 
	,@TipoLogin				CHAR(1)				--ver 1.4 hch  tipo (A=1 ; S=2,)
	,@Fechacaducidadcuenta	DATE
	,@FechaAlta				DATE
	,@FechaBaja				DATE
    ,@UsuarioSistema		VARCHAR(20)
	--3.0 ET,@IdServidor			TINYINT
	,@FechaAltaUsuario		DATETIME			--WRZ 1.11
	,@FechaBajaUsuario		DATETIME)			--WRZ 1.11
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	SET XACT_ABORT ON;							--ver 1.8 wrz
	
	Declare	 @Clave						Varchar(20)
	Declare  @SqlLogin					nVarchar(255)
	Declare	 @SqlLoginPolicy			nVarchar(255)
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @S_username				Varchar(30)
	Declare	 @GetDate					Varchar(10)
	Declare  @Query						nvarchar(max) 
	Declare  @QueryExiste				nvarchar(max) 
	Declare  @FechacaducidadcuentaChr	Char(12)='null'
	Declare  @FechaAltaChr				Char(12)='null'
	Declare  @FechaBajaChr				Char(12)='null'
	Declare  @FechaAltaUsuarioChr		Char(12)='null'
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare	 @QuerySetVariable			nvarchar(max) 
	Declare	 @IdPlantilla				CHAR(1)
	Declare	 @IdAplicacion				SMALLINT
	Declare  @QueryUsuarioLogin			varchar(max)

	Declare   @Retorno_login			Int	
	Declare   @Retorno					Int
	DECLARE   @ErrorSeverity			TINYINT
    DECLARE   @ErrorState				TINYINT
	DECLARE   @ErrorNumber				INTEGER
	DECLARE   @MensajeError				VARCHAR(4096) 
	Declare	  @QueryMax					nvarchar(max)
	Declare	  @IDMaxUser				INTEGER
	DECLARE   @OtrolOgin				char(1)

	BEGIN TRY 

		if exists (select 1  from tempdb..sysobjects WITH ( NOLOCK)  where name like '#TabSQL%')				   
		drop table ##TabSQL

		CREATE TABLE #TabSQL ( 
		 id				Tinyint Identity(1,1)
		,IdBaseDatos	SMALLINT
		,IdRol			SMALLINT  ) 

		Select @S_username	= SUSER_SNAME()
		Select @GetDate		= Convert(Char(10),Getdate(),23)

		/*3.0 ET INICIO Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK)   where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer


		-----Ver 1.7 hch
		SET  @QueryMAx  =   'Select @IDMaxUser =  MAX  ( CASE    WHEN ISNUMERIC(CodigoUsuario) >0  THEN CodigoUsuario ELSE 0 END )
							FROM ['+@NombreServer+'].[bvn_seguridad].Seguridad.Usuario WITH ( NOLOCK) '			  


		  execute sp_executeSql   @QueryMAx,  N'@IDMaxUser Integer OUTPUT',  @IDMaxUser = @IDMaxUser OUTPUT 3.0 ET FIN*/

		  Select @IDMaxUser =  MAX  ( CASE    WHEN ISNUMERIC(CodigoUsuario) >0  THEN CodigoUsuario ELSE 0 END )
							FROM Seguridad.Usuario WITH ( NOLOCK)

		  set  @CodigoUsuario  = @IDMaxUser + 1

		-----Ver 1.7 hch

		--3.0 ET Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[bvn_seguridad].seguridad.Usuario WITH ( NOLOCK)  Where CodigoUsuario ='''+@CodigoUsuario +''''
	
		Insert Into @Tb_Existe
		Select 1 From seguridad.Usuario WITH ( NOLOCK)  Where CodigoUsuario =@CodigoUsuario
		--3.0 ETExec (@QueryExiste)

		If Not Exists(Select Existe From @Tb_Existe)

		Begin
		
				--Solo se permiten NULOS cuando es SERVICIO 1.1 WRZ
				IF @TipoCorporativo='S'
				BEGIN
					IF  @ApellidoPaterno IS null
						Set @ApellidoPaterno='null'
					
					IF  @ApellidoMaterno IS null
						Set @ApellidoMaterno='null'

					IF  @NumeroDocumento IS null
						Set @NumeroDocumento='null'

				END

				IF  @LoginActivo IS null
					Set @LoginActivo='null'

				IF @ApellidoPaterno<>'null' AND @ApellidoPaterno is not null
					SET @ApellidoPaterno	=	'''' + @ApellidoPaterno +''''

				IF @ApellidoMaterno<>'null' AND @ApellidoMaterno is not null
					SET @ApellidoMaterno	=	'''' + @ApellidoMaterno +''''

				IF @NumeroDocumento<>'null' AND @NumeroDocumento is not null
					SET @NumeroDocumento	=	'''' + Left(@NumeroDocumento,13) +'''' --WRZ 1.8	
				-- 1.1 WRZ
					
				If @Fechacaducidadcuenta is not null
					Set @FechacaducidadcuentaChr =  ''''+Convert(Char(10), @Fechacaducidadcuenta,23)  +''''
 
				If @FechaAlta is not null
					Set @FechaAltaChr =  ''''+Convert(Char(10), @FechaAlta,23)  +''''

				if @FechaBaja is not null				
					set @FechaBajaChr = ''''+Convert(Char(10), @FechaBaja,23)  +''''
	
				If @FechaAltaUsuario is not null  --WRZ 1.11	1.12
					Set @FechaAltaUsuarioChr =  ''''+Convert(Char(10), @FechaAltaUsuario,23)  +''''

		 --ver 1.4 hch

				BEGIN TRANSACTION
				/*2.0 ET INICIO
				set @Query  = 'INSERT INTO ['+@NombreServer+'].[bvn_seguridad].seguridad.Usuario (
										 CodigoUsuario
										,Cip
										,Nombre
										,ApellidoPaterno
										,ApellidoMaterno
										,NumeroDocumento
										,TipoCorporativo
										,Estado
										,LoginActivo			
										,Fechacaducidadcuenta
										,FechaAlta
										,FechaBaja
										,FechaAltaUsuario
										,UsuarioSistema
										,FechaSistema										
										 )
								VALUES ( 
							    ' +	'''' +	@CodigoUsuario    + '''
								' + ',' +  case when cast(@Cip as varchar) IS NULL then +' null ' else ''''+@Cip+'''' end +'
								' + ',''' +	@Nombre + '''
								' +	','   + @ApellidoPaterno + '
								' +	','   + @ApellidoMaterno + '
								' +	','   + @NumeroDocumento + '
								' +	',''' +	@TipoCorporativo + '''
								' +	',''' +	@Estado + '''
								' +	',	' + Rtrim(convert(char(2),@LoginActivo))+'
								' +	','   + @FechacaducidadcuentaChr + '
								' + ','   + @FechaAltaChr + '
								' + ','   + @FechaBajaChr + '
								' + ','   + @FechaAltaUsuarioChr + '
								' +	',''' +	@S_username + '''
								' +	',''' +	@GetDate + ''')'

				Execute sp_executeSql  @Query;
				2.0 ET FIN*/
				INSERT INTO seguridad.Usuario (
										 CodigoUsuario
										,Cip
										,Nombre
										,ApellidoPaterno
										,ApellidoMaterno
										,NumeroDocumento
										,TipoCorporativo
										,Estado
										,LoginActivo			
										,Fechacaducidadcuenta
										,FechaAlta
										,FechaBaja
										,FechaAltaUsuario
										,UsuarioSistema
										,FechaSistema										
										 )
								VALUES ( 
							    @CodigoUsuario
								,case when cast(@Cip as varchar) IS NULL then null else @Cip end
								,@Nombre
								,@ApellidoPaterno
								,@ApellidoMaterno
								,@NumeroDocumento
								,@TipoCorporativo
								,@Estado
								,@LoginActivo
								, @Fechacaducidadcuenta
								,@FechaAlta
								,@FechaBaja
								,@FechaAltaUsuario
								,@S_username
								,convert(datetime,@GetDate))

				--Creacion de UsuarioLogin 
				--3.0 ET EXECUTE SEGURIDAD.usp_UsuarioLogin_Insert @CodigoUsuario,@CodigoLogin,@TipoLogin,@IdServidor,@Retorno_login OUTPUT	
				EXECUTE SEGURIDAD.usp_UsuarioLogin_Insert @CodigoUsuario,@CodigoLogin,@TipoLogin,@Retorno_login OUTPUT	
				
				IF @Retorno_login > 0 --@Retorno_sql devuelve id del nuevo login
				Begin
					--Regenerar o reiniciar clave SQL dependiendo del tipo de Login 1.9	
					if @TipoLogin='S'
					Begin						
						--3.0 ET exec SEGURIDAD.usp_Usuario_Resetearclave @CodigoUsuario,@IdServidor,@Retorno OUTPUT
						exec SEGURIDAD.usp_Usuario_Resetearclave @CodigoUsuario,@Retorno OUTPUT
						SET @OtrolOgin='U'
					End
					else
					Begin
						--3.0 ET exec SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario,@IdServidor,@Retorno OUTPUT
						exec SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario,@Retorno OUTPUT
						SET @OtrolOgin='S'
					END

					--Creacion de OTRO UsuarioLogin
					--3.0 ET EXECUTE SEGURIDAD.usp_UsuarioLogin_Insert @CodigoUsuario,@CodigoLogin,@OtrolOgin,@IdServidor,@Retorno_login OUTPUT		--ver 1.10 hch
					EXECUTE SEGURIDAD.usp_UsuarioLogin_Insert @CodigoUsuario,@CodigoLogin,@OtrolOgin,@Retorno_login OUTPUT

					--PTZ 2.0 INICIO
					IF @Retorno_login > 0 --@Retorno_sql devuelve id del nuevo login
					BEGIN
						IF @@trancount > 0 
							COMMIT TRANSACTION;
					END
					ELSE
					Begin
						IF @@trancount > 0 
						BEGIN
							ROLLBACK TRANSACTION;
							RAISERROR ( 'No se pudo crear el Login', 11, 1 ); 
						END
					End
					--PTZ 2.0 FIN
				End
				ELSE
				Begin	--WRZ 1.6	
					IF @@trancount > 0 
					BEGIN
						ROLLBACK TRANSACTION;
						RAISERROR ( 'No se pudo crear el Login', 11, 1 ); 
					END
				End

		End
		
		 
	END TRY

	BEGIN CATCH
		
		 
          SELECT
               @MensajeError = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER();
         
          SELECT @MensajeError = Framework.ufn_ObtenerMensajeDuplicidad(@MensajeError,@ErrorNumber)
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
	END CATCH

	SET LANGUAGE ENGLISH;
END
