/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Listado de usuarios para contingencia

PARAMETROS 	
*	@idServidor		: Id Servidor

CONTROL DE VERSION
Historial		Autor					Fecha			Descripción
1.0			    Walther Rodriguez	    17/06/2020		Versión Inicial
1.1				Walther Rodriguez	    22/07/2022		Usar Int Pb2021
2.0				Edwin Tenorio			19/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_UsuarioContingencia_select
--2.0 ET(@idServidor TINYINT)
as
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	Declare  @nombreLinkedServer varchar(20)
	Declare  @nombreServidor	 varchar(20)
	Declare  @querySelect		 nvarchar(max)		
					
				
	BEGIN TRY
		/*2.0 ET INICIO
		select  @nombreLinkedServer  = isnull(NombreLinkedServer,''),
				@nombreServidor = NombreServidor
		from  Seguridad.Servidor WITH ( NOLOCK) where idServidor = @idServidor

		if @nombreServidor <> @@SERVERNAME and len(@nombreLinkedServer) >  0 and exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreLinkedServer)
			set @nombreServidor = @nombreLinkedServer
		

		-- WRZ 1.1	
		if exists(select 1 from sys.servers WITH ( NOLOCK) where name = @nombreServidor)
		Begin
			set @querySelect = 'select	Convert(int, uc.IdServidor) as IdServidor
										,uc.CodigoUsuario
										,ul.CodigoLogin
										,Rtrim(u.Nombre) + space(1) + u.ApellidoPaterno as Usuario
								from ['+@nombreServidor+'].BVN_SEGURIDAD.SEGURIDAD.UsuarioContingencia uc WITH ( NOLOCK)
								inner join ['+@nombreServidor+'].BVN_SEGURIDAD.SEGURIDAD.Usuario u WITH ( NOLOCK)
									on u.CodigoUsuario = uc.CodigoUsuario
								left join ['+@nombreServidor+'].BVN_SEGURIDAD.Seguridad.UsuarioLogin ul WITH ( NOLOCK)
									on ul.CodigoUsuario = u.CodigoUsuario
									and ul.IdLogin	=	u.LoginActivo'

			execute sp_executeSql  @querySelect
			2.0 ET FIN*/
			Declare @TablaFinal Table
			(
			IdServidor INT
			,CodigoUsuario varchar(20)
			,CodigoLogin varchar(20)
			,Usuario varchar(100)
			)

			Insert Into @TablaFinal
			(
			IdServidor
			,CodigoUsuario
			,CodigoLogin
			,Usuario
			)
			select	Convert(int, uc.IdServidor) as IdServidor
										,uc.CodigoUsuario
										,ul.CodigoLogin
										,Rtrim(u.Nombre) + space(1) + u.ApellidoPaterno as Usuario
								from SEGURIDAD.UsuarioContingencia uc WITH ( NOLOCK)
								inner join BVN_SEGURIDAD.SEGURIDAD.Usuario u WITH ( NOLOCK)
									on u.CodigoUsuario = uc.CodigoUsuario
								left join Seguridad.UsuarioLogin ul WITH ( NOLOCK)
									on ul.CodigoUsuario = u.CodigoUsuario
									and ul.IdLogin	=	u.LoginActivo

			Select
			IdServidor
			,CodigoUsuario
			,CodigoLogin
			,Usuario From @TablaFinal
		--2.0 ET End		 	
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

END
