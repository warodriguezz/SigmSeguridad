/******************************************************************************************
DATOS GENERALES	
* Descripcion			:	Cambiar el password del usuario

PARAMETROS 	
*   @IdServidor             :   Id servidor (solo se utiliza en modulo de seguridad)
								Para framework SIGM-WEB enviar 0
								
*   @CodigoUsuario			:   Nombre del usuario
*   @Clave      	        :   Clave del usuario
*   @Clave_anterior         :   Clave anterior

CONTROL DE VERSION
Historial	Autor						Fecha				Descripción
1.0			Elmer Malca				    24/06/2019		    Versión Inicial
1.1			Walther Rodriguez			02/09/2020			No utilizar codigo dinamico para servidor local
2.0			Edwin Tenorio				18/06/2024			Se comenta @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_Usuario_CambiarPassword
    --2.0 ET @IdServidor	   tinyint
    @CodigoUsuario    varchar(20)
    ,@Clave            nvarchar(100)
    ,@Clave_anterior   nvarchar(100)

AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;

	Declare @SQLString			nvarchar(500)
	Declare @nombreLinkedServer varchar(20)
	Declare @nombreServidor		varchar(20)
	Declare @queyRowCount		nvarchar(max)
	Declare @rowCount			tinyint
	Declare @queryCambiaClave   nvarchar(max)
	Declare @queryUpdateExpira  nvarchar(max)
	Declare	@S_username			Varchar(30)
	Declare	@GetDate			Varchar(10)
    Declare	@DateAdd			Varchar(10)
	Declare	@IndiLocal			TinyInt
	Declare	@CodigoLogin		Varchar(20)

    BEGIN TRY
        
		SELECT @IndiLocal		= 0
		SELECT @CodigoLogin	= @CodigoUsuario

		SELECT @CodigoUsuario=IsNull(U.CodigoUsuario,'')
			FROM [BVN_seguridad].SEGURIDAD.UsuarioLogin Ul WITH ( NOLOCK)
			INNER JOIN [BVN_seguridad].SEGURIDAD.Usuario U WITH ( NOLOCK)
			ON (UL.codigousuario = U.codigousuario and Ul.IdLogin = u.LoginActivo )
		WHERE Ul.CodigoLogin= @CodigoLogin AND Ul.Estado=1;					

		/*2.0 ET INICIO
		if @IdServidor =  0 --Viene por SEGURIDAD WEB, LIma
			select @IdServidor =  idServidor from  Seguridad.Servidor WITH(NOLOCK) where NombreServidor = @@SERVERNAME
		2.0 ET FIN */

		select @nombreLinkedServer = NombreLinkedServer,@nombreServidor = NombreServidor
		from Seguridad.Servidor WITH(NOLOCK) where idServidor =  7 --2.0 ET @IdServidor

		if @nombreServidor=@@SERVERNAME		-- WRZ 1.1
			Set @IndiLocal=1
		
		 if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select * from sys.servers WITH (NOLOCK)  where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer

		/*2.0 ET INICIO
		set @queyRowCount = 'select @rowCount = count(name) 
								 from ['+@nombreServidor+'].master.sys.sql_logins WITH (NOLOCK) where name = '''+@CodigoLogin+'''' 

			execute sp_executeSql   @queyRowCount,  N'@rowCount tinyint OUTPUT',  @rowCount = @rowCount OUTPUT 
		2.0 ET FIN */

		select @rowCount = count(name) 
								 from master.sys.sql_logins WITH (NOLOCK) where name = @CodigoLogin

		if @rowCount > 0 	
			Begin
		
					Select @S_username	= SUSER_SNAME()
					Select @GetDate		= Convert(Char(10),Getdate(),23)
					Select @DateAdd     = Convert(Char(10),dateadd(d, 90, Getdate()),23)
				
					if @IndiLocal=1	 							-- WRZ 1.1	
					Begin
						UPDATE  Seguridad.Usuario
						SET
							FechaCaducidadCuenta	= @DateAdd
							, UsuarioSistema		= @S_username
							, FechaSistema			= @GetDate
						WHERE CodigoUsuario			= @CodigoUsuario;
					End
					Else
					Begin
						Set @queryUpdateExpira = 'EXEC (''UPDATE [BVN_Seguridad].Seguridad.Usuario Set FechaCaducidadCuenta = ' + @DateAdd + ', UsuarioSistema = '+ @S_username +',  FechaSistema = '+ @GetDate+' WHERE  CodigoUsuario = '+quotename(@CodigoUsuario)+';'') AT [' + @nombreLinkedServer + ']'   ---ver 1.1 hch			
						EXECUTE sp_executeSql  @queryUpdateExpira;
					End

				     SET @queryCambiaClave = 'ALTER LOGIN ' + quotename(@CodigoLogin) + ' WITH PASSWORD = ''' + @Clave + ''' OLD_PASSWORD = ''' + @Clave_anterior + ''''
			 
					 
					EXECUTE sp_executesql  @queryCambiaClave;
			End 
    END TRY
    BEGIN CATCH
        
	    DECLARE @MensajeError varchar(4096)
        DECLARE @ErrorSeverity int
        DECLARE @ErrorState int

        SELECT 
            @MensajeError = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR ( @MensajeError, @ErrorSeverity, @ErrorState );

    END CATCH;
    SET LANGUAGE us_english;
END
