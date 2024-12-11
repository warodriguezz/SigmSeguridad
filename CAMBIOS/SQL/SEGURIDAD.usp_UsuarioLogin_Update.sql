/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Actualizar  registro de UsuarioLogin

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @IdLogin				:	Id del login
*  @TipoLogin			:	Tipo de acceso SQL AD dominio
*  @CodigoLogin			:	CodigoLogin 
*  @FechaUltimoAcceso	:	Fecha ultima acceso 
*  @Estado				:	Estado del registro 1 activo 0 inactivo
*  @IdServidor			:   Id servidor	

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		13/04/2020	   version inicial
2.0			Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_UsuarioLogin_Update
	  @CodigoUsuario		VARCHAR(20)
	 ,@IdLogin				Smallint
	 ,@TipoLogin			CHAR(1)	
	 ,@CodigoLogin			VARCHAR(20)
	 ,@FechaUltimoAcceso	DateTime
	 ,@Estado				Tinyint
	 --2.0 ET ,@IdServidor			TINYINT
 
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	
	
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare  @QueryExiste				nvarchar(max) 
	
	
	DECLARE   @ErrorSeverity			TINYINT
    DECLARE   @ErrorState				TINYINT
	DECLARE   @ErrorNumber				INTEGER
	DECLARE   @MensajeError				VARCHAR(4096) 

	DECLARE	  @QueryUsuarioLogin		nvarchar(max) 


	
	BEGIN TRY 

		/*2.0 ET INICIO
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK)   where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

	
		--Verificar Login de usuario en servidor 
		Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].sys.syslogins WITH ( NOLOCK)  where loginname='''+@CodigoLogin +''''    
		2.0 ET FIN*/	

		Insert Into @Tb_Existe
		Select 1 From sys.syslogins WITH ( NOLOCK)  where loginname=@CodigoLogin
		--2.0 ET Exec (@QueryExiste)

		If Exists(Select Existe From @Tb_Existe)
		Begin
			/*2.0 ET INICIO
			set @QueryUsuarioLogin  = 'UPDATE ul set ul.Estado	='+Convert(Char(1),@Estado)+'
									  FROM  ['+@NombreServer+'].[BVN_seguridad].seguridad.UsuarioLogin ul
									  WHERE  ul.CodigoUsuario ='''+@CodigoUsuario +'''
									     and  ul.IdLogin='+Convert(Char(2),@IdLogin)

			Execute sp_executeSql  @QueryUsuarioLogin
			2.0 ET INICIO*/
			UPDATE ul set ul.Estado	=@Estado
			FROM seguridad.UsuarioLogin ul
			WHERE  ul.CodigoUsuario =@CodigoUsuario
				and  ul.IdLogin=@IdLogin
		END  

	
	END TRY


	

	BEGIN CATCH

          SELECT
               @MensajeError = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER();
         
          SELECT @MensajeError = Framework.ufn_ObtenerMensajeDuplicidad(@MensajeError,@ErrorNumber)
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
	END CATCH

	SET LANGUAGE ENGLISH;

END;
