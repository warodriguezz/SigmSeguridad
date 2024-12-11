$PBExportHeader$w_consulta_detalle_usuario.srw
forward
global type w_consulta_detalle_usuario from w_response_mtto
end type
type mle_obs from multilineedit within w_consulta_detalle_usuario
end type
type dw_filtro_fechas from uo_dw within w_consulta_detalle_usuario
end type
type st_1 from statictext within w_consulta_detalle_usuario
end type
end forward

global type w_consulta_detalle_usuario from w_response_mtto
integer width = 4110
integer height = 1924
mle_obs mle_obs
dw_filtro_fechas dw_filtro_fechas
st_1 st_1
end type
global w_consulta_detalle_usuario w_consulta_detalle_usuario

type variables
Date		id_desde
Date		id_hasta
String		is_codusuario

end variables

on w_consulta_detalle_usuario.create
int iCurrent
call super::create
this.mle_obs=create mle_obs
this.dw_filtro_fechas=create dw_filtro_fechas
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.mle_obs
this.Control[iCurrent+2]=this.dw_filtro_fechas
this.Control[iCurrent+3]=this.st_1
end on

on w_consulta_detalle_usuario.destroy
call super::destroy
destroy(this.mle_obs)
destroy(this.dw_filtro_fechas)
destroy(this.st_1)
end on

event open;call super::open;String			ls_observacion
DateTime	ld_fechahora
sqlca.uf_usp_fechahora_select(ld_fechahora)
 
str_arg		lstr_Recep
lstr_Recep = istr_parametros.str_argumentos
  
id_hasta			=	Date(ld_fechahora)
id_desde			=	Date("01/"+String(Month(id_hasta))+"/"+String(Year(id_hasta)))

ls_observacion	=	lstr_Recep.s[4]

//Setear Filtro
dw_filtro_fechas.InsertRow(0)
dw_filtro_fechas.object.desde[1]	=id_desde
dw_filtro_fechas.object.hasta[1]	=id_hasta

//Colocar observacion
mle_obs.text=ls_observacion

dw_principal.setfocus( )
end event

type p_cbcancelar from w_response_mtto`p_cbcancelar within w_consulta_detalle_usuario
integer x = 3611
integer y = 1648
end type

type p_cbaceptar from w_response_mtto`p_cbaceptar within w_consulta_detalle_usuario
integer x = 3186
integer y = 1652
end type

type cbx_filtros from w_response_mtto`cbx_filtros within w_consulta_detalle_usuario
integer x = 69
integer y = 1708
end type

type dw_principal from w_response_mtto`dw_principal within w_consulta_detalle_usuario
integer width = 3995
integer height = 1080
string dataobject = "dw_usuario_auditoria"
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;String			ls_desde
String			ls_hasta
String			ls_parametros
String			ls_codusuario


ls_codusuario=istr_parametros.str_argumentos.s[1]
if IsNull(id_desde) or id_desde=Date("01/01/1900") then
	ls_desde 			=	istr_parametros.str_argumentos.s[2]
Else
	ls_desde 			=	String(id_desde,"yyyymmdd")	
End if

if IsNull(id_hasta)  or id_hasta=Date("01/01/1900") then
	ls_hasta 			=	istr_parametros.str_argumentos.s[3]
Else
	ls_hasta				=	String(id_hasta,"yyyymmdd")
End if

ls_parametros		=	ls_codusuario+","+ls_desde+","+ls_hasta


return Retrieve(2,ls_parametros )
end event

type cb_cancelar from w_response_mtto`cb_cancelar within w_consulta_detalle_usuario
integer x = 3488
integer y = 1660
end type

type cb_aceptar from w_response_mtto`cb_aceptar within w_consulta_detalle_usuario
integer x = 3058
integer y = 1660
end type

type st_mensaje from w_response_mtto`st_mensaje within w_consulta_detalle_usuario
end type

type mle_obs from multilineedit within w_consulta_detalle_usuario
integer x = 37
integer y = 1208
integer width = 3995
integer height = 424
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type dw_filtro_fechas from uo_dw within w_consulta_detalle_usuario
integer x = 55
integer y = 1708
integer width = 1536
integer height = 76
integer taborder = 30
boolean bringtotop = true
string dataobject = "dwe_filtro_fechas"
boolean border = false
boolean ib_dwtipofiltro = true
end type

event itemchanged;call super::itemchanged;String					ls_colname
Boolean				lb_calendar	=	False
ls_colname			=	String(dwo.name)

if  Describe(ls_colname+".EditMask.DDCalendar")='yes' then lb_calendar=True

if lb_calendar then
	Choose case ls_colname
		Case 'desde'
			id_desde=Date(data)
		case 'hasta'
			id_hasta=Date(data)
	End choose
End if


dw_principal.event ue_retrieve( )
end event

type st_1 from statictext within w_consulta_detalle_usuario
integer x = 50
integer y = 1140
integer width = 389
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
long backcolor = 67108864
string text = "Observaciones"
boolean focusrectangle = false
end type

