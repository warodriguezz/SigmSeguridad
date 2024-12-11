/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Asigna Permisos sobre los Usuarios como Rol SecurityAdmin / SysAdmin
PARAMETROS 	
*	 @IdServidor			Id del servidor
  	,@CodigoUsuario			Código Usuario
	,@TipoPermiso			Tipo de Permiso  1 SysAdmin y 2 SecurityAdmin
	,@Accion				1 Agrega , 2 Quita

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Hugo Chuquitaype	    11/09/2019		Versión Inicial
1.1				Hugo Chuquitaype	    12/05/2020		obtener codigologin
1.2				Walther Rodriguez Z		04/09/2020		Corregir parametros
2.0				Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Rol_Sevidor
  (  --2.0 ET @IdServidor		TINYINT
	@CodigoUsuario		VARCHAR(20)
	,@TipoPermiso		TINYINT
	,@Accion			TINYINT

)

as

BEGIN

	SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;	
    
    BEGIN TRY

		DECLARE  @SqlPermiso			Varchar(300)

		Declare  @nombreLinkedServer	Varchar(20)
		Declare	 @NombreServer			Varchar(50)
		Declare  @QuerySelect			nvarchar(max) 
		Declare	 @QuerySetVariable		nvarchar(max)
		Declare  @ServerRol				Varchar(20)
		Declare  @TieneRol				TinyInt
		Declare  @codigologin			Varchar(20)

		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

		--Obtener Login Activo
		Set @CodigoLogin	=	@CodigoUsuario  --ver 1.1 hch

		IF @TipoPermiso=1 
			SET @ServerRol = 'sysadmin'
		ELSE
			SET @ServerRol = 'securityadmin'

		Set @QuerySetVariable ='Select @TieneRol = IS_SRVROLEMEMBER ( ''' + @ServerRol + ''',''' + @codigologin + ''')'    --ver 1.1 hch
	
		execute sp_executeSql   @QuerySetVariable,  N'@TieneRol TinyInt OUTPUT', @TieneRol = @TieneRol OUTPUT 

		--Ini ver 1.1 hch

		IF @Accion=1	--AGREGAR
		BEGIN
			IF @TieneRol=1	--Si ya tiene el ROLSERVER , salir
				RETURN

			if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
					Set @SqlPermiso = 'EXEC (''EXEC sp_addsrvrolemember ' + quotename(@codigologin) + ', ' + @ServerRol + ' ;'') AT [' + @NombreServer + ']'	--WRZ 1.2		
				Else
					set @SqlPermiso = 'EXEC sp_addsrvrolemember ' +   quotename(@codigologin)+ ', ' + @ServerRol + ' ;'
			
		END

		IF @Accion=2	--QUITAR
		BEGIN
			IF @TieneRol=0	--Si NO tiene el ROLSERVER , salir
				RETURN

			if @NombreServer<>@@SERVERNAME and @NombreServer=@nombreLinkedServer	-- ES LINKED
					Set @SqlPermiso = 'EXEC (''EXEC sp_dropsrvrolemember ' + quotename(@codigologin) + ', ' + @ServerRol + ' ;'') AT [' + @NombreServer + ']' --WRZ 1.2
				Else
					set @SqlPermiso = 'EXEC sp_dropsrvrolemember ' +   quotename(@codigologin)+ ', ' + @ServerRol + ' ;'

		END
		--FIn ver 1.1 hch

		exec (@SqlPermiso)

	END TRY
    BEGIN CATCH
		DECLARE @MensajeError varchar(4096)
        DECLARE @ErrorSeverity int
        DECLARE @ErrorState int

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );
    END CATCH;
    SET LANGUAGE us_english;

END
