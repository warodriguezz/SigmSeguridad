/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Habilita / Deshabilitado Usuario 
PARAMETROS 	
* @IdServidor		       :	Id del servidor
* @CodigoUsuario           :	Código de usuario 
* @Accion					:   Condición 1 - activo , 0 - Inactivo
* @DocumentoSustento		:   Nombre del Documento

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		28/11/2019	   Versión Inicial
1.1			Hugo Chuquitaype		13/01/2020	   Se aplica quotename  a @codigousuario
1.2			Hugo Chuquitaype		30/01/2020	   Se ejecuta un store para actualización de fecha de alta y baja con sus respectivos 
												   sustentos (doc)
1.3			Hugo Chuquitaype		27/04/2020	   Se Obtiene nuevo parámetro @CodigoLogin
1.4			Walther	Rodriguez		28/05/2020	   Reseteo para tipo U
1.5			Walther	Rodriguez		23/09/2020	   No resetear clave cuando se Inhabilite un usuario
1.4			Walther Rodriguez		02/11/2020	   Funcion SEGURIDAD.ufn_UsuarioLogin,devuelve el tipo
1.5			Walther Rodriguez		03/11/2020	   Utilizar tipo login , considera dominio al validar usuario U
1.6			Walther Rodriguez		03/12/2020	   Regenerar o reiniciar de acuerdo al tipo
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Habilitar_Deshabilitar
		--2.0 ET @IdServidor			TinyInt
       @CodigoUsuario		varchar(20)   
	   ,@Accion				TinyInt
	   ,@DocumentoSustento  varchar(60)   
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @Retorno_sql			Int	
	Declare  @CodigoLogin			Varchar(20) 
	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	Declare  @From					Varchar(100)
	Declare  @SqlPermiso			nvarchar(max) 
	Declare  @SqlUpdate				nvarchar(max) 
	Declare  @QuerySetVariable		nvarchar(max) 
	Declare  @Retorno				SmallInt
	Declare  @Estado				Char(1)
	Declare  @TipoLogin				Varchar(1)
	Declare  @NombreDominio			Varchar(20)
	
	BEGIN TRY
		SET @Retorno	= 0

		Select @nombreLinkedServer		= IsNull(nombreLinkedServer,'') ,
				@nombreServidor			= NombreServidor
		from seguridad.Servidor WITH (NOLOCK) where idServidor = 7 --2.0 ET 

		/*2.0 ET INICIO if @nombreServidor <> @@SERVERNAME 
			if len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
				set @nombreServidor = @nombreLinkedServer 2.0 ET FIN*/

		--Obtener Login Actual --ver Ini hch 1.3
		Select @QuerySetVariable= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario)
		execute sp_executeSql   @QuerySetVariable,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLogin  OUTPUT 


		If Len(@CodigoLogin)<2
		Begin
			Select -1 as Retorno
			Return
		End

		select @NombreDominio	= Framework.ufn_NombreDominio()
		if @TipoLogin='U'
			Select	@CodigoLogin=Rtrim(@NombreDominio)+'\'+@CodigoLogin	--WRZ 1.5


		--ver FIn hch 1.3
		IF @Accion = 1  ---Activar Login
		BEGIN
			SET @Estado='A'
			if @nombreServidor<>@@SERVERNAME and @nombreServidor=@nombreLinkedServer	-- ES LINKED
				Set @SqlPermiso = 'EXEC (''ALTER LOGIN '+ quotename(@CodigoLogin) +' ENABLE;'') AT [' + @nombreLinkedServer + ']'   ---ver 1.1 hch
			ELSE
				set @SqlPermiso = 'ALTER LOGIN '+ quotename(@CodigoLogin) +' ENABLE ;'				---ver 1.1 hch

		END

		IF @Accion = 0  ---Deshabilitar Login
		BEGIN
			SET @Estado='I'
			if @nombreServidor<>@@SERVERNAME and @nombreServidor=@nombreLinkedServer	-- ES LINKED
				Set @SqlPermiso = 'EXEC (''ALTER LOGIN '+ quotename(@CodigoLogin) +' DISABLE;'') AT [' + @nombreLinkedServer + ']'   ---ver 1.1 hch
			ELSE
				set @SqlPermiso = 'ALTER LOGIN '+ quotename(@CodigoLogin) +' DISABLE ;'   ---ver 1.1 hch

		END

		--Habilitar O Deshabilitar  Usuario
		EXECUTE sp_executesql  @SqlPermiso;

		If @Accion = 0		
			--Si esta desahabilitando, NO resetear WRZ 1.5	
			Set @Retorno_sql=1
		else
			Begin
				--Regenerar o reiniciar clave SQL dependiendo del tipo de Login WRZ 1.6	
				if @TipoLogin='S'
					--2.0 ET exec SEGURIDAD.usp_Usuario_Resetearclave @CodigoUsuario,@IdServidor,@Retorno_sql Output
					exec SEGURIDAD.usp_Usuario_Resetearclave @CodigoUsuario,@Retorno_sql Output
				else
					--2.0 ET exec SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario,@IdServidor,@Retorno_sql Output
					exec SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario,@Retorno_sql Output
			End 
	 
	 
		IF @Retorno_sql=1 or @Retorno_sql=2	--El reseto para U no esta implementado , devuelve siempre 2 wrz 1.4
		BEGIN
			--Actualizar Registro
			/*SET @SqlUpdate='Update  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.usuario 
							SET SEGURIDAD.usuario.Estado=''' +@Estado+ ''' WHERE SEGURIDAD.usuario.CodigoUsuario=''' + @CodigoUsuario + ''''
			
			EXECUTE sp_executesql  @SqlUpdate;*/
			Update  Seguridad.usuario 
							SET SEGURIDAD.usuario.Estado=@Estado WHERE SEGURIDAD.usuario.CodigoUsuario=@CodigoUsuario

			-----Ini Ver 1.2 hch
			--2.0 ET EXECUTE [SEGURIDAD].[usp_Usuario_Historico_Permiso_Insert] @CodigoUsuario,@IdServidor,@Accion,@DocumentoSustento
			 EXECUTE SEGURIDAD.usp_Usuario_Historico_Permiso_Insert @CodigoUsuario,@Accion,@DocumentoSustento
			-----Fin Ver 1.2 hch

			Set @Retorno=1

		END	
		SELECT @Retorno
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

	SET LANGUAGE ENGLISH;
	
END;
