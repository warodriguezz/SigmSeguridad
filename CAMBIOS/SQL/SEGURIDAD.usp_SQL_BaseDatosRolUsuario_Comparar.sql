/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Comparación de Roles por Usuario por Base Datos del servidor SQL
PARAMETROS 	
*  @CodigoUsuario		CODIGO DE USUARIO 
*  @IdBaseDatos			CODIGO DE BD
*  @IdServidor			CODIGO DE SERVIDOR

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Hugo Chuquitaype	    26/06/2019		Versión Inicial
2.0				Edwin Tenorio			12/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_BaseDatosRolUsuario_Comparar
(
   @CodigoUsuario  VARCHAR(20)
 , @IdBaseDatos    SMALLINT
 --2.0 ET , @IdServidor	   TINYINT

)
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY
    
	Declare  @NombreBd				Varchar(60)
	--2.0 ET INICIO
	--Declare  @nombreLinkedServer	Varchar(50)
	--Declare	 @NombreServer			Varchar(50)
	--2.0 ET FIN
	Declare  @QuerySelect			nvarchar(max) 
	Declare	 @QuerySetVariable		nvarchar(max) 

	/* 2.0 ET INICIO
	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
		@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer													
	
	Set @QuerySetVariable ='Select @NombreBd	= NombreBd
								From ['+@NombreServer+'].[BVN_Seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
								where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
	execute sp_executeSql   @QuerySetVariable,  N'@NombreBd Varchar(60) OUTPUT ',  @NombreBd = @NombreBd OUTPUT 

	Set @QuerySelect='SELECT DP1.name AS DatabaseRoleName   
							From ['+@NombreServer+'].['+ @NombreBd +'].sys.database_role_members AS DRM  WITH ( NOLOCK)
							RIGHT OUTER JOIN ['+@NombreServer+'].['+ @NombreBd +'].sys.database_principals AS DP1  WITH ( NOLOCK) 
								ON DRM.role_principal_id = DP1.principal_id  
							LEFT OUTER JOIN ['+@NombreServer+'].['+ @NombreBd +'].sys.database_principals AS DP2  WITH ( NOLOCK)
								ON DRM.member_principal_id = DP2.principal_id  
							WHERE DP1.type = ''R'' and DP2.NAME=	'''+@CodigoUsuario+''' 
							ORDER BY DP1.name '   	
		
			execute (@QuerySelect)
       2.0 ET FIN*/

	   Declare @TablaFinal Table
	   (
	   name sysname
	   )

	   Insert Into @TablaFinal
	   (
	   name
	   )
		SELECT DP1.name AS DatabaseRoleName   
							From sys.database_role_members AS DRM  WITH ( NOLOCK)
							RIGHT OUTER JOIN sys.database_principals AS DP1  WITH ( NOLOCK) 
								ON DRM.role_principal_id = DP1.principal_id  
							LEFT OUTER JOIN sys.database_principals AS DP2  WITH ( NOLOCK)
								ON DRM.member_principal_id = DP2.principal_id  
							WHERE DP1.type = 'R' and DP2.NAME=	@CodigoUsuario 
							ORDER BY DP1.name 
		
		Select
		name
		From @TablaFinal
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
