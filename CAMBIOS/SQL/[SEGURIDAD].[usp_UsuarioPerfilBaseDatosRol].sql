USE [bvn_seguridad_lima]
GO
/****** Object:  StoredProcedure [SEGURIDAD].[usp_UsuarioPerfilBaseDatosRol]    Script Date: 19/06/2024 15:00:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
DATOS GENERALES	
* Descripcion		    :	Generar Permisos con el nuevo Perfil y Elimina Permisos (Roles por Perfil existente)
							
PARAMETROS 	
*	@IdAplicacion		:   Id de la Aplicacion 
*   @IdPerfilNuevo		:   Id del perfil Nuevo
*   @IdPerfilAnterior	:   Id del perfil anterior
*   @CodigoUsuario		:   Codigo Usuario
*	@IdServidor			:	IdServidor

CONTROL DE VERSIÓN
Historial	Autor					Fecha		   Descripción
1.0			Hugo Chuquitaype		18/11/2019	   Versión Inicial
2.0			Milton Palacios  	    19/06/2024	   Se cambia Query dinámico por SQL equivalente
********************************************************************************************/	

ALTER procedure [SEGURIDAD].[usp_UsuarioPerfilBaseDatosRol]
			  @IdAplicacion			SMALLINT
			 ,@IdPerfilNuevo		SMALLINT
			 ,@IdPerfilAnterior		SMALLINT
			 ,@CodigoUsuario		VARCHAR(20)
			-- ,@IdServidor			TINYINT

			
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE SPANISH;
	SET DATEFORMAT MDY;
	
	Declare	 @nombreLinkedServer		Varchar(100)
	Declare	 @NombreServer				Varchar(100)	
	Declare	 @QuerySetVariable			nvarchar(max)
	Declare	 @Query						nvarchar(max)
	Declare  @QuerySetBD				nvarchar(max)
	declare  @QueryExiste				nvarchar(max)
	Declare  @IdBaseDatos				SMALLINT
	Declare  @IdRol						SMALLINT
	DECLARE  @count						SMALLINT
	DECLARE  @id						SMALLINT
	Declare	 @Tb_Existe					Table (Existe TinyInt)
	Declare	 @Tb_ExBD					Table (Existe TinyInt)
	
	BEGIN TRY 
	/*
			if exists (select *  from tempdb..sysobjects where name like '#TabBd%')				   
				drop table ##TabBd

			CREATE TABLE #TabBd ( 
				 id				Tinyint Identity(1,1)
				,IdBaseDatos	SMALLINT
				,IdROl          SMALLINT   )  


			DECLARE @TabSQL	Table(  id		Tinyint Identity(1,1)
							,IdBaseDatos	SMALLINT
							,IdRol			SMALLINT  ) 
			
			DECLARE @TabSQLNEW	Table(  id		Tinyint Identity(1,1)
										,IdBaseDatos	SMALLINT
										,IdRol			SMALLINT  ) 
	
			--Obtener datos servidor
			Select  @nombreLinkedServer = IsNull(NombreLinkedServer,'') ,
					@NombreServer		= NombreServidor
			from seguridad.Servidor WITH ( NOLOCK)   where IdServidor =  @idServidor 

			If @NombreServer<>@@SERVERNAME
			if Len(@nombreLinkedServer)>1 and exists(select 1 from sys.servers WITH (NOLOCK) where name = @nombreLinkedServer)
				Set @NombreServer	=	@nombreLinkedServer

				--Verficar Existencia
				Set @QuerySetVariable = 'Select 1 From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioBaseDatosRol Ubdr WITH (NOLOCK) 
											Left  join (  SELECT Pbdr.IdBaseDatos, Pbdr.IdROl, Pbdr.IdPerfil from 
												['+@NombreServer+'].[BVN_Seguridad].Seguridad.PerfilBaseDatosRol Pbdr WITH (NOLOCK) 
											Where Pbdr.IdAplicacion = ' + Convert(Char(2), @IdAplicacion)+' 
											)TmpPerfil
											On 		 TmpPerfil.IdBasedatos= Ubdr.idbasedatos 	and TmpPerfil.IdRol= Ubdr.IdROl
											Where   Ubdr.CodigoUsuario ='''+@CodigoUsuario +'''
											AND TmpPerfil.IdPerfil= '+ Convert(Char(3), @IdPerfilAnterior)
				
				Insert Into @Tb_Existe
				Exec (@QuerySetVariable)
				
				If Exists(Select Existe From @Tb_Existe)
					Begin

						---Identificar Permisos que existen a nivel de la bd asignado al usuario con otros perfiles
						Set @QuerySetBD = 'Select ubdr.IdBaseDatos, ubdr.IdRol  From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioBaseDatosRol  Ubdr 
												Inner Join seguridad.PerfilBaseDatosRol Pbdr  
													On Pbdr.IdBaseDatos = Ubdr.IdBaseDatos  and Pbdr.idRol = Ubdr.IdRol   
													Inner Join seguridad.UsuarioPerfil Up 
													On  Up.codigousuario = Ubdr.codigousuario
													   and Up.IdPerfil  =  Pbdr.IdPerfil
													   and Up.RegistroActivo =1  
												where Ubdr.codigousuario ='''+@CodigoUsuario +'''
												and  Pbdr.Idperfil <> '+ Convert(Char(3), @IdPerfilAnterior)
						Insert Into #TabBd
						Execute (@QuerySetBD)

						--Seleccionar permisos del Perfil Anterior 			
						Set @QuerySetVariable = 'Select Ubdr.idBasedatos,Ubdr.IdROl From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.UsuarioBaseDatosRol Ubdr WITH (NOLOCK) 
											Left  join (  SELECT Pbdr.IdBaseDatos, Pbdr.IdROl, Pbdr.IdPerfil from 
												['+@NombreServer+'].[BVN_Seguridad].Seguridad.PerfilBaseDatosRol Pbdr WITH (NOLOCK) 
											Where Pbdr.IdAplicacion = ' + Convert(Char(2), @IdAplicacion)+' 
											)TmpPerfil
											On 		 TmpPerfil.IdBasedatos= Ubdr.idbasedatos 	and TmpPerfil.IdRol= Ubdr.IdROl
											Where   Ubdr.CodigoUsuario ='''+@CodigoUsuario +'''
											AND TmpPerfil.IdPerfil= '+ Convert(Char(3), @IdPerfilAnterior)
						Insert Into @TabSQL
						Execute (@QuerySetVariable)
		
						SELECT @count=COUNT(id) from @TabSQL
						set @id = 1
							WHILE(@count>0 AND @id<=@count)
								BEGIN
									SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol  from @TabSQL WHERE Id=@id
										Set @QueryExiste = 'Select 1 From #TabBd  Where IdBaseDatos =' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
										Insert Into @Tb_ExBD
										Exec (@QueryExiste)
										--identificar el permiso correcto a eliminar
										If  Not Exists(Select Existe From @Tb_ExBD)
										 Begin
										 --Eliminar
											Execute Seguridad.usp_UsuarioBaseDatosRol_UpdateInsert @CodigoUsuario,@IdBaseDatos,@IdRol,@IdServidor,0
										 End
											SELECT  @id=@id+1
											delete from @Tb_ExBD
								END
								---asigno nuevos permisos para el perfil nuevo
								BEGIN
							
									Set @QuerySetVariable ='Select  IdBaseDatos, IdRol
											From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.PerfilBaseDatosRol  WITH ( NOLOCK)  
											WHERE idAplicacion=  '+convert(varchar(3),@idAplicacion)+' and IdPerfil  =  '+convert(varchar(3),@IdPerfilNuevo)

									Insert Into @TabSQLNEW
									Execute (@QuerySetVariable)

									SELECT @count=COUNT(id) from @TabSQLNEW
									set @id = 1
										WHILE(@count>0 AND @id<=@count)
											BEGIN
												SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol  from @TabSQLNEW WHERE Id=@id
												--asigno	
												Execute Seguridad.usp_UsuarioBaseDatosRol_UpdateInsert @CodigoUsuario,@IdBaseDatos,@IdRol,@IdServidor,1
												SELECT  @id=@id+1
											END
								END
					END
					---caso de nuevos permisos
					ELSE
						BEGIN
							Set @QuerySetVariable ='Select  IdBaseDatos, IdRol
								From ['+@NombreServer+'].[BVN_Seguridad].Seguridad.PerfilBaseDatosRol  WITH ( NOLOCK)  
								WHERE idAplicacion=  '+convert(varchar(3),@idAplicacion)+'and IdPerfil  =  '+convert(varchar(3),@IdPerfilNuevo)
							Insert Into @TabSQL
							Execute (@QuerySetVariable)

							SELECT @count=COUNT(id) from @TabSQL
							set @id = 1
								WHILE(@count>0 AND @id<=@count)
									BEGIN
										SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol   
											from @TabSQL WHERE Id=@id
		
												Execute Seguridad.usp_UsuarioBaseDatosRol_UpdateInsert @CodigoUsuario,@IdBaseDatos,@IdRol,@IdServidor,1
										SELECT  @id=@id+1
								END
						END
		*/
