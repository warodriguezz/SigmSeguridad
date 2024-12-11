/******************************************************************************************
DATOS GENERALES	
* Descripcion		: Verifica si existe un Usuario con una  Planilla de Configuraicón de Roles por Perfil

PARAMETROS 	
*	@IdAplicacion	: Id Aplicacion
*	@IdPerfil		: Id Perfil de Aplicaciones
*   @CodigoUsuario  : Codigo Usuario
*	@IdServidor		  : Id del servidor
*   @Retorno          : Indicador de retorno

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0				Hugo Chuquitaype      	18/11/2019		Versión Inicial
2.0				Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_UsuarioPerfilBaseDatosRol
(	      @IdAplicacion		SMALLINT
		, @IdPerfil			SMALLINT
		, @CodigoUsuario    VARCHAR(20)
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
	Declare  @QuerySetVariable		nvarchar(max)	
	Declare	 @Tb_Existe				Table (Existe TinyInt)
	Declare  @rowCountPerfil		int


	BEGIN TRY

		/*2.0 ET INICIO
	    select @nombreLinkedServer = isnull(nombreLinkedServer,'') ,@nombreServidor = NombreServidor  
		from seguridad.Servidor WITH (NOLOCK) where idServidor = @idServidor 	


		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers WITH (NOLOCK)  where name = @nombreLinkedServer)
		set @nombreServidor = @nombreLinkedServer

	

		set @queryRowCountPerfil =  'SELECT @rowCountPerfil =  count(idPerfil)  From ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioBaseDatosRol Ubdr WITH (NOLOCK) 
											Left  join (  SELECT Pbdr.IdBaseDatos, Pbdr.IdROl, Pbdr.IdPerfil from 
												['+@nombreServidor+'].[BVN_Seguridad].Seguridad.PerfilBaseDatosRol Pbdr WITH (NOLOCK) 
											Where Pbdr.IdAplicacion = ' + Convert(Char(2), @IdAplicacion)+' 
											)TmpPerfil
											On 		 TmpPerfil.IdBasedatos= Ubdr.idbasedatos 	and TmpPerfil.IdRol= Ubdr.IdROl
											Where   Ubdr.CodigoUsuario ='''+@CodigoUsuario +'''
											AND TmpPerfil.IdPerfil= '+ Convert(Char(3), @IdPerfil)

		execute sp_executeSql @queryRowCountPerfil,  N'@rowCountPerfil tinyint OUTPUT',  @rowCountPerfil  OUTPUT 
		2.0 ET FIN */		
		SELECT @rowCountPerfil =  count(idPerfil)  From Seguridad.UsuarioBaseDatosRol Ubdr WITH (NOLOCK) 
		Left  join (  SELECT Pbdr.IdBaseDatos, Pbdr.IdROl, Pbdr.IdPerfil from 
			Seguridad.PerfilBaseDatosRol Pbdr WITH (NOLOCK) 
		Where Pbdr.IdAplicacion = @IdAplicacion
		)TmpPerfil
		On 		 TmpPerfil.IdBasedatos= Ubdr.idbasedatos 	and TmpPerfil.IdRol= Ubdr.IdROl
		Where   Ubdr.CodigoUsuario =@CodigoUsuario
		AND TmpPerfil.IdPerfil= @IdPerfil

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
