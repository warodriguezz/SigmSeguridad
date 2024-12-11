/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de servidores

PARAMETROS 	
*	@idCompania			:   Id compañia
*	@idUnidadNegocio	:	Id unidad de negocio
*	@idServidor			:	Id del servidor

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Hugo Chuquitaype 		15/05/2020		Versión Inicial
2.0				Edwin Tenorio			12/06/2024		Se quita parámetro @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Servidor_Select_03
   @idCompania  TINYINT
   ,@idUnidadNegocio SMALLINT
   --2.0 ET ,@idServidor    TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	/* 2.0 ET INICIO
	Declare  @nombreLinkedServer		Varchar(20)
	Declare	 @nombreServidor			Varchar(50)
	Declare  @QuerySelect				nvarchar(max)
	2.0 ET FIN */
	BEGIN TRY
	
		 /* 2.0 ET INICIO
		 Select @nombreLinkedServer = isnull(NombreLinkedServer,''), @nombreServidor = NombreServidor
	    from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer
		
		set @QuerySelect =		'select s.idServidor
					,s.IdCompania
					,s.IdUnidadNegocio		
					,s.NombreServidor
					,s.NombreLinkedServer
			FROM Seguridad.Servidor s WITH ( NOLOCK)
			Where s.idUnidadNegocio	=	ISNULL('+ cast(@idUnidadNegocio as varchar(10))+  ',s.idUnidadNegocio)
								and s.idCompania  =	ISNULL('+cast(@idCompania as varchar(10))+ ',s.idCompania) '

			execute sp_executeSql  @QuerySelect
			2.0 ET FIN */
			
			--2.0 ET INICIO
			Declare @Servidores Table
			(
			idServidor INT
					,IdCompania INT
					,IdUnidadNegocio INT		
					,NombreServidor varchar(20)
					,NombreLinkedServer varchar(20)
			)
			
			Insert Into @Servidores
			(
			idServidor
					,IdCompania
					,IdUnidadNegocio		
					,NombreServidor
					,NombreLinkedServer
			)
			select s.idServidor
					,s.IdCompania
					,s.IdUnidadNegocio		
					,s.NombreServidor
					,s.NombreLinkedServer
			FROM Seguridad.Servidor s WITH ( NOLOCK)
			Where s.idUnidadNegocio	=	@idUnidadNegocio
								and s.idCompania  =	@idCompania

			Select
			idServidor
					,IdCompania
					,IdUnidadNegocio		
					,NombreServidor
					,NombreLinkedServer
			From @Servidores
			--2.0 ET FIN

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
