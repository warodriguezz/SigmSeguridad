/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Lista de Usuarios con altas, bajas y permisos
PARAMETROS 	
* @Parametros		       :	Parametros Id Servidro, Fecha Inicio y Fecha Fin


CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		10/02/2020	   Versión Inicial
1.1			Hugo Chuquitaype		09/06/2020	   Incluir CodigoLogin
1.2			Walther Rodriguez		10/11/2022	   No utilizar conversion de fecha
2.0			Edwin Tenorio			17/06/2024		Se quita @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_SQL_Usuario_Permisos
	  @Parametros			VARCHAR(500)	
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;


	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	Declare  @IdServidor            TINYINT
	Declare  @Desde					VARCHAR(8)
	Declare  @Hasta					VARCHAR(8)

	Declare  @DesdeDt				DATETIME
	Declare  @HastaDt				DATETIME

	Declare  @QuerySelect			nvarchar(max) 

	--2.0 ET Select @idServidor			= CONVERT(smallint  ,Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,1))
	Select @Desde				=Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,2)
	Select @Hasta				=Framework.ufn_ObtenerValorConcatenado ( @Parametros,',' ,3)

	Select @DesdeDt  = DATEADD(MONTH, DATEDIFF(MONTH, 0,GETDATE()), 0) 
	Select @HastaDt  = GETDATE()

	--2.0 ET IF len(rtrim(isnull(@idServidor,''))) = 0  SELECT @idServidor = 0
	IF len(rtrim(isnull(@Desde,''))) = 0  SELECT @Desde = convert(varchar, @DesdeDt, 112) -- yyyymm/dd  
	IF len(rtrim(isnull(@Hasta,''))) = 0  SELECT @Hasta = convert(varchar, @HastaDt, 112) -- yyyymm/dd  


	BEGIN TRY

		/*2.0 ET INICIO
		If @idServidor=0		
		Begin
			Set @nombreServidor = @@SERVERNAME
		End
		Else
		Begin
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@nombreServidor		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

			If @nombreServidor<>@@SERVERNAME and  Len(@nombreLinkedServer)> 0 and exists(select 1 from sys.servers WITH ( NOLOCK)  where name = @nombreLinkedServer)
				Set @nombreServidor	=	@nombreLinkedServer
		End
		2.0 ET FIN */
		BEGIN
			--ver hch 1.1
			-- 1.2	wrz
			/*2.0 ET INICIO
			Set @QuerySelect  = '	Select UPPER(p.Codigousuario) Codigousuario , 
										UPPER(u.codigologin) CodigoLogin,
										UPPER(U.NombreCompleto) NombreCompleto,  U.Abreviatura,  p.Accion,
									CASE  p.Accion when 0 Then ''BAJA''
									WHEN  1 Then ''ALTA''
									WHEN  2	Then ''MODIFICACION''
									ELSE   ''MODIFICACION''
									END	 Tipoaccion,
									NombreDocumento,
									p.FechaRegistro
									FROM ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioHistoricoPermiso  P 
									WITH ( NOLOCK)  Inner Join ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.uv_usuario  u  WITH ( NOLOCK)
									ON p.Codigousuario = u.codigoUsuario
									WHERE CONVERT(VARCHAR(8),p.FechaRegistro,112 ) > = ' + CONVERT(VARCHAR(8), @Desde) + 
									' AND CONVERT(VARCHAR(8),p.FechaRegistro,112 ) < = ' + CONVERT(VARCHAR(8), @Hasta) 
									+ ' Order By p.FechaRegistro desc '

										execute sp_executeSql  @QuerySelect
		2.0 ET FIN*/
		Declare @TablaFinal Table
		(
		Codigousuario varchar(20)
		,CodigoLogin varchar(50)
		,NombreCompleto nvarchar(304)
		,Abreviatura varchar(30)
		,Accion int
		,Tipoaccion varchar(50)
		,NombreDocumento varchar(60)
		,FechaRegistro datetime
		)

		Insert into @TablaFinal
		(
		Codigousuario
		,CodigoLogin
		,NombreCompleto
		,Abreviatura
		,Accion
		,Tipoaccion
		,NombreDocumento
		,FechaRegistro
		)
		Select UPPER(p.Codigousuario) Codigousuario , 
										UPPER(u.codigologin) CodigoLogin,
										UPPER(U.NombreCompleto) NombreCompleto,  U.Abreviatura, p.Accion,
									CASE  p.Accion when 0 Then 'BAJA'
									WHEN  1 Then 'ALTA'
									WHEN  2	Then 'MODIFICACION'
									ELSE   'MODIFICACION'
									END	 Tipoaccion,
									NombreDocumento,
									p.FechaRegistro
									FROM Seguridad.UsuarioHistoricoPermiso  P 
									WITH ( NOLOCK)  Inner Join Seguridad.uv_usuario  u  WITH ( NOLOCK)
									ON p.Codigousuario = u.codigoUsuario
									WHERE CONVERT(VARCHAR(8),p.FechaRegistro,112 ) > = CONVERT(VARCHAR(8), @Desde)
									AND CONVERT(VARCHAR(8),p.FechaRegistro,112 ) < = CONVERT(VARCHAR(8), @Hasta) 
									Order By p.FechaRegistro desc

			Select
			Codigousuario
			,CodigoLogin
			,NombreCompleto
			,Abreviatura
			,Accion
			,Tipoaccion
			,NombreDocumento
			,FechaRegistro
			From @TablaFinal
		END	

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
