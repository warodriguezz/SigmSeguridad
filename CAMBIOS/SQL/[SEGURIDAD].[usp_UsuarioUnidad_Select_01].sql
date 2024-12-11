USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioUnidad_Select_01]    Script Date: 19/06/2024 12:15:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de unidades por usuario

PARAMETROS 	
*   @IdServidor         :   IdServidor
*   @CodigoUsuario		:	Codigo de usuario

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    27/03/2019		Versión Inicial
1.1				Walther Rodriguez	    12/08/2021		Convert Int PB2021
2.0				Milton Palacios  	    19/06/2024		Se cambia Query dinámico por SQL equivalente
********************************************************************************************/

ALTER procedure [SEGURIDAD].[usp_UsuarioUnidad_Select_01] 
--@IdServidor TinyInt,
@CodigoUsuario Varchar(20)
as
BEGIN
	SET NOCOUNT ON; 
    SET LANGUAGE SPANISH; 
    SET DATEFORMAT MDY; 

	--Declare  @nombreLinkedServer	Varchar(20)
	--Declare	 @NombreServer			Varchar(50)
	--Declare  @QuerySelect			nvarchar(max) 

	BEGIN TRY
	/*
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer
	
		--1.1	WRZ Convert(Int, S.IdCompania) as IdCompania,
		set @QuerySelect  = 'SELECT 	s.CodigoUsuario,
										Convert(Int, S.IdCompania) as IdCompania,
										S.IdUnidadNegocio,
										Convert(int, S.RegistroActivo) as RegistroActivo,
										U.Abreviatura,
										'+ Rtrim(Convert(Char(2),@IdServidor)) + ' as IdServidor
								FROM ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioUnidad S WITH ( NOLOCK) 
								INNER JOIN ['+@NombreServer+'].[BVN_Seguridad].Maestros.UnidadNegocio U WITH ( NOLOCK)
									ON S.IdCompania			=	U.IdCompania
								AND S.IdUnidadNegocio	=	U.IdUnidadNegocio'
								+ ' Where S.CodigoUsuario ='''+@CodigoUsuario +''''

		execute sp_executeSql  @QuerySelect
		*/
--Inicio V.2.0.MP
		                       SELECT 	s.CodigoUsuario,
										Convert(Int, S.IdCompania) as IdCompania,
										S.IdUnidadNegocio,
										Convert(int, S.RegistroActivo) as RegistroActivo,
										U.Abreviatura,
										0 IdServidor
								FROM    Seguridad.UsuarioUnidad S WITH ( NOLOCK) 
								INNER JOIN Maestros.UnidadNegocio U WITH ( NOLOCK)
									ON S.IdCompania			=	U.IdCompania
								AND S.IdUnidadNegocio	=	U.IdUnidadNegocio
								Where S.CodigoUsuario = @CodigoUsuario 

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

	SET LANGUAGE ENGLISH;
END;
