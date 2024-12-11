/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Insertar  registro de UsuarioLogin

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @CodigoLogin			:	CodigoLogin 
*  @TipoLogin			:	Tipo de acceso SQL AD dominio
*  @IdServidor			:   Id servidor	
*  @Retorno		        :	Variable de Retorno 

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		13/04/2020	    version inicial 
1.1			Walther Rodriguez		01/06/2020		Validacion inicial de UsuarioLogin
1.2			Walther Rodriguez		08/06/2020		Habilitar login si esta deshabilitado
1.3			Walther Rodriguez		26/09/2020		Corregir creacion Login Linked
1.4			Walther Rodriguez		30/10/2020		Incluir el dominio en la creacion de tipo U
1.5			Hugo Chuquitaype		28/01/2021	    No crear Login Tipo U (ActiveDirectory)
2.0			Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_UsuarioLogin_Insert
	  @CodigoUsuario		VARCHAR(20)
	 ,@CodigoLogin			VARCHAR(20)
	 ,@TipoLogin			CHAR(1)	
	 --2.0 ET ,@IdServidor			TINYINT
	 ,@Retorno				int OUTPUT


AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	
	
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @Tb_Existe					Table (Existe TinyInt)


	Declare	 @Clave						Varchar(20)
	Declare  @SqlLogin					nVarchar(255)
	Declare	 @SqlLoginPolicy			nVarchar(255)

	Declare  @QueryExiste				nvarchar(max) 
	
	
	DECLARE   @ErrorSeverity			TINYINT
    DECLARE   @ErrorState				TINYINT
	DECLARE   @ErrorNumber				INTEGER
	DECLARE   @MensajeError				VARCHAR(4096) 


	Declare   @QueryExisteULogin		nvarchar(max)
	DECLARE	  @QueryUsuarioLogin		nvarchar(max) 
	Declare	  @IdLogin					TINYINT
	Declare   @Return					int
	Declare	  @TipoNt					TINYINT
	Declare	  @CodigoLoginbd			Varchar(20)
	DECLARE	  @SqlEstadoLogin			nvarchar(max)
	DECLARE	  @is_disabled				TINYINT
	DECLARE	  @NombreDominio			Varchar(20)
	
	BEGIN TRY 


		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor = 7 --2.0 ET @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK)   where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer


		Set @Return			= 0
		Set @CodigoLoginbd	= @CodigoLogin	

 

		if @TipoLogin='U'
		Begin
			Set	@TipoNt=1
			select @NombreDominio	= Framework.ufn_NombreDominio()
			select	@CodigoLogin=@NombreDominio+'\'+@CodigoLogin	--WRZ 1.4
		End
		else
			Set	@TipoNt=0

		--Validar que el Login no este registrado 1.1	 WRZ
		/*2.0 ET INICIO Set @QueryExisteULogin = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].seguridad.UsuarioLogin WITH ( NOLOCK) 
									Where codigologin = '''+@CodigoLogin +''' 
									and TipoLogin = '''+@TipoLogin +''' 
									and Estado=1' 
									2.0 ET FIN*/

		Insert Into @Tb_Existe
		Select 1 From seguridad.UsuarioLogin WITH ( NOLOCK) 
									Where codigologin = @CodigoLogin
									and TipoLogin = @TipoLogin 
									and Estado=1
		--2.0 ETExec (@QueryExisteULogin)
		If Not Exists(Select Existe From @Tb_Existe)
		Begin
				
			--Crear Login de usuario en servidor sino existe
			Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].sys.syslogins WITH ( NOLOCK)  where loginname='''+@CodigoLogin +''' and isntname='+Convert(Char(1),@TipoNt) 
					
			Delete From @Tb_Existe
			Insert Into @Tb_Existe
			Exec (@QueryExiste)

			If Not Exists(Select Existe From @Tb_Existe)
			Begin --Inicio no existe
				Select @Clave=seguridad.ufn_ProtegerCadena(Lower(@CodigoLogin),1) 
				if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
				Begin
					If @TipoLogin = 'S'
					Begin
						Set @SqlLogin = 'EXEC (''CREATE LOGIN [' + @CodigoLogin + '] WITH PASSWORD=''''' +  @Clave + ''''', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'') AT [' + @NombreServer + ']' --WRZ 1.3	
						Set	@SqlLoginPolicy ='EXEC (''[BVN_seguridad].dbo.sp_executesql N''''ALTER LOGIN ' + Quotename(@CodigoLogin) + ' WITH CHECK_EXPIRATION= ON,CHECK_POLICY = ON'''' '') AT [' + @NombreServer + ']' --WRZ 1.3	
					End
			--		If @TipoLogin = 'U' --ver 1.5 hch
			--		Begin
			--			Set @SqlLogin = 'EXEC (''CREATE LOGIN [' + @CodigoLogin + '] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english] '') AT [' + @NombreServer + ']'
			----			Set @SqlLoginPolicy ='EXEC ('''+Quotename(@NombreServer) +'.[BVN_seguridad].dbo.sp_executesql N''''ALTER LOGIN ' + Quotename(@CodigoLogin) + ' WITH CHECK_EXPIRATION= ON,CHECK_POLICY = ON'''' '') AT [' + @NombreServer + ']'
				
			--		End

				End
				Else    -- NO ES LINKED
				Begin
					If @TipoLogin = 'S'
					Begin
						Set @SqlLogin	   = 'CREATE LOGIN [' + @CodigoLogin +'] WITH PASSWORD = ''' + @Clave + ''', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF'      
						Set @SqlLoginPolicy = 'ALTER LOGIN [' + @CodigoLogin +'] WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON'      
					End
					-- If @TipoLogin = 'U' --ver 1.5 hch
					-- Begin
					--	Set @SqlLogin	   = 'CREATE LOGIN [' + @CodigoLogin +'] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]   '
					----	Set @SqlLoginPolicy = 'ALTER LOGIN [' + @CodigoLogin +'] WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON'
					--End
				End

				--Crear Login , con clave en minuscula
				Execute sp_executeSql  @SqlLogin

				--Activar politicas para SQL
				EXECUTE sp_executesql  @SqlLoginPolicy;	

			End  --Fin no existe
			ELSE
			Begin --Inicio SI existe 
				/* 2.0 ET INICIO Set @SqlEstadoLogin ='Select @is_disabled	= SLG.is_disabled
											From  ['+@NombreServer+'].[BVN_seguridad].sys.server_principals SLG  WITH (NOLOCK)
											where SLG.name  ='''+@CodigoLogin +''''

				execute sp_executeSql   @SqlEstadoLogin,  N'@is_disabled TINYINT OUTPUT',  @is_disabled = @is_disabled OUTPUT 
				2.0 ET FIN */

				Select @is_disabled	= SLG.is_disabled
											From  sys.server_principals SLG  WITH (NOLOCK)
											where SLG.name  =@CodigoLogin

				If @is_disabled=1  -- WRZ 1.2
				Begin
					if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
						Set @SqlLogin = 'EXEC (''ALTER LOGIN '+ quotename(@CodigoLogin) +' ENABLE;'') AT [' + @nombreLinkedServer + ']'   ---ver 1.1 hch
					else
						set @SqlLogin = 'ALTER LOGIN '+ quotename(@CodigoLogin) +' ENABLE ;'				---ver 1.1 hch

					Execute sp_executeSql  @SqlLogin	--Habilitar

				End

			End	  --Fin SI existe


			--INSERTA REGISTRO DE NUEVO LOGIN
			--2.0 ET Execute Framework.usp_GenerarID  @idServidor , 'Seguridad.UsuarioLogin', @CodigoUsuario ,@idLogin output 
			Execute Framework.usp_GenerarID  'Seguridad.UsuarioLogin', @CodigoUsuario ,@idLogin output 

			/*2.0 ET INICIO set @QueryUsuarioLogin  = 'INSERT INTO ['+@NombreServer+'].[BVN_seguridad].seguridad.UsuarioLogin (
													CodigoUsuario
												,IdLogin
												,TipoLogin
												,CodigoLogin
												,Estado
													)
										VALUES ( 
										'''+@CodigoUsuario+'''
										, '+convert(char(2),@idLogin)+'
										,'''+@TipoLogin+'''
										,'''+@CodigoLoginBd+'''
										,1 )'

			Execute sp_executeSql  @QueryUsuarioLogin 2.0 ET FIN*/
			INSERT INTO seguridad.UsuarioLogin (
													CodigoUsuario
												,IdLogin
												,TipoLogin
												,CodigoLogin
												,Estado
													)
										VALUES ( 
										@CodigoUsuario
										, @idLogin
										,@TipoLogin
										,@CodigoLoginBd
										,1 )
			set @Return = @idLogin
		End
		
		Select @Retorno = @Return

	END TRY


	

	BEGIN CATCH

          SELECT
               @MensajeError = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER();
         
          SELECT @MensajeError,@ErrorNumber
          SELECT @MensajeError = Framework.ufn_ObtenerMensajeDuplicidad(@MensajeError,@ErrorNumber)
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
	END CATCH

	SET LANGUAGE ENGLISH;

END;
