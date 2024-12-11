/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de Vistas de base datos del servidor SQL
PARAMETROS 	
*  @IdBaseDatos			Codigo de base datos
*  @IdServidor			Codigo de servidor
			
CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    23/04/2019		Versión Inicial
2.0				Edwin Tenorio			14/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_SQL_BaseDatosVista_Comparar
	@IdBaseDatos	SmallInt
   --2.0 ET ,@IdServidor		TINYINT
AS
BEGIN

	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY
   

	Declare  @NombreBd				Varchar(100)
	--2.0 ET INICIO
	--Declare  @nombreLinkedServer	Varchar(20)
	--Declare	 @NombreServer			Varchar(50)
	--2.0 ET FIN
	Declare  @QuerySelect			nvarchar(max) 
	Declare	 @QuerySetVariable		nvarchar(max)
	Declare	 @IdServidorBd			Tinyint

	if exists (select *  from tempdb..sysobjects where name like '#TabSQL%')				   
		drop table ##TabSQL

	CREATE TABLE #TabSQL ( 
		 id				Tinyint Identity(1,1)
		,NombreVista	Varchar(200))     
 

	if exists (select *  from tempdb..sysobjects where name like '##TabSet%')				   
		drop table ##TabSet

	CREATE TABLE #TabSet ( 
		 id				Tinyint Identity(1,1)
		,NombreVista	Varchar(200)
		,Estado			Char(1))     

	/*2.0 ET INICIO
	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
		@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
		if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK)  where name = @nombreLinkedServer)
			Set @NombreServer	=	@nombreLinkedServer

	Set @QuerySetVariable ='Select @NombreBd	= NombreBd,
							       @IdServidorBd =  idservidor 
								From ['+@NombreServer+'].[BVN_Seguridad].Maestros.BaseDatos  WITH ( NOLOCK)  
								where IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) 
	
	execute sp_executeSql   @QuerySetVariable,  N'@NombreBd Varchar(100) OUTPUT , @IdServidorBd tinyint OUTPUT',  @NombreBd = @NombreBd OUTPUT , @IdServidorBd = @IdServidorBd OUTPUT
	
    Set @QuerySelect  = 'Select Rtrim(s.name)+''.''+Rtrim(ov.name) as Nombre 
						 FROM ['+@NombreServer+'].['+@NombreBd+'].SYS.objects ov  WITH ( NOLOCK) 
						 INNER JOIN ['+@NombreServer+'].['+@NombreBd+'].sys.schemas s WITH ( NOLOCK)   ON s.schema_id = ov.schema_id 
						  Where ov.type = ''V''  '
	
	2.0 ET FIN*/
	Insert Into #TabSQL
	Select Rtrim(s.name)+'.'+Rtrim(ov.name) as Nombre 
						 FROM SYS.objects ov  WITH ( NOLOCK) 
						 INNER JOIN sys.schemas s WITH ( NOLOCK)   ON s.schema_id = ov.schema_id 
						  Where ov.type = 'V'  
    --2.0 ET Execute (@QuerySelect)

 
    --INTERSECT
	/*2.0 ET INICIO 
	Set @QuerySelect  = 'Select Rtrim(r.NombreVista),''O'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosVista r  WITH ( NOLOCK)
						  where  r.IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) +
						' INTERSECT
						  Select Rtrim(NombreVista),''O'' From #TabSQL'
	2.0 ET FIN*/
    Insert Into #TabSet(NombreVista,Estado)
	Select Rtrim(r.NombreVista),'O' From Seguridad.BaseDatosVista r  WITH ( NOLOCK)
						  where  r.IdBaseDatos=	@IdBasedatos
						  INTERSECT
						  Select Rtrim(NombreVista),'O' From #TabSQL
	--2.0 ET Execute(@QuerySelect)

	
    --EXCEPT
  
	/*2.0 ET INICIO
	Set @QuerySelect  = 'Select Rtrim(r.NombreVista),''Q'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosVista r WITH ( NOLOCK)
						where  r.IdBaseDatos=	' + Convert(Char(2),@IdBasedatos) +
					' EXCEPT
						Select Rtrim(NombreVista),''Q'' From #TabSQL'
	2.0 ET FIN*/
    Insert Into #TabSet(NombreVista,Estado)
	Select Rtrim(r.NombreVista),'Q' From Seguridad.BaseDatosVista r WITH ( NOLOCK)
						where  r.IdBaseDatos=	@IdBasedatos
						EXCEPT
						Select Rtrim(NombreVista),'Q' From #TabSQL
	--2.0 ET Execute(@QuerySelect)

	
   -- EXCEPT
   
    /*2.0 ET INICIO
	Set @QuerySelect  = 'Select Rtrim(NombreVista),''A'' From  #TabSQL
					EXCEPT
					 Select Rtrim(r.NombreVista),''A'' From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosVista r WITH ( NOLOCK)
					 where  r.IdBaseDatos=	' + Convert(Char(2),@IdBasedatos)
	2.0 ET FIN*/
	Insert Into #TabSet(NombreVista,Estado)
	Select Rtrim(NombreVista),'A' From  #TabSQL
					EXCEPT
					 Select Rtrim(r.NombreVista),'A' From Seguridad.BaseDatosVista r WITH ( NOLOCK)
					 where  r.IdBaseDatos=	@IdBasedatos
	--2.0 ET Execute(@QuerySelect)

	/*2.0 ET INICIO
	Set @QuerySelect  =  'Select ' +  Convert(Char(2),@IdBaseDatos) + ' as IdBaseDatos,
							TabApp.IdVista,
							Rtrim(ts.NombreVista) as NombreVista,
    						IsNull(TabApp.RegistroActivo,1) as RegistroActivo,
    						ts.Estado,
							' + Convert(Char(2),@IdServidor) + ' as IdServidor
						 From #TabSet ts
						   LEFT Join (Select Rtrim(r.NombreVista) as NombreVista, r.IdVista	, r.RegistroActivo From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.BaseDatosVista r  WITH ( NOLOCK)
    									Where r.IdBaseDatos=' + Convert(Char(2),@IdBasedatos) +') as TabApp
    							on TabApp.NombreVista	=	ts.NombreVista
    					Order by TabApp.IdVista'
	2.0 ET FIN*/
	Declare @SelectFinal Table
	(
	IdBaseDatos INT
	, IdVista INT
	, NombreVista varchar(200)
	, RegistroActivo int
	, Estado char(1)
	, IdServidor int
	)

	Insert Into @SelectFinal
	(
	IdBaseDatos
	, IdVista
	, NombreVista
	, RegistroActivo
	, Estado
	, IdServidor
	)
	Select @IdBaseDatos as IdBaseDatos,
							TabApp.IdVista,
							Rtrim(ts.NombreVista) as NombreVista,
    						IsNull(TabApp.RegistroActivo,1) as RegistroActivo,
    						ts.Estado,
							7 as IdServidor
						 From #TabSet ts
						   LEFT Join (Select Rtrim(r.NombreVista) as NombreVista, r.IdVista	, r.RegistroActivo From Seguridad.BaseDatosVista r  WITH ( NOLOCK)
    									Where r.IdBaseDatos=@IdBasedatos) as TabApp
    							on TabApp.NombreVista	=	ts.NombreVista
    					Order by TabApp.IdVista

	Select
	IdBaseDatos
	, IdVista
	, NombreVista
	, RegistroActivo
	, Estado
	, IdServidor
	From @SelectFinal
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
