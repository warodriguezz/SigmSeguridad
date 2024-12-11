/****************************************************************************************** 
DATOS GENERALES    
* Descripcion          :    Eliminar un usuario de basedatosrol
 
PARAMETROS 
     @CodigoUsuario : Codigo de usuario
     @IdBaseDatos   : Id de base datos
     @IdRol         : Id del rol en la base de datos
     @IdServidor    : Id de servidor
 
CONTROL DE VERSION
Historial       Autor					Fecha           Descripción
1.0             Walther Rodriguez		2019-06-20       Versión Inicial
2.0				Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/ 

ALTER procedure SEGURIDAD.usp_UsuarioBaseDatosRol_delete
(
   @CodigoUsuario  VARCHAR(20)
 , @IdBaseDatos    SMALLINT
 , @IdRol          SMALLINT
 --2.0 ET , @IdServidor	   TINYINT
)
 AS  
  BEGIN 
     SET NOCOUNT ON; 
     SET LANGUAGE SPANISH; 
     SET DATEFORMAT MDY; 
 
     BEGIN TRY 

		Declare	 @nombreLinkedServer		Varchar(100)
		Declare	 @NombreServer				Varchar(100)	
		Declare	 @Tb_Existe					Table (Existe TinyInt)
		Declare  @QueryExiste				nvarchar(max) 
		Declare  @Query						nvarchar(max) 
 
		/*2.0 ET INICIO
 		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

		If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers  WITH ( NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

		Set @QueryExiste = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].seguridad.UsuarioBaseDatosRol  WITH ( NOLOCK) Where CodigoUsuario ='''+@CodigoUsuario +''' AND IdBaseDatos=' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
		2.0 ET FIN */

		Insert Into @Tb_Existe
		Select 1 From seguridad.UsuarioBaseDatosRol  WITH ( NOLOCK) Where CodigoUsuario =@CodigoUsuario AND IdBaseDatos= @IdBaseDatos AND IdRol= @IdRol
		--2.0 ET Exec (@QueryExiste)

		If Exists(Select Existe From @Tb_Existe)
		Begin
			/*2.0 ET INICIO
			set @Query  = 'DELETE FROM ['+@NombreServer+'].[BVN_Seguridad].seguridad.UsuarioBaseDatosRol 
							WHERE CodigoUsuario ='''+@CodigoUsuario +''' AND IdBaseDatos=' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
							 
			Execute sp_executeSql  @Query
			2.0 ET FIN*/
			DELETE FROM seguridad.UsuarioBaseDatosRol 
			WHERE CodigoUsuario =@CodigoUsuario AND IdBaseDatos=@IdBaseDatos AND IdRol= @IdRol
		End

     END TRY
 
     BEGIN CATCH 
 
          DECLARE   @ErrorSeverity TINYINT 
                  , @ErrorState   TINYINT 
                  , @MensajeError VARCHAR(4096)
          SELECT  
               @MensajeError  = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState    = ERROR_STATE()
 
          RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState ); 
 
     END CATCH 
 
     SET LANGUAGE ENGLISH;
  END
