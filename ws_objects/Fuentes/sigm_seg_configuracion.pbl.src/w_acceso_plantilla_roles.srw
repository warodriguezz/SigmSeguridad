$PBExportHeader$w_acceso_plantilla_roles.srw
forward
global type w_acceso_plantilla_roles from w_base
end type
type dw_aplicacion from uo_dwfiltro within w_acceso_plantilla_roles
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_acceso_plantilla_roles
end type
type tab_user from tab within w_acceso_plantilla_roles
end type
type tabpage_acceso from userobject within tab_user
end type
type dw_basedatos from uo_dwbase within tabpage_acceso
end type
type dw_accesobd from uo_dwbase within tabpage_acceso
end type
type tabpage_acceso from userobject within tab_user
dw_basedatos dw_basedatos
dw_accesobd dw_accesobd
end type
type tab_user from tab within w_acceso_plantilla_roles
tabpage_acceso tabpage_acceso
end type
end forward

global type w_acceso_plantilla_roles from w_base
integer width = 7045
dw_aplicacion dw_aplicacion
dw_filtro_servidor dw_filtro_servidor
tab_user tab_user
end type
global w_acceso_plantilla_roles w_acceso_plantilla_roles

type variables
Integer 	ii_idservidor
Integer	ii_IdAplicacion
Integer		ii_idbasedatos

Long		il_Idperfil=0
Long 		ilHandle
Integer	iiStatePictureIndex
Boolean 	ib_clonar = false
Long		iold_handle
datastore ids_Menus
end variables

forward prototypes
public subroutine uf_pasa_datos (datastore ads_dw, long al_rowcount)
public subroutine uf_pasa_datos_dw (datastore ads_dw, long al_rowcount)
end prototypes

public subroutine uf_pasa_datos (datastore ads_dw, long al_rowcount);
end subroutine

public subroutine uf_pasa_datos_dw (datastore ads_dw, long al_rowcount);
end subroutine

on w_acceso_plantilla_roles.create
int iCurrent
call super::create
this.dw_aplicacion=create dw_aplicacion
this.dw_filtro_servidor=create dw_filtro_servidor
this.tab_user=create tab_user
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_aplicacion
this.Control[iCurrent+2]=this.dw_filtro_servidor
this.Control[iCurrent+3]=this.tab_user
end on

on w_acceso_plantilla_roles.destroy
call super::destroy
destroy(this.dw_aplicacion)
destroy(this.dw_filtro_servidor)
destroy(this.tab_user)
end on

event ue_vistaprevia;Return 
end event

event resize;call super::resize;

SetRedraw(False)

st_fondo.x = BordeVertical
st_fondo.y = BordeHorizontal
st_fondo.width = newwidth - ( BordeVertical * 2 )
st_titulo.x = BordeVertical + 20
st_titulo.y = BordeHorizontal + 15
st_titulo.width = (newwidth - ( BordeVertical * 4 ) )/2 // la mitad del ancho

st_menuruta.width = st_titulo.width
st_menuruta.x = st_fondo.x + st_fondo.width - st_menuruta.width

il_AlturaTitulo = st_fondo.height + BordeHorizontal


If	ib_MostrarTitulo = True Then il_AlturaTitulo = st_fondo.height + BordeHorizontal

dw_filtro_servidor.y = BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x =  BordeVertical



dw_principal.y = BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
dw_principal.x = BordeVertical
dw_principal.width = dw_filtro_servidor.y + dw_filtro_servidor.width
dw_principal.height = newheight - dw_filtro_servidor.y - ( BordeHorizontal * 4 )
//


dw_aplicacion.x 		=   dw_principal.x + dw_principal.width + BordeHorizontal
dw_aplicacion.y 		=   dw_filtro_servidor.y 
//
dw_aplicacion.width 	=    dw_aplicacion.y + dw_aplicacion.width
dw_aplicacion.height  = 	newheight - dw_aplicacion.y - ( BordeHorizontal * 4 )

//
//tab_user.x 		=   dw_principal.x    + dw_principal.width + BordeHorizontal

tab_user.y 		=  dw_principal.y

tab_user.width = newwidth - dw_principal.width - ( BordeVertical * 2 )
tab_user.height =dw_principal.height 

//Dimensionar TAB
gf_resize_tab (tab_user)
	
SetRedraw(True)
end event

event ue_nuevo_pre;call super::ue_nuevo_pre;Return -1
end event

event ue_eliminar_pre;call super::ue_eliminar_pre;Return -1
end event

type st_titulo from w_base`st_titulo within w_acceso_plantilla_roles
boolean visible = true
string text = "Plantilla Perfil Roles"
end type

type st_fondo from w_base`st_fondo within w_acceso_plantilla_roles
end type

