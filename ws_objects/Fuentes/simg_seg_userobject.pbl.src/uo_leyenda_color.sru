$PBExportHeader$uo_leyenda_color.sru
forward
global type uo_leyenda_color from userobject
end type
type rr_1 from roundrectangle within uo_leyenda_color
end type
type st_4 from statictext within uo_leyenda_color
end type
type st_3 from statictext within uo_leyenda_color
end type
type st_2 from statictext within uo_leyenda_color
end type
type st_1 from statictext within uo_leyenda_color
end type
type rr_n from roundrectangle within uo_leyenda_color
end type
type rr_m from roundrectangle within uo_leyenda_color
end type
type rr_e from roundrectangle within uo_leyenda_color
end type
type rr_d from roundrectangle within uo_leyenda_color
end type
end forward

global type uo_leyenda_color from userobject
integer width = 1317
integer height = 144
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
rr_1 rr_1
st_4 st_4
st_3 st_3
st_2 st_2
st_1 st_1
rr_n rr_n
rr_m rr_m
rr_e rr_e
rr_d rr_d
end type
global uo_leyenda_color uo_leyenda_color

on uo_leyenda_color.create
this.rr_1=create rr_1
this.st_4=create st_4
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.rr_n=create rr_n
this.rr_m=create rr_m
this.rr_e=create rr_e
this.rr_d=create rr_d
this.Control[]={this.rr_1,&
this.st_4,&
this.st_3,&
this.st_2,&
this.st_1,&
this.rr_n,&
this.rr_m,&
this.rr_e,&
this.rr_d}
end on

on uo_leyenda_color.destroy
destroy(this.rr_1)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.rr_n)
destroy(this.rr_m)
destroy(this.rr_e)
destroy(this.rr_d)
end on

event constructor;rr_e.FillColor  =Rgb(0,0,200) 
rr_n.FillColor  =RGB(0,200,0)
rr_m.FillColor=Rgb(255,117,020)
rr_d.FillColor=Rgb(200,0,0)



end event

type rr_1 from roundrectangle within uo_leyenda_color
long linecolor = 33554432
integer linethickness = 4
long fillcolor = 67108864
integer x = 23
integer width = 1289
integer height = 140
integer cornerheight = 40
integer cornerwidth = 46
end type

type st_4 from statictext within uo_leyenda_color
integer x = 1015
integer y = 8
integer width = 288
integer height = 52
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Eliminado"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_3 from statictext within uo_leyenda_color
integer x = 37
integer y = 8
integer width = 288
integer height = 52
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Registrado"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_2 from statictext within uo_leyenda_color
integer x = 672
integer y = 8
integer width = 288
integer height = 52
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Modificado"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_1 from statictext within uo_leyenda_color
integer x = 343
integer y = 8
integer width = 288
integer height = 52
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Nuevo"
alignment alignment = center!
boolean focusrectangle = false
end type

type rr_n from roundrectangle within uo_leyenda_color
long linecolor = 33554432
integer linethickness = 4
long fillcolor = 1073741824
integer x = 379
integer y = 64
integer width = 197
integer height = 60
integer cornerheight = 40
integer cornerwidth = 46
end type

type rr_m from roundrectangle within uo_leyenda_color
long linecolor = 33554432
integer linethickness = 4
long fillcolor = 1073741824
integer x = 709
integer y = 64
integer width = 197
integer height = 60
integer cornerheight = 40
integer cornerwidth = 46
end type

type rr_e from roundrectangle within uo_leyenda_color
long linecolor = 33554432
integer linethickness = 4
long fillcolor = 1073741824
integer x = 64
integer y = 64
integer width = 197
integer height = 60
integer cornerheight = 40
integer cornerwidth = 46
end type

type rr_d from roundrectangle within uo_leyenda_color
long linecolor = 33554432
integer linethickness = 4
long fillcolor = 1073741824
integer x = 1061
integer y = 64
integer width = 197
integer height = 60
integer cornerheight = 40
integer cornerwidth = 46
end type

