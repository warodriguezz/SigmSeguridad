/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Asigna usuarios de Continegencia
PARAMETROS 	
*	 @Servidores			Nombre del servidor
	,@Accion				Accion
	,@Ret					Valor devuelo

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			   Walther Rodriguez	    24/06/2020		Versión Inicial
2.0				Edwin Tenorio			14/06/2024		Se comenta @nombreServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Contingencia_estado
 (   @Servidores		VARCHAR(20),
	 @Accion			TINYINT,
	 @Ret				SMALLINT OUTPUT
  )

as

BEGIN

	SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;	
    
    BEGIN TRY

		--2.0 ET Declare	@nombreLinkedServer			Varchar(100)
		--2.0 ET Declare	@nombreServidor				Varchar(100)	
		Declare	@rowcount					Smallint
		Declare	@Fila						Smallint	
		Declare	@idServidor					Smallint
		Declare	@idServidorActual			Smallint
		Declare @queyUpdate					nvarchar(max) 
		Declare	@Estado						Char(1)
		Declare @Tabla						Table(Id			Smallint Identity(1,1)
											,IdServidor Smallint)
				
		Set @Ret = 0

		Select @idServidorActual=IdServidor 
		From Seguridad.Servidor WITH ( NOLOCK)  where NombreServidor = @@SERVERNAME

		Insert Into @Tabla
		Select value From FrameWork.ufn_split(@Servidores,'-')

		Select @rowcount= Count(1) from @Tabla
	
		Set @Fila = 1
		WHILE @Fila <= @rowcount
		Begin
			SELECT @idServidor = Idservidor FROM @Tabla WHERE Id = @Fila

			/*2.0 ET INICIO
			select @nombreLinkedServer	= NombreLinkedServer ,
					@nombreServidor		= NombreServidor   
			from Seguridad.Servidor WITH ( NOLOCK)  where idservidor = @idServidor
			

			if @idServidor <> @idServidorActual and len(@nombreLinkedServer) > 1 and exists(select 1 from sys.servers WITH (NOLOCK)   where name = @nombreLinkedServer)
				set @nombreServidor = @nombreLinkedServer
			2.0 ET FIN */

			IF @Accion=1	 
				Set	@Estado=0	--Disponible contingencia
			else
				Set @Estado=1	--Disponible

			/*2.0 ET INICIO
			set @queyUpdate= 'UPDATE ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.Servidor Set Estado='+@Estado+'
							  Where IdServidor='+Convert(Char(2),@idServidor)+';'
			
			execute sp_executeSql   @queyUpdate
			2.0 ET FIN*/
			UPDATE Seguridad.Servidor Set Estado=@Estado
							  Where IdServidor=@idServidor

			Set @Fila = @Fila + 1
		End
		
		--Si hay servidores en unidades, actualizar catalogo de lima
		Update s Set s.Estado=@Estado
		From Seguridad.Servidor s
		Where IdServidor in (select IdServidor From @Tabla where IdServidor<>@idServidorActual)


		Set @Ret = 1
		Return @Ret
			      
     END TRY


    BEGIN CATCH
		DECLARE @MensajeError varchar(4096)
        DECLARE @ErrorSeverity int
        DECLARE @ErrorState int

		Set @Ret=-1

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
    END CATCH;
    SET LANGUAGE us_english;

END
