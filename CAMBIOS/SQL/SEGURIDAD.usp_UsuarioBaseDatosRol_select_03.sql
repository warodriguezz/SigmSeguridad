/****************************************************************************************** 
DATOS GENERALES    
*  Descripcion          :    Insertar un UsuarioBaseDatosRol
 
PARAMETROS   
*  @CodigoUsuario : Codigo de usuario
*  @IdBaseDatos   : Id de base datos
*  @IdEsquema    : Id del Esquema  de la base de datos
*  @IdServidor	  : Id del Servidor
 
CONTROL DE VERSION
Historial       Autor					Fecha           Descripción
1.0             wrodriguez				28/06/2019      Versión Inicial
2.0				Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/ 

ALTER procedure SEGURIDAD.usp_UsuarioBaseDatosRol_select_03
(
   @CodigoUsuario  VARCHAR(20)
 , @IdBaseDatos    SMALLINT
 , @IdEsquema	   SMALLINT
 --2.0 ET, @IdServidor	   TINYINT
		
)
 AS  
  BEGIN 
     SET NOCOUNT ON; 
     SET LANGUAGE SPANISH; 
     SET DATEFORMAT MDY; 

			
	 Declare @nombreLinkedServer	varchar(20)
	 Declare @querySelect			nvarchar(max)
	 Declare @nombreServidor		Varchar(100)
 	
	
       BEGIN
		
			/*2.0 ET INICIO
			 Select @nombreLinkedServer = isnull(nombreLinkedServer,''), 
					@nombreServidor		= NombreServidor
			 from seguridad.Servidor WITH (NOLOCK)
			 where idservidor =@IdServidor

	
			If @nombreServidor <> @@ServerName
				if  exists(select * from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
					Set @nombreServidor	=	@nombreLinkedServer
			
				 
			Set @querySelect  = ' Select 
									  u.CodigoUsuario
									, r.IdBaseDatos
									, r.IdRol 
									, ' + Convert(varchar(2),@IdServidor)+' as idServidor			
									, Case when IsNull(u.CodigoUsuario,'+''''''+') = '+''''''+' then 0 else 1 End Acceso
									, r.NombreRol + '' '' + ''('' + IsNull(r.TipoAcceso,''?'') + '')'' as NombreRol
									, e.IdEsquema
							        , Case when IsNull(e.NombreEsquema,'+''''''+') ='+''''''+' then '+'''ROLES SIN ESQUEMA''' +'else e.NombreEsquema End AS NombreEsquema
									 From ['+ @nombreServidor+'].[BVN_Seguridad].Seguridad.BaseDatosRol r WITH (NOLOCK)
									Left Join ['+ @nombreServidor+'].[BVN_Seguridad].Seguridad.BasedatosEsquemaRol er  WITH (NOLOCK)
											on	er.IdBaseDatos	=	r.IdBaseDatos
											and er.IdRol		=	r.IdRol
									Left Join ['+ @nombreServidor+'].[BVN_Seguridad].Seguridad.Esquema e  WITH (NOLOCK)
											on	er.IdEsquema	=	e.IdEsquema
									Left Join ['+ @nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioBaseDatosRol u  WITH (NOLOCK)
											on	r.IdBaseDatos	=	u.IdBaseDatos
											and  r.IdRol			=	u.IdRol	
											and  u.CodigoUsuario	=	'''+@CodigoUsuario+''' 
										Where r.IdBaseDatos	=	'+convert(varchar(10),@IdBaseDatos)+'
											and Rtrim(Ltrim(NombreRol)) <> ''public''
											and  IsnUll(er.IdEsquema,0)	=	Case when '+ convert(varchar(10), @IdEsquema)+' = 0 then IsNull(er.IdEsquema,0) else ' +convert(varchar(10),@IdEsquema)+' End
											Order by e.NombreEsquema , r.NombreRol'

				
				execute sp_executeSql  @QuerySelect
				2.0 ET FIN */
				Declare @TablaFinal Table
				(
				CodigoUsuario varchar(20)
				,IdBaseDatos int
				,IdRol int
				,idServidor int
				,Acceso int
				,NombreRol varchar(120)
				,IdEsquema int
				,NombreEsquema varchar(50)
				)

				Insert Into @TablaFinal
				(
				CodigoUsuario
				,IdBaseDatos
				,IdRol
				,idServidor
				,Acceso
				,NombreRol
				,IdEsquema
				,NombreEsquema
				)
				Select 
									  u.CodigoUsuario
									, r.IdBaseDatos
									, r.IdRol 
									, 7 as idServidor			
									, Case when IsNull(u.CodigoUsuario,'') = '' then 0 else 1 End Acceso
									, r.NombreRol + ' ' + (IsNull(r.TipoAcceso,'?') ) as NombreRol
									, e.IdEsquema
							        , Case when IsNull(e.NombreEsquema,'') ='' then 'ROLES SIN ESQUEMA' else e.NombreEsquema End AS NombreEsquema
									 From Seguridad.BaseDatosRol r WITH (NOLOCK)
									Left Join Seguridad.BasedatosEsquemaRol er  WITH (NOLOCK)
											on	er.IdBaseDatos	=	r.IdBaseDatos
											and er.IdRol		=	r.IdRol
									Left Join Seguridad.Esquema e  WITH (NOLOCK)
											on	er.IdEsquema	=	e.IdEsquema
									Left Join Seguridad.UsuarioBaseDatosRol u  WITH (NOLOCK)
											on	r.IdBaseDatos	=	u.IdBaseDatos
											and  r.IdRol			=	u.IdRol	
											and  u.CodigoUsuario	= @CodigoUsuario
										Where r.IdBaseDatos	=	@IdBaseDatos
											and Rtrim(Ltrim(NombreRol)) <> 'public'
											and  IsnUll(er.IdEsquema,0)	=	Case when @IdEsquema= 0 then IsNull(er.IdEsquema,0) else @IdEsquema End
											Order by e.NombreEsquema , r.NombreRol

				Select
				CodigoUsuario
				,IdBaseDatos
				,IdRol
				,idServidor
				,Acceso
				,NombreRol
				,IdEsquema
				,NombreEsquema
				From @TablaFinal
        END

     SET LANGUAGE ENGLISH;
  END
