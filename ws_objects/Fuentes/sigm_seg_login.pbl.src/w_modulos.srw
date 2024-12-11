$PBExportHeader$w_modulos.srw
forward
global type w_modulos from window
end type
type phl_8 from picturehyperlink within w_modulos
end type
type phl_6 from picturehyperlink within w_modulos
end type
type st_modulo from statictext within w_modulos
end type
type phl_1 from picturehyperlink within w_modulos
end type
type phl_2 from picturehyperlink within w_modulos
end type
type phl_3 from picturehyperlink within w_modulos
end type
type phl_4 from picturehyperlink within w_modulos
end type
type phl_5 from picturehyperlink within w_modulos
end type
type phl_7 from picturehyperlink within w_modulos
end type
end forward

global type w_modulos from window
integer width = 2007
integer height = 1856
boolean titlebar = true
string title = ":: S E L E C C I O N E   U N   M O D U L O ::"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 134217748
string icon = "Img\Icono\AppBVN.ico"
boolean center = true
windowanimationstyle openanimation = topslide!
windowanimationstyle closeanimation = fadeanimation!
integer animationtime = 400
boolean toolbarinsheet = true
event ue_preopen pbm_open
phl_8 phl_8
phl_6 phl_6
st_modulo st_modulo
phl_1 phl_1
phl_2 phl_2
phl_3 phl_3
phl_4 phl_4
phl_5 phl_5
phl_7 phl_7
end type
global w_modulos w_modulos

type prototypes

end prototypes

type variables
PictureHyperLink		ipic_modulos[]
Integer					ii_tot_picmodulos
Integer					ii_idaplicacion
uo_dsbase    			ids_Proceso                            // Datastore a pasar a la ventana seleccionar
end variables

forward prototypes
public function integer uf_setear_modulos ()
public subroutine uf_seleccionar_modulo (picturehyperlink aphl_modulo)
public subroutine uf_setear_texto (picturehyperlink aphl_modulo)
end prototypes

event ue_preopen;Integer				li_cont
Integer				li_contHL
PictureHyperLink 	lpic_PictureHyperLink

FOR li_cont = 1 to UpperBound(Control[]) 
		if this.Control[li_cont].typeof() = PictureHyperLink! then
			li_contHL ++ 
			lpic_PictureHyperLink=this.Control[li_cont] 
			ipic_modulos[li_contHL]=lpic_PictureHyperLink
		End if
NEXT
ii_tot_picmodulos = Integer(upperbound(ipic_modulos))
this.event open( )
end event

public function integer uf_setear_modulos ();Integer 				li_total 
Integer 				li_CntPHL
Integer 				li_CtdPHL
Integer				li_fila
Integer				li_idaplicacion
PictureHyperLink 	lpic_picmodulo
String					ls_picture
String					ls_pictureno
String         			ls_Argumentos                        // Argumentos del store procedure
String					ls_ObjetoAplicacion

/* Construir variable transaccion */ 
uo_transaction 	bvn_seguridad
bvn_seguridad = create uo_transaction
gf_conectar_db( bvn_seguridad, gs_ArchivoINI, 'Seguridad', gs_usuario, gs_Clave, 0 )

/*Configurar los parámetros que se enviarán al procedimiento*/ 
ls_Argumentos  = gs_usuario

/* Construir el datastore de forma dinámica */
ids_Proceso= gf_Procedimiento_Consultar('dbo.usp_Aplicacion_por_Usuario_Select '+ls_argumentos, bvn_seguridad)

