/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Deshabilitado Usuario 
PARAMETROS 	
* @IdServidor		       :	Id del servidor
* @CodigoUsuario           :	Código de usuario 
* @DocumentoSustento		:   Nombre del Documento

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		08/02/2021	   Versión Inicial
1.1			Pedro Torres			20/09/2022	   Se agrega la fecha de baja en el update
1.2			Walther Rodriguez		05/10/2022	   Correcion x cambio 1.1
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Baja
(--2.0 ET @IdServidor TinyInt
@CodigoUsuario varchar(20)
,@DocumentoSustento varchar(60))
as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	Declare  @SqlUpdate				nvarchar(max) 
	Declare  @SqlExec				nvarchar(max)
	Declare  @Retorno				SmallInt
	Declare  @Estado				Char(1)
	Declare  @Accion				TinyInt
	Declare  @Sql_Ret				Int
	
	BEGIN TRY
		SET @Retorno	= 0
		
		/*2.0 ET INICIO
		Select @nombreLinkedServer		= IsNull(nombreLinkedServer,'') ,
				@nombreServidor			= NombreServidor
		from seguridad.Servidor WITH (NOLOCK) where idServidor = @idServidor 

		if @nombreServidor <> @@SERVERNAME 
			if len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
				set @nombreServidor = @nombreLinkedServer
		2.0 ET FIN*/
		
		SET @Estado='I'
		SET @Accion=0
		Set @Sql_Ret=0


		--Eliminar Usuarios de BD
		/*Set @SqlExec = 'Execute SEGURIDAD.usp_SQL_Usuario_Eliminar_UserBaseDatos '+ Convert(Char(2),@IdServidor)+ ',''' + @CodigoUsuario + ''',1'
		EXECUTE @Sql_Ret = sp_executesql @SqlExec;
		IF @Sql_Ret <> 0
			RAISERROR('Error Eliminando Usuarios, ErrorLogId = %d.', 16, 1, @Sql_Ret) WITH SETERROR*/
		Execute SEGURIDAD.usp_SQL_Usuario_Eliminar_UserBaseDatos @CodigoUsuario,1

		--Eliminar Login
		/*Set @SqlExec = 'Execute SEGURIDAD.usp_SQL_Usuario_Eliminar_Login '+ Convert(Char(2),@IdServidor)+ ',''' + @CodigoUsuario + ''',1'
		EXECUTE @Sql_Ret = sp_executesql @SqlExec;
		IF @Sql_Ret <> 0
			RAISERROR('Error Eliminando Login, ErrorLogId = %d.', 16, 1, @Sql_Ret) WITH SETERROR*/
		Execute SEGURIDAD.usp_SQL_Usuario_Eliminar_Login @CodigoUsuario,1

		-- PT 1.1
		-- WRZ 1.2 
		/*SET @SqlUpdate='Update  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.usuario 
						SET usuario.Estado=''' +@Estado+ ''' , usuario.FechaBajaUsuario = GETDATE() WHERE usuario.CodigoUsuario=''' + @CodigoUsuario + '''' --PTZ 1.1
	
		EXECUTE sp_executesql  @SqlUpdate;*/
		Update Seguridad.usuario 
		SET usuario.Estado=@Estado, usuario.FechaBajaUsuario = GETDATE() WHERE usuario.CodigoUsuario=@CodigoUsuario

		EXECUTE SEGURIDAD.usp_Usuario_Historico_Permiso_Insert @CodigoUsuario,7,@Accion,@DocumentoSustento
		
		Set @Retorno=1


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
