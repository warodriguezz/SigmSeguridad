/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Asigna la Fecha de Acceso, se dispara desde Framework

PARAMETROS 	
*	@IdServidor		   :	Id del servidor
*   @CodigoUsuario		:	Código del usuario


CONTROL DE VERSION
Historial	Autor						Fecha				Descripción
1.0			Hugo Chuquitaype			14/01/2020			Versión Inicial
1.1			Hugo Chuquitaype			11/06/2020			Obtener CodigoLogin	
1.2			Walther Rodriguez			02/09/2020			No utilizar codigo dinamico para servidor local
2.0			Edwin Tenorio				18/06/2024			Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Fecha_Ultimo_Acceso
		--2.0 ET @IdServidor			TinyInt
	   @CodigoUsuario		Varchar(20)
      
AS
   BEGIN
        SET NOCOUNT ON;
        SET LANGUAGE SPANISH;
        SET DATEFORMAT MDY;
        DECLARE @nombreLinkedServer VARCHAR(50);
        DECLARE @NombreServer VARCHAR(50);
        DECLARE @Query NVARCHAR(MAX);
        DECLARE @QueryExiste NVARCHAR(MAX);
        DECLARE @Tb_Existe TABLE(Existe TINYINT);
		DECLARE	@CodigoLogin VARCHAR(20);
		DECLARE @IdServidor	TinyInt--2.0 ET

        BEGIN TRY

				--ver 1.1 hch
				--Obtener codigo de usuario a partir del login
				Set @CodigoLogin	=	@CodigoUsuario

				Select @CodigoUsuario=us.CodigoUsuario 
					From Seguridad.UsuarioLogin ul  WITH (NOLOCK)
					Inner Join Seguridad.Usuario us  WITH (NOLOCK)
					on us.CodigoUsuario	=	ul.CodigoUsuario
					and us.LoginActivo	=	ul.IdLogin
				where ul.CodigoLogin =	@CodigoLogin
				and ul.Estado=1;    
				--Obtener codigo de usuario a partir del login
				--ver 1.1 hch

            IF @idServidor = 0						--Cuando viene de framework es 0 - framework siempre es LIMA
                BEGIN
                    SET @NombreServer = @@SERVERNAME;
				END;
            ELSE
                BEGIN
                    SELECT @nombreLinkedServer = ISNULL(NombreLinkedServer, ''), 
                           @NombreServer = NombreServidor
                    FROM seguridad.Servidor WITH(NOLOCK)
                    WHERE IdServidor = 7 --2.0 ET @idServidor;

                    IF @NombreServer <> @@SERVERNAME
                       AND LEN(@nombreLinkedServer) > 0
                       AND EXISTS
                    (
                        SELECT 1
                        FROM sys.servers WITH(NOLOCK)
                        WHERE name = @nombreLinkedServer
                    )
                        SET @NombreServer = @nombreLinkedServer;
				END;

            --2.0 ET SET @QueryExiste = 'Select 1 From [' + @NombreServer + '].[BVN_Seguridad].Seguridad.UsuarioLogin  WITH ( NOLOCK) Where CodigoUsuario =''' + @CodigoUsuario + ''' and CodigoLogin =''' + @CodigoLogin + '''';
            INSERT INTO @Tb_Existe
			Select 1 From Seguridad.UsuarioLogin  WITH ( NOLOCK) Where CodigoUsuario =@CodigoUsuario and CodigoLogin =@CodigoLogin
            --2.0 ET EXEC (@QueryExiste);
            IF EXISTS(SELECT Existe FROM @Tb_Existe)
            BEGIN
				-- WRZ 1.2 INI
				IF  @idServidor = 0																
					Update Seguridad.UsuarioLogin
					set  FechaUltimoAcceso			= getdate()
					Where CodigoUsuario =@CodigoUsuario and CodigoLogin =@CodigoLogin;
				ELSE
				Begin
				 	Set @Query  = 'EXEC (''UPDATE [BVN_Seguridad].Seguridad.UsuarioLogin Set FechaUltimoAcceso = getdate() WHERE  CodigoUsuario = '+quotename(@CodigoUsuario)+' and CodigoLogin = '+quotename(@CodigoLogin)+';'') AT [' + @nombreLinkedServer + ']'  
					EXECUTE sp_executeSql @Query;
				End
				-- WRZ 1.2 FIN
			END;	
        END TRY
        BEGIN CATCH
            DECLARE @ErrorSeverity TINYINT, @ErrorState TINYINT, @ErrorNumber INTEGER, @MensajeError VARCHAR(4096);
            SELECT @MensajeError = ERROR_MESSAGE(), 
                   @ErrorSeverity = ERROR_SEVERITY(), 
                   @ErrorState = ERROR_STATE(), 
                   @ErrorNumber = ERROR_NUMBER();
            SELECT @MensajeError, 
                   @ErrorNumber;
            SELECT @MensajeError = Framework.ufn_ObtenerMensajeDuplicidad(@MensajeError, @ErrorNumber);
            RAISERROR(@MensajeError, @ErrorSeverity, @ErrorState);
        END CATCH;
        SET LANGUAGE ENGLISH;
    END;
