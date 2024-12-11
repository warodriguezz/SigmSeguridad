USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioPerfil_Delete]    Script Date: 19/06/2024 16:50:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Elimina Perfil de los usuarios por aplicación

PARAMETROS 	
* @CodigoUsuario		:	Código de usuario
* @IdAplicacion			:	Id Aplicación
* @IdPerfil				:   Id perfil
* @IdServidor			:	Id servidor


CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		19/02/2020	   Versión Inicial
2.0			Milton Palacios  	    19/06/2024	   Se cambia Query dinámico por SQL equivalente
********************************************************************************************/

ALTER procedure [SEGURIDAD].[usp_UsuarioPerfil_Delete]
      @CodigoUsuario	VARCHAR(20)
      ,@IdAplicacion	SMALLINT
      ,@IdPerfil		SMALLINT
--	  ,@IdServidor		TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY
	/*
	Declare  @nombreLinkedServer		Varchar(50)
	Declare	 @NombreServer				Varchar(50)
	Declare  @Query						nvarchar(max) 
	Declare  @QueryExiste				nvarchar(max)
	Declare	 @Tb_Existe					Table (Existe TinyInt)
		

	if exists (select 1  from tempdb..sysobjects WITH ( NOLOCK)  where name like '#TabSQL%')				   
		drop table ##TabSQL

		CREATE TABLE #TabSQL ( 
		 id				Tinyint Identity(1,1)
		,IdBaseDatos	SMALLINT
		,IdRol			SMALLINT  ) 


	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
			@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
	if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
		Set @NombreServer	=	@nombreLinkedServer

			
	Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioPerfil WITH (NOLOCK) 
						Where CodigoUsuario ='''+@CodigoUsuario +''' AND idAplicacion=' + Convert(Char(2), @IdAplicacion)+' AND IdPerfil= '+ Convert(Char(3), @IdPerfil)

	Insert Into @Tb_Existe
	Exec (@QueryExiste)

		If Exists(Select Existe From @Tb_Existe)
		Begin

			set @Query  = 'DELETE FROM  ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioPerfil 
								Where CodigoUsuario ='''+@CodigoUsuario +''' AND idAplicacion=' + Convert(Char(2), @IdAplicacion)+' AND IdPerfil= '+ Convert(Char(3), @IdPerfil)

			Execute sp_executeSql  @Query

		End
	*/
	--Inicio V.2.0.MP
	Declare  @Query						nvarchar(max) 
	Declare  @QueryExiste				nvarchar(max)
	Declare	 @Tb_Existe					Table (Existe TinyInt)
		

	if exists (select 1  from tempdb..sysobjects WITH ( NOLOCK)  where name like '#TabSQL%')				   
		drop table ##TabSQL

		CREATE TABLE #TabSQL ( 
		 id				Tinyint Identity(1,1)
		,IdBaseDatos	SMALLINT
		,IdRol			SMALLINT  ) 

	Insert Into @Tb_Existe
	Select 1 From Seguridad.UsuarioPerfil WITH (NOLOCK) 
	Where CodigoUsuario = @CodigoUsuario AND idAplicacion= @IdAplicacion  AND IdPerfil= @IdPerfil;

		If Exists(Select Existe From @Tb_Existe)
		Begin
              DELETE FROM  Seguridad.UsuarioPerfil 
			  Where CodigoUsuario = @CodigoUsuario  AND idAplicacion= @IdAplicacion AND IdPerfil= @IdPerfil;

		End
	--fin V.2.0.MP
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
