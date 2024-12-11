/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de usuarios según tipo de listado y Servidor

PARAMETROS 	
*  @TipoListado			:		Tipo de Listado
*  @idServidor			:       Servidor 

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    14/05/2019		Versión Inicial
1.1				Hugo Chuquitaype		21/11/2019      Incluir  @NombreServer en Sintaxis
1.2				Hugo Chuquitaype		28/11/2019      Visualizar columna Login_Activo
1.3				Hugo Chuquitaype		29/01/2020		Incluir fechaultimoacceso	,FechaAltaUsuario,FechaBajaUsuario
1.4				Hugo Chuquitaype		01/04/2020		Incluir TipoLogin y Quitar Tipoacceso
1.5				Walther Rodriguez	    01/06/2020		Incluir estado de registro UsuarioLogin (NO VAAAAAAAA)
1.6				Hugo Chuquitaype		21/07/2020		Incluir Tipo Listado 3 para Usuarios de Seguridad para Consulta 
1.7				Hugo Chuquitaype		22/01/2021		Retirar Columna U.Cip,U.Fechabaja 
														Incluir Tipo Listado 4 Visualiza Usuario para cambio masivo Login (S y U)
2.0				Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Select_03
		@TipoListado            TINYINT			
	   --2.0 ET ,@idServidor				TINYINT  
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @nombreLinkedServer	Varchar(20)
	Declare  @NombreServer			Varchar(20)
	Declare  @QuerySelect			nvarchar(max) 
	DECLARE  @Order					Varchar(100)	
	DECLARE  @INNERJOIN				Varchar(500)
	Declare  @IdApliParametro		SMALLINT
	declare  @NombrePerfilConsulta	Varchar(20)
	

	BEGIN TRY

		Set @Order  =   ' ORDER BY uL.CodigoLogin ASC'

		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET @idServidor 
		
		SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad'

		--ver 1.6 hch
		SELECT @NombrePerfilConsulta=  Rtrim(ValorCadena) FROM Framework.ParametroAplicacion WITH(NOLOCK) WHERE IdAplicacion = @IdApliParametro
			  and nombre = 'Perfil acceso a usuario' AND nivelconfiguracion='C' 



		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer
		--ver 1.2 hch --Inluir campo Login_Activo	
		--ver 1.3 hch --Incluir campo fehcaultimoacceso	,FechaAltaUsuario,FechaBajaUsuario
		--ver 1.4 hch --incluir  TipoLogin
		--ver 1.5 wrz  -- Incluir estado (NO VAAAAAAA)
		--ver 1.7 hch  -- Retirar Columna U.Cip,U.Fechabaja 
		Set @QuerySelect  = 'SELECT 	 U.CodigoUsuario
										 ,U.Nombre
										,U.ApellidoPaterno
										,U.ApellidoMaterno
										,U.NumeroDocumento
										,U.TipoCorporativo
										,U.Estado	
										,uL.CodigoLogin
										,Ul.TipoLogin	
										,U.FechaAlta
										,U.FechaCaducidadCuenta	
										,Case when IsNull(SLG.NAME,'''')='''' then ''No'' else ''Si'' End as Sql_Login
										,Case when SLG.is_disabled = 0 then  ''Si'' else ''No'' End as Login_Activo
										,uL.FechaUltimoAcceso
										,U.FechaAltaUsuario
										,U.FechaBajaUsuario
										 FROM Seguridad.Usuario U WITH ( NOLOCK) 
										LEFT JOIN  Seguridad.UsuarioLogin uL WITH (NOLOCK)
											On Ul.IdLogin= U.LoginActivo
											And Ul.CodigoUsuario= U.CodigoUsuario
									 LEFT JOIN sys.server_principals SLG  WITH (NOLOCK)
											on SLG.name = ul.codigologin '
	IF @TipoListado=1 
		Begin
			Set @QuerySelect = @QuerySelect + @Order
			execute sp_executeSql  @QuerySelect 

		END


	IF @TipoListado=2 
	Begin
		--Ini  hch  V1.1
		--Ini  hch  V1.4
		Set @INNERJOIN   = ' INNER JOIN sys.syslogins AS SL WITH (NOLOCK) 	ON 
							ul.codigologin  = SL.loginname WHERE ( SL.securityadmin = 1 OR SL.sysadmin = 1 )  AND
							U.Estado   = ''A''
							'
		--Fin  hch  V1.1
		--Fin  hch  V1.4
		Set @QuerySelect = @QuerySelect + @INNERJOIN + @Order

		execute sp_executeSql  @QuerySelect
	
	END

	--ver 1.6 hch
	IF @TipoListado=3
	Begin

		Set @QuerySelect = ' select CodigoLogin, codigousuario, Nombres, Estado from Seguridad.uv_UsuarioPerfil up WITH (NOLOCK) where up.NombrePerfil  = '''+@NombrePerfilConsulta+'''' +' Order By CodigoLogin '
		execute sp_executeSql  @QuerySelect
	
	END

	--ver 1.7 hch
	IF @TipoListado=4
	Begin
		SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad'
		Set @QuerySelect = ' select Ul.codigousuario
							,ul.CodigoLogin
							,Rtrim(u.Nombre) + space(1) + u.ApellidoPaterno as Usuario
							,Ul.IdLogin, Ul.TipoLogin
							,Tipo.Descripcion
							,space(1)  as UserSel
							from Seguridad.Usuario u WITH ( NOLOCK)
							left join Seguridad.UsuarioLogin ul WITH ( NOLOCK)
										on ul.CodigoUsuario = u.CodigoUsuario
										and ul.IdLogin	=	u.LoginActivo 
							left join ( SELECT SubString(value,charindex('':'',value,1)+1,1) AS Tipo, Left(value,Charindex('':'',value,1)-1) AS Descripcion   
										 FROM Framework.ufn_Split(
										(SELECT  Rtrim(ValorCadena) FROM Framework.ParametroAplicacion WITH(NOLOCK) WHERE IdAplicacion 
										= '+ Convert(Char(2), @IdApliParametro)+'					
										 and nombre = ''TipoLogin''
										AND nivelconfiguracion=''C'' ) 
										,'','') ) as Tipo 
										On Tipo.Tipo=  ul.TipoLogin
							Inner Join sys.server_principals SLG  WITH (NOLOCK)
											on SLG.name = ul.codigologin and SLG.is_disabled=0
							WHERE u.TipoCorporativo in (''C'',''T'')
								  AND u.estado = ''A''
							Order By Ul.CodigoLogin ASC'
						
		execute sp_executeSql  @QuerySelect
	
	END

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
	 
	  SELECT @MensajeError,@ErrorNumber
	  SELECT @MensajeError = Framework.ufn_ObtenerMensajeDuplicidad(@MensajeError,@ErrorNumber)
	  RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
	END CATCH

	SET LANGUAGE ENGLISH
    		
END;
