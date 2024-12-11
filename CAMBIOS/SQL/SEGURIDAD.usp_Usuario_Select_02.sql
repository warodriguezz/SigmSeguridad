/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de usaurios segun tipo de listado

PARAMETROS 	
*  @TipoListado			:		Tipo de Listado
								
								1) Listado general de usuarios (usa vista)
								2) Opciones de usuario
								3) Listado para estado de bloqueo/desbloqueo
								4) Listado de estado de usuarios y login en BD
								5) Listado de usuario SYSADMIN
					
*  @Parametros			:       Parametros

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0				Walther Rodriguez		26/02/2019		Listado de usuarios
1.1				Walther Rodriguez		15/11/2019		Correcion para obtener propiedad del Login remoto en tipo 3
1.2				Walther Rodriguez		27/11/2019		Correcion para obtener acceso a la vista uv_Persona_Meta4
1.3				Hugo Chuquitaype		28/01/2020		Obtener la Ctd_Dias_SinAcceso a la Aplicación SIGM
1.4				Hugo Chuquitaype		01/04/2020		agregar columna LoginActivo, TipoLogin  y retirar tipoacceso
1.5				Walther Rodriguez		01/06/2020		Incluir resgistro de estado UsuarioLogin
1.6				Hugo Chuquitaype		20/01/2021		Correción correctamente la fecha de Ultimo Acceso y CodigoLogin
														No considerar Estado de UsuarioLogin
2.0				Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Select_02
	 @TipoListado                  TINYINT			
	,@Parametros					VARCHAR(300)	