type dw_principal from w_base`dw_principal within w_acceso_plantilla_roles
string tag = "<MenuAdicional:N,Aplicar Base:S,Aplicar Roles Perfil:S>"
integer x = 59
integer y = 256
integer width = 1687
integer height = 1640
string dataobject = "dw_perfil"
boolean hscrollbar = true
boolean livescroll = false
boolean ib_actualizar = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

if dw_filtro_servidor.ib_ServerDisponible=False then Return 0
if isnull(ii_IdAplicacion) then  ii_IdAplicacion =  0
//return  retrieve(ii_idservidor, ii_IdAplicacion)
return  retrieve( ii_IdAplicacion)	//1.0



end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;If currentrow>0 Then
	
	il_idPerfil	=	this.getitemnumber(currentrow,'idPerfil')

	tab_user.tabpage_acceso.dw_basedatos.triggerevent("ue_retrieve")
	tab_user.tabpage_acceso.dw_accesobd.triggerevent("ue_retrieve")

End if
end event

event dw_principal::ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;// 1.1	09/09/2024	Se elimina ID Servidor
Integer 			li_fila
Integer	 		li_filasel
Integer 			li_idPerfiCopial
Integer 			li_filanew
String 			ls_nombrePerfil
string				ls_Parametros,ls_Error
String				ls_retorno[]
Integer			 li_retorno
uo_dsbase		luo_ds_query
str_response    lstr_Response


If this.getrow()= 0 then return 


Choose Case as_menutexto
		
	Case 'Aplicar Roles Perfil'
		
		
			if dw_principal.Getrow()  = 0 then return 
			
			//luo_ds_query			= gf_Procedimiento_Consultar(" Seguridad.usp_Perfil_Select_03 " +string(ii_idservidor)+","+string(ii_IdAplicacion)  ,SQLCA) 
			luo_ds_query			= gf_Procedimiento_Consultar(" Seguridad.usp_Perfil_Select_03 " +string(ii_IdAplicacion)  ,SQLCA)   //1.1
			
			if luo_ds_query.rowcount() < 1 then Return
			
			lstr_response.b_usar_datastore		= 	True
			lstr_response.ds_datastore    			= 	luo_ds_query
			lstr_response.s_titulo      				= 	'Listado de Perfil' 
			lstr_response.b_seleccion_multiple	= 	FALSE
			lstr_response.b_mostrar_contador		= 	False
			lstr_response.s_titulos_columnas		=	'3:NombrePerfil'
			lstr_response.b_redim_ventana		= 	True
			lstr_response.l_ancho						= 	1250
			lstr_response.l_alto						= 	1780
				  
			OpenWithParm(w_response_seleccionar,	lstr_Response)
			
			IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return
			IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return
			
			for li_fila= 1 to Integer(upperbound(luo_ds_query.ii_filasseleccionadas[]))
				li_filasel			=	luo_ds_query.ii_filasseleccionadas[li_fila]
				li_idPerfiCopial			=	luo_ds_query.getitemnumber(li_filasel,'Idperfil')
				ls_nombrePerfil =  luo_ds_query.getitemstring(li_filasel,'NombrePerfil')
				
				
					//ls_Parametros = string(ii_IdAplicacion)+","+string(il_Idperfil)+","+string(li_idPerfiCopial)+","+string(ii_idservidor)
					ls_Parametros = string(ii_IdAplicacion)+","+string(il_Idperfil)+","+string(li_idPerfiCopial) //1.1
				    li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_PerfilBaseDatosRol_Copia", ls_Parametros, ls_retorno, ls_Error)

				dw_principal.event ue_retrieve()
		
			Next
				
	
		Case 'Aplicar Base'
		
			if dw_principal.Getrow()  = 0 then return 
	
			//ls_Parametros = string(ii_IdAplicacion)+","+string(il_Idperfil)+","+string(ii_idservidor)
			ls_Parametros = string(ii_IdAplicacion)+","+string(il_Idperfil)	//1.1
			String ls_ret
			ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_PerfilBaseDatosRol_Base ",ls_Parametros)  
			If Integer(ls_ret) = 0 Then 
				gf_mensaje(gs_Aplicacion, 'No se pudo ejecutar el proceso de Perfil Base, revise la configuración ', '', 2)
				Return
			Else
				gf_mensaje(gs_Aplicacion, 'Se realizó la aplicación del Perfil Base', '', 1)
				dw_principal.event ue_retrieve()
			End if
End Choose 
end event

type st_menuruta from w_base`st_menuruta within w_acceso_plantilla_roles
end type

type dw_aplicacion from uo_dwfiltro within w_acceso_plantilla_roles
integer x = 1765
integer y = 124
integer width = 1435
integer height = 84
integer taborder = 30
boolean bringtotop = true
string title = ""
string dataobject = "dwf_aplicacion"
boolean border = false
borderstyle borderstyle = styleshadowbox!
boolean ib_editar = false
end type

event ue_poblardddw;call super::ue_poblardddw;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idaplicacion' 
		//li_ret = ldwc_child.Retrieve(ii_idservidor ) 
		//li_ret = ldwc_child.Retrieve() // Recuepara los parámetros por ambiente	1.0
		li_ret = ldwc_child.Retrieve(2,'') // Recuepara los parámetros por ambiente	1.0
End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )
end event

