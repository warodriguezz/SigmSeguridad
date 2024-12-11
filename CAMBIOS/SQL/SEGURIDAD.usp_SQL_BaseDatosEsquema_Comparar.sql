/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de objetos Database_esquema del servidor SQL-Diferencia por is_fixed_role (Rol de Sistema)
PARAMETROS 	
*  @IdBaseDatos : Id de las base de datos
*  @IdServidor  : Id del servidor

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    20/02/2019		Versión Inicial
2.0				Edwin Tenorio			12/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_BaseDatosEsquema_Comparar
   	@IdBaseDatos	SmallInt
   --2.0 ET ,@IdServidor		TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY
    

	--2.0 ET Declare  @NombreBd				Varchar(60)
	--2.0 ET Declare  @nombreLinkedServer	Varchar(20)
	--2.0 ET Declare	 @NombreServer			Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 
	Declare	 @QuerySetVariable		nvarchar(max)
	Declare	 @IdServidorBd			Tinyint
	Declare  @IdObjSys				SMALLINT
	Declare	 @IdAplicacion			SMALLINT

	--2.0 ET INICIO
	Declare @ValoresFinales Table
	(
	IdBaseDatos INT
	,IdEsquema INT
	,NombreEsquema varchar(50)
	,DescripcionEsquema varchar(100)
	,RegistroActivo int
	,Estado CHAR(1)
	,IdServidor INT
	)
	--2.0 ET FIN

	if exists (select *  from tempdb..sysobjects where name like '#TabSQL%')				   
		drop table ##TabSQL

	CREATE TABLE #TabSQL ( 
		 id				Tinyint Identity(1,1)
		,NombreEsquema	Varchar(50)
		,RolSys			Tinyint )     
 

	if exists (select *  from tempdb..sysobjects where name like '##TabSet%')				   
		drop table ##TabSet

	CREATE TABLE #TabSet ( 
		 id				Tinyint Identity(1,1)
		,NombreEsquema	Varchar(50)
		,Estado			Char(1))     

	SELECT  @IdAplicacion = idaplicacion FROM Seguridad.aplicacion WITH (NOLOCK) WHERE ObjetoAplicacion  ='sigm_seguridad'
	SELECT  @IdObjSys = CASE WHEN IsNull(valorcadena,'N') = 'N' Then 0 ELSE 1 END   from Framework.ParametroAplicacion WITH ( NOLOCK) where  NivelConfiguracion='C' AND IdAplicacion=@IdAplicacion and Nombre='VerObjetosSistema'

	/*2.0 ET INICIO
	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
		@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  WITH (NOLOCK) where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer
	

			
			Set @QuerySetVariable ='Select @NombreBd	= NombreBd,
									@IdServidorBd =  idservidor 
									From ['+@NombreServer+'].[BVN_Seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
									where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
			execute sp_executeSql   @QuerySetVariable,  N'@NombreBd Varchar(60) OUTPUT , @IdServidorBd tinyint OUTPUT',  @NombreBd = @NombreBd OUTPUT , @IdServidorBd = @IdServidorBd OUTPUT
	2.0 ET FIN */
	
			IF 	@IdObjSys =   1
			Begin
					/*2.0 ET INICIO
					Set @QuerySelect  = 'Select 
   											Rtrim(a.name) as Nombre, b.is_fixed_role as RolSys
	   										From ['+@NombreServer+'].['+@NombreBd+'].sys.schemas a  WITH ( NOLOCK) 
											LEFT JOIN  ['+@NombreServer+'].['+@NombreBd+'].sys.database_principals b WITH ( NOLOCK) 
											ON a.principal_id = b.principal_id '
					2.0 ET FIN*/

					--2.0 ET INICIO
					Insert Into #TabSQL
					Select 
   					Rtrim(a.name) as Nombre, b.is_fixed_role as RolSys
	   				From sys.schemas a  WITH ( NOLOCK) 
					LEFT JOIN  sys.database_principals b WITH ( NOLOCK) 
					ON a.principal_id = b.principal_id
					--2.0 ET FIN
				End
			ELSE
				Begin
						/*2.0 ET INICIO
						Set @QuerySelect  = 'Select 
   									Rtrim(a.name) as Nombre, b.is_fixed_role as RolSys
	   								From ['+@NombreServer+'].['+@NombreBd+'].sys.schemas a  WITH ( NOLOCK) 
									LEFT JOIN  ['+@NombreServer+'].['+@NombreBd+'].sys.database_principals b WITH ( NOLOCK) 
									ON a.principal_id = b.principal_id  
									Where b.is_fixed_role =' + Convert(Char(1),@IdObjSys )
						2.0 ET FIN*/

						--2.0 ET INICIO
						Insert Into #TabSQL
						Select 
   						Rtrim(a.name) as Nombre, b.is_fixed_role as RolSys
	   					From sys.schemas a  WITH ( NOLOCK) 
						LEFT JOIN  sys.database_principals b WITH ( NOLOCK) 
						ON a.principal_id = b.principal_id  
						Where b.is_fixed_role =Convert(Char(1),@IdObjSys )
						--2.0 ET FIN
				End

		
			--2.0 ET Insert Into #TabSQL
			--2.0 ET Execute (@QuerySelect)

		/*2.0 ET INICIO
		Set @QuerySelect  = 'Select e.NombreEsquema,''O'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
    						Inner Join ['+@NombreServer+'].[BVN_Seguridad].Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
  							Where be.IdBaseDatos=' + Convert(Char(2),@IdBasedatos) +
     						' INTERSECT
    						Select NombreEsquema,''O''  From #TabSQL'
							2.0 ET FIN*/
							--2.0 ET INICIO
		Insert Into #TabSet(NombreEsquema,Estado)
		Select e.NombreEsquema,'O' From Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
    						Inner Join Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
  							Where be.IdBaseDatos=@IdBasedatos
     						INTERSECT
    						Select NombreEsquema,'O'  From #TabSQL
							--2.0 ET FIN
		--2.0 ET Execute(@QuerySelect)

		/*2.0 ET INICIO
		Set @QuerySelect  = 'Select e.NombreEsquema,''Q'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
							 Inner Join ['+@NombreServer+'].[BVN_Seguridad].Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
							 where  be.IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) +
							' EXCEPT
							Select Rtrim(NombreEsquema),''Q'' From #TabSQL'
		2.0 ET FIN*/

		--2.0 ET INICIO
		Insert Into #TabSet(NombreEsquema,Estado)
		Select e.NombreEsquema,'Q' From Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
							 Inner Join Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
							 where  be.IdBaseDatos=	@IdBasedatos
							 EXCEPT
							Select Rtrim(NombreEsquema),'Q' From #TabSQL
							--2.0 ET FIN
		--2.0 ET Execute(@QuerySelect)

		/*2.0 ET INICIO
		Set @QuerySelect  = 'Select NombreEsquema,''A'' From #TabSQL
					    	EXCEPT
					    	Select e.NombreEsquema,''A'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
					    	Inner Join ['+@NombreServer+'].[BVN_Seguridad].Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
					    	Where be.IdBaseDatos=	' + Convert(Char(2),@IdBasedatos)
		2.0 ET FIN*/

		--2.0 ET INICIO
		Insert Into #TabSet(NombreEsquema,Estado)
		Select NombreEsquema,'A' From #TabSQL
					    	EXCEPT
					    	Select e.NombreEsquema,'A' From Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
					    	Inner Join Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
					    	Where be.IdBaseDatos=	@IdBasedatos
							--2.0 ET FIN
		--2.0 ET Execute(@QuerySelect)

		/*2.0 ET INICIO
		Set @QuerySelect  =  'SELECT  ' +  Convert(Char(2),@IdBaseDatos) + ' as IdBaseDatos,
				    			TabApp.IdEsquema,
				    			Rtrim(ts.NombreEsquema) as NombreEsquema,
				    			TabApp.DescripcionEsquema,
				    			IsNull(TabApp.RegistroActivo,1) as RegistroActivo,
				    			ts.Estado,
								' + Convert(Char(2),@IdServidor) + ' as IdServidor
				    			From #TabSet ts
				    			LEFT Join (Select be.IdEsquema,e.NombreEsquema,e.DescripcionEsquema,be.RegistroActivo
				    				From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
				    				Inner Join ['+@NombreServer+'].[BVN_Seguridad].Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
				    				Where be.IdBaseDatos =' + Convert(Char(2),@IdBasedatos) +') as TabApp
				    				on tabapp.NombreEsquema	=	ts.NombreEsquema
				    				Order by TabApp.IdEsquema '
		Execute(@QuerySelect)
    	2.0 ET FIN*/   	

		--2.0 ET INICIO
		Insert Into @ValoresFinales
		(
		IdBaseDatos
		,IdEsquema
		,NombreEsquema
		,DescripcionEsquema
		,RegistroActivo
		,Estado
		,IdServidor
		)
		SELECT  @IdBaseDatos as IdBaseDatos,
				    			TabApp.IdEsquema,
				    			Rtrim(ts.NombreEsquema) as NombreEsquema,
				    			TabApp.DescripcionEsquema,
				    			IsNull(TabApp.RegistroActivo,1) as RegistroActivo,
				    			ts.Estado,
								7 as IdServidor
				    			From #TabSet ts
				    			LEFT Join (Select be.IdEsquema,e.NombreEsquema,e.DescripcionEsquema,be.RegistroActivo
				    				From Seguridad.BaseDatosEsquema be  WITH ( NOLOCK)
				    				Inner Join Seguridad.Esquema e  WITH ( NOLOCK) on be.IdEsquema=e.IdEsquema
				    				Where be.IdBaseDatos =@IdBasedatos) as TabApp
				    				on tabapp.NombreEsquema	=	ts.NombreEsquema
				    				Order by TabApp.IdEsquema
									
		Select
		IdBaseDatos
		,IdEsquema
		,NombreEsquema
		,DescripcionEsquema
		,RegistroActivo
		,Estado
		,IdServidor
		From @ValoresFinales
		--2.0 ET FIN
		  
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
