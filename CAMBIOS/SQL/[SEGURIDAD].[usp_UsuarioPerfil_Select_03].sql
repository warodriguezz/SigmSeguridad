USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioPerfil_Select_03]    Script Date: 19/06/2024 15:23:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de perfiles de usuario por aplicación

PARAMETROS 	
*	@idServidor				:  Id del servidor
*   @idaplicacion 			:  Id aplicacion
*	@CodigoUsuario			:  Codigo de usuario

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    14/06/2019		Versión Inicial
1.1				Walther Rodriguez	    22/07/2022		Usar Int Pb2021
2.0			    Milton Palacios  	    19/06/2024	    Se cambia Query dinámico por SQL equivalente
********************************************************************************************/

ALTER procedure [SEGURIDAD].[usp_UsuarioPerfil_Select_03] 
--@IdServidor TINYINT,
@idaplicacion TINYINT,
@CodigoUsuario varchar(20)
as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
    
	Declare	 @Str_Idaplicacion		Varchar(2)
	Declare  @nombreLinkedServer	Varchar(50)
	Declare  @NombreServer			Varchar(50)
	Declare  @QuerySelect			nvarchar(max) 

	BEGIN TRY
	/*	
		Select @Str_Idaplicacion	=	Rtrim(Convert(char(2),@idaplicacion))

		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 
		
		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer
		
		--1.1	wrz
		Set @QuerySelect  = 'select convert(varchar(20),''0'')  as CodigoUsuario
									,sp.idperfil
									,sp.idaplicacion
									,sp.NombrePerfil 
									,sp.Clonado
									,0 as RegistroActivo	
									,'+ Rtrim(Convert(Char(2),@IdServidor)) + ' as IdServidor
								from ['+@NombreServer+'].[BVN_Seguridad].Seguridad.perfil as sp WITH(NOLOCK) '
								+ ' where  sp.idaplicacion =' +  @Str_Idaplicacion
								+ ' and sp.idperfil not in  (select sup.idperfil from ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioPerfil as sup WITH(NOLOCK)  where sup.CodigoUsuario = '''+ @CodigoUsuario+''')
								    and sp.EstadoPerfil=''S''
								Union All
									select  sup.CodigoUsuario
										,sp.idperfil
										,sp.idaplicacion
										,sp.NombrePerfil 
										,sp.Clonado
										,Convert(Int, IsNull(sup.RegistroActivo,0)) as RegistroActivo
										,'+ Rtrim(Convert(Char(2),@IdServidor)) + ' as IdServidor
									from ['+@NombreServer+'].[BVN_Seguridad].Seguridad.perfil as sp WITH(NOLOCK) '
								+ ' inner join  ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioPerfil as sup WITH(NOLOCK)  on sp.IdPerfil = sup.IdPerfil 
									where sp.idaplicacion	  = ' + @Str_Idaplicacion + '
										and sup.CodigoUsuario = ''' + @CodigoUsuario + '''
										and sp.EstadoPerfil=''S'' '

		execute sp_executeSql  @QuerySelect
		*/
--Inicio V.2.0.MP
		Select @Str_Idaplicacion	=	Rtrim(Convert(char(2),@idaplicacion))
         
		                        select '0' as CodigoUsuario
									,sp.idperfil
									,sp.idaplicacion
									,sp.NombrePerfil 
									,sp.Clonado
									,0 as RegistroActivo	
									,0 as IdServidor
								from Seguridad.perfil as sp WITH(NOLOCK) 
								   where  sp.idaplicacion =   @Str_Idaplicacion
								   and sp.idperfil not in  (select sup.idperfil from Seguridad.UsuarioPerfil as sup WITH(NOLOCK)  where sup.CodigoUsuario = @CodigoUsuario)
								   and sp.EstadoPerfil='S'
								Union All
							    select  sup.CodigoUsuario
										,sp.idperfil
										,sp.idaplicacion
										,sp.NombrePerfil 
										,sp.Clonado
										, IsNull(sup.RegistroActivo,0) as RegistroActivo
										,0 as IdServidor
								from Seguridad.perfil as sp WITH(NOLOCK) 
								inner join  Seguridad.UsuarioPerfil as sup WITH(NOLOCK)  on sp.IdPerfil = sup.IdPerfil 
								where sp.idaplicacion	  = @Str_Idaplicacion 
									and sup.CodigoUsuario = @CodigoUsuario 
									and sp.EstadoPerfil='S'

--Fin V.2.0.MP
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
