/******************************************************************************************
DATOS GENERALES	
*  Descripcion		    :	Historico Alatas , Bajas y Permisos por Aplicaciones perfil y  menu perfil 

PARAMETROS 	
* @CodigoUsuario		: Código del Usuario 
* @IdServidor			: Id del servidor
* @Accion				: Accion 
							0: Baja de Usuario, 
							1:Alta de Usuario, 
							2:Asigna o Modifica  Unidad, 
							3:Asigna Aplicacion y/o Modifica Perfil

* @DocumentoSustento	: Nombre del Documento y/o Sustento


CONTROL DE VERSIÓN
Historial	Autor					Fecha			Descripción
1.0			Hugo chuquitaype		10/02/2020		Versión Inicial
1.1			Walther Rodriguez		27/10/2021		Se utiliza el signo +  para el ultimo registro añadido
1.2			Pedro Torres			26/09/2022		Se cambia varchar(3) por varchar(10)
1.3			Walther Rodriguez		20/01/2023		Se corrige error RETURN
2.0			Edwin Tenorio			18/06/2024		Se comenta @IdServidor
********************************************************************************************/

ALTER procedure SEGURIDAD.usp_Usuario_Historico_Permiso_Insert
(@CodigoUsuario Varchar(20)
--2.0 ET ,@IdServidor tinyint
,@Accion TinyInt
,@DocumentoSustento Varchar(60))
as
BEGIN
SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	
	Declare	 @Return				Int 
	Declare  @nombreLinkedServer	Varchar(100)
	Declare  @nombreServidor		Varchar(100)
	Declare  @idHistoricoPermiso	SMALLINT
	Declare  @QueryInsert			nvarchar(max) 
	Declare	 @SqlUpdate				nvarchar(max) 
	Declare	 @QueryMax				nvarchar(max)
	Declare  @QueryExiste			nvarchar(max) 
	Declare	 @IDMaxUser				INTEGER
	Declare	 @Tb_Existe				Table (Existe TinyInt)

	BEGIN TRY

		set @idHistoricoPermiso = 0

		Select @nombreLinkedServer = IsNull(nombreLinkedServer,'') , @nombreServidor = NombreServidor
			from seguridad.Servidor WITH (NOLOCK) where idServidor = 7 --2.0 ET @idServidor 
			
			if @nombreServidor <> @@SERVERNAME 
				if len(@nombreLinkedServer) > 0 and exists(select 1 from sys.servers  WITH ( NOLOCK)  where name = @nombreLinkedServer)
					set @nombreServidor = @nombreLinkedServer


				--2.0 ET
				Execute Framework.usp_GenerarID  'Seguridad.UsuarioHistoricoPermiso','',@idHistoricoPermiso output 

				If @idHistoricoPermiso > 0
				Begin
					--Ajuste para tomar el codigo del ultimo registo 1.1 WRZ
					If Rtrim(@CodigoUsuario) = '+'
					Begin
						/*2.0 ET INICIO SET  @QueryMAx  =   'Select @IDMaxUser =  MAX  ( CASE    WHEN ISNUMERIC(CodigoUsuario) >0  THEN CodigoUsuario ELSE 0 END )
							FROM ['+@nombreServidor+'].[bvn_seguridad].Seguridad.Usuario WITH ( NOLOCK) '			  

						execute sp_executeSql   @QueryMAx,  N'@IDMaxUser Integer OUTPUT',  @IDMaxUser = @IDMaxUser OUTPUT 2.0 ET FIN*/
						Select @IDMaxUser =  MAX  ( CASE    WHEN ISNUMERIC(CodigoUsuario) >0  THEN CodigoUsuario ELSE 0 END )
							FROM Seguridad.Usuario WITH ( NOLOCK) 

						set  @CodigoUsuario  = @IDMaxUser
					End

					--2.0 ET Set @QueryExiste = 'Select 1 From ['+@nombreServidor+'].[bvn_seguridad].seguridad.UsuarioHistoricoPermiso WITH ( NOLOCK)  Where CodigoUsuario ='''+@CodigoUsuario +''' and idHistoricoPermiso = ' + Rtrim(Convert(VarChar(10),@idHistoricoPermiso)) --PTZ 1.2
	
					Insert Into @Tb_Existe
					Select 1 From seguridad.UsuarioHistoricoPermiso WITH ( NOLOCK)  Where CodigoUsuario =@CodigoUsuario and idHistoricoPermiso = @idHistoricoPermiso

					--2.0 ET Exec (@QueryExiste) --WRZ 1.3
						
					If Not Exists(Select Existe From @Tb_Existe)
					Begin
							/*2.0 ET INICIO Set @QueryInsert	 =  'INSERT INTO ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.UsuarioHistoricoPermiso 
															( CodigoUsuario
															  ,IdHistoricoPermiso
															  ,Accion
															  ,FechaRegistro
															  , NombreDocumento
															  ) 
													values (
															'''+@CodigoUsuario+'''
															,'+convert(varchar(10),@idHistoricoPermiso)+'
															, '+convert(char(1),@Accion)+'
															, getdate()
															,'''+@DocumentoSustento+'''
															 )'

						execute sp_executeSql   @QueryInsert;2.0 ET FIN */

						INSERT INTO Seguridad.UsuarioHistoricoPermiso
															( CodigoUsuario
															  ,IdHistoricoPermiso
															  ,Accion
															  ,FechaRegistro
															  , NombreDocumento
															  ) 
													values (
															@CodigoUsuario
															,@idHistoricoPermiso
															, @Accion
															, getdate()
															,@DocumentoSustento
															 )
					End
				IF @Accion < 2
				BEGIN
					--actualiza cambios sobre fechas  ( FechaAltaUsuario, FechaBajaUsuario, Sustento )
					/*2.0 ET INICIO SET @SqlUpdate='Update  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.usuario 
									SET FechaBajaUsuario = CASE WHEN ' + CONVERT(CHAR(1),@Accion) + ' = 0 THEN getdate() ELSE FechaBajaUsuario  END 
									, FechaAltaUsuario = CASE WHEN ' + CONVERT(CHAR(1),@Accion) + ' = 1 THEN getdate() ELSE FechaAltaUsuario END 
									, DocBajaUsuario = CASE WHEN ' + CONVERT(CHAR(1),@Accion) + ' = 0  THEN '''+ @DocumentoSustento+''' ELSE DocBajaUsuario END 
									, DocAltaUsuario = CASE WHEN ' + CONVERT(CHAR(1),@Accion) + ' = 1  THEN '''+ @DocumentoSustento+''' ELSE DocAltaUsuario END 
									 WHERE CodigoUsuario=''' + @CodigoUsuario + ''''
					EXECUTE sp_executesql  @SqlUpdate;2.0 ET FIN*/
					Update  Seguridad.usuario 
									SET FechaBajaUsuario = CASE WHEN @Accion= 0 THEN getdate() ELSE FechaBajaUsuario  END 
									, FechaAltaUsuario = CASE WHEN @Accion= 1 THEN getdate() ELSE FechaAltaUsuario END 
									, DocBajaUsuario = CASE WHEN @Accion= 0  THEN @DocumentoSustento ELSE DocBajaUsuario END 
									, DocAltaUsuario = CASE WHEN @Accion= 1  THEN @DocumentoSustento ELSE DocAltaUsuario END 
									 WHERE CodigoUsuario= @CodigoUsuario
				END

				IF @Accion > 2 
					---actualizo documento de sustento para permisos de unidad,aplicacion, perfil
				BEGIN
					/*2.0 ET INICIO SET @SqlUpdate='Update  ['+@nombreServidor+'].[BVN_Seguridad].Seguridad.usuario 
							SET 	 DocAccesoUsuario =  '''+ @DocumentoSustento+'''
							WHERE CodigoUsuario=''' + @CodigoUsuario + ''''

					EXECUTE sp_executesql  @SqlUpdate;2.0 ET FIN */
					Update Seguridad.usuario 
					SET 	 DocAccesoUsuario = @DocumentoSustento
					WHERE CodigoUsuario=@CodigoUsuario
				END

			End 

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

	SET LANGUAGE ENGLISH;	
END
