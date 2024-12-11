/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Elimina Login por usuario
PARAMETROS 	
* @IdServidor		       :	Id del servidor
* @CodigoUsuario           :	Código de usuario 
* @Desahabilitar			:   Identifica accion para actualizar



CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		08/02/2021	   Versión Inicial
1.1			Walther Rodriguez		11/05/2023	   Corrige eliminacion para Linked Server
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Eliminar_Login
(--2.0 ET @IdServidor TinyInt
@CodigoUsuario varchar(20)
,@Desahabilitar TinyInt) as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	
	Declare  @nombreLinkedServer	varchar(20)
	Declare  @nombreServidor		varchar(20)
	Declare	 @CodigoLogin			varchar(20)
	Declare  @SqlDrop				nvarchar(max)
	Declare  @QueryUsuarioLogin		nvarchar(max)
	Declare  @SqlDropLogin			nvarchar(max)
	Declare  @ExisteLogin			nvarchar(max)
	Declare  @RowCount				TinyInt
	Declare	 @Fila					TinyInt
	Declare	 @Tb_Existe				Table (Existe TinyInt)
	Declare  @TabUsuarioLogin		Table
									(    Id int identity (1,1)
										,CodigoLogin varchar(20))

	BEGIN TRY	 

	Select @nombreLinkedServer		= isnull(NombreLinkedServer,'') ,
					@nombreServidor	= nombreServidor
	From seguridad.Servidor WITH (NOLOCK) Where idservidor =7 --2.0 ET 	

	/*2.0 ET INICIO
	If @nombreServidor <> @@ServerName 
		if len(@nombreLinkedServer) > 1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
			set @nombreServidor	=	@nombreLinkedServer
	2.0 ET FIN*/

	--Recuperar todos los logins que tiene el usuario
	/*set @QueryUsuarioLogin  = 'Select Distinct CodigoLogin From ['+@nombreServidor+'].[BVN_seguridad].seguridad.UsuarioLogin ul WITH(NOLOCK)
									  WHERE  ul.CodigoUsuario ='''+@CodigoUsuario +''''*/
	
	Insert into @TabUsuarioLogin(CodigoLogin)
	Select Distinct CodigoLogin From seguridad.UsuarioLogin ul WITH(NOLOCK)
									  WHERE  ul.CodigoUsuario =@CodigoUsuario
	--execute sp_executeSql  @QueryUsuarioLogin
	
	Set @rowCount = (Select Count(1) From @TabUsuarioLogin)
	Set @Fila=1

	WHILE @Fila <=@rowCount
	BEGIN
		--sI EXISTE
		Select @CodigoLogin = CodigoLogin From @TabUsuarioLogin Where id = @Fila;

		--Set @ExisteLogin = 'Select 1 From ['+@nombreServidor+'].Master.[sys].[syslogins] WITH ( NOLOCK) WHERE loginname ='''+@CodigoLogin +''''  
		Insert Into @Tb_Existe
		Select 1 From Master.[sys].[syslogins] WITH ( NOLOCK) WHERE loginname =@CodigoLogin
		--Exec (@ExisteLogin)
			
		If  Exists(Select Existe From @Tb_Existe )
		Begin
			--Eliminando Login 
			if @nombreServidor<>@@SERVERNAME and @nombreServidor=@nombreLinkedServer	-- ES LINKED 1.1 WRZ
				Set @SqlDropLogin = 'EXEC (''USE MASTER '' ; ''DROP LOGIN '+ quotename(@CodigoLogin)  +' ;'') AT [' + @nombreLinkedServer + ']' 
			ELSE
				set @SqlDropLogin = 'USE MASTER' + '; DROP LOGIN  ' + quotename(@CodigoLogin)  +' ;'
						
			execute sp_executeSql  @SqlDropLogin
		End

		Set @Fila=@Fila + 1

	END
	
	if @Desahabilitar=1 
	Begin
		--Desvincular Login vs Users
		/*2.0 ET INICIO
		set @QueryUsuarioLogin  = 'UPDATE ul set ul.Estado	= 0 ' +'
								FROM  ['+@nombreServidor+'].[BVN_seguridad].seguridad.UsuarioLogin ul
								WHERE  ul.CodigoUsuario ='''+@CodigoUsuario +''''
		Execute sp_executeSql  @QueryUsuarioLogin
		2.0 ET FIN */
		UPDATE ul set ul.Estado	= 0
		FROM  seguridad.UsuarioLogin ul
		WHERE  ul.CodigoUsuario =@CodigoUsuario
	End 


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
END ;
