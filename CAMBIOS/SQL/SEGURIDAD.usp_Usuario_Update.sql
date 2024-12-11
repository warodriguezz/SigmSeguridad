/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Actualizar los datos de usaurio

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @Cip					:	Código id externo 
*  @Nombre				:   Nombre
*  @ApellidoPaterno		:	Apellido Paterno
*  @ApellidoMaterno		:	Apellido Materno	
*  @NumeroDocumento		:	NumeroDocumento	
*  @TipoCorporativo		:   Tipo Corporativo S corporativo N tercero
*  @Estado				:   estado
*  @LoginActivo			:	Login activo (1:S,2:A) Tipo de acceso SQL AD dominio     ---Se modifica por  @TipoAcceso	
*  @Fechacaducidadcuenta:   Fecha caducidad cuenta clave
*  @FechaAlta			:   fecha de ingreso
*  @FechaBaja			:   Fecha de baja
*  @UsuarioSistema      :   Usuario Sistema  de la actualizaciòn realizada
*  @IdServidor			:  id servidor
*  @CodigoLogin			:	Codigo de login
*  @TipoLogin			:	Id del login

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodirguez		01/03/2019	   Versión Inicial
1.1			Hugo Chuquitaype		06/04/2020		Cambio por TipoLogin 
1.2			Walther Rodriguez		27/10/2021	   Incluir Fecha de alta y baja de usuario (NO SE ACTUALIZAN)
1.3			Walther Rodriguez		01/12/2022	   Utilizar transaccion distribuida para linked
2.0			Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/	
ALTER procedure SEGURIDAD.usp_Usuario_Update (
	 @CodigoUsuario			VARCHAR(20)
	,@Cip					VARCHAR(12)	
	,@Nombre				VARCHAR(30)
	,@ApellidoPaterno		VARCHAR(30)
	,@ApellidoMaterno		VARCHAR(30)	
	,@NumeroDocumento		VARCHAR(15)
	,@TipoCorporativo		VARCHAR(1)
	,@Estado				CHAR(1)
	,@LoginActivo			TINYINT       ----,@TipoAcceso			VARCHAR(2)
	,@CodigoLogin			VARCHAR(20)			--ver 1.1 hch  
	,@TipoLogin				CHAR(1)				--ver 1.1 hch  tipo (SQL=1 ; AD=2,)	
	,@Fechacaducidadcuenta	DATE
	,@FechaAlta				DATE
	,@FechaBaja  			DATE
	,@UsuarioSistema		VARCHAR(20)
	--2.0 ET,@IdServidor			TINYINT
	,@FechaAltaUsuario		DATETIME			--WRZ 1.2
	,@FechaBajaUsuario		DATETIME)			--WRZ 1.2
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	SET XACT_ABORT ON;


	
	Declare  @nombreLinkedServer		Varchar(50)
	Declare	 @NombreServer				Varchar(50)
	Declare  @Query						nvarchar(max) 
	Declare  @QueryExiste				nvarchar(max) 
	Declare	 @S_username				Varchar(30)
	Declare	 @GetDate					Varchar(10)
	Declare  @FechacaducidadcuentaChr	Char(12)='null'
	Declare  @FechaAltaChr				Char(12)='null'
	Declare  @FechaBajaChr				Char(12)='null'
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare   @Retorno_sql				Int	
	Declare  @SqlUpdate				nvarchar(max) 
	
	BEGIN DISTRIBUTED TRANSACTION;	--WRZ 1.3

	BEGIN TRY 

			Select @S_username	= SUSER_SNAME()
			Select @GetDate		= Convert(Char(10),Getdate(),23)
		
			/*2.0 ET INICIO Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

			If @NombreServer<>@@SERVERNAME
				if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers   WITH ( NOLOCK) where name = @nombreLinkedServer)
					Set @NombreServer	=	@nombreLinkedServer

			Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].seguridad.Usuario  WITH ( NOLOCK) Where CodigoUsuario ='''+@CodigoUsuario +'''' 2.0 ET FIN*/

			Insert Into @Tb_Existe
			Select 1 From seguridad.Usuario  WITH ( NOLOCK) Where CodigoUsuario =@CodigoUsuario
			--2.0 ET Exec (@QueryExiste)

			If Exists(Select Existe From @Tb_Existe)
			Begin
				/* 2.0 ET INICIO 
				If @Fechacaducidadcuenta is not null
					Set @FechacaducidadcuentaChr =  ''''+Convert(Char(10), @Fechacaducidadcuenta,23)  +''''
 
				If @FechaAlta is not null
					Set @FechaAltaChr =  ''''+Convert(Char(10), @FechaAlta,23)  +''''

				If @FechaBaja is not null
					Set @FechaBajaChr =  ''''+Convert(Char(10), @FechaBaja,23)  +''''

				set @Query  = 'Update ['+@NombreServer+'].[BVN_seguridad].seguridad.Usuario
							set  Cip					= ' + case when cast(@Cip as varchar) IS NULL then +' null ' else ''''+@Cip+'''' end +' 
							' + ',Nombre				= ''' +	@Nombre + '''
							' +	',ApellidoPaterno		= ''' +	@ApellidoPaterno + '''
							' + ',ApellidoMaterno		= ''' +	@ApellidoMaterno + '''
							' +	',NumeroDocumento		= ''' +	@NumeroDocumento + '''
							' +	',TipoCorporativo		= ''' +	@TipoCorporativo + '''
							' +	',Estado				= ''' +	@Estado + '''
							' +	',LoginActivo				= ' + convert(char(2),@LoginActivo)+'
							' +	',Fechacaducidadcuenta	= ' + @FechacaducidadcuentaChr + '
							' + ',FechaAlta				= ' + @FechaAltaChr + '
							' + ',FechaBaja				= ' + @FechaBajaChr + '
							' +	',UsuarioSistema		= ''' +	@S_username + '''
							' +	',FechaSistema			= ''' +	@GetDate + '''
							' +' Where CodigoUsuario ='''+@CodigoUsuario +''''
						
				Execute sp_executeSql  @Query 2.0 ET FIN*/
			
				--print @Query
				Update seguridad.Usuario
							set  Cip					= case when cast(@Cip as varchar) IS NULL then null else @Cip end
							,Nombre				= @Nombre
							,ApellidoPaterno		= @ApellidoPaterno
							,ApellidoMaterno		= @ApellidoMaterno
							,NumeroDocumento		= @NumeroDocumento
							,TipoCorporativo		= @TipoCorporativo
							,Estado				= @Estado
							,LoginActivo				= @LoginActivo
							,Fechacaducidadcuenta	= @Fechacaducidadcuenta
							,FechaAlta				= @FechaAlta
							,FechaBaja				= @FechaBaja
							,UsuarioSistema		= @S_username
							,FechaSistema			= 	convert(datetime,@GetDate)
							Where CodigoUsuario =@CodigoUsuario

				----ver 1.1 hch
				--Creacion de UsuarioLogin 
				--2.0 ET EXECUTE [SEGURIDAD].[usp_UsuarioLogin_Insert] @CodigoUsuario,@CodigoLogin,@TipoLogin,@IdServidor,@Retorno_sql OUTPUT
				EXECUTE [SEGURIDAD].[usp_UsuarioLogin_Insert] @CodigoUsuario,@CodigoLogin,@TipoLogin,@Retorno_sql OUTPUT
				IF @Retorno_sql > 0 
				BEGIN
					--Actualizar Registro
					/*2.0 ET INICIO SET @SqlUpdate='Update  ['+@NombreServer+'].[BVN_seguridad].Seguridad.usuario 
									SET usuario.LoginActivo=' + convert(char(2),@Retorno_sql)+' 
									WHERE usuario.CodigoUsuario=''' + @CodigoUsuario + ''''
				
					--print @SqlUpdate
					EXECUTE sp_executesql  @SqlUpdate;2.0 ET FIN*/
					Update  Seguridad.usuario
									SET usuario.LoginActivo=@Retorno_sql
									WHERE usuario.CodigoUsuario= @CodigoUsuario
				END
					
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

	COMMIT;
	SET XACT_ABORT OFF;

	SET LANGUAGE ENGLISH;
END;