event itemchanged;call super::itemchanged;This.accepttext( )
ii_IdAplicacion  =  integer(data)
if ii_IdAplicacion > 0 then 
	
//	dw_principal.event ue_retrieve( )
	dw_principal.TriggerEvent("ue_retrieve")
	tab_user.tabpage_acceso.dw_basedatos.triggerevent("ue_retrieve")
	tab_user.tabpage_acceso.dw_accesobd.triggerevent("ue_retrieve")

End if



end event

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_acceso_plantilla_roles
integer x = 69
integer y = 124
integer height = 104
integer taborder = 40
boolean bringtotop = true
string is_nombreserverfiltro = "0"
end type

event itemchanged;call super::itemchanged;Integer				li_null
Integer				li_ret
Datawindowchild	ldc_aplicacion

setnull(li_null)
ii_idservidor	=	ii_idservidorfiltro

dw_principal.reset()
tab_user.tabpage_acceso.dw_basedatos.reset( )
tab_user.tabpage_acceso.dw_accesobd.reset( )

if 	dw_aplicacion.GetChild('idaplicacion',ldc_aplicacion)>0 then
	ldc_aplicacion.reset( )
	dw_aplicacion.setitem(dw_aplicacion.getrow(),'idaplicacion',li_null)
End if
//Administrar solo los servidores LinKed o el servidor con conexion
if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible...verifique', '', 3)
	Return -2
Else
	dw_aplicacion.event ue_poblardddw('idaplicacion')
End if











end event

type tab_user from tab within w_acceso_plantilla_roles
event create ( )
event destroy ( )
integer x = 1769
integer y = 244
integer width = 3259
integer height = 2092
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
boolean boldselectedtext = true
integer selectedtab = 1
tabpage_acceso tabpage_acceso
end type

on tab_user.create
this.tabpage_acceso=create tabpage_acceso
this.Control[]={this.tabpage_acceso}
end on

on tab_user.destroy
destroy(this.tabpage_acceso)
end on

type tabpage_acceso from userobject within tab_user
event create ( )
event destroy ( )
string tag = "RV50"
integer x = 18
integer y = 112
integer width = 3223
integer height = 1964
long backcolor = 67108864
string text = "Base de datos y roles"
long tabtextcolor = 128
string picturename = "CreateForeignKey!"
long picturemaskcolor = 536870912
dw_basedatos dw_basedatos
dw_accesobd dw_accesobd
end type

on tabpage_acceso.create
this.dw_basedatos=create dw_basedatos
this.dw_accesobd=create dw_accesobd
this.Control[]={this.dw_basedatos,&
this.dw_accesobd}
end on

on tabpage_acceso.destroy
destroy(this.dw_basedatos)
destroy(this.dw_accesobd)
end on

type dw_basedatos from uo_dwbase within tabpage_acceso
integer y = 60
integer width = 1435
integer height = 1832
integer taborder = 10
string title = ""
string dataobject = "dw_basedatos"
boolean hscrollbar = true
boolean resizable = true
boolean ib_actualizar = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

event constructor;call super::constructor;//No editable en esta ventana
this.Modify("descripcionbd.TabSequence = 0")
end event

event rowfocuschanged;call super::rowfocuschanged;if currentrow>0 then
	
	if dw_accesobd.uf_cambios_pendientes()=-1 then
			If	MessageBox( 'CONFIRMACIÓN', "Existen cambios sin actualizar. ¿Desea actualizarlos?", Question!, YesNo! ) = 2 Then 
				iw_VentanaPadre.event ue_cancelar() /*	Ejecuta el evento ue_cancelar */
			Else		
				iw_VentanaPadre.event ue_grabar()	/*	Ejecuta el evento ue_grabar */
			End If
	End if
	
	ii_idbasedatos	=	this.getitemnumber(currentrow,'idbasedatos')
	tab_user.tabpage_acceso.dw_accesobd.TriggerEvent("ue_retrieve")
	
	
End if
end event

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

//Return this.retrieve(ii_idservidor)
String		ls_parametros

ls_parametros	=String(ii_idaplicacion)+","+String(il_idperfil)
Return this.retrieve(2,ls_parametros)	//1.0
end event

type dw_accesobd from uo_dwbase within tabpage_acceso
integer x = 1454
integer y = 60
integer width = 1641
integer height = 1832
integer taborder = 10
string title = ""
string dataobject = "dwtv_acceso_perfil_basedatos_rol"
boolean hscrollbar = true
boolean resizable = true
boolean ib_activarfiltros = false
boolean ib_resaltarfila = false
boolean ib_menudetalle = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

//Return this.retrieve( ii_IdAplicacion,il_Idperfil, ii_idbasedatos,0,ii_idservidor)
Return this.retrieve( ii_IdAplicacion,il_Idperfil, ii_idbasedatos,0)	//1.0
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;Return -1
end event

event rowfocuschanged;call super::rowfocuschanged;
	This.Setitem(currentrow,'idaplicacion',ii_IdAplicacion)
	This.Setitem(currentrow,'Idperfil',il_IdPerfil)

end event

