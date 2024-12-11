/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Verificar si existe el usuario en el Servidor SQL

PARAMETROS 	
* @Tipo				   :	Tipo 1 (NO SE USA)
* @IdServidor		   :	Id del servidor
* @BaseDatos		   :    Id de la Base Datos
* @CodigoUsuario       :	Código de usuario 
* @TipoLogin		   :	Tipo Login --cambio por Tipo Usuario
* @Retorno		       :	Variable de Retorno 

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		25/06/2019	   Versión Inicial
1.1         Hugo Chuquitaype		07/05/2020	   Asignar @tipologin
1.2			Walther Rodriguez		02/11/2020	   Funcion SEGURIDAD.ufn_UsuarioLogin,devuelve el tipo
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/
ALTER procedure SEGURIDAD.usp_SQL_Usuario_Login_Validar
		@Tipo				TinyInt
	   --2.0 ET,@IdServidor			TinyInt
	   ,@BaseDatos			varchar(100) 
	   ,@CodigoUsuario		varchar(20)       
	   ,@TipoLogin			Char(1)					--QUITAR
	   ,@Retorno			VarChar(5) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	Declare  @QuerySelect			nvarchar(max) 
	Declare  @QuerySetVariable		nvarchar(max) 
	Declare  @CodigoLogin			Varchar(20)
	Declare	 @TipoLoginRet			Varchar(1)

	BEGIN TRY

	--Obtener Login Actual
		Select @QuerySetVariable= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario) --2.0 ET ,@idServidor)
		--VER 1.2	WRZ
		execute sp_executeSql   @QuerySetVariable,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLoginRet  OUTPUT 

		/*2.0 ET INICIO
		Select @nombreLinkedServer		= IsNull(nombreLinkedServer,'') ,
				@nombreServidor			= NombreServidor
		from seguridad.Servidor WITH (NOLOCK) where idServidor = @idServidor 

		if @nombreServidor <> @@SERVERNAME 
			if len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
				set @nombreServidor = @nombreLinkedServer
		

		--ver 1.1 hch
		Set @QuerySelect=' SELECT @Retorno= Case 
										When (a.name = b.name and a.sid <> b.sid and B.sid is not Null) then ''SinAs''
										When (a.name = b.name and a.sid = b.sid and B.sid is not Null) then ''ConLg''
										Else ''SinLg''
									END  
						FROM ['+@nombreServidor+'].['+@BaseDatos+'].sys.database_principals a  WITH ( NOLOCK)
						Left Join ['+@nombreServidor+'].Master.[sys].[syslogins] b  WITH ( NOLOCK)
							on a.sid = b.sid or a.name = b.name
						Where type ='''+@TipoLoginRet+'''
						 AND principal_id > 4 
							AND A.name='''+@codigologin+''' '
		
		--ver 1.1 hch
		EXEC SP_EXECUTESQL @QuerySelect, N'@Retorno Varchar(5) OUTPUT', @Retorno=@Retorno OUTPUT
		2.0 ET FIN */

		SELECT @Retorno= Case 
										When (a.name = b.name and a.sid <> b.sid and B.sid is not Null) then 'SinAs'
										When (a.name = b.name and a.sid = b.sid and B.sid is not Null) then 'ConLg'
										Else 'SinLg'
									END  
						FROM sys.database_principals a  WITH ( NOLOCK)
						Left Join Master.[sys].[syslogins] b  WITH ( NOLOCK)
							on a.sid = b.sid or a.name = b.name
						Where type =@TipoLoginRet
						 AND principal_id > 4 
							AND A.name=@codigologin

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
