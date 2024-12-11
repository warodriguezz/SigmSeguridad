/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Generar Permisos con el nuevo Perfil y Elimina Permisos (Roles por Perfil existente)
							
PARAMETROS 	
*   @CodigoUsuario		:   Codigo Usuario
*   @CodigoLogin		:   Codigo Login
*   @codigoLogin_ant	:   Codigo Login Anterior  ????? y si tiene 3 logins ????
*	@Eliminar_ant		:   Eliminar persimos de login anterior S/N
*	@IdServidor			:	IdServidor

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		12/05/2020	    Versión Inicial
1.1			Walther	Rodriguez		28/05/2020		Controlar por login, eliminacion condicional
1.2			Walther Rodriguez		03/12/2020	    Utilizar tipo login , considera dominio al validar usuario U
1.3			Walther Rodriguez		16/12/2020	    Utilizar solo el tipo (S) , anular cambio 1.2
2.0			Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_UsuarioLoginPerfilBaseDatosRol
  @CodigoUsuario		VARCHAR(20)
 ,@codigoLogin			VARCHAR(20)
 ,@codigoLogin_ant		VARCHAR(20)
 ,@Eliminar_ant			CHAR(1)
 --2.0 ET ,@IdServidor			TINYINT

			
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @QuerySetVariable			nvarchar(max)
	Declare  @QueryExiste				nvarchar(max)
	Declare  @IdBaseDatos				SMALLINT
	Declare  @IdRol						SMALLINT
	Declare  @IdVista					SMALLINT
	DECLARE  @count						SMALLINT
	DECLARE  @id						SMALLINT
	Declare	 @Tb_Existe					Table (Existe TinyInt)

	Declare @NombreBD					Varchar(60)
	Declare @NombreRol					Varchar(60)
	Declare	@SqlPermiso					nVarchar(max)
	Declare @SqlCrear					nVarchar(max)
	Declare @RetValidar					Int
	Declare @RetEstado					Varchar(5) 
	Declare @NombreVista				Varchar(60)
	Declare @NombreVistaSinEsquema		Varchar(60)
	Declare @SqlEsquema					Varchar(300)
	Declare @NombreEsquema				Varchar(50)	
	Declare	@tipologin					CHAR(1)
	Declare	@tipologin_ant				CHAR(1)
	

	BEGIN TRY 

			DECLARE @TabSQL	Table(  id		Tinyint Identity(1,1)
							,IdBaseDatos	SMALLINT
							,IdRol			SMALLINT  ) 
			
			DECLARE @TabSQLVista	Table(  id		Tinyint Identity(1,1)
							,IdBaseDatos	SMALLINT
							,IdVista			SMALLINT  ) 
								
			--Obtener datos servidor
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET @idServidor 

			If @NombreServer<>@@SERVERNAME
				if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
					Set @NombreServer	=	@nombreLinkedServer

			
			--Obtener Tipo de Login Actual
			/*2.0 ET INICIO
			Set @QuerySetVariable ='Select @TipoLogin	= IsNull(Ul.TipoLogin,'''')
											From ['+@NombreServer+'].[BVN_seguridad].seguridad.Usuariologin ul  WITH ( NOLOCK)
											INNER JOIN ['+@NombreServer+'].[BVN_seguridad].SEGURIDAD.Usuario U WITH ( NOLOCK)
											ON (UL.codigousuario = U.codigousuario and Ul.IdLogin = u.LoginActivo )
											where Ul.CodigoUsuario= '''+@CodigoUsuario +''' AND Ul.Estado=1'
	
			execute sp_executeSql   @QuerySetVariable,  N'@TipoLogin Char(1) OUTPUT',  @TipoLogin = @TipoLogin OUTPUT 
			2.0 ET FIN*/
			Select @TipoLogin	= IsNull(Ul.TipoLogin,'''')
											From seguridad.Usuariologin ul  WITH ( NOLOCK)
											INNER JOIN SEGURIDAD.Usuario U WITH ( NOLOCK)
											ON (UL.codigousuario = U.codigousuario and Ul.IdLogin = u.LoginActivo )
											where Ul.CodigoUsuario= @CodigoUsuario AND Ul.Estado=1

			--Obtener Tipo de Login Anterior
			/*2.0 ET INICIO Set @QuerySetVariable ='Select @tipologin_ant	= IsNull(Ul.TipoLogin,'''')
											From ['+@NombreServer+'].[BVN_seguridad].seguridad.Usuariologin ul  WITH ( NOLOCK)
											INNER JOIN ['+@NombreServer+'].[BVN_seguridad].SEGURIDAD.Usuario U WITH ( NOLOCK)
											ON (UL.codigousuario = U.codigousuario and Ul.IdLogin <> u.LoginActivo )
											where Ul.CodigoUsuario= '''+@CodigoUsuario +''' AND Ul.Estado=1'
	
			execute sp_executeSql   @QuerySetVariable,  N'@tipologin_ant Char(1) OUTPUT',  @tipologin_ant = @tipologin_ant OUTPUT 
			2.0 ET FIN*/
			Select @tipologin_ant	= IsNull(Ul.TipoLogin,'''')
											From seguridad.Usuariologin ul  WITH ( NOLOCK)
											INNER JOIN SEGURIDAD.Usuario U WITH ( NOLOCK)
											ON (UL.codigousuario = U.codigousuario and Ul.IdLogin <> u.LoginActivo )
											where Ul.CodigoUsuario= @CodigoUsuario AND Ul.Estado=1

				--Verficar Existencia
				/*2.0 ET INICIO 
			Set @QuerySetVariable ='Select 1
							From ['+@NombreServer+'].[BVN_seguridad].Seguridad.UsuarioBaseDatosRol  WITH ( NOLOCK)  
							Where   CodigoUsuario ='''+@CodigoUsuario +''''
						2.0 ET FIN*/	
		
			--if @TipoLogin='U'
			--	Select	@codigoLogin=Framework.ufn_NombreDominio()+'\'+@CodigoLogin	--WRZ 1.2

			if @TipoLogin='U'	--Si es Active Direcory, cambiar a SQL igual WRZ 1.3
			Begin
				Set @TipoLogin	='S'
			End
		 
			Insert Into @Tb_Existe
			Select 1
			From Seguridad.UsuarioBaseDatosRol  WITH ( NOLOCK)  
			Where   CodigoUsuario =@CodigoUsuario
			--2.0 ET Exec (@QuerySetVariable)


			If Exists(Select Existe From @Tb_Existe)
				Begin
				--Seleccionar permisos 		
					/*2.0 ET INICIO Set @QuerySetVariable = 'Select idBasedatos,IdROl 
											From ['+@NombreServer+'].[BVN_seguridad].Seguridad.UsuarioBaseDatosRol  WITH ( NOLOCK)  
											Where   CodigoUsuario ='''+@CodigoUsuario +''''
											2.0 ET FIN*/
					Insert Into @TabSQL
					Select idBasedatos,IdROl 
											From Seguridad.UsuarioBaseDatosRol  WITH ( NOLOCK)  
											Where   CodigoUsuario =@CodigoUsuario
					--2.0 ET Execute (@QuerySetVariable)
	
					SELECT @count=COUNT(id) from @TabSQL
					
					set @id = 1
					WHILE(@count>0 AND @id<=@count)
						BEGIN
							SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol  from @TabSQL WHERE Id=@id

							--Obtener Nombre de Base de datos
							/*2.0 ET INICIO Set @QuerySetVariable ='Select @NombreBD	= NombreBd
											From ['+@NombreServer+'].[BVN_seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
											where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
							execute sp_executeSql   @QuerySetVariable,  N'@NombreBD Varchar(60) OUTPUT',  @NombreBD = @NombreBD OUTPUT 
							2.0 ET FIN */
							Select @NombreBD	= NombreBd
											From Maestros.BaseDatos  WITH ( NOLOCK)  
											where IdBaseDatos=	@IdBasedatos

							--Obtener Nombre de Rol de Base de datos
							/*2.0 ET INICIO Set @QuerySetVariable ='Select @NombreRol	= NombreRol
											From ['+@NombreServer+'].[BVN_seguridad].Seguridad.BaseDatosRol  WITH ( NOLOCK)  
											where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) + ' and idrol = ' + Convert(Char(3),@IdRol)
	
							execute sp_executeSql   @QuerySetVariable,  N'@NombreRol Varchar(60) OUTPUT',  @NombreRol = @NombreRol OUTPUT 
							2.0 ET FIN*/

							Select @NombreRol	= NombreRol
											From Seguridad.BaseDatosRol  WITH ( NOLOCK)  
											where IdBaseDatos=	@IdBasedatos and idrol = @IdRol

							--2.0 ET Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].seguridad.BaseDatosRol WITH ( NOLOCK)  Where IdBaseDatos =' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
							Insert Into @Tb_Existe
							Select 1 From seguridad.BaseDatosRol WITH ( NOLOCK)  Where IdBaseDatos =@IdBaseDatos AND IdRol= @IdRol
							--2.0 ETExec (@QueryExiste)		

							If  Exists(Select Existe From @Tb_Existe)
							Begin
							--Validar que usuario este creado en BD
									
									--2.0 ET exec Seguridad.usp_SQL_Usuario_Validar 2, @IdServidor,@NombreBD,@CodigoUsuario,@tipologin,@RetValidar output  --wrz 1.1
									exec Seguridad.usp_SQL_Usuario_Validar 2,@NombreBD,@CodigoUsuario,@tipologin,@RetValidar output  --wrz 1.1
									
									if @RetValidar=0 --No esta creado, CREAR   wrz 1.1
									Begin
	
										if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
											Set @SqlCrear = 'EXEC (''USE ' + @NombreBD + '; CREATE USER  ' + quotename(@codigologin) +' FROM LOGIN ' + quotename(@codigologin) +' ;'') AT [' + @NombreServer + ']'
										else
											Begin
												Set @SqlCrear = 'USE ' + @NombreBD + '; CREATE USER  ' + quotename(@codigologin) +' FROM LOGIN ' + quotename(@codigologin) +' ;'
												exec (@SqlCrear)
											End
									End
														
									--Asignar usuario en la base de datos
									if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
										Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; EXEC sp_addrolemember ' + @NombreRol +',' + quotename(@codigologin) +' ;'') AT [' + @NombreServer + ']'
									else
										Set @SqlPermiso = 'USE ' + @NombreBD + '; EXEC sp_addrolemember ' + @NombreRol +',' + quotename(@codigologin) +' ;'
									exec (@SqlPermiso)

									--Validar si el usuario tiene mapeo usuario-login en esa bd
									--2.0 ET Exec Seguridad.usp_SQL_Usuario_Login_Validar 1,@IdServidor,@NombreBD,@codigoLogin,@tipologin, @RetEstado output 
									Exec Seguridad.usp_SQL_Usuario_Login_Validar 1,@NombreBD,@codigoLogin,@tipologin, @RetEstado output 

									if @RetEstado='SinAs'
									Begin
					
									--Mapear usuario
										if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
											Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; ALTER USER ' + quotename(@codigologin) +  ' WITH LOGIN = ' + quotename(@codigologin) + ';'') AT [' + @NombreServer + ']'    ----wrz 1.1
										else
											Set @SqlPermiso = 'USE ' + @NombreBD + '; ALTER USER ' + quotename(@codigologin) +  ' WITH LOGIN = ' + quotename(@codigologin) + ';'											--wrz 1.1
											exec (@SqlPermiso)
										End
										
									--Quitar usuario en la base de datos
									IF @Eliminar_ant='S'
									Begin
										--Primero verificar que el anterior Exista en esa BD
										--2.0 ET exec Seguridad.usp_SQL_Usuario_Validar 2, @IdServidor,@NombreBD,@codigoLogin_ant,@tipologin_ant,@RetValidar output
										exec Seguridad.usp_SQL_Usuario_Validar 2,@NombreBD,@codigoLogin_ant,@tipologin_ant,@RetValidar output
										if @RetValidar=1	--Si existe
										Begin
											if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
												Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; EXEC sp_droprolemember ' + @NombreRol +',' + quotename(@codigoLogin_ant) +' ;'') AT [' + @NombreServer + ']'
											else
												Set @SqlPermiso = 'USE ' + @NombreBD + '; EXEC sp_droprolemember ' + @NombreRol +',' + quotename(@codigoLogin_ant) +' ;'
					
											exec (@SqlPermiso)
										end							
									End
								End
								
							SELECT  @id=@id+1
					END
			END	

			--Verficar Existencia Permisos en Vista
			/*2.0 ET INICIO Set @QuerySetVariable ='Select 1
							From ['+@NombreServer+'].[BVN_seguridad].Seguridad.BaseDatosVistaUsuario  WITH ( NOLOCK)  
							Where   CodigoUsuario ='''+@CodigoUsuario +''''
			2.0 ET FIN*/
			Insert Into @Tb_Existe
			Select 1
							From Seguridad.BaseDatosVistaUsuario  WITH ( NOLOCK)  
							Where   CodigoUsuario =@CodigoUsuario
			--2.0 ET Exec (@QuerySetVariable)

			If Exists(Select Existe From @Tb_Existe)
				BEGIN
				--Seleccionar  Vistas			
					/* 2.0 ET INICIO Set @QuerySetVariable = 'Select idBasedatos,IdVista 
											From ['+@NombreServer+'].[BVN_seguridad].Seguridad.BaseDatosVistaUsuario  WITH ( NOLOCK)  
											Where   CodigoUsuario ='''+@CodigoUsuario +''''
											2.0 ET FIN*/

					Insert Into @TabSQLVista
					Select idBasedatos,IdVista 
											From Seguridad.BaseDatosVistaUsuario  WITH ( NOLOCK)  
											Where   CodigoUsuario =@CodigoUsuario
					--2.0 ET Execute (@QuerySetVariable)
	
					SELECT @count=COUNT(id) from @TabSQLVista
						
					set @id = 1
			
					WHILE(@count>0 AND @id<=@count)
						BEGIN
							SELECT @IdBaseDatos= IdBaseDatos,@IdVista = IdVista  from @TabSQLVista WHERE Id=@id

							--Obtener Nombre de Base de datos
							/*2.0 ET INICIOSet @QuerySetVariable ='Select @NombreBD	= NombreBd
											From ['+@NombreServer+'].[BVN_seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
											where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
							execute sp_executeSql   @QuerySetVariable,  N'@NombreBD Varchar(60) OUTPUT',  @NombreBD = @NombreBD OUTPUT 2.0 ET FIN*/
							Select @NombreBD	= NombreBd
											From Maestros.BaseDatos  WITH ( NOLOCK)  
											where IdBaseDatos=	@IdBasedatos

							--Obtener Nombre de Vista de Base de datos
							Set @QuerySetVariable ='Select @NombreVista	= NombreVista
											From ['+@NombreServer+'].[BVN_seguridad].Seguridad.BaseDatosVista  WITH ( NOLOCK)  
											where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) + ' and idvista = ' + Convert(Char(3),@IdVista)
							execute sp_executeSql   @QuerySetVariable,  N'@NombreVista Varchar(50) OUTPUT , @IdVista SmallInt OUTPUT',  @NombreVista = @NombreVista OUTPUT , @IdVista = @IdVista OUTPUT

							--Obetener Nombre Vista Sin Esquema
							SET  @QuerySetVariable =  'SELECT @NombreVistaSinEsquema =  RIGHT('''+ @NombreVista+''', CHARINDEX(''.'', REVERSE('''+ @NombreVista+''')) - 1)  '
							execute sp_executeSql   @QuerySetVariable,  N'@NombreVistaSinEsquema Varchar(50) OUTPUT',  @NombreVistaSinEsquema = @NombreVistaSinEsquema OUTPUT 
			
							--Obetener Nombre Esquema
							Set @QuerySetVariable ='Select @NombreEsquema = TABLE_SCHEMA FROM ' + @NombreBD + '.INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME  = '''+ @NombreVistaSinEsquema +''' '
							execute sp_executeSql   @QuerySetVariable,  N'@NombreEsquema Varchar(50) OUTPUT',  @NombreEsquema = @NombreEsquema OUTPUT 

							Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_seguridad].seguridad.BaseDatosVista WITH ( NOLOCK)  Where IdBaseDatos =' + Convert(Char(2), @IdBaseDatos)+' AND IdVista = '+ Convert(Char(3), @IdVista)
							Insert Into @Tb_Existe
							Exec (@QueryExiste)

							If  Exists(Select Existe From @Tb_Existe)
							Begin
							--Asignar usuario en la base de datos para Vista
								if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
								Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; GRANT SELECT ON '+@NombreEsquema+'.'+ @NombreVistaSinEsquema +'  TO  '+ quotename(@codigologin) +' ;'') AT [' + @NombreServer + ']'
								else
								set @SqlPermiso = 'USE ' + @NombreBD + '; GRANT SELECT ON '+@NombreEsquema+'.'+ @NombreVistaSinEsquema +'  TO  '+ quotename(@codigologin) +' ;'
								
								exec (@SqlPermiso)
				
								--Quitar usuario en la base de datos para Vista
								if @Eliminar_ant='S'
								Begin
									if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
										Set @SqlPermiso = 'EXEC (''USE ' + @NombreBD + '; REVOKE SELECT ON '+@NombreEsquema+'.'+ @NombreVistaSinEsquema +'  TO  '+ quotename(@codigoLogin_ant) +' ;'') AT [' + @NombreServer + ']'
									else
										set @SqlPermiso = 'USE ' + @NombreBD + '; REVOKE SELECT ON '+@NombreEsquema+'.'+ @NombreVistaSinEsquema +'  TO  '+ quotename(@codigoLogin_ant) +' ;'
								   
									exec (@SqlPermiso)
								End
							End

							SELECT  @id=@id+1
					END
			END	
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

	SET LANGUAGE ENGLISH;
END;
