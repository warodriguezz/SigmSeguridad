/******************************************************************************************
DATOS GENERALES	
* Descripcion		      :	Resetear clave usuario

PARAMETROS 	
*  @CodigoUsuario		   :	Código de usuario
*  @idServidor			   :	Id servidor
*  @Retorno		           :	Variable de Retorno (1=Reseteo S OK, 2=Reseteo U no habilitada, -1 Error)

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Elmer Malca				02/05/2019	   Versión Inicial
1.1			Hugo Chuquitaype		30/04/2020     Cambio por  sys.sql_logins  por sys.server_principals
1.2			Walther Rodriguez		29/05/2020	   Devolver 2 para tipo U, resetear por codigo de login
1.3			Walther Rodriguez		02/11/2020	   Funcion SEGURIDAD.ufn_UsuarioLogin,devuelve el tipo
2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Resetearclave
     @CodigoUsuario	varchar(20)	
	--2.0 ET ,@idServidor    tinyint
	,@Retorno	    int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    SET DATEFORMAT MDY;   
	 
	Declare	@cadenaClave		varchar(60)
	Declare	@nombreLinkedServer varchar(20)
	Declare	@nombreServidor		varchar(20)
	Declare @queyRowCount		nvarchar(max)
	declare @rowCount			smallint
	Declare	@querySqlClave		nvarchar(max)
	Declare @QuerySetVariable	nvarchar(max)
	Declare @Return				int =  0
	Declare @CodigoLogin		nvarchar (20)   ---ver 1.1 hch
	Declare @TipoLogin			varchar(1)

    BEGIN TRY  
	
		select @nombreLinkedServer = NombreLinkedServer  ,@nombreServidor = NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)  where idServidor = 7 --2.0 ET @idServidor
		
		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers WITH ( NOLOCK)  where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer

		--ver 1.1 hch
		Select @QuerySetVariable= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario) --2.0 ET ,@idServidor)
		--ver 1.3 wrz ufn_UsuarioLogin,devuelve el tipo
		execute sp_executeSql   @QuerySetVariable,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLogin  OUTPUT 

		--ver 1.1 hch
		/*2.0 ET INICIO set @queyRowCount = 'select @rowCount = count(name) 
								from ['+@nombreServidor+'].master.sys.server_principals WITH ( NOLOCK)
								where name = '''+@CodigoLogin+''' and  type = '''+@TipoLogin+''''    ---ver 1.1 hch

		execute sp_executeSql   @queyRowCount,  N'@rowCount tinyint OUTPUT',  @rowCount = @rowCount OUTPUT 2.0 ET FIN*/

		select @rowCount = count(name) 
								from master.sys.server_principals WITH ( NOLOCK)
								where name = @CodigoLogin and  type = @TipoLogin

		If @TipoLogin = 'S'   ---ver 1.1 hch--caso Sql
			Begin
			set @CodigoLogin = lower(ltrim(rtrim(@CodigoLogin)))
			set @cadenaClave  = Seguridad.ufn_ProtegerCadena (@CodigoLogin,1)
				
			if @rowCount > 0 	
				Begin
				
					set @querySqlClave = QUOTENAME(@nombreServidor) + '.[BVN_Seguridad].dbo.sp_executesql N''ALTER LOGIN '+ Quotename(@CodigoLogin)+' WITH  PASSWORD = '''''+@cadenaClave+''''' ,CHECK_EXPIRATION= OFF,CHECK_POLICY = OFF''';      
					execute(@querySqlClave);
				
					set @querySqlClave = QUOTENAME(@nombreServidor) + '.[BVN_Seguridad].dbo.sp_executesql N''ALTER LOGIN '+ Quotename(@CodigoLogin)+' WITH CHECK_EXPIRATION= ON,CHECK_POLICY = ON''';      
					execute (@querySqlClave);

					set @Return =  1 
				End
			End
		If @TipoLogin = 'U' --tipo ActiveDirectory 1.2 WRZ
			Begin
				set @Return = 2
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

	 Select @Retorno = @Return
	 Return @Retorno
END;
