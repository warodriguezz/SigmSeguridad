/******************************************************************************************
DATOS GENERALES	
* Descripcion			   :	Elimina Sesiones de Aplicaciones SQL

PARAMETROS 	
*  @IdServidor				Codigo del servidor

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		03/06/2020	    Versión Inicial
1.1			Walther Rodriguez		27/10/2020		Eliminar sesiones de serviores Linked
													Parametro IdServidor
2.0			Edwin Tenorio			14/06/2024		Se quita @IdServidor
********************************************************************************************/	

ALTER procedure SEGURIDAD.usp_SQL_Eliminacion_Sesiones
  --2.0 ET @IdServidor			TinyInt  --WRZ 1.1	
AS
BEGIN
	SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;

	declare  @sql						varchar(max)
	declare  @spid						int
	declare  @loginame					varchar(100)
	declare  @hostname					varchar(100)
	DECLARE  @user_spid					Integer
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)
	Declare  @QuerySelect				nvarchar(max) 
	Declare  @QueyKill					nvarchar(max) 
	Declare	 @rowcount					Smallint
	Declare	 @Fila						Smallint	
	Declare  @IdApliParametro			Smallint
	Declare  @ValorParametro			Varchar(256)
	Declare  @ListaBlanca				Table (LoginName varchar(30))
	Declare  @ListaBlancaV				Varchar(256)
	Declare  @TabPIDLnk					Table( id Tinyint Identity(1,1)
												,SPID int	)

	BEGIN TRY

		--Lista blanca se controla desde Lima
		SELECT  @IdApliParametro = idaplicacion FROM Seguridad.aplicacion WITH ( NOLOCK)  WHERE ObjetoAplicacion  ='sigm_seguridad'
		
		Select @ValorParametro = valorcadena from Framework.ParametroAplicacion with(nolock)
		where Nombre='ListaBlancaSesiones' and IdAplicacion = @IdApliParametro AND NivelConfiguracion='C'

		--Variable para el dinamico
		--2.0 ET Select @ListaBlancaV = ''''+@ValorParametro+''''
		Select @ListaBlancaV = @ValorParametro
		--2.0 ET Select @ListaBlancaV = REPLACE(@ListaBlancaV, ',', ''',''');


		INSERT INTO @ListaBlanca (LoginName)
		SELECT
		convert(VARCHAR,Framework.ufn_ObtenerValorConcatenado(value,':',1)) FROM Framework.ufn_Split(@ValorParametro,',')
		
		--Obtener nombre servidor
		Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
				@NombreServer		= NombreServidor
		from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  7 --2.0 ET 

		
		If @NombreServer=@@SERVERNAME
		Begin
				DECLARE CurSPID CURSOR FAST_FORWARD
				FOR
					SELECT  des.session_id
					FROM    sys.dm_exec_sessions des WITH ( NOLOCK) 
					LEFT JOIN sys.databases d WITH ( NOLOCK) ON des.database_id = d.database_id
					WHERE   des.session_id <>@@spid 
					and d.name in ('BDOPERACIONES','bvn_seguridad','SIGM') 
					and des.login_name not in (select LoginName From @ListaBlanca)
					and des.login_name Not IN (select Ul.CodigoLogin  from Seguridad.UsuarioContingencia uc WITH (NOLOCK)
																	Left Join Seguridad.UsuarioLogin uL WITH (NOLOCK)
																	on uc.codigousuario = ul.codigousuario
																	Where  uL.estado= 1 );
					
					OPEN CurSPID
					FETCH NEXT FROM CurSPID INTO @user_spid
						WHILE (@@FETCH_STATUS=0)
						BEGIN
						  EXEC('KILL '+@user_spid)
						FETCH NEXT FROM CurSPID INTO @user_spid
						END
					CLOSE CurSPID
					DEALLOCATE CurSPID

					RETURN 1
		End
		Else
		Begin
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH ( NOLOCK)   where name = @nombreLinkedServer) --1.1 WRZ
			begin
				Set @NombreServer	=	@nombreLinkedServer
			
					/*2.0 ET INICIO
					Set @QuerySelect ='SELECT s.spid
					FROM  ['+@NombreServer+'].BVN_SEGURIDAD.sys.sysprocesses s WITH ( NOLOCK) 
					Inner Join ['+@NombreServer+'].BVN_SEGURIDAD.sys.databases d WITH ( NOLOCK) on s.dbid=d.database_id
					WHERE s.spid <> ' + Convert(Char(10),@@spid)   + ' and s.spid> 50
					and d.name in (''BDOPERACIONES'',''bvn_seguridad'',''SIGM'')
					and s.loginame not in (' + @ListaBlancaV +')
					and s.loginame Not IN (select Ul.CodigoLogin  from Seguridad.UsuarioContingencia uc WITH (NOLOCK)
																	Left Join Seguridad.UsuarioLogin uL WITH (NOLOCK)
																	on uc.codigousuario = ul.codigousuario
																	Where  uL.estado= 1 ) '
					2.0 ET FIN*/

				Insert Into @TabPIDLnk
				SELECT s.spid
					FROM  sys.sysprocesses s WITH ( NOLOCK) 
					Inner Join sys.databases d WITH ( NOLOCK) on s.dbid=d.database_id
					WHERE s.spid <> @@spid and s.spid> 50
					and d.name in ('BDOPERACIONES','bvn_seguridad','SIGM')
					and s.loginame not in (@ListaBlancaV )
					and s.loginame Not IN (select Ul.CodigoLogin  from Seguridad.UsuarioContingencia uc WITH (NOLOCK)
																	Left Join Seguridad.UsuarioLogin uL WITH (NOLOCK)
																	on uc.codigousuario = ul.codigousuario
																	Where  uL.estado= 1 )
				--2.0 ET Exec (@QuerySelect)

				Select @rowcount= Count(1) from @TabPIDLnk
			
				Set @Fila = 1
				WHILE @Fila <= @rowcount
				Begin

					Select @spid =  SPID from @TabPIDLnk Where id=@Fila

					Set @QueyKill='EXEC(''KILL ' + Rtrim(Convert(Char(10),@spid))  + ''') AT [' + @NombreServer + ']'   
					
					Execute sp_executeSql @QueyKill

					Set @Fila = @Fila + 1
				End

			end
		End
				
	
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
