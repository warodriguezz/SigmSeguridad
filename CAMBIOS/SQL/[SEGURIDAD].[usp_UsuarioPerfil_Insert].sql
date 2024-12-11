USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioPerfil_Insert]    Script Date: 19/06/2024 16:41:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Insertar los perfil de los usuario por aplicación

PARAMETROS 	
* @CodigoUsuario		:	Código de usuario
* @IdAplicacion			:	Id Aplicación
* @IdPerfil				:   Id perfil
* @IdServidor           :   Id de servidor

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Elmer Malca				26/04/2019	   Versión Inicial
1.1			Hugo Chuquitaype		19/02/2020		Eliminar parámetro RegistroActivo	
1.2			Walther Rodriguez		11/08/2022		Eliminar creacion tabla
2.0			Milton Palacios  	    19/06/2024	    Se cambia Query dinámico por SQL equivalente
********************************************************************************************/	

ALTER procedure [SEGURIDAD].[usp_UsuarioPerfil_Insert] 
 	   @CodigoUsuario	varchar(20)
      ,@IdAplicacion	SMALLINT
      ,@IdPerfil		SMALLINT
	 -- ,@IdServidor		TINYINT				
	  ---ver 1.1 hch
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	BEGIN TRY

/*
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)
	Declare  @S_username				Varchar(20)	
	Declare	 @GetDate					Varchar(10)
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare  @QueryExiste				nvarchar(max) 
	Declare  @Query						nvarchar(max) 

	Declare	 @QuerySetVariable			nvarchar(max) 
	Declare   @IdBaseDatos				SMALLINT
	Declare   @IdRol					SMALLINT
	Declare	 @RetTabla					Char(1)

	Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
			@NombreServer		= NombreServidor
	from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

	If @NombreServer<>@@SERVERNAME
	if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  WITH ( NOLOCK) where name = @nombreLinkedServer)
		Set @NombreServer	=	@nombreLinkedServer

	-- 1.2		Eliminar tabla

	Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioPerfil WITH (NOLOCK) 
						Where CodigoUsuario ='''+@CodigoUsuario +''' AND idAplicacion=' + Convert(Char(2), @IdAplicacion)+' AND IdPerfil= '+ Convert(Char(3), @IdPerfil)

	Insert Into @Tb_Existe
	Exec (@QueryExiste)

	If Not Exists(Select Existe From @Tb_Existe)
	Begin

		Select @S_username	= SUSER_SNAME()
		Select @GetDate		= Convert(Char(10),Getdate(),23)

		set @Query  = 'INSERT INTO ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioPerfil (
										 CodigoUsuario
										,IdAplicacion
										,IdPerfil
										,RegistroActivo
										,UsuarioRegistro
										,FechaRegistroUsuarioPerfil)
								VALUES ( 
										' +	'''' +	@CodigoUsuario    + '''
										,' + Convert(Char(2), @IdAplicacion) +'
										,' + Convert(Char(3), @IdPerfil) +'
										,1
										,' + '''' +	@S_username    + '''
										,' + '''' +	@GetDate    + '''
										);' 
					 
		Execute sp_executeSql  @Query	 
 	
	
	END
	*/

--Inicio V.2.0.MP

	Declare  @S_username				Varchar(20)	
	Declare	 @GetDate					Varchar(10)
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare  @QueryExiste				nvarchar(max) 
	Declare  @Query						nvarchar(max) 

	Declare	  @QuerySetVariable			nvarchar(max) 
	Declare   @IdBaseDatos				SMALLINT
	Declare   @IdRol					SMALLINT
	Declare	  @RetTabla					Char(1)

	Insert Into @Tb_Existe
	Select 1 From Seguridad.UsuarioPerfil WITH (NOLOCK) 
	Where CodigoUsuario = @CodigoUsuario AND idAplicacion= @IdAplicacion AND IdPerfil= @IdPerfil;

	If Not Exists(Select Existe From @Tb_Existe)
	Begin

		Select @S_username	= SUSER_SNAME()
		Select @GetDate		= Convert(Char(10),Getdate(),23)
             
			       INSERT INTO      Seguridad.UsuarioPerfil (
									 CodigoUsuario
									,IdAplicacion
									,IdPerfil
									,RegistroActivo
									,UsuarioRegistro
									,FechaRegistroUsuarioPerfil)
					VALUES          ( 
									 @CodigoUsuario
									,@IdAplicacion
									,@IdPerfil
									,1
									,@S_username
									,@GetDate 
										);
	END
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
END
