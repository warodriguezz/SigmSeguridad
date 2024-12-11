$PBExportHeader$w_consulta_filtro_seguridad.srw
forward
global type w_consulta_filtro_seguridad from w_base_consulta_filtro_seg
end type
end forward

global type w_consulta_filtro_seguridad from w_base_consulta_filtro_seg
integer height = 2288
end type
global w_consulta_filtro_seguridad w_consulta_filtro_seguridad

type variables
uo_documento     iuo_documento


uo_dsbase 	ids_AuditoriaTabla


uo_transaction		itr_operacioneswf

end variables

on w_consulta_filtro_seguridad.create
int iCurrent
call super::create
end on

on w_consulta_filtro_seguridad.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
end on

event ue_vistaprevia;Return
end event

event open;call super::open;choose case String(istr_preview.entidad)
	case 'AuditoriaUsuarioSeg'

		dw_filtro.modify("estado.visible = 0")
		dw_filtro.modify("t_2.visible = 0")
	case 'UnidadesUsuario'
		dw_servidorusuario.visible = False
	case 'SolicitudesUsuario'
		dw_servidorusuario.visible = False
End Choose
end event

event ue_verauditoria;call super::ue_verauditoria;string ls_codigousuario
string ls_Parametros
Integer li_idservidor
Date  ld_fechainimes
Date  ld_fechafinmes
String ls_tabla
Integer  li_accion
str_response lstr_Response

If dw_principal.ib_menuauditoria = false Then return

li_idservidor	=	dw_servidorusuario.ii_idservidorfiltro
if li_idservidor<1 then Return


if dw_principal.rowcount() = 0 Then Return

	ls_codigousuario			= dw_principal.getitemstring(dw_principal.getrow(),'codigousuario')
	li_accion						= dw_principal.getitemnumber(dw_principal.getrow(),'accion')
	ld_fechainimes  			= dw_filtro.getitemdate(dw_filtro.GetRow() , 'desde')
	ld_fechafinmes  			= dw_filtro.getitemdate(dw_filtro.GetRow() , 'hasta')
	

	If li_accion =  2  Then    ///'UNIDAD' Then
		
		ls_tabla  						='UsuarioUnidad'
		ls_parametros	=	String(li_idservidor)+","+ls_codigousuario+","+ls_tabla+","+String(ld_fechainimes,"yyyymmdd")+","+String(ld_fechafinmes,"yyyymmdd")
		
		ids_AuditoriaTabla=  gf_procedimiento_consultar("Seguridad.usp_SQL_Usuario_PermisosTablas '"+ ls_Parametros+"'", sqlca)
		
		
		lstr_Response.b_usar_datastore		= true
		lstr_Response.ds_datastore 				= ids_AuditoriaTabla
		lstr_Response.s_titulo     				= 'Auditoria Usuario Unidad '   
		lstr_Response.s_titulos_columnas		=  '1:Operación:350,2:Fecha:500,3:Compañía:500,4:Unidad Negocio:600'
		lstr_Response.l_ancho					= 2500
		lstr_Response.l_alto						= 1300
		lstr_Response.b_redim_ventana			= True
	
		OpenWithParm(w_response_mtto,	lstr_Response)
	End If

	If li_accion = 3  Then    ///'PERMISO'
		
		ls_tabla  						='UsuarioPerfil'
			
		ls_parametros	=	String(li_idservidor)+","+ls_codigousuario+","+ls_tabla+","+String(ld_fechainimes,"yyyymmdd")+","+String(ld_fechafinmes,"yyyymmdd")
		
		ids_AuditoriaTabla=  gf_procedimiento_consultar("Seguridad.usp_SQL_Usuario_PermisosTablas '"+ ls_Parametros+"'", sqlca)
		
		
		lstr_Response.b_usar_datastore		= true
		lstr_Response.ds_datastore 				= ids_AuditoriaTabla
		lstr_Response.s_titulo     				= 'Auditoria Usuario Perfil '   
		lstr_Response.s_titulos_columnas		=  '1:Operación:350,2:Fecha:500,3:Aplicación:650,4:Perfil:600'
		lstr_Response.l_ancho					= 2500
		lstr_Response.l_alto						= 1300
		lstr_Response.b_redim_ventana		= True
		
	
		OpenWithParm(w_response_mtto,	lstr_Response)
	End If

end event

event ue_preopen;call super::ue_preopen;Integer li_ret
itr_operacioneswf	= Create uo_transaction
	
if lower(sqlca.database) = "bvn_seguridad" then
	li_ret=gf_conectar_db( itr_operacioneswf, gs_archivoini, 'WorkFlowRol', gs_usuario, gs_clave, 1)
	 if li_ret<>1 then
		Messagebox("Seguridad","Problemas con la conexion de framework" )
	End if
Else
	itr_operacioneswf	=	sqlca
End if

return 1
end event

type st_titulo from w_base_consulta_filtro_seg`st_titulo within w_consulta_filtro_seguridad
integer x = 0
boolean enabled = true
end type

type st_fondo from w_base_consulta_filtro_seg`st_fondo within w_consulta_filtro_seguridad
integer x = 0
end type

