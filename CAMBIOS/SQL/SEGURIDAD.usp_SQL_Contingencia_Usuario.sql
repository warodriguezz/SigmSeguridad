/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Asigna usuarios de Continegencia
PARAMETROS 	
*	 @IdServidor			Id del servidor
  	,@CodigoUsuario			Código Usuario
	,@Accion				Accion

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Hugo Chuquitaype	    19/06/2020		Versión Inicial
2.0				Edwin Tenorio			14/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Contingencia_Usuario
  (  --2.0 ET @IdServidor		TINYINT
	@CodigoUsuario		VARCHAR(20)
	,@Accion			TINYINT	
)

as

BEGIN

	SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;	
    
    BEGIN TRY

	--2.0 ET Declare	 @nombreLinkedServer		Varchar(100)
	--2.0 ET Declare	 @nombreServidor			Varchar(100)	
	Declare  @queyInsert				nvarchar(max) 
	Declare  @queyDelete				nvarchar(max) 
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare  @QueryExiste				nvarchar(max) 

	/*2.0 ET INICIO
		select @nombreLinkedServer = NombreLinkedServer ,@nombreServidor = NombreServidor   
		from Seguridad.Servidor WITH ( NOLOCK)  where idservidor = @idServidor


		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 1 and exists(select * from sys.servers WITH (NOLOCK)   where name = @nombreLinkedServer)
		set @nombreServidor = @nombreLinkedServer	
	2.0 ET FIN*/

		IF @Accion=1	--AGREGAR
		Begin

		--2.0 ET Set @QueryExiste = 'Select 1 From ['+@nombreServidor+'].[bvn_seguridad].seguridad.UsuarioContingencia WITH ( NOLOCK)  Where CodigoUsuario ='''+@CodigoUsuario +''''
	
		Insert Into @Tb_Existe
		Select 1 From seguridad.UsuarioContingencia WITH ( NOLOCK)  Where CodigoUsuario =@CodigoUsuario
		--2.0 ET Exec (@QueryExiste)

		If Not Exists(Select Existe From @Tb_Existe)
			Begin
			/*2.0 ET INICIO
			set @queyInsert = 'INSERT INTO ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioContingencia 
										  ( 
											  IdServidor
											, CodigoUsuario
											
											 )
								VALUES	(  
										'+convert(varchar(2),@IdServidor)+'
										,'''+@codigousuario+'''
										);'

				execute sp_executeSql   @queyInsert
				2.0 ET FIN*/
				INSERT INTO Seguridad.UsuarioContingencia 
										  ( 
											  IdServidor
											, CodigoUsuario
											
											 )
								VALUES	(  
										7
										,@codigousuario
										);
			End
		End

		IF @Accion=2	--QUITA
		Begin
		/*2.0 ET INICIO
		set @queyDelete = 'DELETE FROM ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioContingencia 
							WHERE CodigoUsuario = '''+@codigousuario+'''
							AND		IdServidor = '+convert(varchar(2),@IdServidor)
									
						
			execute sp_executeSql   @queyDelete
		2.0 ET FIN*/

		DELETE FROM Seguridad.UsuarioContingencia 
							WHERE CodigoUsuario = @codigousuario
							AND		IdServidor = 7
		End

				      
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
