
/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de objetos Database_rol del servidor SQL-Diferencia por is_fixed_role (Rol de Sistema)
PARAMETROS 	
*  @IdBaseDatos		: Id de la Base de Datos
*  @IdServidor		: Id del Servidor

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    20/02/2019		Versión Inicial
2.0				Edwin Tenorio			12/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_BaseDatosRol_Comparar
     @IdBaseDatos	 SmallInt
	 --2.0 ET ,@IdServidor		TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY
    
		Declare  @NombreBd				Varchar(60)
		-- 2.0 ET INICIO
		--Declare  @nombreLinkedServer	Varchar(20)
		--Declare	 @NombreServer			Varchar(50)
		Declare @TablaFinal Table
		( IdBaseDatos INT,
        	IdRol INT ,
        	NombreRol varchar(120),
        	tipoacceso CHAR(1),
        	Estado char(1),
			IdServidor INT
		)
		--2.0 ET FIN
		Declare  @QuerySelect			nvarchar(max) 
		Declare	 @QuerySetVariable		nvarchar(max)
		Declare	 @IdServidorBd			Tinyint
		Declare  @IdObjSys				SMALLINT
		Declare	 @IdAplicacion			SMALLINT

		
	if exists (select *  from tempdb..sysobjects where name like '#TabSQL%')				   
		drop table ##TabSQL

	CREATE TABLE #TabSQL ( 
		 id				Tinyint Identity(1,1)
		,NombreRol	Varchar(50)
		,RolSys       Tinyint )     
 

	if exists (select *  from tempdb..sysobjects where name like '##TabSet%')				   
		drop table ##TabSet

	CREATE TABLE #TabSet ( 
		 id				Tinyint Identity(1,1)
		,NombreRol	Varchar(50)
		,Estado			Char(1))     

	SELECT  @IdAplicacion = idaplicacion FROM Seguridad.aplicacion WITH (NOLOCK) WHERE ObjetoAplicacion  ='sigm_seguridad'
	SELECT  @IdObjSys = CASE WHEN IsNull(valorcadena,'N') = 'N' Then 0 ELSE 1 END   from Framework.ParametroAplicacion WITH ( NOLOCK) where  NivelConfiguracion='C' AND IdAplicacion=@IdAplicacion and Nombre='VerObjetosSistema'

	/*2.0 ET INICIO
	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
		@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer

		Set @QuerySetVariable ='Select @NombreBd	= NombreBd,
							       @IdServidorBd =  idservidor 
								From ['+@NombreServer+'].[BVN_Seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
								where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
			execute sp_executeSql   @QuerySetVariable,  N'@NombreBd Varchar(60) OUTPUT , @IdServidorBd tinyint OUTPUT',  @NombreBd = @NombreBd OUTPUT , @IdServidorBd = @IdServidorBd OUTPUT
	2.0 ET FIN*/

			---sysdb.is_fixed_role Indetifica si es Rol de Sistema
			IF 	@IdObjSys =   1
			Begin
				/*2.0 ET INICIO
				Set @QuerySelect  = 'Select sysusr.name as Nombre ,  sysdb.is_fixed_role as RolSys
						FROM ['+@NombreServer+'].['+@NombreBd+'].sys.sysusers sysusr  WITH ( NOLOCK) 
								INNER JOIN ['+@NombreServer+'].['+@NombreBd+'].sys.database_principals sysdb WITH ( NOLOCK) 
								ON (sysusr.name  =  sysdb.name)
								 Where issqlrole = 1'
				2.0 ET FIN*/
				--2.0 ET INICIO
				Insert Into #TabSQL
				Select sysusr.name as Nombre ,  sysdb.is_fixed_role as RolSys
						FROM sys.sysusers sysusr  WITH ( NOLOCK) 
								INNER JOIN sys.database_principals sysdb WITH ( NOLOCK) 
								ON (sysusr.name  =  sysdb.name)
								 Where issqlrole = 1
				--2.0 ET FIN
			End
			ELSE
				Begin
				/*2.0 ET INICIO
				Set @QuerySelect  = 'Select sysusr.name as Nombre ,  sysdb.is_fixed_role as RolSys
						FROM ['+@NombreServer+'].['+@NombreBd+'].sys.sysusers sysusr  WITH ( NOLOCK) 
								INNER JOIN ['+@NombreServer+'].['+@NombreBd+'].sys.database_principals sysdb WITH ( NOLOCK) 
								ON (sysusr.name  =  sysdb.name)
								 Where issqlrole = 1 
								 and sysdb.is_fixed_role =' + Convert(Char(1),@IdObjSys )
				2.0 ET FIN*/
				--2.0 ET INICIO
				Insert Into #TabSQL
				Select sysusr.name as Nombre ,  sysdb.is_fixed_role as RolSys
						FROM sys.sysusers sysusr  WITH ( NOLOCK) 
								INNER JOIN sys.database_principals sysdb WITH ( NOLOCK) 
								ON (sysusr.name  =  sysdb.name)
								 Where issqlrole = 1 
								 and sysdb.is_fixed_role =@IdObjSys
				--2.0 ET FIN
				End

			/*2.0 ET INICIO
			Insert Into #TabSQL
			Execute (@QuerySelect)
			2.0 ET FIN*/

			/*2.0 ET INICIO
			Set @QuerySelect  = 'Select r.NombreRol,''O'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosRol r WITH (NOLOCK)
        						Where r.IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) +
         						'INTERSECT
        						Select NombreRol,''O'' From #TabSQL'
			2.0 ET FIN*/

			Insert Into #TabSet(NombreRol,Estado)
			Select r.NombreRol,'O' From Seguridad.BaseDatosRol r WITH (NOLOCK)
        						Where r.IdBaseDatos=@IdBasedatos
         						INTERSECT
        						Select NombreRol,'O' From #TabSQL
			--2.0 ET Execute(@QuerySelect)

			/*2.0 ET INICIO
			Set @QuerySelect  = 'Select r.NombreRol,''Q'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosRol r WITH (NOLOCK)
        						Where r.IdBaseDatos=' + Convert(Char(2),@IdBasedatos) +
        						' EXCEPT
        						Select NombreRol,''Q'' From #TabSQL'
			2.0 ET FIN*/

			Insert Into #TabSet(NombreRol,Estado)
			Select r.NombreRol,'Q' From Seguridad.BaseDatosRol r WITH (NOLOCK)
        						Where r.IdBaseDatos=@IdBasedatos
        						EXCEPT
        						Select NombreRol,'Q' From #TabSQL
			--2.0 ET Execute(@QuerySelect)

			/*2.0 ET INICIO
			Set @QuerySelect  = 'Select NombreRol,''A'' From #TabSQL 
        						 EXCEPT
								 Select r.NombreRol,''A'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosRol r WITH (NOLOCK)
        						 Where r.IdBaseDatos =' + Convert(Char(2),@IdBasedatos) 
			2.0 ET FIN*/

			Insert Into #TabSet(NombreRol,Estado)
			Select NombreRol,'A' From #TabSQL 
        						 EXCEPT
								 Select r.NombreRol,'A' From Seguridad.BaseDatosRol r WITH (NOLOCK)
        						 Where r.IdBaseDatos =@IdBasedatos
			--2.0 ET Execute(@QuerySelect)

        	/*2.0 ET INICIO
			Set @QuerySelect  =  'SELECT  ' +  Convert(Char(2),@IdBaseDatos) + ' as IdBaseDatos,
        							TabApp.IdRol,
        							Rtrim(ts.NombreRol) as NombreRol,
        							TabApp.tipoacceso,
        							ts.Estado,
									' + Convert(Char(2),@IdServidor) + ' as IdServidor
        							From #TabSet ts
        							LEFT Join (Select r.NombreRol, r.IdRol, r.TipoAcceso From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosRol r WITH (NOLOCK)
        								Where r.IdBaseDatos=' + Convert(Char(2),@IdBasedatos) +') as TabApp
        								on tabapp.NombreRol	=	ts.NombreRol
        							Order by TabApp.IdRol '
				2.0 ET FIN*/

				Insert Into @TablaFinal
				( IdBaseDatos,
        			IdRol,
        			NombreRol,
        			tipoacceso,
        			Estado,
					IdServidor
				)
				SELECT  @IdBaseDatos as IdBaseDatos,
        							TabApp.IdRol,
        							Rtrim(ts.NombreRol) as NombreRol,
        							TabApp.tipoacceso,
        							ts.Estado,
									7 as IdServidor
        							From #TabSet ts
        							LEFT Join (Select r.NombreRol, r.IdRol, r.TipoAcceso From Seguridad.BaseDatosRol r WITH (NOLOCK)
        								Where r.IdBaseDatos=@IdBasedatos) as TabApp
        								on tabapp.NombreRol	=	ts.NombreRol
        							Order by TabApp.IdRol

				Select
				IdBaseDatos,
        			IdRol,
        			NombreRol,
        			tipoacceso,
        			Estado,
					IdServidor
					From @TablaFinal
				--2.0 ET Execute(@QuerySelect)
            
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
