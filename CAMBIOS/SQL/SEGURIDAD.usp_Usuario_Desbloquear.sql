/******************************************************************************************
DATOS GENERALES	
*  Descripcion		    :	Desbloquear,bloquear  Usuario

PARAMETROS 	
*  @CodigoUsuario		   :	Código de usuario
*  @estadousuariodb		   :	Estado boqueado o desbloqueado DB 
*  @idservidor			   :	Id servidor
*  @Retorno		           :	Variable de Retorno 

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Elmer Malca				02/05/2019	    Versión Inicial
1.1			Hugo Chuquitaype		30/04/2020		Incluir CodigoLogin
1.2			Walther Rodriguez		02/11/2020	    Funcion SEGURIDAD.ufn_UsuarioLogin,devuelve el tipo
2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Desbloquear
        @CodigoUsuario		varchar(20)	  
       ,@estadousuariodb	varchar (20)
	   --2.0 ET ,@idservidor			tinyint 
	   ,@Retorno			Int OUTPUT
AS
BEGIN


	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare @nombreLinkedServer varchar(20) 
	Declare @nombreServidor		varchar(20) 
	Declare @querySqldesbloqueo nvarchar(max)	
	Declare @Return				int =  0
	Declare @SQLString			nvarchar(max)	
	Declare @QuerySetVariable	nvarchar(max)
	Declare @TipoLogin			char(1)
	Declare @CodigoLogin		varchar(20) 

	BEGIN TRY

		select @nombreLinkedServer  = isnull(NombreLinkedServer,'') ,@nombreServidor = NombreServidor
		from seguridad.servidor WITH ( NOLOCK) where IdServidor =7 --2.0 ET @idservidor 
		
		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0  and   exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
		   set @nombreServidor = @nombreLinkedServer

		--ver 1.1 hch Obtener TipoLogin Según CodigoUsuario
		Select @QuerySetVariable= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario) --2.0 ET ,@idServidor)
		--ver 1.2 wrz ufn_UsuarioLogin,devuelve el tipo
		execute sp_executeSql   @QuerySetVariable,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLogin  OUTPUT 
		--ver 1.1 hch




			If @TipoLogin = 'S'   ---ver 1.1 hch--caso Sql
			 Begin
			   if @estadousuariodb = 'B'   --ESTA BLOEQUEADO , DESBLOQUEAR
					Begin					

						SET @SQLString = QUOTENAME(@nombreServidor) + '.[BVN_Seguridad].dbo.sp_executesql N''ALTER LOGIN '+ Quotename(@CodigoLogin)+' WITH CHECK_POLICY = OFF'''; 
					
						EXECUTE sp_executesql  @SQLString;

						SET @SQLString = QUOTENAME(@nombreServidor) + '.[BVN_Seguridad].dbo.sp_executesql N''ALTER LOGIN '+ Quotename(@CodigoLogin)+' WITH CHECK_POLICY = ON'''; 
													     
						EXECUTE sp_executesql  @SQLString;				

						set @Return =  1 			
					End	
			 End
			 If @TipoLogin = 'U' --tipo ActiveDirectory
			  Begin
				set @Return = -1 
			  End		
		
	END TRY

	BEGIN CATCH
		DECLARE	@ErrorSeverity TINYINT
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

	
	 Select @Retorno = @Return
	 Return @Retorno
     
	SET LANGUAGE ENGLISH;
END;
