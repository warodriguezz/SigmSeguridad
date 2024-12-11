/******************************************************************************************
DATOS GENERALES	
* Descripcion		      :		Regenera clave usuario

PARAMETROS 	
*  @CodigoUsuario		   :	Código de usuario
*  @idServidor			   :	Id servidor
*  @Retorno		           :	Variable de Retorno (1=Regeneracion S OK, 2=Regeneracion U no habilitada, -1 Error)
*
*  LAS CLAVE AUTOGENERADA POR LOGIN CAMBIAR CADA MES, SE ADECUA A LAS POLITICAS DE CUENTAS

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Walther Rodriguez		28/10/2020	   Versión Inicial
2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_RegenerarClave
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
	Declare @CodigoLogin		nvarchar (20)  
	Declare @TipoLogin			varchar(1)

    BEGIN TRY  
	
		

		select @nombreLinkedServer = NombreLinkedServer  ,@nombreServidor = NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)  where idServidor = 7 --2.0 ET @idServidor
		
		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers WITH ( NOLOCK)  where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer

		--ver 1.1 hch
		Select @QuerySetVariable= SEGURIDAD.ufn_UsuarioLogin(@CodigoUsuario) --2.0 ET ,@idServidor)
		execute sp_executeSql   @QuerySetVariable,  N'@CodigoLogin VarChar(20) OUTPUT, @TipoLogin Varchar(1) OUTPUT',  @CodigoLogin = @CodigoLogin  OUTPUT, @TipoLogin = @TipoLogin  OUTPUT 

		
		If @TipoLogin = 'U'   -- AD
			Begin
			set @CodigoLogin = lower(ltrim(rtrim(@CodigoLogin)))
			set @CodigoLogin = SubString(@CodigoLogin,CharIndex('\',@CodigoLogin,1)+1,Len(@CodigoLogin))

			Set @cadenaClave = Rtrim(SEGURIDAD.ufn_ProtegerCadena(Rtrim(@CodigoLogin)+'@cmbsaa'+Convert(NvarChar(2),Month(GetDate())) ,1))
			Set @cadenaClave=@cadenaClave+Char(65+Month(GetDate())) 
	
					
					set @querySqlClave = QUOTENAME(@nombreServidor) + '.[BVN_Seguridad].dbo.sp_executesql N''ALTER LOGIN '+ Quotename(@CodigoLogin)+' WITH  PASSWORD = '''''+@cadenaClave+''''' ,CHECK_EXPIRATION= OFF,CHECK_POLICY = OFF''';      
					execute(@querySqlClave);
				
					set @querySqlClave = QUOTENAME(@nombreServidor) + '.[BVN_Seguridad].dbo.sp_executesql N''ALTER LOGIN '+ Quotename(@CodigoLogin)+' WITH CHECK_EXPIRATION= ON,CHECK_POLICY = ON''';      
					execute (@querySqlClave);

					set @Return =  1 
				End

		If @TipoLogin = 'S' --NO HACE NADA
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