AS
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
	Declare	 @QuerySetVariable		nvarchar(max)
	Declare	 @IdBaseDatos			Smallint
	Declare  @NombreBd				Varchar(100)
	Declare  @IdApliParametro		SMALLINT

		
	IF @TipoListado=1 
	Begin
		SELECT @CodigoUsuario				=  Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1)
		--2.0 ET SELECT @IdServidor					=  Convert(TinyInt, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2))
		
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET @idServidor 

		SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad'

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

		--Ini Ver 1.3	HCH
		--Ini Ver 1.4   hch
		--Ini Ver 1.5   WRZ
		--Ini ver 1.6   hch
		/*2.0 ET INICIO
		Set @QuerySelect  = 'SELECT 	u.CodigoUsuario,
										u.Cip,
										u.Nombre,
										u.ApellidoPaterno,
										u.ApellidoMaterno,
										u.NumeroDocumento,
										u.TipoCorporativo,
										u.Estado,
										u.LoginActivo,	
										Ul.CodigoLogin,		
										Ul.TipoLogin,								
										u.FechaCaducidadCuenta,
										u.FechaAlta,
										u.FechaBaja,
										u.UsuarioSistema,
										'+ Rtrim(Convert(Char(2),@IdServidor)) + ' as IdServidor, 
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
		2.0 ET FIN */
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
										u.LoginActivo,	
										Ul.CodigoLogin,		
										Ul.TipoLogin,								
										u.FechaCaducidadCuenta,
										u.FechaAlta,
										u.FechaBaja,
										u.UsuarioSistema,
										7  as IdServidor, 
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

	--Fin Ver 1.3	HCH
	--Fin Ver 1.4	HCH
	--Fin Ver 1.5   WRZ
	--Fin ver 1.6   hch
		--2.0 ETexecute sp_executeSql  @QuerySelect
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
			NombreCompleto,
			dsc_tipotrabajador,
			Area,
			Area_Sup,
			Cargo,
			email,
			Ctd_Dias_SinAcceso
		From @TablaFinal
	End

	IF @TipoListado=2 
	Begin
		 SELECT @CodigoUsuario				=  Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1)

		 SELECT   u.CodigoUsuario,
				  (Select TipoLogin from SEGURIDAD.ufn_UsuarioLogin (U.CodigoUsuario) ) as TipoLogin,   --ver 1.4 hch
				  SysAdmin = IsNull(( SELECT  SECURITYADMIN FROM MASTER.DBO.SYSLOGINS (NOLOCK) WHERE NAME COLLATE SQL_Latin1_General_CP1_CI_AS =   u.CodigoUsuario) , 0)
		 FROM Seguridad.Usuario u WITH ( NOLOCK)
		 Where u.CodigoUsuario=@CodigoUsuario
	End
		
	IF @TipoListado=3 --1.1	WRZ
		BEGIN

		    
			select  @IdServidor		=  7 --2.0 ET Convert(TinyInt, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1))
			 
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
				from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 
		


			If @NombreServer=@@SERVERNAME			--EJECUCION LOCAL, NO USAR NADA ACA 1.1	
			BEGIN
			
				SELECT U.CodigoUsuario
						,uL.CodigoLogin  --ver 1.4 hch
										,U.ApellidoPaterno +  space(1) +U.ApellidoMaterno + space(1) + U.Nombre  as usuario
										,U.fechacaducidadcuenta as Fecha_Cese
										,U.TipoCorporativo										
										,case when LOGINPROPERTY(Ul.CodigoLogin, 'IsLocked') = 1 then 'B' else 'A' end  as EstadoSQL --ver 1.4 hch
									    ,case when IsNull(SLG.NAME,'')='' then 'N' else 'S' End as Sql_Login
										 FROM [BVN_seguridad].Seguridad.Usuario U WITH ( NOLOCK) 
										 LEFT JOIN [BVN_seguridad].maestros.uv_Persona_Meta4 as VP  WITH (NOLOCK) --1.2	WRZ
											on  U.Cip = VP.cip
										LEFT JOIN  [BVN_seguridad].Seguridad.UsuarioLogin uL WITH (NOLOCK)  ---ver 1.4 hch
										On Ul.IdLogin= u.LoginActivo
										And Ul.CodigoUsuario= u.CodigoUsuario
										and Ul.Estado = 1
										 LEFT JOIN [BVN_seguridad].sys.server_principals SLG  WITH (NOLOCK)
											on SLG.name = uL.CodigoLogin 
											and SLG.type collate SQL_Latin1_General_CP1_CI_AS 
											=uL.TipoLogin      --ver 1.4 hch ---Obtner Tipo Login  S/U
										
					order by EstadoSQL DESC , U.CodigoUsuario ASC
	

			END




			If @NombreServer<>@@SERVERNAME			--EJECUCION REMOTA, DINAMICO ALLA 1.1	,   1.2	WRZ
				if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
				bEGIN
					Set @NombreServer	=	@nombreLinkedServer

					--Ini ver 1.4 hch  -- Obtner Tipo Login S/U
					Set @QuerySelect = 'EXEC ('' SELECT U.CodigoUsuario, uL.CodigoLogin
										,U.ApellidoPaterno +  space(1) +U.ApellidoMaterno + space(1) + U.Nombre  as usuario
										,U.fechacaducidadcuenta as Fecha_Cese
										,U.TipoCorporativo										
										,case when LOGINPROPERTY(Ul.CodigoLogin, ''''IsLocked'''') = 1 then ''''B'''' else ''''A'''' end  as EstadoSQL
									    ,case when IsNull(SLG.NAME,'''''''')='''''''' then ''''N'''' else ''''S'''' End as Sql_Login
										 FROM [BVN_seguridad].Seguridad.Usuario U WITH ( NOLOCK) 
										 LEFT JOIN [BVN_seguridad].maestros.uv_Persona_Meta4 as VP WITH (NOLOCK)
											on  U.Cip = VP.cip
										LEFT JOIN  [BVN_seguridad].Seguridad.UsuarioLogin uL WITH (NOLOCK)  
										On Ul.IdLogin= u.LoginActivo
										And Ul.CodigoUsuario= u.CodigoUsuario and ul.Estado=1
										 LEFT JOIN [BVN_seguridad].sys.server_principals SLG  WITH (NOLOCK)
											on SLG.name = uL.CodigoLogin 
											and SLG.type collate SQL_Latin1_General_CP1_CI_AS = ul.TipoLogin
								order by EstadoSQL DESC , U.CodigoUsuario ASC    '')
											AT [' + @NombreServer + ']'
					--Fin ver 1.4 hch
	
					execute sp_executeSql  @QuerySelect
				eND
	
	End 

	IF @TipoListado=4
		Begin
		    Select  @IdServidor		=  7 --2.0 ET Convert(TinyInt, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1))
			Select  @IdBaseDatos	=  Convert(Smallint, Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2))
			 
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
				from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 
		
			If @NombreServer<>@@SERVERNAME
				if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
					Set @NombreServer	=	@nombreLinkedServer
 

			/*2.0 ET INICIO Set @QuerySetVariable ='Select @NombreBd	= NombreBd
									From ['+@NombreServer+'].[BVN_seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
									where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
			execute sp_executeSql   @QuerySetVariable,  N'@NombreBd Varchar(100) OUTPUT ',  @NombreBd = @NombreBd OUTPUT  2.0 ET FIN */
			Select @NombreBd	= NombreBd
									From Maestros.BaseDatos  WITH ( NOLOCK)  
									where IdBaseDatos=	@IdBasedatos

			/*2.0 ET INICIO Set @QuerySelect  = ' SELECT  a.name as CodUser
											,a.Create_Date as FechaCreacion
											,Case when b.SecurityAdmin=1 or b.sysadmin=1 then ''S'' else ''N'' End as UserSeg
											,b.accdate as FechaUltAcceso
											,Case 
												When (a.name = b.name and a.sid <> b.sid and B.sid is not Null) then ''No relacionado''
												When (a.name = b.name and a.sid = b.sid and B.sid is not Null) then ''Con Login''
												Else ''Sin Login''
												END as Estado
									FROM ['+@NombreServer+'].['+@NombreBd+'].sys.database_principals a WITH (NOLOCK)
									Left Join ['+@NombreServer+'].Master.[sys].[syslogins] b WITH (NOLOCK)
										on a.sid = b.sid or a.name = b.name
									Where a.type = ''S''
										AND a.principal_id > 5 
										AND a.authentication_type=1
										AND NOT (a.name = b.name and a.sid = b.sid and B.sid is not Null)  
									Order by Estado, CodUser'

			execute sp_executeSql  @QuerySelect 2.0 ET FIN*/
			SELECT  a.name as CodUser
					,a.Create_Date as FechaCreacion
					,Case when b.SecurityAdmin=1 or b.sysadmin=1 then 'S' else 'N' End as UserSeg
					,b.accdate as FechaUltAcceso
					,Case 
						When (a.name = b.name and a.sid <> b.sid and B.sid is not Null) then 'No relacionado'
						When (a.name = b.name and a.sid = b.sid and B.sid is not Null) then 'Con Login'
						Else 'Sin Login'
						END as Estado
			FROM sys.database_principals a WITH (NOLOCK)
			Left Join Master.[sys].[syslogins] b WITH (NOLOCK)
				on a.sid = b.sid or a.name = b.name
			Where a.type = 'S'
				AND a.principal_id > 5 
				AND a.authentication_type=1
				AND NOT (a.name = b.name and a.sid = b.sid and B.sid is not Null)  
			Order by Estado, CodUser
	End 



	if @TipoListado=5
	Begin

		SELECT
			 USU.CodigoUsuario as cod_usuario
		FROM 
			Seguridad.Usuario AS USU WITH (NOLOCK)
			INNER JOIN sys.syslogins AS SLG WITH (NOLOCK) 
				ON USU.CodigoUsuario =SLG.loginname
		WHERE
			SLG.securityadmin = 1
			AND USU.Estado   = 'A'  
		ORDER BY 
			USU.CodigoUsuario ASC
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

END;
