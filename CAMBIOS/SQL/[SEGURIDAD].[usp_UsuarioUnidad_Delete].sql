USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioUnidad_Delete]    Script Date: 19/06/2024 12:23:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Elimina de unidades por usuario

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @IdCompania			:	Compañia
*  @IdUnidadNegocio		:	Unidad de negocio
*   @IdServidor         :   IDServidor

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    27/03/2019		Versión Inicial
1.1			    Walther Rodriguez	    13/04/2023		Utilizar transaccion distribuida para linked
2.0				Milton Palacios  	    19/06/2024		Se cambia Query dinámico por SQL equivalente
********************************************************************************************/
ALTER procedure [SEGURIDAD].[usp_UsuarioUnidad_Delete]
			 @CodigoUsuario		VARCHAR(20)
			,@IdCompania		TINYINT
			,@IdUnidadNegocio	SMALLINT
		--	,@IdServidor		TINYINT
AS
BEGIN
	 SET NOCOUNT ON; 
     SET LANGUAGE SPANISH; 
     SET DATEFORMAT MDY; 	 
	 SET XACT_ABORT ON;


	 BEGIN DISTRIBUTED TRANSACTION;	--WRZ 1.1
	 BEGIN TRY 
	 /*
			Declare	 @nombreLinkedServer		Varchar(100)
			Declare	 @NombreServer				Varchar(100)	
			Declare	 @Tb_Existe					Table (Existe TinyInt)
			Declare  @QueryExiste				nvarchar(max) 
			Declare  @Query						nvarchar(max) 

			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

			If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

			Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].seguridad.Usuariounidad WITH ( NOLOCK) Where CodigoUsuario ='''+@CodigoUsuario +''' AND IdCompania=' + Convert(Char(2), @IdCompania)+' AND IdUnidadNegocio= '+ Convert(Char(2), @IdUnidadNegocio)

			Insert Into @Tb_Existe
			Exec (@QueryExiste)

			If Exists(Select Existe From @Tb_Existe)
			Begin
				set @Query  = 'DELETE FROM ['+@NombreServer+'].[BVN_Seguridad].seguridad.Usuariounidad 
							   WHERE CodigoUsuario ='''+@CodigoUsuario +''' AND IdCompania=' + Convert(Char(2), @IdCompania)+' AND IdUnidadNegocio= '+ Convert(Char(2), @IdUnidadNegocio)
							 
				Execute sp_executeSql  @Query
			End
		*/
		--Inicio V.2.0.MP
			Declare	 @Tb_Existe					Table (Existe TinyInt)
			Declare  @QueryExiste				nvarchar(max) 
			Declare  @Query						nvarchar(max) 

			Insert Into @Tb_Existe
		    Select 1 From seguridad.Usuariounidad WITH ( NOLOCK) Where CodigoUsuario = @CodigoUsuario AND IdCompania= @IdCompania AND IdUnidadNegocio= @IdUnidadNegocio

			If Exists(Select Existe From @Tb_Existe)
			Begin
			    DELETE FROM Seguridad.Usuariounidad 
				WHERE CodigoUsuario = @CodigoUsuario  AND IdCompania= @IdCompania AND IdUnidadNegocio= @IdUnidadNegocio;					 
			End
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

	COMMIT;
	SET XACT_ABORT OFF;
	SET LANGUAGE ENGLISH;
END;
