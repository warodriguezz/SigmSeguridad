$PBExportHeader$w_asignacion_usuario_bd.srw
forward
global type w_asignacion_usuario_bd from w_base
end type
type uo_mapear from uo_boton within w_asignacion_usuario_bd
end type
type st_buscar from statictext within w_asignacion_usuario_bd
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_asignacion_usuario_bd
end type
type sle_buscar from singlelineedit within w_asignacion_usuario_bd
end type
type dw_basedatos from uo_dwfiltro within w_asignacion_usuario_bd
end type
end forward

global type w_asignacion_usuario_bd from w_base
integer width = 3301
integer height = 2024
string title = "Asignacion Usuario / Login"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
string icon = "CreateLibrary5!"
boolean clientedge = false
integer ii_modoventana = 3
boolean ib_mostrartitulo = false
boolean ib_ventanaeditable = false
boolean ib_instanciarmenu = false
boolean ib_toolbarmodoconsulta = true
boolean ib_arraydw_proteger = false
uo_mapear uo_mapear
st_buscar st_buscar
dw_filtro_servidor dw_filtro_servidor
sle_buscar sle_buscar
dw_basedatos dw_basedatos
end type
global w_asignacion_usuario_bd w_asignacion_usuario_bd

type variables
String 	is_codigoUsuario		=	''
Integer	ii_idservidor
Integer	ii_idbasedatos
end variables

forward prototypes
public function integer wf_mapear_usuario_bd (string as_codigo_usuario, integer ai_basedatos)
end prototypes

public function integer wf_mapear_usuario_bd (string as_codigo_usuario, integer ai_basedatos);String		ls_Clave
Integer	li_retorno
String		ls_retorno []
String 	ls_Parametros
String 	ls_Error 
Integer	li_ret

li_ret=-1

ls_Parametros = string(ii_idservidor)+","+string(ai_basedatos)+","+ as_codigo_usuario 
li_retorno		= gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_MapearBD ",ls_Parametros,ls_retorno, ls_Error)


if upperbound(ls_retorno)>0 then
	if Integer(ls_retorno[1])=1 then 
		li_ret = 1
		gf_mensaje(gs_Aplicacion, 'Proceso realizado existosamente', '', 1)
	End if 
End if 

//if li_retorno=100 then
//	li_ret=1
//	gf_mensaje(gs_Aplicacion, 'Proceso realizado existosamente', '', 1)
//End if

//if upperbound(ls_retorno)>0 then
//	if Integer(ls_retorno[1])=1 then 
//		li_ret=1
//		gf_mensaje(gs_Aplicacion, 'Proceso realizado existosamente', '', 1)
//	End if 
//End if 


	
Return li_ret




end function

on w_asignacion_usuario_bd.create
int iCurrent
call super::create
this.uo_mapear=create uo_mapear
this.st_buscar=create st_buscar
this.dw_filtro_servidor=create dw_filtro_servidor
this.sle_buscar=create sle_buscar
this.dw_basedatos=create dw_basedatos
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.uo_mapear
this.Control[iCurrent+2]=this.st_buscar
this.Control[iCurrent+3]=this.dw_filtro_servidor
this.Control[iCurrent+4]=this.sle_buscar
this.Control[iCurrent+5]=this.dw_basedatos
end on

on w_asignacion_usuario_bd.destroy
call super::destroy
destroy(this.uo_mapear)
destroy(this.st_buscar)
destroy(this.dw_filtro_servidor)
destroy(this.sle_buscar)
destroy(this.dw_basedatos)
end on

event open;dw_principal.object.datawindow.readonly='Yes'




end event

type st_titulo from w_base`st_titulo within w_asignacion_usuario_bd
integer x = 3342
integer y = 44
integer width = 809
integer height = 96
end type

type st_fondo from w_base`st_fondo within w_asignacion_usuario_bd
integer x = 3392
integer y = 228
integer width = 261
end type

