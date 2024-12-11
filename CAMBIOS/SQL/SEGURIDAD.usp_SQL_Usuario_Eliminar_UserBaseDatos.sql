/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Elimina User por cada Base de Datos y Login  
PARAMETROS 	
* @IdServidor		       :	Id del servidor
* @CodigoUsuario           :	Código de usuario 
* @Desahabilitar			: Identifica accion para deshabilitar



CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		25/01/2021	   Versión Inicial
1.1			Pedro Torres			06/12/2023	   Se agrega drop schema
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Eliminar_UserBaseDatos
(--2.0 ET @IdServidor TinyInt
@CodigoUsuario varchar(20)
,@Desahabilitar TinyInt) as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	
	Declare  @nombreLinkedServer	varchar(20)
	Declare  @nombreServidor		varchar(20)
	Declare  @QueryUsuarioBd		nvarchar(max)
	Declare  @SqlDrop				nvarchar(max)
	Declare  @NombreBD				varchar(20)
	Declare	 @Tb_Existe				Table (Existe TinyInt)
	Declare	 @QueryExiste			nvarchar(max)
	DECLARE	 @Tb_ExisteSch				TABLE (Existe TINYINT) --PTZ 1.1

	Declare @UsuarioBaseDatos TABLE
			(    Idtabla int identity (1,1)
				,NombreBD varchar(60)	
				,CodigoUsuario	 varchar(20))  

	BEGIN TRY	 

	Select @nombreLinkedServer		= isnull(NombreLinkedServer,'') ,
					@nombreServidor	= nombreServidor
	From seguridad.Servidor WITH (NOLOCK) Where idservidor =7 --2.0 ET 	

	/*2.0 ET INICIO
	If @nombreServidor <> @@ServerName 
		if len(@nombreLinkedServer) > 1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
			set @nombreServidor	=	@nombreLinkedServer
			2.0 ET FIN */

		--Elimina Users por Bd
		--PTZ 1.1 join master.sys.databases
		/*set @QueryUsuarioBd = 'select distinct NombreBd, CodigoUsuario from  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioBaseDatosROl Rol  WITH(NOLOCK)
									Inner Join ['+@nombreServidor+'].[BVN_Seguridad].Maestros.BaseDatos  Bd  WITH(NOLOCK)
									on Rol.Idbasedatos = Bd.IdBasedatos
									Inner Join seguridad.BaseDatosRol Bdr WITH(NOLOCK)
									on Bdr.IdRol = Rol.Idrol and Bdr.Idbasedatos = Rol.Idbasedatos
									and codigousuario ='''+@CodigoUsuario +'''
									INNER JOIN [' + @nombreServidor+'].master.sys.databases SDB WITH (NOLOCK)
									ON SDB.name = Bd.NombreBd'  */

		Insert into @UsuarioBaseDatos(NombreBD,CodigoUsuario)
		select distinct NombreBd, CodigoUsuario from  Seguridad.UsuarioBaseDatosROl Rol  WITH(NOLOCK)
									Inner Join Maestros.BaseDatos  Bd  WITH(NOLOCK)
									on Rol.Idbasedatos = Bd.IdBasedatos
									Inner Join seguridad.BaseDatosRol Bdr WITH(NOLOCK)
									on Bdr.IdRol = Rol.Idrol and Bdr.Idbasedatos = Rol.Idbasedatos
									and codigousuario =@CodigoUsuario
									INNER JOIN master.sys.databases SDB WITH (NOLOCK)
									ON SDB.name = Bd.NombreBd
		--2.0 ETexecute sp_executeSql  @QueryUsuarioBd

		DECLARE UsuarioBaseDatos CURSOR FOR Select NombreBD  From @UsuarioBaseDatos
		OPEN UsuarioBaseDatos 
			FETCH NEXT FROM UsuarioBaseDatos INTO @NombreBD
			WHILE @@fetch_status = 0
			BEGIN

				--Set @QueryExiste = 'Select 1 From ['+@nombreServidor+'].'+@NombreBD+'.sys.database_principals WHERE name ='''+@CodigoUsuario +''''  
				Insert Into @Tb_Existe
				Select 1 From sys.database_principals WHERE name =@CodigoUsuario
				--Exec (@QueryExiste)
				
				If  Exists(Select Existe From @Tb_Existe )
				Begin
					--PTZ 1.1 INICIO
					--Set @QueryExiste = 'Select 1 From ['+@nombreServidor+'].'+@NombreBD+'.sys.schemas s inner join sys.sysusers u on u.uid = s.principal_id WHERE s.name ='''+@CodigoUsuario +''''  
					Insert Into @Tb_ExisteSch
					Select 1 From sys.schemas s inner join sys.sysusers u on u.uid = s.principal_id WHERE s.name =@CodigoUsuario
					--Exec (@QueryExiste)
					IF EXISTS(SELECT Existe FROM @Tb_ExisteSch)
					BEGIN
						if @nombreServidor<>@@SERVERNAME and @nombreServidor=@nombreLinkedServer	-- ES LINKED
							Set @SqlDrop = 'EXEC (''USE ''' + @NombreBD + '; ''DROP SCHEMA ''  '+ quotename(@CodigoUsuario)  +' ;'') AT [' + @nombreLinkedServer + ']' 
						ELSE
							set @SqlDrop = 'USE ' + @NombreBD + '; DROP SCHEMA  ' + quotename(@CodigoUsuario)  +' ;'
	
						execute sp_executeSql  @SqlDrop
						DELETE FROM @Tb_ExisteSch
					END
					--PTZ 1.1 FIN
					if @nombreServidor<>@@SERVERNAME and @nombreServidor=@nombreLinkedServer	-- ES LINKED
						Set @SqlDrop = 'EXEC (''USE ''' + @NombreBD + '; ''DROP USER ''  '+ quotename(@CodigoUsuario)  +' ;'') AT [' + @nombreLinkedServer + ']' 
					ELSE
						set @SqlDrop = 'USE ' + @NombreBD + '; DROP USER  ' + quotename(@CodigoUsuario)  +' ;'
	
					execute sp_executeSql  @SqlDrop
				End
				DELETE FROM @Tb_Existe --PTZ 1.1
		FETCH NEXT FROM UsuarioBaseDatos INTO @NombreBD
		END
		CLOSE UsuarioBaseDatos
		DEALLOCATE UsuarioBaseDatos

		if @Desahabilitar=1 
		Begin
		--Desvincular Login vs Users
		/*2.0 ET INICIO
		set @QueryUsuarioBd  = 'Delete FROM  ['+@nombreServidor+'].[BVN_seguridad].Seguridad.UsuarioBaseDatosROl
								WHERE  CodigoUsuario ='''+@CodigoUsuario +''''
		Execute sp_executeSql  @QueryUsuarioBd
		2.0 ET FIN*/
		Delete FROM  Seguridad.UsuarioBaseDatosROl
								WHERE  CodigoUsuario =@CodigoUsuario
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
