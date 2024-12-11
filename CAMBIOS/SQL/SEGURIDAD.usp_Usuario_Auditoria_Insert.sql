/******************************************************************************************
DATOS GENERALES    
* Descripcion          :    Insertar un registro Auditoria

PARAMETROS     
*     @UsuarioRegsitro		: Úsuario Sysadmin o security admin que ejecutó la acción
*     @IdServidor               : Id del servidor sobre el que se realizó la acción
*     @codigousuario			: Usuario afectado por la acción
*     @Accion                   : D: Desbloqueo, R: Reseteo de contraseña
*     @IpRegistro				: Registro de IP de PC
*     @HostNameRegistro			: Registro de HostName de PC
*	  @NombreAplicacion			: Nombre de Aplicación	

    
CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Hugo Chuquitaype        06/12/2019      Versión Inicial
1.1				Walther Rodriguez		04/09/2020		No utilizar dinamico para servidor local
1.2				Walther Rodriguez		04/11/2020		Identificar servidor local 0 (desde sigm)
1.3				Hugo Chuquitaype        01/09/2021      Registro NombreBaseDatos, NombreAplicacion, SPID
1.4				Walther Rodriguez		26/07/2022		Obtener IP cliente si viene en blanco
2.0				Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Auditoria_Insert
(@UsuarioRegsitro varchar(20)
--2.0 ET ,@IdServidor Int
,@codigousuario varchar(20)
,@Accion char(1)
,@IpRegistro varchar(20)
,@HostNameRegistro varchar(20)
,@NombreAplicacion varchar(100)) as
BEGIN
     SET NOCOUNT ON;
     SET LANGUAGE SPANISH;
     SET DATEFORMAT MDY;
	
	 Declare  @nombreLinkedServer	varchar(20)
	 Declare  @nombreServidor		varchar(20)
	 Declare  @queyInsert			nvarchar(max)
	 Declare  @IndiLocal			TinyInt
	 Declare  @Spid					Int
	 Declare  @BaseDatos			varchar(100)
	 Declare @IdServidor Int --2.0 ET
     BEGIN TRY

		SELECT @IndiLocal		= 0

		Select @IdServidor=7 --2.0 ET
		IF @IdServidor=0	--1.2	WRZ Viene del SIGM
		begin
			Set @nombreServidor= @@SERVERNAME
			Select @IdServidor = idservidor From [BVN_Seguridad].seguridad.Servidor WITH(NOLOCK) where NombreServidor=@nombreServidor;
			Set @IndiLocal	=1
		End
		Else
		begin
			select @nombreLinkedServer = NombreLinkedServer ,@nombreServidor = NombreServidor   
			from [BVN_Seguridad].Seguridad.Servidor WITH ( NOLOCK)  where idservidor = @idServidor

			if @nombreServidor=@@SERVERNAME	-- WRZ 1.1
				Set @IndiLocal=1
		end

		Select @spid = @@SPID
		SELECT @BaseDatos  = DB_NAME()

		If Len(rtrim(Ltrim(@IpRegistro)))<1		-- WRZ 1.4		
			SELECT @IpRegistro=CONVERT(char(15), CONNECTIONPROPERTY('client_net_address'))

		If Len(rtrim(Ltrim(@IpRegistro)))<1	
			SELECT @IpRegistro = client_net_address FROM sys.dm_exec_connections WHERE Session_id = @spid;

		if @IndiLocal =0 and len(@nombreLinkedServer) > 1 and exists(select 1 from sys.servers WITH (NOLOCK)   where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer	
	
			if @IndiLocal =1	-- WRZ 1.1
					INSERT INTO [BVN_Seguridad].Seguridad.UsuarioAuditoria 
										( 
											  IdServidor
											, CodigoUsuario
											, Accion
											, UsuarioRegistro
											, IpRegistro
											, HostNameRegistro
											, FechaHoraRegistro
											, Spid
											, BaseDatos
											, NombreAplicacion					
											 )
									VALUES	(  
											convert(varchar(2),@IdServidor)
											,@codigousuario
											,@Accion
											,@UsuarioRegsitro
											,@IpRegistro
											,@HostNameRegistro
											,GETDATE()
											,@Spid	
											,@BaseDatos
											,@NombreAplicacion)							--ver 1.3 hch
		Else
		Begin
			Set @queyInsert = 'EXEC (''INSERT INTO [BVN_Seguridad].Seguridad.UsuarioAuditoria 
										( 
											  IdServidor
											, CodigoUsuario
											, Accion
											, UsuarioRegistro
											, IpRegistro
											, HostNameRegistro
											, FechaHoraRegistro
											, Spid
											, BaseDatos
											, NombreAplicacion
											 )
									VALUES	(  
											'+convert(varchar(2),@IdServidor)+'
											,'''''+@codigousuario+'''''
											,'''''+@Accion+'''''
											,'''''+@UsuarioRegsitro+'''''
											,'''''+@IpRegistro+'''''
											,'''''+@HostNameRegistro+'''''
											, getdate()
											,'''''+@Spid+'''''
											,'''''+@BaseDatos+'''''
											,'''''+@NombreAplicacion+'''''     );'') AT [' + @nombreLinkedServer + ']'		--ver 1.3 hch


			execute sp_executeSql   @queyInsert
		End
			      
     END TRY

     BEGIN CATCH
          DECLARE     @ErrorSeverity  TINYINT
                    , @ErrorState   TINYINT
                    , @ErrorNumber  INTEGER
                    , @MensajeError VARCHAR(4096) 

          SELECT
               @MensajeError = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER();
      
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );

     END CATCH

     SET LANGUAGE ENGLISH;
END