type dw_principal from w_base`dw_principal within w_asignacion_usuario_bd
integer x = 0
integer y = 404
integer width = 3232
integer height = 1484
string title = ""
string dataobject = "dw_asignacion_usuario_bd"
boolean hsplitscroll = true
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_menupopup = false
boolean ib_menufiltrar = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve; if ii_idservidor >  0  and ii_idbasedatos>0  then 
	Return this.retrieve(4,String(ii_idservidor)+","+String(ii_idbasedatos))
end if 

end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;is_codigousuario	=	''

if this.rowcount()<1 then Return

if currentrow>0 and this.rowcount()>0 then  is_codigousuario	=	this.getitemstring(currentrow, 'coduser')
end event

type st_menuruta from w_base`st_menuruta within w_asignacion_usuario_bd
boolean visible = false
integer x = 3438
integer y = 136
integer width = 87
string text = ""
end type

type uo_mapear from uo_boton within w_asignacion_usuario_bd
integer x = 2587
integer y = 20
integer height = 144
integer taborder = 20
boolean bringtotop = true
string is_imagen = "Img\Icono\Actualizar.png"
string is_texto = "Mapear usuario"
end type

on uo_mapear.destroy
call uo_boton::destroy
end on

event ue_postclicked;call super::ue_postclicked;Integer	li_ret
String		ls_nombrebd

if isnull(is_codigoUsuario) or is_codigoUsuario = ""then 
	gf_mensaje(gs_Aplicacion, 'Seleccionar usuario', '', 1)
	return 
end if 

li_ret	=	wf_mapear_usuario_bd(is_codigoUsuario,ii_idbasedatos)
if li_ret <1 then 
	gf_mensaje(gs_Aplicacion, 'Error al ejecutar el proceso de reasignación', '', 3)
	return 
else
	dw_principal.event ue_retrieve( )
End if
end event

type st_buscar from statictext within w_asignacion_usuario_bd
integer x = 59
integer y = 260
integer width = 667
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
long backcolor = 67108864
string text = "Buscar por Codigo :"
alignment alignment = right!
boolean focusrectangle = false
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_asignacion_usuario_bd
integer x = 27
integer y = 24
integer taborder = 40
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible...verifique', '', 3)
	Return -2
Else
	dw_basedatos.event ue_poblardddw('idbasedatos')
End if
end event

type sle_buscar from singlelineedit within w_asignacion_usuario_bd
integer x = 754
integer y = 240
integer width = 1445
integer height = 88
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event modified;String		ls_cadfind
Integer	li_found
String		ls_colsort=''
String		ls_texbus=''

ls_texbus		=	Upper(this.text)
ls_colsort	=	'coduser'
ls_cadfind = "Upper(" + ls_colsort +") LIKE "+ "'" + trim(ls_texbus) + "%'"
li_found = dw_principal.find( ls_cadfind, 1, dw_principal.RoWCount())		
If li_found > 0 Then dw_principal.ScrollToRow(li_found)
end event

type dw_basedatos from uo_dwfiltro within w_asignacion_usuario_bd
integer x = 59
integer y = 116
integer width = 1582
integer height = 108
integer taborder = 30
boolean bringtotop = true
string dataobject = "dwf_basedatos"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;Integer li_null
SetNull(li_null)

This.accepttext( )

ii_idBaseDatos  =  integer(data)

dw_principal.event ue_retrieve( )







end event

event ue_poblardddw;call super::ue_poblardddw;// v  1.1		03/10/2024	Se elimina uso de IDSERVIDOR
Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idbasedatos' 
	//	li_ret = ldwc_child.Retrieve(ii_idservidor) // recuperar las bd 1.1
	//	li_ret = ldwc_child.Retrieve() // recuperar las bd		
		li_ret = ldwc_child.Retrieve(3,'') // recuperar las bd		
End Choose



// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )

end event

event ue_retrieve;call super::ue_retrieve;return 1

end event

