/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de aplicaciones por usuario

PARAMETROS 	
*  @TipoListado			:		Tipo de Listado
*  @Parametros			:       Paramtros 

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0				Walther Rodriguez       12/06/2019		Listado de usuarios
2.0				Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_UsuarioAplicacion_Select_02
      @TipoListado                  TINYINT			
	 ,@Parametros					VARCHAR(300)	
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @CodigoUsuario			varchar(20)
	Declare  @IdServidor			TinyInt
	Declare	 @NombreServer			varchar(50)
	Declare  @nombreLinkedServer	Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 

	BEGIN TRY 

	IF @TipoListado=1
	BEGIN
		SELECT @CodigoUsuario	=  Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1)
		--2.0 ET SELECT @IdServidor		=  Convert(TinyInt, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2))

		/*2.0 ET INICIO
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

		set @QuerySelect  = 'SELECT  a.idaplicacion
									    ,a.NombreAplicacion
								 from ['+@NombreServer+'].[BVN_Seguridad].Seguridad.Aplicacion a WITH ( NOLOCK)
							 Where a.idaplicacion in (select up.idaplicacion  from ['+@NombreServer+'].[BVN_Seguridad].Seguridad.usuarioperfil up WITH ( NOLOCK) where up.CodigoUsuario =''' +  @CodigoUsuario + ''' and up.registroActivo  = 1 )'
		
		execute sp_executeSql  @QuerySelect
		2.0 ET FIN */
		Declare @TablaFinal Table
		(
		idaplicacion INT
		, NombreAplicacion varchar(120)
		)
		Insert INTO @TablaFinal
		(
		idaplicacion
		, NombreAplicacion
		)
		SELECT  a.idaplicacion
				,a.NombreAplicacion
			from Seguridad.Aplicacion a WITH ( NOLOCK)
		Where a.idaplicacion in (select up.idaplicacion  from Seguridad.usuarioperfil up WITH ( NOLOCK) where up.CodigoUsuario =@CodigoUsuario and up.registroActivo  = 1 )

		Select
		idaplicacion
		, NombreAplicacion
		From @TablaFinal
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
END
