$PBExportHeader$w_login.srw
forward
global type w_login from window
end type
type st_ojito from statictext within w_login
end type
type p_fondo from picture within w_login
end type
type cb_cancelar from commandbutton within w_login
end type
type p_logo from picture within w_login
end type
type cb_ingresar from commandbutton within w_login
end type
type sle_clave from singlelineedit within w_login
end type
type sle_usuario from singlelineedit within w_login
end type
type st_pass from statictext within w_login
end type
type st_user from statictext within w_login
end type
end forward

global type w_login from window
string tag = "login"
integer width = 2053
integer height = 1284
boolean titlebar = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "D:\BVN\Logo\bvn.ico"
boolean center = true
st_ojito st_ojito
p_fondo p_fondo
cb_cancelar cb_cancelar
p_logo p_logo
cb_ingresar cb_ingresar
sle_clave sle_clave
sle_usuario sle_usuario
st_pass st_pass
st_user st_user
end type
global w_login w_login

type prototypes
 
end prototypes

type variables
Integer		ii_Intentos = 0 				// Número de intentos al acceder al login

end variables

forward prototypes
public function integer uf_cambiar_clave (transaction atr_transaction)
public function integer uf_validaciones (transaction atr_transaction, readonly string as_tipo_usuario)
end prototypes

public function integer uf_cambiar_clave (transaction atr_transaction);// **********************************************************************************
//	Descripción			:	Invoca la ventana de cambio de clave.
//
//	Argumentos			:	Ninguno
//
//	Valor de Retorno	:	1 = Sin error
//								-1 = Error
//
//	Control de Versión:
//
//	Versión	Autor								Fecha				Descripción
//	1.0		Wilbert Santos Mucha			14/12/2015		Versión inicial
// **********************************************************************************

This.Visible = False 
OpenWithParm( w_cambiar_clave, atr_transaction )
This.Visible = True

If	Message.StringParm <> 'OK' Then
	Return -1
End If

Return 1
end function

public function integer uf_validaciones (transaction atr_transaction, readonly string as_tipo_usuario);// **********************************************************************************
//	Descripción			:	Valida el password del usuario que se está conectando
//								Si se ha reseteado la clave del usuario o la fecha de caducidad ya venció se muestra la
//								pantalla de cambio de clave.
//
//	Argumentos			:	Transaction		atr_transaction		Transanción con la que se realizará la conexión
//								String				as_tipo_usuario	U: Usuario, S: SysAdmin o SecurityAdmin
//
//	Valor de Retorno	:	1 = Sin error
//								-1 = Error
//
//	Control de Versión:
//
//	Versión	Autor								Fecha				Descripción
//	1.0		Wilbert Santos Mucha			14/12/2015		Versión inicial
//  1.1		Walther Rodriguez				11/09/2019		Validar  gb_SysAdmin para tipo de usuario S
// **********************************************************************************
Integer		li_ValorRetorno					// Valor retornado por la ejecución de los stores procedures
Integer		li_Dias = 0						// Días que faltan para que caduque la clave
Integer		li_TipoValidacion
Integer		li_diasaviso=0

uo_proc_seguridad		uo_stored
uo_stored  = create uo_proc_seguridad

/* Valida si se reseteo la clave */	
If	( Lower( gs_Usuario ) = Lower( sle_clave.text ) ) Then 
	gf_mensaje( gs_Aplicacion, 'Proceda a cambiar su contraseña.', '', 1 ) 
	If	This.uf_cambiar_clave( atr_transaction ) = -1 Then
		Return -1
	End If
End if

/* Revisa las validaciones según el tipo de usuaurio */
//gb_sysadmin		=	False
li_ValorRetorno 	= uo_stored.uf_usp_usuario_validar( atr_transaction, gs_Usuario, as_tipo_usuario )
li_TipoValidacion	=	li_ValorRetorno
If	li_ValorRetorno < 0 Then
	gf_mensaje( gs_Aplicacion, 'Usuario no es Security Admin o no tiene perfil de acceso, revisar configuración.', '', 1 ) 
	Return -1
End if

/* aplico la fecha de ultimo accesp */
li_ValorRetorno = uo_stored.uf_usp_usuario_fecha_ultimo_acceso( atr_transaction, gs_Usuario )
If	li_ValorRetorno < 0 Then
	gf_mensaje( gs_Aplicacion, 'Problemas con el control de la fecha de último acceso.', '', 1 ) 
	Return -1
End If


/* Si el Tipo es U se valida la fecha de caducidad de la contraseña */
If	as_tipo_usuario = 'S' Then
	li_ValorRetorno = uo_stored.uf_usp_usuario_validarfechacaducidad( atr_transaction, gs_Usuario, li_Dias ,li_diasaviso )
	If	li_ValorRetorno < 0 Then
		/* Validación con respecto a los días de caducidad de la clave */
		If	li_Dias < 1 Then
			If	This.uf_cambiar_clave( atr_transaction ) = -1 Then  Return -1
			
		ElseIf li_Dias < 4 Then
			If	gf_mensaje( gs_Aplicacion, 'Su contraseña caducará en: ' + String(li_Dias) + ' días.~rDesea cambiarla?', '', 4 ) = 1 Then
				If	This.uf_cambiar_clave( atr_transaction ) = -1 Then Return -1
			End If
		End If
	End If
End if

