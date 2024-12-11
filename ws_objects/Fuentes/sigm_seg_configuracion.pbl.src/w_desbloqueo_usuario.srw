$PBExportHeader$w_desbloqueo_usuario.srw
forward
global type w_desbloqueo_usuario from w_base
end type
type uo_reset from uo_boton within w_desbloqueo_usuario
end type
type uo_block from uo_boton within w_desbloqueo_usuario
end type
type st_buscar from statictext within w_desbloqueo_usuario
end type
type em_buscar from uo_edm_texto within w_desbloqueo_usuario
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_desbloqueo_usuario
end type
type sle_buscar from singlelineedit within w_desbloqueo_usuario
end type
end forward

global type w_desbloqueo_usuario from w_base
integer width = 3785
integer height = 2024
string title = "Bloqueo / Desbloqueo usuarios"
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
uo_reset uo_reset
uo_block uo_block
st_buscar st_buscar
em_buscar em_buscar
dw_filtro_servidor dw_filtro_servidor
sle_buscar sle_buscar
end type
global w_desbloqueo_usuario w_desbloqueo_usuario

type variables
String  is_codigoUsuario		=	''
string  is_CodigoLogin  = ''
Integer ii_idservidor

end variables

forward prototypes
public function integer uf_cambios_pendientes ()
public function integer uf_bloquear_desbloquear (string as_tipo, string as_codigousuario, string as_codigologin)
public function integer uf_resetear_usuario (string as_codigousuario, string as_codigologin)
end prototypes

public function integer uf_cambios_pendientes ();//dfsdf
return 1
end function

public function integer uf_bloquear_desbloquear (string as_tipo, string as_codigousuario, string as_codigologin);String		ls_Parametros
String 	ls_retorno[]
Integer	li_ret
String		ls_Error 
Integer 	li_retorno=-1

if as_tipo = 'A' then 
		gf_mensaje(gs_Aplicacion, 'NO disponible', '', 1)
		return li_retorno
end if 

//ls_Parametros =  "'"+as_CodigoUsuario+"',"+"'"+as_CodigoLogin+"',"+as_tipo+","+string(ii_idservidor)+","+String(0)
ls_Parametros =  "'"+as_CodigoUsuario+"',"+as_tipo+","+string(ii_idservidor)+","+String(0)
li_ret				= gf_Procedimiento_Ejecutar("Seguridad.usp_Usuario_Desbloquear ",ls_Parametros,ls_retorno, ls_Error)

if upperbound(ls_retorno)>0 then
	if Integer(ls_retorno[1])=1 then
		li_retorno=1
		//Listo para registrar evento
		f_auditoria_usuario( ii_idservidor, as_codigousuario, 'D')
	Elseif Integer(ls_retorno[1])=-1 Then
		gf_mensaje(gs_Aplicacion, 'No se pudo Desbloquear el Usuario', '', 1)
		Return -1		
	End If
End if 



Return li_retorno
end function

public function integer uf_resetear_usuario (string as_codigousuario, string as_codigologin);String ls_Clave
Integer li_retorno
String ls_retorno []
String ls_Parametros
String ls_Error 

//se cambio as_CodigoUsuario por as_codigologin
If gf_mensaje(gs_Aplicacion, 'Esta seguro de  reiniciar la clave de: ' +as_codigologin,'', 4)=2 then
	Return -1
end if 
//


//ls_Parametros =  "'"+as_CodigoUsuario+"','"+as_codigologin+"',"+string(ii_idservidor)+","+String(li_retorno)
ls_Parametros =  "'"+as_CodigoUsuario+"',"+String(li_retorno)
li_retorno	= gf_Procedimiento_Ejecutar("Seguridad.usp_Usuario_Resetearclave",ls_Parametros,ls_retorno, ls_Error)

if upperbound(ls_retorno)>0 then
	if Integer(ls_retorno[1])=1 then 
		gf_mensaje(gs_Aplicacion, 'Clave Reiniciada en Minúscula', '', 1)
		//Listo para registrar evento
		f_auditoria_usuario( ii_idservidor, as_codigousuario, 'R')
	Elseif Integer(ls_retorno[1])=-1 Then
		gf_mensaje(gs_Aplicacion, 'No se pudo Reiniciar la Clave', '', 1)
		Return -1		
	End If

End if 

return  1
end function

on w_desbloqueo_usuario.create
int iCurrent
call super::create
this.uo_reset=create uo_reset
this.uo_block=create uo_block
this.st_buscar=create st_buscar
this.em_buscar=create em_buscar
this.dw_filtro_servidor=create dw_filtro_servidor
this.sle_buscar=create sle_buscar
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.uo_reset
this.Control[iCurrent+2]=this.uo_block
this.Control[iCurrent+3]=this.st_buscar
this.Control[iCurrent+4]=this.em_buscar
this.Control[iCurrent+5]=this.dw_filtro_servidor
this.Control[iCurrent+6]=this.sle_buscar
end on

on w_desbloqueo_usuario.destroy
call super::destroy
destroy(this.uo_reset)
destroy(this.uo_block)
destroy(this.st_buscar)
destroy(this.em_buscar)
destroy(this.dw_filtro_servidor)
destroy(this.sle_buscar)
end on

event open;This.uf_crear_array_dw( )
This.uf_crear_array_ds( )
dw_principal.object.datawindow.readonly='Yes'


