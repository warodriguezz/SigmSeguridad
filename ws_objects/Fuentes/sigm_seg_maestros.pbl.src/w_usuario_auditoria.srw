$PBExportHeader$w_usuario_auditoria.srw
forward
global type w_usuario_auditoria from w_base
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_usuario_auditoria
end type
type dw_filtro from uo_dw within w_usuario_auditoria
end type
end forward

global type w_usuario_auditoria from w_base
string title = "Auditoria de usuarios"
boolean ib_toolbarmodoconsulta = true
dw_filtro_servidor dw_filtro_servidor
dw_filtro dw_filtro
end type
global w_usuario_auditoria w_usuario_auditoria

type variables
Integer 	ii_IdServidor 
Date			id_desde
Date			id_hasta
Integer		ii_anio
Integer		ii_mes
end variables

forward prototypes
public subroutine uf_configurar_opciones_menu (m_mbase am_menu)
end prototypes

public subroutine uf_configurar_opciones_menu (m_mbase am_menu);Application lapp_local
lapp_local = GetApplication( )

/* Realiza el llamado a la función cambiar modulo de la aplicación*/
lapp_local. dynamic function uf_configurar_opciones_menu( am_menu )
end subroutine

on w_usuario_auditoria.create
int iCurrent
call super::create
this.dw_filtro_servidor=create dw_filtro_servidor
this.dw_filtro=create dw_filtro
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_filtro_servidor
this.Control[iCurrent+2]=this.dw_filtro
end on

on w_usuario_auditoria.destroy
call super::destroy
destroy(this.dw_filtro_servidor)
destroy(this.dw_filtro)
end on

event resize;call super::resize;dw_filtro_servidor.y				= BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x 				= BordeVertical

dw_filtro.y   =   BordeHorizontal + il_AlturaTitulo
dw_filtro.x 	=   dw_filtro_servidor.x  +  dw_filtro_servidor.width



dw_principal.x 				= BordeVertical
dw_principal.y 				= BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
dw_principal.width 		=  ((st_fondo.width  - (1 * BordeHorizontal) ) )
dw_principal.height 		=  (newheight - ( (dw_filtro_servidor.y + 1 * BordeHorizontal ) + il_AlturaTitulo))


end event

event open;call super::open;DateTime	ld_fechahora
 sqlca.uf_usp_fechahora_select(ld_fechahora)
 
id_desde		=	Date(ld_fechahora)
id_hasta		=	Date(ld_fechahora)
//
ii_anio=Year(id_desde)
ii_mes=Month(id_desde)

//Setear Filtro
dw_filtro.InsertRow(0)
dw_filtro.object.desde[1]	=id_desde
dw_filtro.object.hasta[1]		=id_hasta

dw_principal.setfocus( )

timer(180)
end event

event ue_vistaprevia;//nada
end event

type st_titulo from w_base`st_titulo within w_usuario_auditoria
end type

type st_fondo from w_base`st_fondo within w_usuario_auditoria
end type

type dw_principal from w_base`dw_principal within w_usuario_auditoria
integer x = 46
integer y = 288
integer height = 992
string dataobject = "dw_usuario_auditoria"
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;// WR 14/11/2024	Nuevos parametros para Consulta

String 		 	ls_parametros
String				ls_desde
String				ls_hasta

dw_filtro.accepttext( )

ls_desde 			=	String(id_desde,"yyyymmdd")
ls_hasta				=	String(id_hasta,"yyyymmdd")

ls_parametros		=	ls_desde+","+ls_hasta

return Retrieve(1,ls_parametros )
end event

type st_menuruta from w_base`st_menuruta within w_usuario_auditoria
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_usuario_auditoria
integer x = 46
integer y = 144
integer taborder = 10
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	dw_principal.reset()
	Return -2
Else
	dw_principal.event ue_retrieve( )
	 
End if

end event

type dw_filtro from uo_dw within w_usuario_auditoria
integer x = 1637
integer y = 144
integer width = 1541
integer height = 92
integer taborder = 20
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

