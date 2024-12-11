/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de usaurioLogin

PARAMETROS 	
*  @TipoListado			:		Tipo de usaurioLogin
								
								1) Listado general de usaurioLogin 

					
*  @Parametros			:       Parametros

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0				Hugo Chuquitaype		02/04/2020		Listado de usuarioLogin
1.1				Walther Rodriguez		01/06/2020		Incluir Estado en Select
1.2				Walther Rodriguez		15/08/2022		Conversion Int PB2021
2.0				Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_UsuarioLogin_Select_02
(@TipoListado TINYINT
,@Parametros VARCHAR(300)) as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY 

	Declare  @CodigoUsuario			Varchar(20)
	Declare  @IdServidor			TinyInt
	Declare  @nombreServer			Varchar(50)
	Declare  @nombreLinkedServer	Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 
	Declare	 @RetTabla				Char(1)

	IF @TipoListado=1 
	Begin
		SELECT @CodigoUsuario				=  Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1)
		/*2.0 ET INICIO SELECT @IdServidor					=   Convert(TinyInt, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2))
		
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer
				2.0 ET FIN */
		--ver 1.1 wrz
		--ver 1.2 wrz Convert(Int, uL.IdLogin) as IdLogin,


		Execute Seguridad.usp_TablasTemporales 1,'tbllogin',1,@RetTabla OUTPUT		--Crear tabla


		/*2.0 ET INICIO
		Set @QuerySelect  = 'SELECT 	uL.IdLogin,
										uL.CodigoUsuario,
										uL.CodigoLogin,
										uL.TipoLogin,
										Case when SLG.is_disabled = 0 then  ''Si'' else ''No'' End as LoginActivo,
										Case when u.LoginActivo = uL.IdLogin then 1 else 0 End as LoginSel,
										uL.Estado
								FROM ['+@NombreServer+'].[BVN_seguridad].Seguridad.UsuarioLogin uL WITH ( NOLOCK)
								INNER JOIN ['+@NombreServer+'].[BVN_seguridad].Seguridad.Usuario u
										on u.CodigoUsuario	=	ul.CodigoUsuario
								LEFT JOIN ['+@NombreServer+'].[BVN_seguridad].sys.server_principals SLG  WITH (NOLOCK)
											on SLG.name = uL.CodigoLogin 
								WHERE uL.CodigoUsuario='''+@CodigoUsuario +''''
					2.0 ET FIN */			
		Insert Into ##tbllogin(
				IdLogin,
				CodigoUsuario,
				CodigoLogin,
				TipoLogin,
				LoginActivo,
				LoginSel,
				Estado
				)
			SELECT 	uL.IdLogin,
										uL.CodigoUsuario,
										uL.CodigoLogin,
										uL.TipoLogin,
										Case when SLG.is_disabled = 0 then  'Si' else 'No' End as LoginActivo,
										Case when u.LoginActivo = uL.IdLogin then 1 else 0 End as LoginSel,
										uL.Estado
								FROM Seguridad.UsuarioLogin uL WITH ( NOLOCK)
								INNER JOIN Seguridad.Usuario u
										on u.CodigoUsuario	=	ul.CodigoUsuario
								LEFT JOIN sys.server_principals SLG  WITH (NOLOCK)
											on SLG.name = uL.CodigoLogin 
								WHERE uL.CodigoUsuario=@CodigoUsuario
		--2.0 ET Execute sp_executeSql  @QuerySelect
		
		Select  IdLogin,
				CodigoUsuario,
				CodigoLogin,
				TipoLogin,
				LoginActivo,
				LoginSel,
				Estado
		From ##tbllogin

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

END
