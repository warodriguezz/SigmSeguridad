/***************************************************************************************** 
DATOS GENERALES	
* Descripción: Cambia las claves de los usuarios se ejecuta mensualmente
PARAMETROS 	
*Ninguno

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    walther Rodriguez	    03/11/2020		Versión Inicial
1.1				walther Rodriguez	    04/02/2021		Utilizar sp de regeneracion de claves	
1.2				walther Rodriguez	    10/02/2021		RRecorrer todos los servidores
1.3				walther Rodriguez	    01/03/2021		Corregir IDSERVIDOR
1.4				walther Rodriguez	    31/03/2021		Corregir Secuencia ID en @TabUsuario
1.5				Edwin Tenorio			12/06/2024		Se quita @NombreServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Actualiza_Claves_Job
as
BEGIN

	SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;	
    
	Declare	@rowCount		Int
	Declare @Fila			Int
	Declare @Mes			Smallint
	Declare @SqlAlter		nVarchar(max)
	Declare @QueryInsert	nVarchar(max)
	Declare	@count			Int
	Declare	@id				Int
	Declare @CodigoLogin	Varchar(20)
	Declare @CodigoUsuario	Varchar(20)
	Declare	@Clave			Varchar(50)
	Declare @S_username		Varchar(20)
	Declare @IdServidor		Smallint
	Declare @Accion			Varchar(1)
	--1.5 ET Declare @NombreServer	Varchar(20)
	--1.5 ET Declare @NombreServidor	Varchar(20)
	--1.5 ET Declare @NombreLinkedServer	Varchar(20)
	Declare	@Ip				Varchar(16)
	DECLARE @user_spid		Integer
	DECLARE @Retorno	    Integer
	Declare	@TabUsuario		Table(id				Int			--WRZ 1.4 
								  ,CodigoUsuario	Varchar(20)
								  ,CodigoLogin		Varchar(20))
	Declare @TablaServidores Table(id Int Identity(1,1) 
							,IdServidor			SmallInt
							,NombreServidor		Varchar(50)
							,NombreLinkedServer	Varchar(50)	)

	
	Select	@Mes		=	Month(GetDate())


	--1.2	WRZ INI							
	Insert Into @TablaServidores						
	Select IdServidor, NombreServidor, NombreLinkedServer
	FROM   Seguridad.Servidor WITH ( NOLOCK) 
	where  (Nombreservidor =@@SERVERNAME or (NombreLinkedServer IS  NOT NULL  AND  NombreLinkedServer <> '') )
	and RegistroActivo=1 and Estado=1

	Set @rowCount = (Select Count(1) From @TablaServidores)
	Set @Fila=1

	WHILE (@rowCount>0) and (@Fila <=@rowCount)
	BEGIN
		--1.5 ET INICIO
		--Select @NombreServidor = NombreServidor , @NombreLinkedServer= NombreLinkedServer,@IdServidor=IdServidor 
		--From @TablaServidores Where id = @Fila;

		--IF @NombreServidor =  @@SERVERNAME
		--	set @NombreServer = @NombreServidor
		-- ELSE
		--BEGIN
		--	if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
		--		set @NombreServer = @NombreLinkedServer
		--END
		--1.5 ET FIN

		--Obtener Listado de usuarios con login 
		Delete From @TabUsuario;
		 
		 --WRZ 1.4
		 --1.5 ET INICIO 
		--Set @QueryInsert='Select ROW_NUMBER() OVER (ORDER BY us.CodigoUsuario) id,  us.CodigoUsuario, ul.CodigoLogin from ' + QUOTENAME(@NombreServer)  +'.[BVN_Seguridad].Seguridad.UsuarioLogin ul WITH ( NOLOCK)
		--				Inner join ' + QUOTENAME(@NombreServer)  + '.[BVN_Seguridad].Seguridad.Usuario us WITH ( NOLOCK) on us.CodigoUsuario = ul.CodigoUsuario and us.LoginActivo = ul.IdLogin
		--				Inner join ' + QUOTENAME(@NombreServer)  + '.[BVN_Seguridad].sys.server_principals SLG  WITH (NOLOCK) on SLG.name = uL.CodigoLogin 
		--				Inner join ' + QUOTENAME(@NombreServer)  + '.[BVN_Seguridad].sys.syslogins AS SL WITH (NOLOCK) ON  SL.loginname = ul.codigologin  
		--				Where ul.TipoLogin=''U'' and us.Estado=''A''
		--				order by 2'
		--1.5 ET FIN 

		Insert Into @TabUsuario
		--1.5 ET INICIO
		Select ROW_NUMBER() OVER (ORDER BY us.CodigoUsuario) id,  us.CodigoUsuario, ul.CodigoLogin from Seguridad.UsuarioLogin ul WITH ( NOLOCK)
						Inner join Seguridad.Usuario us WITH ( NOLOCK) on us.CodigoUsuario = ul.CodigoUsuario and us.LoginActivo = ul.IdLogin
						Inner join sys.server_principals SLG  WITH (NOLOCK) on SLG.name = uL.CodigoLogin 
						Inner join sys.syslogins AS SL WITH (NOLOCK) ON  SL.loginname = ul.codigologin  
						Where ul.TipoLogin='U' and us.Estado='A'
						order by 2
		--1.5 ET FIN
		--1.5 ET Execute(@QueryInsert);

		--PROCESO
		SELECT @count=COUNT(1) from @TabUsuario
		IF @count>0
		BEGIN
				Set @id = 1
				WHILE(@count>0 AND @id<=@count)
				BEGIN
					
						SELECT @CodigoLogin=CodigoLogin  
							  ,@CodigoUsuario=CodigoUsuario
						from @TabUsuario WHERE Id=@id

						----Eliminar SESION
						DECLARE CurSPID CURSOR FAST_FORWARD
						FOR
						SELECT  des.session_id
						FROM    sys.dm_exec_sessions des WITH ( NOLOCK) 
						LEFT JOIN sys.databases d WITH ( NOLOCK) ON des.database_id = d.database_id
						WHERE   des.session_id <>@@spid 
						and d.name in ('BDOPERACIONES','bvn_seguridad','SIGM') 
						and des.login_name = @CodigoLogin;
					
						OPEN CurSPID
						FETCH NEXT FROM CurSPID INTO @user_spid
							WHILE (@@FETCH_STATUS=0)
							BEGIN
								EXEC('KILL '+@user_spid)
							FETCH NEXT FROM CurSPID INTO @user_spid
							END
						CLOSE CurSPID
						DEALLOCATE CurSPID

						--2.0 ET EXECUTE SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario , @IdServidor, @Retorno Output  -- WRZ 1.3
						EXECUTE SEGURIDAD.usp_Usuario_RegenerarClave @CodigoUsuario, @Retorno Output

						Set @S_username		= SUSER_SNAME()
						Set @Accion			= 'J'
						--1.5 ET Select @NombreServer = Convert(Varchar(20),SERVERPROPERTY('MachineName'))
						Select @Ip			= client_net_address FROM sys.dm_exec_connections WITH ( NOLOCK) WHERE session_id = @@SPID; 

						--1.5 ET INICIO
						--Set @QueryInsert = 'INSERT INTO ['+@NombreServer+'].[BVN_Seguridad].SEGURIDAD.UsuarioAuditoria(IdServidor,CodigoUsuario,Accion,IpRegistro,HostNameRegistro,UsuarioRegistro,FechaHoraRegistro)
						--					VALUES ('+Convert(char(2),@IdServidor)+','''+@CodigoUsuario+''','''+@Accion+''','''+@Ip+''','''+@NombreServer+''','''+@S_username+''',getdate())'

						--Registrar audiroria
						--Execute sp_executesql @QueryInsert
						--1.5 ET FIN

						INSERT INTO UsuarioAuditoria(IdServidor,CodigoUsuario,Accion,IpRegistro,HostNameRegistro,UsuarioRegistro,FechaHoraRegistro)
											VALUES (@IdServidor,@CodigoUsuario,@Accion,@Ip,@@SERVERNAME,@S_username,getdate())

						Set @id=@id + 1
	
				END
		END

		Set @Fila=@Fila + 1
	END
	--1.2	WRZ FIN		

	SET LANGUAGE ENGLISH;
END;