// Busqueda
em_buscar.istr_bus.dw_datawin   =	 dw_principal
em_buscar.istr_bus.b_secuencial  = 	TRUE
//hch
//em_buscar.istr_bus.s_columna     =	 'codigousuario' 
em_buscar.istr_bus.s_columna     =	 'codigologin'
em_buscar.istr_bus.s_tipobusca	=	'N'


dw_principal.triggerevent ( 'ue_powerfilter' )




end event

type st_titulo from w_base`st_titulo within w_desbloqueo_usuario
integer x = 3342
integer y = 44
integer width = 809
integer height = 96
end type

type st_fondo from w_base`st_fondo within w_desbloqueo_usuario
integer x = 3392
integer y = 228
integer width = 261
end type

type dw_principal from w_base`dw_principal within w_desbloqueo_usuario
integer x = 0
integer y = 320
integer width = 3698
integer height = 1484
string dataobject = "dw_desbloqueousuario"
boolean hsplitscroll = true
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_menupopup = false
boolean ib_menufiltrar = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve; if ii_idservidor >  0 then 
	Return this.retrieve(3,String(ii_idservidor))
end if 

end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;String		ls_estadoSql=''
Integer	li_NroColumnas
Integer	li_Columna
String		ls_Columna

is_codigousuario	=	''

if this.rowcount()<1 then Return

if currentrow>0 and this.rowcount()>0 then
	is_codigousuario	=	this.getitemstring(currentrow, 'codigousuario')
	is_CodigoLogin    =     this.getitemstring(currentrow, 'CodigoLogin')    
	ls_estadoSql		=	this.getitemstring(currentrow, 'estadosql')
End if

uo_block.tag=ls_estadoSql

uo_block.Visible = false

if  Len(ls_estadoSql)>0  then
	if  ls_estadoSql='A'  then
		uo_block.st_texto.text='Bloquear'
	elseif ls_estadoSql = 'B' then
		uo_block.st_texto.text='Desbloquear'
		uo_block.Visible = true
	Else
		uo_block.st_texto.text=''
	End if
End if

li_NroColumnas				= Integer(This.Object.Datawindow.Column.Count)

this.setredraw( false) 
For li_Columna = 1 To li_NroColumnas
	ls_Columna = '#' + string(li_Columna)
	This.modIfy(ls_Columna + ".Background.color='16777215~tif( getrow() in ("+ String( currentrow )+"), 16755261, 16777215 )'")	
Next
this.setredraw( true) 
end event

type st_menuruta from w_base`st_menuruta within w_desbloqueo_usuario
boolean visible = false
integer x = 3438
integer y = 136
integer width = 87
string text = ""
end type

type uo_reset from uo_boton within w_desbloqueo_usuario
integer x = 2336
integer y = 36
integer height = 144
integer taborder = 20
boolean bringtotop = true
string is_imagen = "Img\Icono\generar.png"
string is_texto = " Reiniciar Clave"
end type

on uo_reset.destroy
call uo_boton::destroy
end on

event ue_clicked;call super::ue_clicked;//is_codigoUsuario  por   is_CodigoLogin

if isnull(is_CodigoLogin) or is_CodigoLogin = ""then 
	gf_mensaje(gs_Aplicacion, 'Seleccionar usuario', '', 1)
	return 
end if 
if dw_principal.getitemstring( dw_principal.getrow(),'sql_login')='S' then
	uf_resetear_usuario(is_CodigoUsuario, is_CodigoLogin)
Else
	gf_mensaje(gs_Aplicacion, 'Usuario NO tiene LOGIN asignado', '', 1)
End if
end event

type uo_block from uo_boton within w_desbloqueo_usuario
integer x = 1669
integer y = 40
integer height = 144
integer taborder = 30
boolean bringtotop = true
string is_imagen = "Img\Icono\Unlock.png"
end type

on uo_block.destroy
call uo_boton::destroy
end on

event ue_clicked;call super::ue_clicked;String		ls_estado

// Cambio  is_codigousuario  por  is_CodigoLogin

if Len(is_CodigoLogin)>1 then
	ls_estado	=	String(this.tag)	
	
	if uf_bloquear_desbloquear(ls_estado,is_codigousuario,is_codigologin) = 1 then
		gf_mensaje(gs_Aplicacion, 'Proceso realizado existosamente para el usuario: "' + is_CodigoLogin + '" ', '', 1)
		dw_principal.event ue_retrieve( )
	Else
		gf_mensaje(gs_Aplicacion, 'No se pudo realizar el proceso para el usuario: "' + is_CodigoLogin + '" ..Verifique ', '', 1)
	End if
End if
end event

type st_buscar from statictext within w_desbloqueo_usuario
integer x = 59
integer y = 236
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
string text = "Buscar por Código :"
alignment alignment = right!
boolean focusrectangle = false
end type

type em_buscar from uo_edm_texto within w_desbloqueo_usuario
boolean visible = false
integer x = 2318
integer y = 216
integer width = 178
integer taborder = 30
boolean bringtotop = true
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_desbloqueo_usuario
integer x = 64
integer y = 48
integer taborder = 40
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible...verifique', '', 3)
	Return -2
Else
	dw_principal.event ue_retrieve( )
End if
end event

type sle_buscar from singlelineedit within w_desbloqueo_usuario
integer x = 754
integer y = 216
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
//ls_colsort	=	'codigousuario'
ls_colsort	=	'codigologin'
ls_cadfind = "Upper(" + ls_colsort +") LIKE "+ "'" + trim(ls_texbus) + "%'"
li_found = dw_principal.find( ls_cadfind, 1, dw_principal.RoWCount())		
If li_found > 0 Then dw_principal.ScrollToRow(li_found)
end event

