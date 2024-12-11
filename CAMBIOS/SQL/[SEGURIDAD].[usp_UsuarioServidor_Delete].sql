USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioServidor_Delete]    Script Date: 19/06/2024 12:57:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Elimina el servidor asociado al usuario

PARAMETROS 	
*  @idServidor			:   Id  servidor
*  @codigoUsuario    	:   Id  código usuario
*  @idservidorReg		:   id  servidor seleccionado

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Elmer Malca				18/06/2019	   Versión Inicial
2.0			Milton Palacios  	    19/06/2024	   Se cambia Query dinámico por SQL equivalente
********************************************************************************************/	

ALTER procedure [SEGURIDAD].[usp_UsuarioServidor_Delete] 
  --  @idServidor tinyint,
    @codigoUsuario varchar(20)
 -- ,@idservidorReg  tinyint
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare @nombreLinkedServer	varchar(20)
	Declare @nombreServidor		varchar(20)
	Declare @queryRowCount		nvarchar(max)
	Declare @rowCount				tinyint		
	Declare @queryDelete		nvarchar(max)
	
	BEGIN TRY 
	/*
		select @nombreLinkedServer = isnull(nombreLinkedServer,'') ,@nombreServidor = NombreServidor
		from Seguridad.Servidor WITH ( NOLOCK) where idServidor = @idservidorReg

		 if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer) 
			set @nombreServidor = @nombreLinkedServer
					 
			set @queryRowCount  =  'SELECT @rowCount = count(idServidor)  
								FROM ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioServidor WITH (NOLOCK) 
								WHERE idServidor = '+convert(varchar(10),@idServidor)+' 
								AND   codigoUsuario = '''+@codigoUsuario+''''

			execute sp_executeSql   @queryRowCount,  N'@rowCount INT OUTPUT',  @rowCount = @rowCount OUTPUT
			 
			if @rowCount =  1
				Begin
					set @queryDelete = ' DELETE ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioServidor 
										WHERE idServidor = '+convert(varchar(10),@idServidor)+' 
										AND   codigoUsuario = '''+@codigoUsuario+''''

					execute sp_executeSql @queryDelete
				End
 
     */

	 --Inicio V.2.0.MP
					 
			  SELECT @rowCount = count(idServidor)  
			  FROM Seguridad.UsuarioServidor WITH (NOLOCK) 
			  WHERE codigoUsuario = @codigoUsuario

			if @rowCount =  1
				Begin
					DELETE Seguridad.UsuarioServidor 
					WHERE  codigoUsuario = @codigoUsuario;
				End
	 --Fin V.2.0.MP
	END TRY

	BEGIN CATCH
		DECLARE  @ErrorSeverity  TINYINT
                ,@ErrorState   TINYINT
                ,@ErrorNumber  INTEGER
                ,@MensajeError VARCHAR(4096) 

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
