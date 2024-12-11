USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioUnidad_Insert]    Script Date: 19/06/2024 12:27:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Insertar  registro de unidad por usaurios

PARAMETROS 	
*  @CodigoUsuario		:	Código de Usuario
*  @IdCompania			:	Compañia
*  @IdUnidadNegocio		:	Unidad de negocio
*  @RegistroActivo	    :   Registro activo
*   @IdServidor		    :  Id servidor

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		01/05/2019	   Versión Inicial
1.1			Walther Rodriguez		03/02/2023	   Utilizar transaccion distribuida para linked
2.0		    Milton Palacios  	    19/06/2024	   Se cambia Query dinámico por SQL equivalente
********************************************************************************************/	

ALTER procedure [SEGURIDAD].[usp_UsuarioUnidad_Insert] 
 @CodigoUsuario VARCHAR(20)
,@IdCompania TINYINT
,@IdUnidadNegocio SMALLINT
,@RegistroActivo TINYINT
--,@IdServidor TINYINT
as
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	SET XACT_ABORT ON;

	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare  @QueryExiste				nvarchar(max) 
	Declare  @Query						nvarchar(max) 

	BEGIN DISTRIBUTED TRANSACTION;	--WRZ 1.1

	BEGIN TRY 
	/*		
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

			If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

			
			Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].seguridad.Usuariounidad WITH ( NOLOCK) Where CodigoUsuario ='''+@CodigoUsuario +''' AND IdCompania=' + Convert(Char(2), @IdCompania)+' AND IdUnidadNegocio= '+ Convert(Char(2), @IdUnidadNegocio)

			Insert Into @Tb_Existe
			Exec (@QueryExiste)

			If Not Exists(Select Existe From @Tb_Existe)
			Begin
				
				
				set @Query  = 'INSERT INTO ['+@NombreServer+'].[BVN_Seguridad].seguridad.Usuariounidad (
										 CodigoUsuario
										,IdCompania
										,IdUnidadNegocio
										,RegistroActivo)
								VALUES ( 
										' +	'''' +	@CodigoUsuario    + '''
										,' + Convert(Char(2), @IdCompania) +'
										,' + Convert(Char(2), @IdUnidadNegocio) +'
										,1
										)' 
								 
				Execute sp_executeSql  @Query

			End
				
    */
	--Inicio V.2.0.MP
			Insert Into @Tb_Existe
			Select 1 From seguridad.Usuariounidad WITH ( NOLOCK) Where CodigoUsuario = @CodigoUsuario AND IdCompania= @IdCompania AND IdUnidadNegocio= @IdUnidadNegocio;

			If Not Exists(Select Existe From @Tb_Existe)
			Begin
				             INSERT INTO seguridad.Usuariounidad (
										 CodigoUsuario
										,IdCompania
										,IdUnidadNegocio
										,RegistroActivo)
								VALUES ( 
										 @CodigoUsuario
										,@IdCompania
										,@IdUnidadNegocio
										,1
										);
								 
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
