$PBExportHeader$w_cambiar_clave.srw
forward
global type w_cambiar_clave from window
end type
type cb_cancelar from commandbutton within w_cambiar_clave
end type
type sle_clave_conf from singlelineedit within w_cambiar_clave
end type
type st_4 from statictext within w_cambiar_clave
end type
type sle_clave_nueva from singlelineedit within w_cambiar_clave
end type
type st_3 from statictext within w_cambiar_clave
end type
type st_1 from statictext within w_cambiar_clave
end type
type st_2 from statictext within w_cambiar_clave
end type
type sle_usuario_c from singlelineedit within w_cambiar_clave
end type
type sle_clave_anterior from singlelineedit within w_cambiar_clave
end type
type cb_aceptar from commandbutton within w_cambiar_clave
end type
type p_logo from picture within w_cambiar_clave
end type
end forward

global type w_cambiar_clave from window
integer width = 1783
integer height = 972
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_cancelar cb_cancelar
sle_clave_conf sle_clave_conf
st_4 st_4
sle_clave_nueva sle_clave_nueva
st_3 st_3
st_1 st_1
st_2 st_2
sle_usuario_c sle_usuario_c
sle_clave_anterior sle_clave_anterior
cb_aceptar cb_aceptar
p_logo p_logo
end type
global w_cambiar_clave w_cambiar_clave

type variables
uo_proc_seguridad			uo_procedure
transaction 						itr_seguridad
str_arg							istr_argumentos
end variables

on w_cambiar_clave.create
this.cb_cancelar=create cb_cancelar
this.sle_clave_conf=create sle_clave_conf
this.st_4=create st_4
this.sle_clave_nueva=create sle_clave_nueva
this.st_3=create st_3
this.st_1=create st_1
this.st_2=create st_2
this.sle_usuario_c=create sle_usuario_c
this.sle_clave_anterior=create sle_clave_anterior
this.cb_aceptar=create cb_aceptar
this.p_logo=create p_logo
this.Control[]={this.cb_cancelar,&
this.sle_clave_conf,&
this.st_4,&
this.sle_clave_nueva,&
this.st_3,&
this.st_1,&
this.st_2,&
this.sle_usuario_c,&
this.sle_clave_anterior,&
this.cb_aceptar,&
this.p_logo}
end on

on w_cambiar_clave.destroy
destroy(this.cb_cancelar)
destroy(this.sle_clave_conf)
destroy(this.st_4)
destroy(this.sle_clave_nueva)
destroy(this.st_3)
destroy(this.st_1)
destroy(this.st_2)
destroy(this.sle_usuario_c)
destroy(this.sle_clave_anterior)
destroy(this.cb_aceptar)
destroy(this.p_logo)
end on

event open;// **********************************************************************************
//    Control de Versión:
//    Versión    Autor                                 		Fecha              	Descripción
//    1.0       Walther Rodriguez           		 09/12/2019      		Versión inicial
//	  1.1		Hugo Chuquitaype					 24/09/2021				Declaración de estructura y asignación de itr_seguridad
//	  1.2	    Walther Rodriguez           		 09/12/2019      		Usar variable Instancia
// **********************************************************************************

If	Not Isvalid(Message.PowerObjectParm) Then Return
	
istr_argumentos	=	Message.PowerObjectParm		// 1.2 wrz
itr_seguridad 		= 	istr_argumentos.tr[1]			//ver 1.1 hch

sle_usuario_c.text = gs_Usuario
sle_clave_anterior.text = gs_Clave

sle_clave_nueva.SetFocus()



 
 


end event

event key;If	KeyDown(KeyEnter! )THEN
	cb_Aceptar.SetFocus()
     cb_Aceptar.event clicked( )
END IF
end event

type cb_cancelar from commandbutton within w_cambiar_clave
integer x = 955
integer y = 800
integer width = 549
integer height = 104
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Cancelar"
end type

event clicked;CloseWithReturn( parent, '-' )
end event

type sle_clave_conf from singlelineedit within w_cambiar_clave
integer x = 795
integer y = 660
integer width = 814
integer height = 104
integer taborder = 40
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean password = true
borderstyle borderstyle = stylelowered!
end type

type st_4 from statictext within w_cambiar_clave
integer x = 174
integer y = 676
integer width = 571
integer height = 88
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Confirmar contraseña:"
boolean focusrectangle = false
end type

type sle_clave_nueva from singlelineedit within w_cambiar_clave
integer x = 795
integer y = 524
integer width = 814
integer height = 104
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean password = true
borderstyle borderstyle = stylelowered!
end type