/* Si el Tipo es S valida el tipo de Admin   v 1.1 */  
If	as_tipo_usuario = 'S' Then
//	if li_TipoValidacion=1 then 	gb_SysAdmin			=True
	if li_TipoValidacion=3 then	gb_SegPerfilConsulta	=True
end if

Destroy( uo_stored )

Return 1

end function

on w_login.create
this.st_ojito=create st_ojito
this.p_fondo=create p_fondo
this.cb_cancelar=create cb_cancelar
this.p_logo=create p_logo
this.cb_ingresar=create cb_ingresar
this.sle_clave=create sle_clave
this.sle_usuario=create sle_usuario
this.st_pass=create st_pass
this.st_user=create st_user
this.Control[]={this.st_ojito,&
this.p_fondo,&
this.cb_cancelar,&
this.p_logo,&
this.cb_ingresar,&
this.sle_clave,&
this.sle_usuario,&
this.st_pass,&
this.st_user}
end on

on w_login.destroy
destroy(this.st_ojito)
destroy(this.p_fondo)
destroy(this.cb_cancelar)
destroy(this.p_logo)
destroy(this.cb_ingresar)
destroy(this.sle_clave)
destroy(this.sle_usuario)
destroy(this.st_pass)
destroy(this.st_user)
end on

event open;sle_usuario.setfocus()
end event

type st_ojito from statictext within w_login
event ue_lbuttondown pbm_lbuttondown
event ue_lbuttonup pbm_lbuttonup
integer x = 1664
integer y = 916
integer width = 110
integer height = 60
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "(☼)"
alignment alignment = center!
boolean focusrectangle = false
end type

event ue_lbuttondown;sle_clave.password=False
end event

event ue_lbuttonup;sle_clave.password=True
end event

type p_fondo from picture within w_login
integer width = 2048
integer height = 460
boolean originalsize = true
string picturename = "Img\Logos\logo_seg.png"
boolean focusrectangle = false
end type

type cb_cancelar from commandbutton within w_login
integer x = 1051
integer y = 1028
integer width = 590
integer height = 116
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&Cancelar"
end type

event clicked;Halt Close
end event

type p_logo from picture within w_login
integer x = 407
integer y = 508
integer width = 1202
integer height = 256
string picturename = "Img\Logos\Buenaventura.png"
boolean focusrectangle = false
end type

type cb_ingresar from commandbutton within w_login
integer x = 379
integer y = 1028
integer width = 590
integer height = 116
integer taborder = 40
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&Ingresar"
boolean default = true
end type

event clicked;// **********************************************************************************
//	Descripción			:	Permite autenticar al usuario 
//								
//	Argumentos			:	Ninguno
//
//	Valor de Retorno	:	1 = Autenticación exitosa
//							  - 1 = Error en la Autenticación
//
//	Control de Versión:
//
//	Versión	Autor								Fecha				Descripción
//	1.0		Wilbert Santos Mucha			09/12/2015		Versión inicial
//	1.1		Walther Rodriguez				03/08/2020		Validar disponibilidad servidor
//	1.2		Walther Rodriguez				12/08/2020		Uso de objeto guo_proc_seg_login
//	1.3		Walther Rodriguez				12/11/2024		Eliminar ajuste para SA
// **********************************************************************************

Integer		li_Retorno

If Trim( sle_usuario.text ) = '' Then
	gf_mensaje( 'Inicio de sesión', 'Ingrese el usuario.', '', 1 )
	sle_usuario.SetFocus( )
	Return -1
End If 

If	Trim( sle_clave.text ) = '' Then 
	gf_mensaje( 'Inicio de sesión', 'Ingrese la contraseña.', '', 1 )
	sle_clave.SetFocus( )
	Return -1
End If

gs_Usuario 	= Trim( sle_usuario.text )

//Ajuste para dejar entrar al SA
//If Lower( gs_Usuario ) = 'sa'  or Lower( gs_Usuario ) = 'adm_secsa'  Then	//1.3
//	gs_Clave = Trim( sle_clave.text )
//Else
	gs_Clave =  gf_protege_cadena( Trim( sle_clave.text ), 1 ) // Almacena la clave encriptada
//End If

/* Validar estado servidor 1.2*/
//NO APLICA


////Para Seguriadd TODOS los usuarios son SQL	21/11/2024
 gs_tipo_login='S'

ii_intentos++

///* Conectar 1.2*/
li_Retorno = guo_proc_seg_login.uf_conectar( ii_Intentos )

If	li_Retorno = -1 Then
	sle_clave.text=''
	sle_clave.SetFocus()
	sle_clave.SelectText( 1, 100 )
Else
	CloseWithReturn( Parent, 1 )
End If
end event

type sle_clave from singlelineedit within w_login
integer x = 823
integer y = 904
integer width = 814
integer height = 92
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean password = true
borderstyle borderstyle = stylelowered!
boolean hideselection = false
end type

event modified;IF KeyDown(KeyEnter! )THEN
	 cb_Ingresar.SetFocus()
END IF


end event

type sle_usuario from singlelineedit within w_login
integer x = 823
integer y = 788
integer width = 814
integer height = 92
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean hideselection = false
end type

type st_pass from statictext within w_login
integer x = 379
integer y = 920
integer width = 398
integer height = 88
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Contraseña :"
boolean focusrectangle = false
end type

type st_user from statictext within w_login
integer x = 379
integer y = 796
integer width = 398
integer height = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Usuario :"
boolean focusrectangle = false
end type

