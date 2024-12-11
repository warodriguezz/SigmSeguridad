USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioPerfil_UpdateInsert]    Script Date: 19/06/2024 15:34:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Actualizar acceso perfil
							Se ejecuta como UPDATE E INSERT

PARAMETROS 	
* @CodigoUsuario		:	Código de usuario
* @IdAplicacion			:	Id Aplicación
* @IdPerfil				:   Id perfil
* @RegistroActivo		:   Activo 1 desactivado 0
* @IdServidor			:	Id servidor
 
CONTROL DE VERSION
Historial       Autor					Fecha           Descripción
1.0				Hugo Chuquitaype		19-02-2020		Versión Inicial
1.1				Walther Rodriguez		03/02/2023		Utilizar transaccion distribuida para linked
2.0			    Milton Palacios  	    19/06/2024	    Se cambia Query dinámico por SQL equivalente
********************************************************************************************/ 

ALTER procedure [SEGURIDAD].[usp_UsuarioPerfil_UpdateInsert] 
  @CodigoUsuario VARCHAR(20)
 ,@IdAplicacion SMALLINT
 ,@IdPerfil SMALLINT
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

	BEGIN DISTRIBUTED TRANSACTION;	--WRZ 1.1

	BEGIN TRY 
	/*
			--Obtener datos servidor
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

			If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

			
				Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].seguridad.UsuarioPerfil WITH ( NOLOCK)  
					Where CodigoUsuario ='''+@CodigoUsuario +''' AND idAplicacion=' + Convert(Char(2), @IdAplicacion)+' AND IdPerfil= '+ Convert(Char(3), @IdPerfil)

				Insert Into @Tb_Existe
				Exec (@QueryExiste)

				--RegistroActivo = 1 , sino existe, REGISTRAR
				If @RegistroActivo=1
				Begin
					If Not Exists(Select Existe From @Tb_Existe)
					Execute Seguridad.usp_UsuarioPerfil_insert @CodigoUsuario,@IdAplicacion,@IdPerfil,@IdServidor
				
				End
				--RegistroActivo = 0 , si existe, ELIMINAR
				If @RegistroActivo=0
				Begin
					If Exists(Select Existe From @Tb_Existe)
						Execute Seguridad.usp_UsuarioPerfil_Delete @CodigoUsuario,@IdAplicacion,@IdPerfil,@IdServidor
		
				End
     */
	 --Inicio  V.2.0.MP
				 Insert Into @Tb_Existe
			     Select 1 From seguridad.UsuarioPerfil WITH ( NOLOCK)  
				 Where CodigoUsuario =@CodigoUsuario  AND idAplicacion= @IdAplicacion AND IdPerfil= @IdPerfil;

				--RegistroActivo = 1 , sino existe, REGISTRAR
				If @RegistroActivo=1
				Begin
					If Not Exists(Select Existe From @Tb_Existe)
					Execute Seguridad.usp_UsuarioPerfil_insert @CodigoUsuario,@IdAplicacion,@IdPerfil
				
				End
				--RegistroActivo = 0 , si existe, ELIMINAR
				If @RegistroActivo=0
				Begin
					If Exists(Select Existe From @Tb_Existe)
						Execute Seguridad.usp_UsuarioPerfil_Delete @CodigoUsuario,@IdAplicacion,@IdPerfil
		
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