type st_3 from statictext within w_cambiar_clave
integer x = 174
integer y = 540
integer width = 485
integer height = 88
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Contraseña nueva:"
boolean focusrectangle = false
end type

type st_1 from statictext within w_cambiar_clave
integer x = 178
integer y = 264
integer width = 398
integer height = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Usuario:"
boolean focusrectangle = false
end type

type st_2 from statictext within w_cambiar_clave
integer x = 174
integer y = 404
integer width = 526
integer height = 88
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Contraseña anterior:"
boolean focusrectangle = false
end type

type sle_usuario_c from singlelineedit within w_cambiar_clave
integer x = 795
integer y = 256
integer width = 814
integer height = 108
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean enabled = false
borderstyle borderstyle = stylelowered!
end type

type sle_clave_anterior from singlelineedit within w_cambiar_clave
integer x = 795
integer y = 388
integer width = 814
integer height = 104
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean enabled = false
boolean password = true
borderstyle borderstyle = stylelowered!
end type

type cb_aceptar from commandbutton within w_cambiar_clave
integer x = 229
integer y = 800
integer width = 549
integer height = 104
integer taborder = 50
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Aceptar"
boolean default = true
end type

event clicked;//  1.0		Utilizar validacion para tipo de cambio de clave

String			ls_NuevaClaveNoEnc			// Clave nueva no encriptada
String			ls_ConfirmarClaveNoEnc		// Clave nueva no encriptada confirmada
Integer		li_ValorRetorno					// Valor retornado por la ejecución de los stores procedures
String			ls_tipollamado
String			ls_clave							// Guarda la clave pero en MINUSCULAS

ls_NuevaClaveNoEnc = sle_clave_nueva.text
ls_ConfirmarClaveNoEnc = sle_clave_conf.text

//ls_claveanterior	= Lower(gs_clave)

If ( ls_NuevaClaveNoEnc <> ls_ConfirmarClaveNoEnc ) Then 
	gf_mensaje( gs_Aplicacion, 'Error al cambiar el password.', 'Las claves no concuerdan.', 2 )
	Return
End if

If	( gf_protege_cadena( gs_clave, 2 ) = ls_NuevaClaveNoEnc ) Then
	gf_mensaje( gs_Aplicacion, 'Error al cambiar el password.', 'La nueva clave no puede ser igual a la actual.', 2 )
	Return
End If

/* Evalua si el cambio de contraseña es producto del reseteo o no */
If	istr_argumentos.b[1] = True Then
	ls_Clave = gf_protege_cadena( Lower(gs_usuario), 1 ) //v 1.0
Else
	ls_Clave = gs_clave
End If

/* Realiza el cambio de password */
uo_procedure = create uo_proc_seguridad
li_ValorRetorno = uo_procedure.uf_usp_usuario_cambiarpassword( itr_seguridad , gi_idservidor, gs_usuario, gf_protege_cadena( ls_NuevaClaveNoEnc, 1 ), ls_Clave )
Destroy( uo_procedure )


If	li_ValorRetorno > 0 Then	
	Disconnect using  itr_seguridad;
	gf_mensaje( gs_Aplicacion, 'Contraseña actualizada. El sistema se cerrará, por favor vuelva ingresar al sistema.', '', 1 )
Else
	CloseWithReturn( parent, 'False' )
End if

ls_tipollamado='V'
If ls_tipollamado = 'V' Then
	CloseWithReturn( Parent, 'False' )
End If

/* Cuando es llamado desde el menú   'M' - 2017.05.14 */
If ls_tipollamado = 'M' Then
	Halt Close
End If


 

//	Disconnect using itr_seguridad;
//	itr_Seguridad.logpass = gf_protege_cadena( ls_NuevaClaveNoEnc, 1 )
//	itr_Seguridad.dbpass = gf_protege_cadena( ls_NuevaClaveNoEnc, 1 )
//	Connect using itr_seguridad;
//	
//	gf_mensaje( gs_Aplicacion, 'Contraseña actualizada.', '', 1 )
//	gs_Clave = gf_protege_cadena( ls_NuevaClaveNoEnc, 1 )
//	CloseWithReturn( parent, 'OK' )





end event

type p_logo from picture within w_cambiar_clave
integer x = 293
integer width = 1202
integer height = 256
string picturename = "Img\Logos\Buenaventura.png"
boolean focusrectangle = false
end type

