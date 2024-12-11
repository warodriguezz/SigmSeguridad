/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Valida servidores para contingencia
PARAMETROS 	
*	 @Servidores			Nombre del servidor
	,@Ret					Valor devuelo

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    19/06/2020		Versión Inicial
2.0				Edwin Tenorio			14/06/2024		Se comenta @nombreLinkedServer
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Contingencia_validar
  (  @Servidores		VARCHAR(20),
	 @Ret				SMALLINT OUTPUT
  )

as

BEGIN

	SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;	
    
    BEGIN TRY

		--2.0 ET Declare	@nombreLinkedServer			Varchar(100)
		Declare	@nombreServidor				Varchar(100)	
		Declare	@rowcount					Smallint
		Declare	@Fila						Smallint	
		Declare	@idServidor					Smallint
		Declare @QueryExiste				nvarchar(max) 
		Declare	@Tb_Existe					Table (Existe TinyInt)
		Declare @Tabla						Table(Id			Smallint Identity(1,1)
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
			/*2.0 ET INICIO
			SELECT @idServidor = Idservidor FROM @Tabla WHERE Id = @Fila

			
			select @nombreLinkedServer	= NombreLinkedServer ,
					@nombreServidor		= NombreServidor   
			from Seguridad.Servidor WITH ( NOLOCK)  where idservidor = @idServidor
			
			if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 1 and exists(select 1 from sys.servers WITH (NOLOCK)   where name = @nombreLinkedServer)
				set @nombreServidor = @nombreLinkedServer
			2.0 ET FIN*/
			
			select @nombreServidor		= NombreServidor   
			from Seguridad.Servidor WITH ( NOLOCK)  where idservidor = 7

			--Validar que el servidor esten accesible
			if not exists(select 1 from sys.servers WITH (NOLOCK)   where name = @nombreServidor)
			Begin
				Set @Ret = -1
				return @Ret
			End 
			
			--Validar que existan usuarios de contigencia en ese servidor
			--2.0 ET Set @QueryExiste = 'Select 1 From ['+@nombreServidor+'].BVN_SEGURIDAD.SEGURIDAD.UsuarioContingencia uc WITH (NOLOCK)'
		
			Delete From @Tb_Existe
			Insert Into @Tb_Existe
			Select 1 From SEGURIDAD.UsuarioContingencia uc WITH (NOLOCK)
			--2.0 ET Exec (@QueryExiste)

			If Not Exists(Select Existe From @Tb_Existe)
			Begin
				Set @Ret = -2
				return @Ret
			End 
			

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