--Inicio V.2.0.MP

			if exists (select *  from tempdb..sysobjects where name like '#TabBd%')				   
				drop table ##TabBd

			CREATE TABLE #TabBd ( 
				 id				Tinyint Identity(1,1)
				,IdBaseDatos	SMALLINT
				,IdROl          SMALLINT   )  


			DECLARE @TabSQL	Table(  id		Tinyint Identity(1,1)
							,IdBaseDatos	SMALLINT
							,IdRol			SMALLINT  ) 
			
			DECLARE @TabSQLNEW	Table(  id		Tinyint Identity(1,1)
										,IdBaseDatos	SMALLINT
										,IdRol			SMALLINT  ) 
	
				--Verficar Existencia
				Insert Into @Tb_Existe
				Select 1 From Seguridad.UsuarioBaseDatosRol Ubdr WITH (NOLOCK) 
				 Left  join (SELECT Pbdr.IdBaseDatos, Pbdr.IdROl, Pbdr.IdPerfil from Seguridad.PerfilBaseDatosRol Pbdr WITH (NOLOCK) 
							 Where Pbdr.IdAplicacion = @IdAplicacion)TmpPerfil
				             On TmpPerfil.IdBasedatos= Ubdr.idbasedatos and TmpPerfil.IdRol= Ubdr.IdROl
				Where   Ubdr.CodigoUsuario = @CodigoUsuario
				AND TmpPerfil.IdPerfil= @IdPerfilAnterior;
				
				If Exists(Select Existe From @Tb_Existe)
					Begin

						---Identificar Permisos que existen a nivel de la bd asignado al usuario con otros perfiles
						Insert Into #TabBd
						Select ubdr.IdBaseDatos, ubdr.IdRol From Seguridad.UsuarioBaseDatosRol  Ubdr 
						Inner Join seguridad.PerfilBaseDatosRol Pbdr  
						   On Pbdr.IdBaseDatos = Ubdr.IdBaseDatos  and Pbdr.idRol = Ubdr.IdRol   
						Inner Join seguridad.UsuarioPerfil Up 
						    On  Up.codigousuario = Ubdr.codigousuario
						    and Up.IdPerfil  =  Pbdr.IdPerfil
						    and Up.RegistroActivo =1  
						where Ubdr.codigousuario =  @CodigoUsuario
							  and  Pbdr.Idperfil <> @IdPerfilAnterior

						--Seleccionar permisos del Perfil Anterior 			
						Insert Into @TabSQL
						Select Ubdr.idBasedatos,Ubdr.IdROl From Seguridad.UsuarioBaseDatosRol Ubdr WITH (NOLOCK) 
						Left join (  SELECT Pbdr.IdBaseDatos, Pbdr.IdROl, Pbdr.IdPerfil from Seguridad.PerfilBaseDatosRol Pbdr WITH (NOLOCK) 
										Where Pbdr.IdAplicacion = @IdAplicacion)TmpPerfil
						    On TmpPerfil.IdBasedatos= Ubdr.idbasedatos 	and TmpPerfil.IdRol= Ubdr.IdROl
						Where   Ubdr.CodigoUsuario = @CodigoUsuario
							AND TmpPerfil.IdPerfil= @IdPerfilAnterior;
		
						SELECT @count=COUNT(id) from @TabSQL
						set @id = 1
							WHILE(@count>0 AND @id<=@count)
								BEGIN
									SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol  from @TabSQL WHERE Id=@id
										Set @QueryExiste = 'Select 1 From #TabBd  Where IdBaseDatos =' + Convert(Char(2), @IdBaseDatos)+' AND IdRol= '+ Convert(Char(3), @IdRol)
										Insert Into @Tb_ExBD
										Exec (@QueryExiste)
										--identificar el permiso correcto a eliminar
										If  Not Exists(Select Existe From @Tb_ExBD)
										 Begin
										 --Eliminar
											Execute Seguridad.usp_UsuarioBaseDatosRol_UpdateInsert @CodigoUsuario,@IdBaseDatos,@IdRol,0
										 End
											SELECT  @id=@id+1
											delete from @Tb_ExBD
								END
								---asigno nuevos permisos para el perfil nuevo
								BEGIN
									Insert Into @TabSQLNEW
			                        Select  IdBaseDatos, IdRol
									From Seguridad.PerfilBaseDatosRol  WITH ( NOLOCK)  
									WHERE idAplicacion=  @idAplicacion and IdPerfil  = @IdPerfilNuevo;

									SELECT @count=COUNT(id) from @TabSQLNEW
									set @id = 1
										WHILE(@count>0 AND @id<=@count)
											BEGIN
												SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol  from @TabSQLNEW WHERE Id=@id
												--asigno	
												Execute Seguridad.usp_UsuarioBaseDatosRol_UpdateInsert @CodigoUsuario,@IdBaseDatos,@IdRol,1
												SELECT  @id=@id+1
											END
								END
					END
					---caso de nuevos permisos
					ELSE
						BEGIN
							Insert Into @TabSQL
							Select  IdBaseDatos, IdRol
							From Seguridad.PerfilBaseDatosRol  WITH ( NOLOCK)  
							WHERE idAplicacion= @idAplicacion and IdPerfil = @IdPerfilNuevo;

							SELECT @count=COUNT(id) from @TabSQL
							set @id = 1
								WHILE(@count>0 AND @id<=@count)
									BEGIN
										SELECT @IdBaseDatos= IdBaseDatos,@IdRol = IdRol   
											from @TabSQL WHERE Id=@id
												Execute Seguridad.usp_UsuarioBaseDatosRol_UpdateInsert @CodigoUsuario,@IdBaseDatos,@IdRol,1
										SELECT  @id=@id+1
								END
						END
--Fin V.2.0.MP
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