type dw_principal from w_base_consulta_filtro_seg`dw_principal within w_consulta_filtro_seguridad
integer x = 46
integer y = 256
integer height = 1872
boolean ib_menuauditoria = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;// 	Version 1.0				23/09/2024			Walther Rodriguez				Se omite idservidor


Integer	li_idservidor
Integer	li_idaplicacion
String		ls_parametros
integer   li_ctd_dias_ultimo_acceso 
Date 		ld_fechainimes, ld_fechafinmes
Integer 	li_estado

li_idservidor	=	dw_servidorusuario.ii_idservidorfiltro
if li_idservidor<1 then Return -1

dw_filtro.accepttext( )


choose case String(istr_preview.entidad)
	case 'Usuarios'
		  This.retrieve(1,li_idservidor)
	case 'UnidadesUsuario'
		this.retrieve( )
	case 'PefilUsuarios'
		
		li_idaplicacion	=	dw_filtro.getitemnumber(dw_filtro.GetRow() , 'idaplicacion')
		if IsNull(li_idaplicacion) or String(li_idaplicacion)='null' then
			li_idaplicacion=0
		End if
		//This.retrieve(li_idservidor,li_idaplicacion)
		This.retrieve(li_idaplicacion)		//Se omite IDSERVIDOR
	case 'OpcionesPerfil'
		
		li_idaplicacion	=	dw_filtro.getitemnumber(dw_filtro.GetRow() , 'idaplicacion')
		if li_idaplicacion=0 then //TODOS
			this.Reset()
			gf_mensaje(gs_Aplicacion, 'Opcion NO valida para este reporte' , '', 3)
		Else
			ls_parametros	= String(li_idservidor)+","+String(li_idaplicacion)
			This.retrieve(4,ls_parametros)
		End if
	case 'OpcionesMenuPerfilUsuario'      //  "Consulta de Opciones de Menú del Perfil por usuario" // Título del reporte
		
		li_idaplicacion	=	dw_filtro.getitemnumber(dw_filtro.GetRow() , 'idaplicacion')
		if IsNull(li_idaplicacion) or String(li_idaplicacion)='null' then
			li_idaplicacion=0
		End if
		SetPointer(Hourglass!)
		This.retrieve(li_idservidor,li_idaplicacion)
		
//	case 'FechaUltimoAcceso'
//	
//		li_ctd_dias_ultimo_acceso	=	dw_filtro.getitemnumber(dw_filtro.GetRow() , 'ctd_dias_ultimo_acceso')
//		
//		if IsNull(li_ctd_dias_ultimo_acceso) or String(li_ctd_dias_ultimo_acceso)='null' then
//			li_ctd_dias_ultimo_acceso= istr_preview.a[1]
//		End if
//
//		ls_parametros	=	String(li_idservidor)+","+String(li_ctd_dias_ultimo_acceso)
//		
//		This.retrieve(1, ls_parametros)
		 
	
case 'AuditoriaUsuarioSeg'
		dw_principal.ib_menuauditoria = true
		dw_principal.ib_menudetalle = true
		
		ld_fechainimes  = dw_filtro.getitemdate(dw_filtro.GetRow() , 'desde')
		ld_fechafinmes  = dw_filtro.getitemdate(dw_filtro.GetRow() , 'hasta')
		
		if IsNull(ld_fechainimes)   then
			ld_fechainimes= date( istr_preview.a[1])
		End if
		
		if IsNull(ld_fechafinmes)  then
			ld_fechafinmes= date( istr_preview.a[2])
		End if
		
	
		ls_parametros	=	String(li_idservidor)+","+String(ld_fechainimes,"yyyymmdd")+","+String(ld_fechafinmes,"yyyymmdd")
				
		 This.retrieve(ls_parametros )
		 
case 'SolicitudesUsuario'
		dw_principal.ib_menuauditoria = true
		dw_principal.ib_menudetalle = true
		
		ld_fechainimes  = dw_filtro.getitemdate(dw_filtro.GetRow() , 'desde')
		ld_fechafinmes  = dw_filtro.getitemdate(dw_filtro.GetRow() , 'hasta')
		
		if IsNull(ld_fechainimes)   then
			ld_fechainimes= date( istr_preview.a[1])
		End if
		
		if IsNull(ld_fechafinmes)  then
			ld_fechafinmes= date( istr_preview.a[2])
		End if
		
		String ls_ini
		String ls_fin
		
		ls_ini	=	String(ld_fechainimes,"yyyymmdd")
		ls_fin	=	String(ld_fechafinmes,"yyyymmdd")
		this.settransobject(itr_operacioneswf)
		 This.retrieve(ls_ini, ls_fin )
	case 'ActiveDirectory'
		 This.retrieve( )		 
		 
	case 'AccesosApp'
		dw_principal.ib_menuauditoria = true
		dw_principal.ib_menudetalle = true
		Integer li_tipo
		
		li_idaplicacion	= dw_filtro.getitemnumber(dw_filtro.GetRow() , 'idaplicacion')
		li_tipo				= dw_filtro.getitemnumber(dw_filtro.GetRow() , 'tipo')
		ld_fechainimes  = dw_filtro.getitemdate(dw_filtro.GetRow() , 'desde')
		ld_fechafinmes  = dw_filtro.getitemdate(dw_filtro.GetRow() , 'hasta')
				
		 This.retrieve(li_tipo, li_idaplicacion,ld_fechainimes,ld_fechafinmes )
End Choose
Return 1

end event

event dw_principal::doubleclicked;call super::doubleclicked;String 	ls_NombreArchivo
string  	ls_Ruta
long		 ll_rpta
string 	ls_Parametros
String 	ls_retorno[]
String 	ls_Error
String 	ls_directorio
String 	ls_codigousuario
String		 ls_tipoaccion
String    ls_usuario
String 	 ls_dominio
String		 ls_clave
Long		 il_Token
String     ls_ParametroWS_LogonUser
String    ls_retorno4[]


CHOOSE CASE dwo.name
	CASE 'nombredocumento'
		
		IF NOT IsValid(iuo_documento) THEN iuo_documento = CREATE uo_documento
		
		ls_Parametros = ",0,0,'RutaArchivoSustento',1"
		ls_Parametros = string(gi_IdAplicacion)+ls_Parametros
		gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",ls_Parametros,ls_retorno, ls_Error)
		
		If UpperBound(ls_retorno)<=0 Then
			  gf_mensaje(gs_Aplicacion, 'No se encontro el parametro ,comuniquese con el Area de Sistemas', '', 3)
			  Return
		End If
		
		ls_directorio = String(ls_retorno[1])
		
//		ls_ParametroWS_LogonUser = string(gi_IdAplicacion)+",0,0,'WS_LogonUser',1"
//		gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",ls_ParametroWS_LogonUser,ls_retorno4, ls_Error)
//		If UpperBound(ls_retorno4)<=0 Then
//			  gf_mensaje(gs_Aplicacion, 'No se encontro el parametro WS_LogonUser ,comuniquese con el Area de Sistemas', '', 3)
//			 RETURN
//		Else
//			  ls_dominio= ls_retorno4[1]
//			  ls_usuario = ls_retorno4[2]
//			  ls_clave     = ls_retorno4[3]
//		End If
		
		
		ls_NombreArchivo 			= dw_principal.getitemstring(getrow(),'nombredocumento')
		ls_codigousuario			= dw_principal.getitemstring(getrow(),'codigousuario')
		ls_tipoaccion				= dw_principal.getitemstring(getrow(),'tipoaccion')
		
		
		ls_Ruta  = ls_directorio +"\"+ ls_codigousuario +"\"+ls_tipoaccion+"\"+ls_NombreArchivo

		//Impersonalizacion
//		il_Token = iuo_documento.uf_Impersonalizar(ls_usuario, ls_dominio, ls_clave)   
//		IF il_Token = 0 THEN  RETURN 
		
		ll_rpta = iuo_documento.uf_abrir_archivo(ls_Ruta)
				
		IF ll_rpta = 2 THEN
			gf_mensaje(gs_Aplicacion, 'No existe archivo en la ruta especificada', '', 3)
//			IF il_Token >0 THEN
//				RevertToSelf()
//				CloseHandle(il_Token)	
//			END IF
//			Return
		END IF
		
END CHOOSE

//IF il_Token >0 THEN
//	RevertToSelf()
//	CloseHandle(il_Token)	
//END IF
	
end event

type st_menuruta from w_base_consulta_filtro_seg`st_menuruta within w_consulta_filtro_seguridad
integer x = 2427
integer y = 40
integer height = 60
end type

