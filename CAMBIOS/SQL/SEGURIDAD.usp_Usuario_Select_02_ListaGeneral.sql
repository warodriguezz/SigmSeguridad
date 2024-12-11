/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de usaurios segun tipo de listado

PARAMETROS 	
			
*  @Parametros			:       Parametros

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0				Walther Rodriguez		19/09/2022		Version Inicial (tipo 1)
2.0				Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/
ALTER procedure SEGURIDAD.usp_Usuario_Select_02_ListaGeneral (@Parametros VARCHAR(300)) as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY 

	Declare  @CodigoUsuario			Varchar(20)
	--2.0 ET Declare  @IdServidor			TinyInt
	Declare  @nombreServer			Varchar(50)
	Declare  @nombreLinkedServer	Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 

	SELECT @CodigoUsuario				=  Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1)
	/*2.0 ET INICIO
	SELECT @IdServidor					=  Convert(TinyInt, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2))
		
	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
			@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET @idServidor 

	--SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad'

	If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer
		2.0 ET FIN*/

	Declare @TablaFinal Table
		(
			CodigoUsuario varchar(20),
			Cip varchar(12),
			Nombre varchar(30),
			ApellidoPaterno varchar(30),
			ApellidoMaterno varchar(30),
			NumeroDocumento varchar(15),
			TipoCorporativo char(1),
			Estado char(1),
			LoginActivo int,	
			CodigoLogin varchar(50),		
			TipoLogin char(1),								
			FechaCaducidadCuenta date,
			FechaAlta date,
			FechaBaja date,
			UsuarioSistema varchar(20),
			IdServidor int,
			FechaAltaUsuario datetime,
			FechaBajaUsuario datetime,
			NombreCompleto nvarchar(304),
			dsc_tipotrabajador nvarchar(508),
			Area nvarchar(508),
			Area_Sup varchar(3),
			Cargo nvarchar(508),
			email nvarchar(508),
			Ctd_Dias_SinAcceso datetime
		)

		Insert Into @TablaFinal
		(
			CodigoUsuario,
			Cip,
			Nombre,
			ApellidoPaterno,
			ApellidoMaterno,
			NumeroDocumento,
			TipoCorporativo,
			Estado,
			LoginActivo,	
			CodigoLogin,		
			TipoLogin,								
			FechaCaducidadCuenta,
			FechaAlta,
			FechaBaja,
			UsuarioSistema,
			IdServidor,
			FechaAltaUsuario,
			FechaBajaUsuario,
			NombreCompleto,
			dsc_tipotrabajador,
			Area,
			Area_Sup,
			Cargo,
			email,
			Ctd_Dias_SinAcceso
		)
		SELECT 	u.CodigoUsuario,
									u.Cip,
									u.Nombre,
									u.ApellidoPaterno,
									u.ApellidoMaterno,
									u.NumeroDocumento,
									u.TipoCorporativo,
									u.Estado,
									Convert(int,u.LoginActivo) as LoginActivo,	
									Ul.CodigoLogin,		
									Ul.TipoLogin,								
									u.FechaCaducidadCuenta,
									u.FechaAlta,
									u.FechaBaja,
									u.UsuarioSistema,
									7 as IdServidor, 
									u.FechaAltaUsuario,
									u.FechaBajaUsuario,
									vp.NombreCompleto,
									vp.dsc_tipotrabajador,
									vp.Area,
									vp.Area_Sup,
									vp.Cargo,
									vp.email,
									ISNULL(ABS(DATEDIFF(day, GETDATE( ), TabUltimo.FechaUltimoAcceso )),0) as Ctd_Dias_SinAcceso
									FROM Seguridad.Usuario u WITH ( NOLOCK)
								LEFT Join Maestros.uv_Persona_Meta4 vp WITH (NOLOCK)
										on vp.cip	=	u.Cip
									LEFT JOIN  Seguridad.UsuarioLogin uL WITH (NOLOCK)
											On uL.IdLogin=  U.LoginActivo
											and uL.CodigoUsuario = U.CodigoUsuario
								LEFT JOIN  (	select ulf.CodigoUsuario
														,ulf.CodigoLogin
														,Max(ulf.FechaUltimoAcceso) as FechaUltimoAcceso
													from Seguridad.UsuarioLogin ulf WITH (NOLOCK)
														where ulf.FechaUltimoAcceso is not null
														group by ulf.CodigoUsuario,ulf.CodigoLogin) as TabUltimo 
										on TabUltimo.CodigoUsuario	=	u.CodigoUsuario
								WHERE Ul.codigousuario=@CodigoUsuario

	Select
			CodigoUsuario,
			Cip,
			Nombre,
			ApellidoPaterno,
			ApellidoMaterno,
			NumeroDocumento,
			TipoCorporativo,
			Estado,
			LoginActivo,	
			CodigoLogin,		
			TipoLogin,								
			FechaCaducidadCuenta,
			FechaAlta,
			FechaBaja,
			UsuarioSistema,
			IdServidor,
			FechaAltaUsuario,
			FechaBajaUsuario,
			NombreCompleto,
			dsc_tipotrabajador,
			Area,
			Area_Sup,
			Cargo,
			email,
			Ctd_Dias_SinAcceso From @TablaFinal
	/*2.0 ET INICIO
	Set @QuerySelect  = 'SELECT 	u.CodigoUsuario,
									u.Cip,
									u.Nombre,
									u.ApellidoPaterno,
									u.ApellidoMaterno,
									u.NumeroDocumento,
									u.TipoCorporativo,
									u.Estado,
									Convert(int,u.LoginActivo) as LoginActivo,	
									Ul.CodigoLogin,		
									Ul.TipoLogin,								
									u.FechaCaducidadCuenta,
									u.FechaAlta,
									u.FechaBaja,
									u.UsuarioSistema,
									'+ Rtrim(Convert(Char(2),@IdServidor)) + ' as IdServidor, 
									u.FechaAltaUsuario,
									u.FechaBajaUsuario,
									vp.NombreCompleto,
									vp.dsc_tipotrabajador,
									vp.Area,
									vp.Area_Sup,
									vp.Cargo,
									vp.email,
									ISNULL(ABS(DATEDIFF(day, GETDATE( ), TabUltimo.FechaUltimoAcceso )),0) as Ctd_Dias_SinAcceso
									FROM ['+@NombreServer+'].[BVN_seguridad].Seguridad.Usuario u WITH ( NOLOCK)
								LEFT Join ['+@NombreServer+'].[BVN_seguridad].Maestros.uv_Persona_Meta4 vp WITH (NOLOCK)
										on vp.cip	=	u.Cip
									LEFT JOIN  ['+@NombreServer+'].[BVN_seguridad].Seguridad.UsuarioLogin uL WITH (NOLOCK)
											On uL.IdLogin=  U.LoginActivo
											and uL.CodigoUsuario = U.CodigoUsuario
								LEFT JOIN  (	select ulf.CodigoUsuario
														,ulf.CodigoLogin
														,Max(ulf.FechaUltimoAcceso) as FechaUltimoAcceso
													from ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioLogin ulf WITH (NOLOCK)
														where ulf.FechaUltimoAcceso is not null
														group by ulf.CodigoUsuario,ulf.CodigoLogin) as TabUltimo 
										on TabUltimo.CodigoUsuario	=	u.CodigoUsuario
								WHERE Ul.codigousuario='''+@CodigoUsuario +''''



		execute sp_executeSql  @QuerySelect
		2.0 ET FIN*/	
        
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
