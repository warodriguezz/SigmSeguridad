/******************************************************************************************
DATOS GENERALES	
* Descripcion		:	Listado de Unidades de negocio por compañia para mantenimiento

PARAMETROS 	
* @TipoListado	:   1 - Muestra Todos los Registros
					
* @IdCompania		:	Código de la compania

* @IdServidor		:   Id del Servidor

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
 1				Walther Rodriguez		20-06-19		Listado de unidades por servidor
 1.1			Walther Rodriguez		27-07-2022		Usar tabla temporal
 2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure MAESTROS.usp_UnidadNegocio_Select_03
(@TipoListado TINYINT
,@Idcompania TINYINT
--2.0 ET ,@IdServidor TINYINT
) as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	
	Declare  @nombreLinkedServer	Varchar(20)
	Declare	 @NombreServer			Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 
	Declare	 @RetTabla				Int

	BEGIN TRY

	/*2.0 ET INICIO
	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
			@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer
	2.0 ET FIN*/

	--IF (@TipoListado=1)
	--Begin

		Execute Seguridad.usp_TablasTemporales 1,'tblunidades',1,@RetTabla OUTPUT		--Crear tabla wrz 1.1	
		
		/*2.0 ET INICIO
		Set @QuerySelect  = 'SELECT UN.IdCompania,
		UN.IdUnidadNegocio, 
		UN.Abreviatura, 
		CONVERT(VARCHAR(4),UN.IdCompania)+''-''+CONVERT(VARCHAR(4),UN.IdUnidadNegocio) as Codigo
		FROM ['+@NombreServer+'].[BVN_Seguridad].Maestros.UnidadNegocio UN WITH ( NOLOCK)
		Where (UN.IdCompania=' + Convert(Char(2), @IdCompania) +' OR ' + Convert(Char(1), @IdCompania) +'=0) 
		Order by UN.Abreviatura;'
		2.0 ET FIN*/

		Insert Into ##tblunidades
		SELECT UN.IdCompania,
		UN.IdUnidadNegocio, 
		UN.Abreviatura, 
		CONVERT(VARCHAR(4),UN.IdCompania)+'-'+CONVERT(VARCHAR(4),UN.IdUnidadNegocio) as Codigo
		FROM Maestros.UnidadNegocio UN WITH ( NOLOCK)
		Where (UN.IdCompania=@IdCompania OR @IdCompania=0) 
		Order by UN.Abreviatura;

       --2.0 ET execute sp_executeSql  @QuerySelect

		Select * From ##tblunidades
 
--	End
    
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