li_total		=	ids_Proceso.rowcount( )
li_CtdPHL 	= UpperBound(ipic_modulos)
//Activar los modulos segun el perfil
For li_fila = 1 to li_total
	For li_CntPHL = 1 to li_CtdPHL 
			li_idaplicacion		=	ids_Proceso.GetItemNumber(li_fila,'id_aplicacion')
			ls_ObjetoAplicacion 	= ids_Proceso.getitemstring(li_fila , 'objeto_aplicacion' )
			ls_ObjetoAplicacion	= Replace ( ls_ObjetoAplicacion, 0, len("sigm_"), "" ) + "no.png"
			
			If Pos( Lower(ipic_modulos[li_CntPHL].picturename),"\"+lower(ls_ObjetoAplicacion) )>0 Then
				ls_pictureno		=	ipic_modulos[li_CntPHL].picturename
				ls_picture		= 	Left(ls_pictureno,Pos(ls_pictureno,".")-3)
				ls_picture		=	ls_picture+".png"
				ipic_modulos[li_CntPHL].picturename=ls_picture
				ipic_modulos[li_CntPHL].enabled=true
				ipic_modulos[li_CntPHL].tag = String(li_idaplicacion)+","+ ids_Proceso.getitemstring(li_fila , 'nm_aplicacion' )
 			End If
	Next
Next
Destroy bvn_seguridad
Return li_total
end function

public subroutine uf_seleccionar_modulo (picturehyperlink aphl_modulo);Integer        	li_FilaSeleccionada                	// Cantidad de filas seleccionadas
String 			ls_valores[]
 
gf_split(ls_valores, aphl_modulo.tag, ",")
ii_idaplicacion	=	Integer(ls_valores[1])

//Obteener la fila seleccionada a partir del Id Aplicion seleccionado
li_FilaSeleccionada=ids_proceso.find("id_aplicacion="+String(ii_idaplicacion),1,ids_proceso.rowcount( ))
ids_proceso.ii_filasseleccionadas[1]=li_FilaSeleccionada
CloseWithReturn(this,ids_proceso)

end subroutine

public subroutine uf_setear_texto (picturehyperlink aphl_modulo);String 			ls_valores[]
String 			ls_Modulo
 
gf_split(ls_valores, aphl_modulo.tag, ",")
ls_Modulo	=	Upper(ls_valores[2])
if st_modulo.text<>ls_Modulo then  st_modulo.text = ls_Modulo
end subroutine

on w_modulos.create
this.phl_8=create phl_8
this.phl_6=create phl_6
this.st_modulo=create st_modulo
this.phl_1=create phl_1
this.phl_2=create phl_2
this.phl_3=create phl_3
this.phl_4=create phl_4
this.phl_5=create phl_5
this.phl_7=create phl_7
this.Control[]={this.phl_8,&
this.phl_6,&
this.st_modulo,&
this.phl_1,&
this.phl_2,&
this.phl_3,&
this.phl_4,&
this.phl_5,&
this.phl_7}
end on

on w_modulos.destroy
destroy(this.phl_8)
destroy(this.phl_6)
destroy(this.st_modulo)
destroy(this.phl_1)
destroy(this.phl_2)
destroy(this.phl_3)
destroy(this.phl_4)
destroy(this.phl_5)
destroy(this.phl_7)
end on

event open;if this.uf_setear_modulos( ) <1 then
	Messagebox("Error","No se puede obtener informacion de aplicaciones")
	Halt Close
End if
end event

event mousemove;st_modulo.text = ''
end event

type phl_8 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "27"
integer x = 731
integer y = 1076
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\seguridadno.png"
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)

end event

type phl_6 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "25"
integer x = 1371
integer y = 600
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\Geologiano.png"
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)

end event

type st_modulo from statictext within w_modulos
integer y = 1560
integer width = 1943
integer height = 136
integer textsize = -14
integer weight = 700
fontcharset fontcharset = hebrewcharset!
fontpitch fontpitch = variable!
string facename = "Levenim MT"
long textcolor = 128
long backcolor = 67108864
alignment alignment = center!
boolean focusrectangle = false
end type

event constructor;This.Backcolor = Parent.Backcolor
end event

type phl_1 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "19"
integer x = 69
integer y = 60
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\Maestrosno.png"
borderstyle borderstyle = styleraised!
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)
end event

type phl_2 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "20"
integer x = 722
integer y = 60
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\plantano.png"
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)

end event

type phl_3 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "22"
integer x = 1371
integer y = 60
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\LIMSno.png"
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)

end event

type phl_4 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "23"
integer x = 69
integer y = 600
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\Planeamientono.png"
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)
end event

type phl_5 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "24"
integer x = 722
integer y = 600
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\OSno.png"
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)

end event

type phl_7 from picturehyperlink within w_modulos
event ue_mousemove pbm_mousemove
string tag = "26"
integer x = 69
integer y = 1092
integer width = 475
integer height = 392
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
string picturename = "Img\Icono_App\Productividadno.png"
boolean focusrectangle = false
end type

event ue_mousemove;uf_setear_texto(This)
end event

event clicked;uf_seleccionar_modulo (this)

end event

