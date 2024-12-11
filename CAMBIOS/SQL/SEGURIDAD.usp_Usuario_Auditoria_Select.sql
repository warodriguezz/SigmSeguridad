/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de registros bloqueados y desbloqueados para reporte

PARAMETROS 	
*   	@Parametros    : parametros (Id Servidor, fecha Inicio, Fecha Fin)
	

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		06/12/2019	   Versión Inicial
1.1			Hugo Chuquitaype		06/06/2020	    Usuario Login
1.2			Walther Rodriguez		30/10/2020		Incluir acciones de cmabio de login activo
1.3			Hugo Chuquitaype		22/01/2021	    Incluir acciones Inicio Sesion Tipo A: Usuario Dominio S: SQL
1.4			Hugo Chuquitaype		02/02/2021		Reseteo de contraseña por Asignación de Login (S) / Generación de contraseña por Asignación de Login (U)
1.5			Walther Rodriguez		11/02/2020		Mejora por versiones de servidor
1.6			Walther Rodriguez		15/08/2022		Convert Int PB2021
1.7			Walther Rodriguez		14/09/2023		No incluir registros de bd TransPortePErsonal
2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_Usuario_Auditoria_Select
(@Parametros VARCHAR(200)) as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
    
	Declare  @nombreLinkedServer	Varchar(50)
	Declare  @nombreServidor		Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 
	Declare  @idServidor			TINYINT   
	Declare  @Desde					VARCHAR(8)
	Declare  @Hasta					VARCHAR(8)

	BEGIN TRY 

	SET NOCOUNT ON;

	SELECT @idServidor						= 7 --2.0 ET CONVERT(TINYINT  ,Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1))
	SELECT @Desde							= Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2)
	SELECT @Hasta							= Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,3)

	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') , @nombreServidor	= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 
	
		If @nombreServidor<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @nombreServidor	=	@nombreLinkedServer
				--ver 1.1. hch , 1.2 WRZ, 1.3 hch, 1.4 hch , 1.5 wrz	
				-- 1.6 wrz	Convert(Int, ua.IdServidor)
				-- 1.7	wrz ' AND BaseDatos <> ''BDTransportePersonal'' '  +
			/*2.0 ET INICIO
			Set @QuerySelect  = ' SELECT ua.IdUsuarioAuditoria,	
										Convert(Int, ua.IdServidor) as IdServidor,    
										ua.CodigoUsuario , 	
										COALESCE(
											CASE ua.Accion 
												WHEN ''D'' THEN ''Desbloqueo de usuario''
												WHEN ''B'' THEN ''[Job] Baja de usuario''
												WHEN ''R'' THEN ''Reseteo de contraseña''
												WHEN ''J'' THEN ''[Job] Generacion de contraseña''
												WHEN ''E'' THEN ''[Login] Asignación de Login (S)''
												WHEN ''G'' THEN ''[Login] Asignación de Login (U)''  
												WHEN ''W'' THEN ''[Opserv] Asignación de Login (S)''
												WHEN ''Z'' THEN ''[Opserv] Asignación de Login (U)''
												WHEN ''U'' THEN ''[U] Inicio de sesión'' 
											END,
											CASE ua.Accion
												WHEN ''S'' THEN ''[S] Inicio de sesión''
												WHEN ''I'' THEN ''Inicio de sesión''
												ELSE ''[Sin Información]'' 
											END) As ''Accion'',
										ua.IpRegistro , 
										ua.HostNameRegistro , 
										ua.UsuarioRegistro ,   		 
										ua.FechaHoraRegistro , 
										uL.CodigoLogin
									FROM ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioAuditoria ua WITH ( NOLOCK)
									INNER JOIN ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.Usuario u WITH ( NOLOCK) 
										on (U.CodigoUsuario= UA.CodigoUsuario)
									INNER JOIN ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioLogin uL WITH ( NOLOCK) 
										on (U.CodigoUsuario= UL.CodigoUsuario 
										AND UL.IdLogin  = u.LoginActivo) 
										WHERE idServidor= ' + CONVERT(VARCHAR(10), @idServidor) +
								    ' AND CONVERT(VARCHAR(8),FechaHoraRegistro,112 ) > = ' + CONVERT(VARCHAR(8),@Desde) +
									' AND CONVERT(VARCHAR(8),FechaHoraRegistro,112 ) < = ' + CONVERT(VARCHAR(8),@Hasta) +
									' AND BaseDatos <> ''BDTransportePersonal'' '  +
									' ORDER BY IdUsuarioAuditoria DESC '
				--ver 1.1. hch, 1.2 WRZ, 1.3 hch, 1.4 hch	, 1.5 wrz

			print @QuerySelect
			execute sp_executeSql  @QuerySelect	
			2.0 ET FIN*/

			Declare @TablaFinal Table
			(
			IdUsuarioAuditoria int
			,IdServidor int
			,CodigoUsuario varchar(20)
			,Accion varchar(100)
			,IpRegistro varchar(20)
			,HostNameRegistro varchar(20)
			,UsuarioRegistro varchar(20)
			,FechaHoraRegistro datetime
			,CodigoLogin varchar(50)
			)

			Insert Into @TablaFinal
			(
			IdUsuarioAuditoria
			,IdServidor
			,CodigoUsuario
			,Accion
			,IpRegistro
			,HostNameRegistro
			,UsuarioRegistro
			,FechaHoraRegistro
			,CodigoLogin
			)
			SELECT ua.IdUsuarioAuditoria,	
										Convert(Int, ua.IdServidor) as IdServidor,    
										ua.CodigoUsuario , 	
										COALESCE(
											CASE ua.Accion 
												WHEN 'D' THEN 'Desbloqueo de usuario'
												WHEN 'B' THEN '[Job] Baja de usuario'
												WHEN 'R' THEN 'Reseteo de contraseña'
												WHEN 'J' THEN '[Job] Generacion de contraseña'
												WHEN 'E' THEN '[Login] Asignación de Login (S)'
												WHEN 'G' THEN '[Login] Asignación de Login (U)'
												WHEN 'W' THEN '[Opserv] Asignación de Login (S)'
												WHEN 'Z' THEN '[Opserv] Asignación de Login (U)'
												WHEN 'U' THEN '[U] Inicio de sesión'
											END,
											CASE ua.Accion
												WHEN 'S' THEN '[S] Inicio de sesión'
												WHEN 'I' THEN 'Inicio de sesión'
												ELSE '[Sin Información]' 
											END) As 'Accion',
										ua.IpRegistro , 
										ua.HostNameRegistro , 
										ua.UsuarioRegistro ,   		 
										ua.FechaHoraRegistro , 
										uL.CodigoLogin
									FROM Seguridad.UsuarioAuditoria ua WITH ( NOLOCK)
									INNER JOIN Seguridad.Usuario u WITH ( NOLOCK) 
										on (U.CodigoUsuario= UA.CodigoUsuario)
									INNER JOIN Seguridad.UsuarioLogin uL WITH ( NOLOCK) 
										on (U.CodigoUsuario= UL.CodigoUsuario 
										AND UL.IdLogin  = u.LoginActivo) 
										WHERE idServidor= @idServidor
								     AND CONVERT(VARCHAR(8),FechaHoraRegistro,112 ) > =  CONVERT(VARCHAR(8),@Desde)
									 AND CONVERT(VARCHAR(8),FechaHoraRegistro,112 ) < = CONVERT(VARCHAR(8),@Hasta)
									 AND BaseDatos <> 'BDTransportePersonal'
									 ORDER BY IdUsuarioAuditoria DESC

			Select
			IdUsuarioAuditoria
			,IdServidor
			,CodigoUsuario
			,Accion
			,IpRegistro
			,HostNameRegistro
			,UsuarioRegistro
			,FechaHoraRegistro
			,CodigoLogin
			From @TablaFinal

	END TRY

	BEGIN CATCH

	DECLARE   @ErrorSeverity			TINYINT
    DECLARE   @ErrorState				TINYINT
	DECLARE   @ErrorNumber				INTEGER
	DECLARE   @MensajeError				VARCHAR(4096) 

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
END
