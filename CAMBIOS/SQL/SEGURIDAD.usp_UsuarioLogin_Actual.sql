/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Setea el login activo del usuario

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @IdLogin				:	Id del Login a setear
*  @CodigoLogin		    :	Código de Usuario
*  @TipoLogin			:	TipoLogin
*  @IdServidor			:   Id servidor	


CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		13/04/2020	   version inicial 
1.1			Walther Rodriguez		26/09/2020		Corregir actualizacion en linked server
1.2			Walther Rodriguez		19/10/2020		Regenerar o reiniciar clave SQL dependiendo del tipo de Login
1.3			Walther Rodriguez		30/10/2020		Insertar registro de auditoria al resetear o regenerar
1.4			Walther Rodriguez		14/01/2021		Se borro la revision 1.3
2.0			Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_UsuarioLogin_Actual
	  @CodigoUsuario		VARCHAR(20)
	 ,@IdLogin				SMALLINT		
	 ,@CodigoLogin			VARCHAR(20)
	 ,@TipoLogin			Char(1)		--WRZ 1.2
	 --2.0 ET,@IdServidor			TINYINT
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	
	
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	DECLARE  @SqlUpdate					nvarchar(max)
	DECLARE	 @SqlEstadoLogin			nvarchar(max)
	DECLARE	 @QuerySetVariable			nvarchar(max)
	DECLARE	 @QueryInsert				nvarchar(max)
	DECLARE	 @is_disabled				TINYINT
	DECLARE	 @Estado					nVarchar(1)
	DECLARE  @Retorno					Int

	
	DECLARE   @ErrorSeverity			TINYINT
    DECLARE   @ErrorState				TINYINT
	DECLARE   @ErrorNumber				INTEGER
	DECLARE   @MensajeError				VARCHAR(4096) 

	BEGIN TRY 

		
		/*2.0 ET INICIO
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK)   where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer
				
		--Actualizar Login actual WRZ 1.1			
		SET @SqlUpdate='Update  ['+@NombreServer+'].[bvn_seguridad].Seguridad.usuario 
						SET LoginActivo=' + convert(char(2),@IdLogin)+' 
						WHERE CodigoUsuario=''' + @CodigoUsuario + ''''
		
		EXECUTE sp_executesql  @SqlUpdate;
		2.0 ET FIN */
		Update  Seguridad.usuario 
						SET LoginActivo=@IdLogin
						WHERE CodigoUsuario=@CodigoUsuario

		--Regenerar o reiniciar clave SQL dependiendo del tipo de Login 1.2	
		if @TipoLogin='S'
			--2.0 ET exec SEGURIDAD.usp_Usuario_Resetearclave @CodigoUsuario,@IdServidor,@Retorno Output
			exec SEGURIDAD.usp_Usuario_Resetearclave @CodigoUsuario,@Retorno Output
		else
			--2.0 ET exec SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario,@IdServidor,@Retorno Output
			exec SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario,@Retorno Output
	
		--Actaualizar estado de usuario en funcion del estado del login 
		/*2.0 ET INICIO Set @SqlEstadoLogin ='Select @is_disabled	= SLG.is_disabled
											From  ['+@NombreServer+'].[BVN_seguridad].sys.server_principals SLG  WITH (NOLOCK)
											where SLG.name  ='''+@CodigoLogin +''''
	
		execute sp_executeSql   @SqlEstadoLogin,  N'@is_disabled TINYINT OUTPUT',  @is_disabled = @is_disabled OUTPUT 
		2.0 ET FIN*/

		Select @is_disabled	= SLG.is_disabled
											From sys.server_principals SLG  WITH (NOLOCK)
											where SLG.name  =@CodigoLogin

		If @is_disabled=1 
			Set @Estado='I'
		else
			Set @Estado='A'
			
		/*2.0 ET INICIO SET @SqlUpdate='Update  ['+@NombreServer+'].[bvn_seguridad].Seguridad.usuario 
					SET Estado=''' + @Estado + '''
					WHERE CodigoUsuario=''' + @CodigoUsuario + ''''

		EXECUTE sp_executesql  @SqlUpdate;2.0 ET FIN*/
		Update Seguridad.usuario 
					SET Estado=@Estado
					WHERE CodigoUsuario=@CodigoUsuario

		-- 1.3 WRZ SE ELIMINIO CON LA REVISION 1.4
		-- 1.4 WRZ ELIMINAR LA REVISION 1.3
	END TRY


	

	BEGIN CATCH

          SELECT
               @MensajeError = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER();
         
          SELECT @MensajeError = FrameWork.ufn_ObtenerMensajeDuplicidad(@MensajeError,@ErrorNumber)
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
	END CATCH

	SET LANGUAGE ENGLISH;

END;
