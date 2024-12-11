$PBExportHeader$w_auditoriatablas_sigm.srw
forward
global type w_auditoriatablas_sigm from w_base
end type
type dp_ini from datepicker within w_auditoriatablas_sigm
end type
type dp_fin from datepicker within w_auditoriatablas_sigm
end type
type st_1 from statictext within w_auditoriatablas_sigm
end type
type st_2 from statictext within w_auditoriatablas_sigm
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_auditoriatablas_sigm
end type
end forward

global type w_auditoriatablas_sigm from w_base
string tag = "historial_de_auditoria_de_tablas"
integer width = 12923
string title = "Auditoria de Tablas"
boolean ib_toolbarmodoconsulta = true
dp_ini dp_ini
dp_fin dp_fin
st_1 st_1
st_2 st_2
dw_filtro_servidor dw_filtro_servidor
end type
global w_auditoriatablas_sigm w_auditoriatablas_sigm

type variables

Date			id_FechaIni
Date			id_FechaFin
Integer 		ii_IdServidor 
end variables

forward prototypes
public subroutine uf_configurar_opciones_menu (m_mbase am_menu)
end prototypes

public subroutine uf_configurar_opciones_menu (m_mbase am_menu);
end subroutine

on w_auditoriatablas_sigm.create
int iCurrent
call super::create
this.dp_ini=create dp_ini
this.dp_fin=create dp_fin
this.st_1=create st_1
this.st_2=create st_2
this.dw_filtro_servidor=create dw_filtro_servidor
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dp_ini
this.Control[iCurrent+2]=this.dp_fin
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.dw_filtro_servidor
end on

on w_auditoriatablas_sigm.destroy
call super::destroy
destroy(this.dp_ini)
destroy(this.dp_fin)
destroy(this.st_1)
destroy(this.st_2)
destroy(this.dw_filtro_servidor)
end on

event resize;call super::resize;dw_filtro_servidor.y				= BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x 				= BordeVertical

dw_filtro_servidor.y				= BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x 				= BordeVertical

dw_principal.x 				= BordeVertical
dw_principal.y 				= BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
dw_principal.width 		=  ((st_fondo.width  - (1 * BordeHorizontal) ) )
dw_principal.height 		=  (newheight - ( (dw_filtro_servidor.y + 1 * BordeHorizontal ) + il_AlturaTitulo))




end event

event ue_preopen;call super::ue_preopen;DateTime ldt_fechaactual
Date ld_fechaactual

Sqlca.uf_usp_fechahora_select(ldt_fechaactual)
ld_fechaactual	=	Date(ld_fechaactual)

id_FechaIni = Date( String(year(ld_fechaactual))+'/'+String(month(ld_fechaactual))+'/'+'01' )
id_FechaFin = ld_fechaactual

Return 1
end event

event ue_vistaprevia;//nada
end event

type st_titulo from w_base`st_titulo within w_auditoriatablas_sigm
end type

type st_fondo from w_base`st_fondo within w_auditoriatablas_sigm
integer width = 12800
end type

type dw_principal from w_base`dw_principal within w_auditoriatablas_sigm
integer x = 46
integer y = 276
integer width = 12805
integer height = 1608
string dataobject = "dw_auditoriatablas_sigm"
boolean hscrollbar = true
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_menuexportar = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;id_FechaIni = Date( dp_ini.value )
id_FechaFin = Relativedate( Date( dp_fin.value ), 1 )

Return This.retrieve( ii_IdServidor, id_FechaIni, id_FechaFin )

end event

type st_menuruta from w_base`st_menuruta within w_auditoriatablas_sigm
integer x = 3429
integer height = 56
end type

type dp_ini from datepicker within w_auditoriatablas_sigm
integer x = 1847
integer y = 152
integer width = 521
integer height = 100
integer taborder = 40
boolean bringtotop = true
date maxdate = Date("2999-12-31")
date mindate = Date("1800-01-01")
datetime value = DateTime(Date("2020-01-02"), Time("08:03:10.000000"))
integer textsize = -9
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
integer calendarfontweight = 400
boolean todaysection = true
boolean todaycircle = true
boolean valueset = true
end type

event valuechanged;dw_principal.setredraw( False )
dw_principal.event ue_retrieve( )
dw_principal.setredraw( True )
end event

type dp_fin from datepicker within w_auditoriatablas_sigm
integer x = 2880
integer y = 152
integer width = 521
integer height = 100
integer taborder = 50
boolean bringtotop = true
date maxdate = Date("2999-12-31")
date mindate = Date("1800-01-01")
datetime value = DateTime(Date("2020-01-02"), Time("08:03:10.000000"))
integer textsize = -9
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
integer calendarfontweight = 400
boolean todaysection = true
boolean todaycircle = true
boolean valueset = true
end type

event valuechanged;dw_principal.setredraw( False )
dw_principal.event ue_retrieve( )
dw_principal.setredraw( True )
end event

type st_1 from statictext within w_auditoriatablas_sigm
integer x = 1559
integer y = 172
integer width = 251
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Desde:"
boolean focusrectangle = false
end type

type st_2 from statictext within w_auditoriatablas_sigm
integer x = 2624
integer y = 172
integer width = 187
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Hasta:"
boolean focusrectangle = false
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_auditoriatablas_sigm
integer x = 41
integer y = 160
integer taborder = 20
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro
//Administrar solo los servidores LinKed o el servidor con conexion
if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	dw_principal.reset( )
	Return -2
Else
	dw_principal.event ue_retrieve( )
End if



end event

