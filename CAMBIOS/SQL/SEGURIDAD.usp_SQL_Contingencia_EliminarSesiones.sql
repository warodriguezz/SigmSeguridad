/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Elimina sesiones de servidores para contingencia
PARAMETROS 	
*	 @Servidores			Nombre del servidor
	,@Ret					Valor devuelo

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    19/06/2020		Versión Inicial
2.0				Edwin Tenorio			14/06/2024		Se quita @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Contingencia_EliminarSesiones
  (  @Servidores		VARCHAR(20),
	 @Ret				SMALLINT OUTPUT
  )

as

BEGIN

	SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;	
    
    BEGIN TRY

		Declare	@rowcount					Smallint
		Declare	@Fila						Smallint	
		--2.0 ET Declare	@idServidor					Smallint
		Declare @Tabla						Table(Id		Smallint Identity(1,1)
												,IdServidor Smallint)
				
		Set @Ret = 1

		Insert Into @Tabla
		Select value From FrameWork.ufn_split(@Servidores,'-')

		Select @rowcount= Count(1) from @Tabla
		if @rowcount < 1
		Begin
			Set @Ret = 0
			return @Ret
		End 

		Set @Fila = 1
		WHILE @Fila <= @rowcount
		Begin
			--2.0 ET SELECT @idServidor = Idservidor FROM @Tabla WHERE Id = @Fila

			EXECUTE [SEGURIDAD].[usp_SQL_Eliminacion_Sesiones] --2.0 ET @idServidor

			Set @Fila = @Fila + 1
		End

		Return @Ret
			      
     END TRY


    BEGIN CATCH
		DECLARE @MensajeError varchar(4096)
        DECLARE @ErrorSeverity int
        DECLARE @ErrorState int

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
    END CATCH;
    SET LANGUAGE us_english;

END
