/******************************************************************************************
DATOS GENERALES	
* Descripcion		: Verifica si existe una Planilla de Configuraicón de Roles por Perfil

PARAMETROS 	
*	@IdAplicacion	: Id Aplicacion
*	@IdPerfil		: Id Perfil de Aplicaciones
*	@IdServidor		  : Id del servidor
*   @Retorno          : Indicador de retorno

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0				Hugo Chuquitaype      	30/11/2019		Versión Inicial
2.0				Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_PerfilBaseDatosRol
(	      @IdAplicacion		SMALLINT
		, @IdPerfil			SMALLINT
		--2.0 ET , @IdServidor		TINYINT
		, @Retorno			TinyInt OUTPUT  
)

AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;


	Declare  @nombreServidor		varchar(20)	
	Declare  @nombreLinkedServer	varchar(20)
	Declare  @queryRowCountPerfil	nvarchar(max)
	Declare  @rowCountPerfil		int


	BEGIN TRY

		/*2.0 ET INICIO
	    select @nombreLinkedServer = isnull(nombreLinkedServer,'') ,@nombreServidor = NombreServidor  
		from seguridad.Servidor WITH (NOLOCK) where idServidor = @idServidor 	


		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers WITH (NOLOCK)  where name = @nombreLinkedServer)
		set @nombreServidor = @nombreLinkedServer
		
	
 
		set @queryRowCountPerfil = ' SELECT @rowCountPerfil =  count(idPerfil) 
											FROM ['+@nombreServidor+'].[bvn_seguridad].seguridad.PerfilBaseDatosRol  WITH (NOLOCK) 
											WHERE idAplicacion=  '+convert(varchar(10),@idAplicacion)+'							
											and IdPerfil  =  '+convert(varchar(10),@IdPerfil)+''

		execute sp_executeSql @queryRowCountPerfil,  N'@rowCountPerfil tinyint OUTPUT',  @rowCountPerfil  OUTPUT 
		2.0 ET FIN*/

		SELECT @rowCountPerfil =  count(idPerfil) 
		FROM seguridad.PerfilBaseDatosRol  WITH (NOLOCK) 
		WHERE idAplicacion=  @idAplicacion
		and IdPerfil  =  @IdPerfil

		Select @Retorno=@rowCountPerfil  

	
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
