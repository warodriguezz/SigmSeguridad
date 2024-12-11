/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Actualizar acceso menú perfil
							Se ejecuta como UPDATE E INSERT

PARAMETROS 
     @CodigoUsuario : Codigo de usuario
     @IdBaseDatos   : Id de base datos
     @IdRol         : Id del rol en la base de datos
     @IdServidor    : Id de servidor
     @Acceso        :  1) con acceso  2) sin acceso
 
CONTROL DE VERSION
Historial       Autor               Fecha           Descripción
1.0             Walther Rodriguez  2019-06-20       Versión Inicial
1.1				Hugo Chuquitaype   13-01-2020		Se aplica quotename a @codigousuario
1.2				Hugo Chuquitaype   07-05-2020		Obtener y Asignar LoginActivo 
1.3				Walther Rodriguez	02/11/2020	    Funcion SEGURIDAD.ufn_UsuarioLogin,devuelve el tipo
1.4				Walther Rodriguez	03/12/2020	    Utilizar tipo login , considera dominio al validar usuario U
1.5				Walther Rodriguez	6/12/2020	    Validar que exista antes de eliminar
1.6				Walther Rodriguez	7/12/2020	    Si es tipo U , siempre devolver SQL
1.7				Walther Rodriguez	13/04/2023		Utilizar transaccion distribuida para linked
2.0				Edwin Tenorio		19/06/2024		Se comenta @IdServidor
********************************************************************************************/ 
ALTER procedure SEGURIDAD.usp_UsuarioBaseDatosRol_UpdateInsert
 	 @CodigoUsuario	VARCHAR(50)
	,@IdBaseDatos	SMALLINT
	,@IdRol		    SMALLINT
	--2.0 ET ,@IdServidor	TINYINT
	,@Acceso		TINYINT
			
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	SET XACT_ABORT ON;
	
	Declare @NombreBD					Varchar(60)
	Declare @NombreRol					Varchar(60)
	Declare	@SqlPermiso					nVarchar(max)
	Declare @SqlCrear					nVarchar(max)
	Declare @RetValidar					Int
	Declare @RetEstado					Varchar(5) 

	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare  @QueryExiste				nvarchar(max) 
	Declare  @Query						nvarchar(max) 
	Declare	 @QuerySetVariable			nvarchar(max) 
	Declare  @codigologin				VARCHAR(20)   --ver 1.2 hch
	Declare  @TipoLogin					VarChar(1)
	Declare	 @codigoLoginSrv			VARCHAR(20) 

	BEGIN DISTRIBUTED TRANSACTION;	--WRZ 1.7

	BEGIN TRY 

	
		--Obtener datos servidor
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET @idServidor 

		If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer

		--ver 1.3 hch

		--Obtener Login Actual
		Select @QuerySetVariable= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario) --2.0 ET ,@idServidor)
		execute sp_executeSql   @QuerySetVariable,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLogin  OUTPUT 

		if @TipoLogin='U'	--Si es Active Direcory, cambiar a SQL igual WRZ 1.6
		Begin
			Set @TipoLogin	='S'
		End

		--Obtener Nombre de Base de datos
		Set @QuerySetVariable ='Select @NombreBD	= NombreBd
						From ['+@NombreServer+'].[BVN_seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
						where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
		execute sp_executeSql   @QuerySetVariable,  N'@NombreBD Varchar(60) OUTPUT',  @NombreBD = @NombreBD OUTPUT 

		--Obtener Nombre de Rol de Base de datos
		Set @QuerySetVariable ='Select @NombreRol	= NombreRol
						From ['+@NombreServer+'].[BVN_seguridad].Seguridad.BaseDatosRol  WITH ( NOLOCK)  
						where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) + ' and idrol = ' + Convert(Char(3),@IdRol)
	
		execute sp_executeSql   @QuerySetVariable,  N'@NombreRol Varchar(60) OUTPUT',  @NombreRol = @NombreRol OUTPUT 

		Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].seguridad.BaseDatosRol WITH ( NOLOCK)  Where IdBaseDatos =' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
		Insert Into @Tb_Existe
		Exec (@QueryExiste)

			If  Exists(Select Existe From @Tb_Existe)
			Begin

				Delete From @Tb_Existe
				Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].seguridad.UsuarioBaseDatosRol WITH ( NOLOCK)  Where CodigoUsuario	=	'''+@CodigoUsuario +'''  and  IdBaseDatos =' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
		
				Insert Into @Tb_Existe
				Exec (@QueryExiste)

				--CON Acceso , sino existe, REGISTRAR
				If @Acceso=1
				Begin
						If Not Exists(Select Existe From @Tb_Existe)
							Execute Seguridad.Usp_UsuarioBaseDatosRol_insert @CodigoUsuario,@IdBaseDatos,@IdRol --2.0 ET ,@IdServidor

						--2.0 ET exec Seguridad.usp_SQL_Usuario_Validar 2, @IdServidor,@NombreBD,@CodigoUsuario,@TipoLogin,@RetValidar output --ver 1.3 hch
						exec Seguridad.usp_SQL_Usuario_Validar 2,@NombreBD,@CodigoUsuario,@TipoLogin,@RetValidar output --ver 1.3 hch

						if @RetValidar=0
						Begin	--No esta creado, CREAR
				
							if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
								Set @SqlCrear = 'EXEC (''USE ' + @NombreBD + '; CREATE USER  ' + quotename(@codigologin) +' FROM LOGIN ' + quotename(@codigologin) +' ;'') AT [' + @NombreServer + ']'
							else
								Set @SqlCrear = 'USE ' + @NombreBD + '; CREATE USER  ' + quotename(@codigologin) +' FROM LOGIN ' + quotename(@codigologin) +' ;'
							
							exec (@SqlCrear)
						End
						
						--Asignar usuario en la base de datos
						if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
							Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; EXEC sp_addrolemember ' + @NombreRol +',' + quotename(@codigologin) +' ;'') AT [' + @NombreServer + ']'
						else
							Set @SqlPermiso = 'USE ' + @NombreBD + '; EXEC sp_addrolemember ' + @NombreRol +',' + quotename(@codigologin) +' ;'
						exec (@SqlPermiso)

						--Validar si el usuario tiene mapeo usuario-login en esa bd
						--2.0 ET Exec Seguridad.usp_SQL_Usuario_Login_Validar 1,@IdServidor,@NombreBD,@CodigoUsuario,@TipoLogin, @RetEstado output 
						Exec Seguridad.usp_SQL_Usuario_Login_Validar 1,@NombreBD,@CodigoUsuario,@TipoLogin, @RetEstado output 

						if @RetEstado='SinAs'
						Begin
							--ver 1.1 hch
							--Mapear usuario
							if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
								Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; ALTER USER ' + quotename(@codigologin) +  ' WITH LOGIN = ' + quotename(@codigologin) + ';'') AT [' + @NombreServer + ']'    --ver 1.1 hch
							else
								Set @SqlPermiso = 'USE ' + @NombreBD + '; ALTER USER ' + quotename(@codigologin) +  ' WITH LOGIN = ' + quotename(@codigologin) + ';'											--ver 1.1 hch
							exec (@SqlPermiso)
						End

						
				End
				--SIN Acceso , si existe, ELIMINAR
				If @Acceso=0
				Begin
					If Exists(Select Existe From @Tb_Existe)
						--2.0 ET Execute Seguridad.usp_UsuarioBaseDatosRol_delete @CodigoUsuario,@IdBaseDatos,@IdRol,@IdServidor
						Execute Seguridad.usp_UsuarioBaseDatosRol_delete @CodigoUsuario,@IdBaseDatos,@IdRol --2.0 ET ,@IdServidor

					--Desasignar usuario en la base de datos
					--2.0 ET exec Seguridad.usp_SQL_Usuario_Validar 2, @IdServidor,@NombreBD,@CodigoUsuario,@TipoLogin,@RetValidar output --ver 1.5 WRZ
					exec Seguridad.usp_SQL_Usuario_Validar 2,@NombreBD,@CodigoUsuario,@TipoLogin,@RetValidar output --ver 1.5 WRZ

					if @RetValidar=1
					Begin	--Si esta creado, Quitar

						if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
								Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; EXEC sp_droprolemember ' + @NombreRol +',' + quotename(@codigologin) +' ;'') AT [' + @NombreServer + ']'
							else
								Set @SqlPermiso = 'USE ' + @NombreBD + '; EXEC sp_droprolemember ' + @NombreRol +',' + quotename(@codigologin) +' ;'
					
						exec (@SqlPermiso)
					End
				End


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