type dw_filtro from w_base_consulta_filtro_seg`dw_filtro within w_consulta_filtro_seguridad
integer x = 1509
integer y = 172
integer width = 3447
integer height = 64
end type

event dw_filtro::ue_poblardddw;call super::ue_poblardddw;Integer                     li_ret				//Valor de retorno
Integer					li_filafind			//Para fila del area en requisito
datawindowchild     	ldwc_child		//Para requisito
datawindowchild		ldwc_childAux
String						ls_parametros
Integer					li_idservidor

if Getrow()<1 then Return
If     This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

li_idservidor	=	dw_servidorusuario.ii_idservidorfiltro

Choose case as_columna  
	case 'idaplicacion'
		//li_Ret							= ldwc_Child.Retrieve(li_idservidor)	
	
	li_Ret							= ldwc_Child.Retrieve(2,'')	
		
End Choose

/*     Si el datawindowChild no tiene elementos se inserta un registro en blanco*/
If     li_Ret < 1 Then      ldwc_child.Insertrow( 0 )
 
end event

type uo_visualizar from w_base_consulta_filtro_seg`uo_visualizar within w_consulta_filtro_seguridad
end type

type dw_servidorusuario from w_base_consulta_filtro_seg`dw_servidorusuario within w_consulta_filtro_seguridad
integer y = 156
string title = "none"
end type

event dw_servidorusuario::itemchanged;call super::itemchanged;//Administrar solo los servidores LinKed o el servidor con conexion
if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	dw_principal.reset( )
Else
	dw_principal.event ue_retrieve( )
End if



end event

