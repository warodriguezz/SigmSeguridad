USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioServidor_select]    Script Date: 19/06/2024 12:52:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de servidores asociados al usuario

PARAMETROS 	
*	@idServidor		: Id Servidor
*	@codigoUsuario 		: Código Usuario

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Elmer Malca 		    17/06/2019		Versión Inicial
2.0				Milton Palacios  	    19/06/2024		Se cambia Query dinámico por SQL equivalente
********************************************************************************************/

ALTER procedure [SEGURIDAD].[usp_UsuarioServidor_select]
	--   @idServidor TINYINT,
	   @codigoUsuario varchar(20)

AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @nombreLinkedServer varchar(20)
	Declare  @nombreServidor	 varchar(20)
	Declare  @querySelect		 nvarchar(max)		
					
				
	BEGIN TRY 
	/*
		select  @nombreLinkedServer  = isnull(NombreLinkedServer,''),
				@nombreServidor = NombreServidor
		from  Seguridad.Servidor WITH ( NOLOCK) where idServidor =  @idServidor

		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) >  0 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer
			
			if @codigoUsuario <> '0' 
				Begin
					set @querySelect =  'SELECT  s.idServidor
													,s.nombreServidor
													,us.codigoUsuario
													,'+Cast(@idServidor as varchar(2))+ ' as idservidorReg
											from  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.Servidor as s WITH ( NOLOCK)
											inner join  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioServidor as us WITH ( NOLOCK) on  s.idServidor = us.idServidor
											where codigoUsuario ='''+@codigoUsuario+''''

					execute sp_executeSql  @querySelect
				End 
			else 
				Begin
					set @querySelect = 'select  idServidor
												,nombreServidor
												,convert(varchar(20),null) as codigoUsuario
												,'+Cast(@idServidor as varchar(2))+' as idservidorReg
										from ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.Servidor WITH ( NOLOCK)'

					execute sp_executeSql  @querySelect
				End 
		*/
	--Inicio V.2.0.MP
			
			if @codigoUsuario <> '0' 
				Begin
				                           SELECT  s.idServidor
													,s.nombreServidor
													,us.codigoUsuario
													,0 as idservidorReg
											from    Seguridad.Servidor as s WITH ( NOLOCK)
											inner join  Seguridad.UsuarioServidor as us WITH ( NOLOCK) on  s.idServidor = us.idServidor
											where codigoUsuario = @codigoUsuario


				End 
			else 
				Begin
					                    select  idServidor
												,nombreServidor
												,convert(varchar(20),null) as codigoUsuario
												,0  as idservidorReg
										from     Seguridad.Servidor WITH ( NOLOCK)

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

	SET LANGUAGE ENGLISH

END;
