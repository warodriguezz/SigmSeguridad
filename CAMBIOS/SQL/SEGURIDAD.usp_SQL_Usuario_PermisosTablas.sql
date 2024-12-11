/******************************************************************************************
DATOS GENERALES	
* Descripcion				:	Detalle de Registros Auditados
PARAMETROS 	
* @Parametros				:	Parametros Id Servidor, Codigo Usuario, Nombre de Tabla, Fecha Inicio y Fecha Fin


CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		18/02/2020	   Versión Inicial
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_SQL_Usuario_PermisosTablas
	  @Parametros			VARCHAR(500)	

AS

BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;


	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	--2.0 ET Declare  @IdServidor            TINYINT
	Declare  @Desde					VARCHAR(8)
	Declare  @Hasta					VARCHAR(8)
	Declare  @QuerySelect			nvarchar(max) 
	Declare  @codigousuario			VARCHAR(20)
	Declare  @TablaAuditoria		VARCHAR(100)
	Declare	 @IdApliParametro		TINYINT

	--2.0 ET Select @idServidor			= CONVERT(smallint  ,Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1))
	Select @codigousuario		= Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2)
	Select @TablaAuditoria		= Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,3)
	Select @Desde				=Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,4)
	Select @Hasta				=Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,5)

	SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad'

	BEGIN TRY

		if exists (select 1  from tempdb..sysobjects  WITH ( NOLOCK) where name like '##TabPlt%')				   
		drop table ##TabPlt

		CREATE TABLE #TabPlt ( 
							Contador			tinyint Identity(1,1)
							,Operacion			Varchar(30)
							,Fecha				Datetime
							,IdCompania			Varchar(10)
							,IdUnidadNegocio	Varchar(10)   )


		if exists (select 1  from tempdb..sysobjects  WITH ( NOLOCK) where name like '##TabUp%')				   
		drop table ##TabUp

		CREATE TABLE #TabUp ( 
							Contador			tinyint Identity(1,1)
							,Operacion			Varchar(30)
							,Fecha				Datetime
							,IdAplicacion		Varchar(10)
							,IdPerfil			Varchar(10)   )

		Select @nombreLinkedServer		= IsNull(nombreLinkedServer,'') ,
				@nombreServidor			= NombreServidor
		from seguridad.Servidor WITH (NOLOCK) where idServidor = 7 --2.0 ET 

		if @nombreServidor <> @@SERVERNAME 
			if len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
				set @nombreServidor = @nombreLinkedServer
		
	

		If @TablaAuditoria ='UsuarioUnidad'
			Begin
				Set @QuerySelect  = ' Select  Case  When	Operacion =''I'' Then ''AGREGA''
													When Operacion =''D'' Then ''ELIMINA''
													END,
													Fecha,
													IdCompania , 
													IdUnidadNegocio
								From ( 
								Select   Operacion,  Auditoria, Nombre , Fecha, Valor
								from (
								select 	 ac.Operacion ,
											
										  ad.IdAuditoria Auditoria,  cc.IdColumna Columna, cc.Nombre Nombre , FechaHora as Fecha,
								 case   when ad.ValorAnterior  IS NULL then  ad.ValorPosterior else ad.ValorAnterior   end as Valor
								FROM audit.auditoriacabecera ac WITH ( NOLOCK)
								Inner Join bvn_auditoria.audit.auditoriadetalle ad WITH ( NOLOCK)	
									on (ac.idauditoria = ad.idauditoria  )  
								Inner Join bvn_auditoria.audit.ConfiguracionColumna cc WITH ( NOLOCK)	
									on ( cc.idcolumna = ad.idcolumna and cc.idtabla = ac.idtabla   )
								Inner Join bvn_auditoria.audit.configuraciontabla ct WITH ( NOLOCK)		
									on (ct.IdTabla = cc.IdTabla and ct.idaplicacion = cc.IdAplicacion )
								Where ct.Nombre  = '''+ @TablaAuditoria+'''	and  cc.Nombre in ( ''IdCompania'', ''IdUnidadNegocio'')	
									and cc.Flag= 1 and   cc.idaplicacion= '+ Convert(Char(2), @IdApliParametro)+'	
									and ac.PrimaryKey like ''%CodigoUsuario="'+@codigousuario+'"%'' 
									and convert(VARCHAR(8),ac.FechaHora,112 ) > = ' + convert(VARCHAR(8), @Desde) + 
									' and convert(VARCHAR(8),ac.FechaHora,112 ) < = ' + convert(VARCHAR(8), @Hasta) +'
								) Tabla1
									) d pivot
								 ( max( Valor ) 
								for  Nombre  in (  IdCompania , IdUnidadNegocio  ) )  	piv 	order by Auditoria'


							Insert Into #TabPlt
							Exec (@QuerySelect)
					
							select A.Operacion operacion, a.Fecha, vun.Compañia compania, vun.UnidadNegocio unidadnegocio  from #TabPlt A
							left JOIN [BVN_Seguridad].Maestros.uv_UnidadNegocio  vun  WITH ( NOLOCK)  
											ON vun.IdCompania	= a.Idcompania
											AND vun.IdUnidadNegocio	= a.Idunidadnegocio
				End

		If @TablaAuditoria ='UsuarioPerfil'
			Begin
				Set @QuerySelect  = ' select    Case  When	Operacion =''I'' Then ''AGREGA''
													When Operacion =''D'' Then ''ELIMINA''
													END,
													Fecha,
													IdAplicacion ,
													IdPerfil
								From ( 
								Select   Operacion,  Auditoria, Nombre , Fecha, Valor
								from (
								select 	 ac.Operacion ,ad.IdAuditoria Auditoria,  cc.IdColumna Columna, cc.Nombre Nombre , FechaHora as Fecha,
								 case   when ad.ValorAnterior  IS NULL then  ad.ValorPosterior else ad.ValorAnterior   end as Valor
								FROM bvn_auditoria.audit.auditoriacabecera ac WITH ( NOLOCK)
								Inner Join bvn_auditoria.audit.auditoriadetalle ad WITH ( NOLOCK)	
									on (ac.idauditoria = ad.idauditoria  )  
								Inner Join bvn_auditoria.audit.ConfiguracionColumna cc WITH ( NOLOCK)	
									on ( cc.idcolumna = ad.idcolumna and cc.idtabla = ac.idtabla   )
								Inner Join bvn_auditoria.audit.configuraciontabla ct WITH ( NOLOCK)		
									on (ct.IdTabla = cc.IdTabla and ct.idaplicacion = cc.IdAplicacion )
								Where ct.Nombre  = '''+ @TablaAuditoria+'''		
									and cc.Flag= 1 and   cc.idaplicacion= '+ Convert(Char(2), @IdApliParametro)+'	
									and ac.PrimaryKey like ''%CodigoUsuario="'+@codigousuario+'"%'' 
									and convert(VARCHAR(8),ac.FechaHora,112 ) > = ' + convert(VARCHAR(8), @Desde) + 
									' and convert(VARCHAR(8),ac.FechaHora,112 ) < = ' + convert(VARCHAR(8), @Hasta) +'
								) Tabla1
									) d pivot
								 ( max( Valor ) 
								for  Nombre  in (  IdAplicacion , IdPerfil  ) )  	piv 	order by Auditoria'

						
							Insert Into #TabUp
							Exec (@QuerySelect)
					
							select tup.Operacion operacion, tup.Fecha, a.NombreAplicacion, p.NombrePerfil  from #TabUp tup
							 Inner Join Seguridad.Perfil p WITH ( NOLOCK) on (p.idaplicacion = tup.idaplicacion and  
																		p.IdPerfil = tup.IdPerfil )
								Inner Join Seguridad.Aplicacion a WITH ( NOLOCK) on (a.idaplicacion = tup.idaplicacion )

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

	SET LANGUAGE ENGLISH;

	
END;
