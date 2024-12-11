$PBExportHeader$w_usuario_loginactivo.srw
forward
global type w_usuario_loginactivo from w_response_mtto
end type
type st_titulo from statictext within w_usuario_loginactivo
end type
end forward

global type w_usuario_loginactivo from w_response_mtto
integer width = 2935
integer height = 728
string title = "Login User"
boolean clientedge = true
st_titulo st_titulo
end type
global w_usuario_loginactivo w_usuario_loginactivo

type variables
string 	is_codigousuario
string 	is_codigologin
Integer 	ii_idservidor
string  	is_tipologin
String  	is_dominio
Integer	ii_fila_nueva
Integer	ii_idloginactual
 String	is_mantener_permiso




 

 
end variables

forward prototypes
public function integer wf_valida_usuario_sql (integer ai_idservidor, string as_codigologin, string as_codigousuario, string as_tipo)
public function integer wf_crear_login (string as_codigousuario, string as_codigologin, string as_tipologin, integer ai_idservidor)
public function integer wf_quitar_login (string as_codigousuario, integer ai_idlogin, string as_codigologin, integer ai_estado, integer ai_idservidor)
public function integer wf_setear_login_actual (integer ai_idservidor, string as_codigousuario, integer ai_idlogin, string as_codigologin, string as_tipologin, string as_codigologin_ant)
end prototypes

public function integer wf_valida_usuario_sql (integer ai_idservidor, string as_codigologin, string as_codigousuario, string as_tipo);// 1.1			Walther Rodriguez					20/06/2024		Se quito el parametro IDServidor de Seguridad.usp_SQL_Usuario_Validar

Integer	li_ret
String		ls_parametros
Integer	li_retornoOUT
String		ls_ret

// Validacion usuario en servidor SQL
ls_Parametros = "1,"+ ",' ','"+as_codigousuario +"','"+as_tipo+"',"+String(li_retornoOUT)	//1.1
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Validar",ls_Parametros)  
If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL ', '', 2)
	Return -1
End if

li_ret	=	Integer(ls_ret)

Return li_ret
end function

public function integer wf_crear_login (string as_codigousuario, string as_codigologin, string as_tipologin, integer ai_idservidor);Integer	li_ret
String		ls_parametros
Integer	li_retornoOUT
String		ls_ret

// Crear Login
ls_Parametros = "'"+as_codigousuario+"','"+as_codigologin+"','"+as_tipologin+"',"+String( ai_idservidor)+","+String(li_retornoOUT)
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_UsuarioLogin_Insert",ls_Parametros)  

If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL ', '', 2)
	Return -1
End if

li_ret	=	Integer(ls_ret)


Return li_ret
end function

public function integer wf_quitar_login (string as_codigousuario, integer ai_idlogin, string as_codigologin, integer ai_estado, integer ai_idservidor);//	1.1	03/10/2024		Se omite el idservidor
Integer	li_ret
String		ls_parametros
String		ls_ret

// Quitar Login
//ls_Parametros = "'"+as_codigousuario+"',"+String(ai_idlogin)+",' ','"+as_codigologin+"',' ',"+String(ai_estado)+","+String( ai_idservidor) NO USAR IDSERVIDOR 1.1
ls_Parametros = "'"+as_codigousuario+"',"+String(ai_idlogin)+",' ','"+as_codigologin+"',' ',"+String(ai_estado)
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_UsuarioLogin_Update",ls_Parametros)  

If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo actualizar registro de Login ', '', 2)
	Return -1
End if

li_ret	=	Integer(ls_ret)

Return li_ret
end function

public function integer wf_setear_login_actual (integer ai_idservidor, string as_codigousuario, integer ai_idlogin, string as_codigologin, string as_tipologin, string as_codigologin_ant);// 	1.0	09/07/2204	Walther Rodriguez		No se envia IDSERVIDOR

Integer	li_ret
Integer	li_ret2
Integer	li_ret3
String		ls_ret
String		ls_parametros
String		ls_eliminar
String		ls_retorno[]
String		ls_error
String		ls_mensaje
String		ls_accion

li_ret	=	1

// Setear Login actual 
//ls_Parametros = "'"+as_codigousuario+"',"+String(ai_idlogin)+",'"+as_codigologin+"','"+as_tipologin+"',"+String( ai_idservidor)
ls_Parametros = "'"+as_codigousuario+"',"+String(ai_idlogin)+",'"+as_codigologin+"','"+as_tipologin+"'" //1.0
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_UsuarioLogin_Actual",ls_Parametros)  
If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo cambiar login actual ', '', 2)
	Return -1
End if

//Registrar Auditoria
if as_tipologin='U' then 
	ls_accion='G'
else
	ls_accion='E'
End if
li_ret2=f_auditoria_usuario( ii_idservidor, as_codigousuario,ls_accion)
	
// Asignar los permisos al Login Actual
ls_eliminar	=	'S'
if is_mantener_permiso='S' then ls_eliminar	=	'N'
//ls_Parametros =  "'"+as_codigousuario +"','"+as_codigoLogin +"','"+as_codigologin_ant+"','"+ls_eliminar+"',"+String( ii_idservidor) 
ls_Parametros =  "'"+as_codigousuario +"','"+as_codigoLogin +"','"+as_codigologin_ant+"','"+ls_eliminar+"'"		//1.0
li_ret3	 =  gf_Procedimiento_Ejecutar("Seguridad.usp_UsuarioLoginPerfilBaseDatosRol", ls_Parametros, ls_retorno, ls_Error)
if li_ret3 < 0 Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo asignar permiso al login actual ', '', 2)
	Return -1
End If

if as_tipologin='U' then
	ls_mensaje='clave generada automáticamente'
else
	ls_mensaje='clave reiniciada'
end if

gf_mensaje(gs_Aplicacion, 'Login asignado, '+ls_mensaje, '', 1)

Return li_ret
end function

on w_usuario_loginactivo.create
int iCurrent
call super::create
this.st_titulo=create st_titulo
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_titulo
end on

on w_usuario_loginactivo.destroy
call super::destroy
destroy(this.st_titulo)
end on

event open;call super::open;str_response 	lstr_Response
String   			ls_Nombre
String 			ls_parametros
String 			ls_retornotipo
String				ls_retorno[]
String				ls_error

is_dominio				=	''
ii_fila_nueva				=	0

lstr_Response			=	istr_parametros

is_codigoUsuario 		= lstr_Response.str_argumentos.s[1]

is_codigoLogin 		= lstr_Response.str_argumentos.s[2]


ii_idservidor			 	= lstr_Response.str_argumentos.i[1]
ii_idloginactual		 	= lstr_Response.str_argumentos.i[2]


ls_Nombre 				= 'TipoLogin'
ls_parametros			= "'"+String(gi_IdAplicacion)+',' +ls_Nombre+',' +'C' +"'" 
ls_retornotipo			= Trim(gf_objetobd_ejecutar( SQLCA,"Framework.ufn_ParametroTipoLogin_Default", ls_parametros))

If ls_retornotipo = 'N' Then 
	gf_mensaje(gs_Aplicacion,'Se deberá registrar la configuración del tipo de Login. ~n En el parámetro TipoLogin a nivel corporativo.', "",1)
	Return
Else
	is_tipologin = ls_retornotipo
End If

//Dominio
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",string(gi_IdAplicacion)+",0,0,'Dominio',1",ls_retorno, ls_Error)
if upperbound(ls_retorno)>0 then 
	is_dominio=ls_retorno[1]
End if

//Permisos
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",string(gi_IdAplicacion)+",0,0,'MantenerPermisosLogin',1",ls_retorno, ls_Error)
if upperbound(ls_retorno)>0 then 
	is_mantener_permiso=ls_retorno[1]
End if


dw_principal.event ue_retrieve( )	
dw_principal.event ue_poblardddw('TipoLogin')

end event

event ue_menu_popup;// **********************************************************************************
//	Descripción			:	Creación del menú emergente (Popup)
//
//	Argumentos			:	Ninguno
//
//	Valor de Retorno	:	Ninguno
//
//	Control de Versión:
//
//	Versión	Autor								Fecha				Descripción
//	1.0		Wilbert Santos	Mucha		23/04/2016		Versión inicial
// **********************************************************************************

m_response i_menu_popup

If ib_VentanaEditable = False Then Return

If	ib_MenuPopup = False Then Return

i_menu_popup = Create m_response
i_menu_popup.m_agregar.visible = TRUE
i_menu_popup.m_insertar.visible = TRUE
i_menu_popup.m_eliminar.visible = TRUE
i_menu_popup.m_exportar.visible = FALSE
i_menu_popup.m_div.visible=False


i_menu_popup.popmenu(   pointerx() + 20  ,   pointery()  + 208 )
end event

type p_cbcancelar from w_response_mtto`p_cbcancelar within w_usuario_loginactivo
end type

type p_cbaceptar from w_response_mtto`p_cbaceptar within w_usuario_loginactivo
end type

type cbx_filtros from w_response_mtto`cbx_filtros within w_usuario_loginactivo
integer y = 1700
end type

type dw_principal from w_response_mtto`dw_principal within w_usuario_loginactivo
integer x = 14
integer y = 4
integer width = 2281
integer height = 600
string dataobject = "dw_usuario_loginactivo"
end type

event dw_principal::itemchanged;call super::itemchanged;Integer li_Fila
Integer li_RowCount
String ls_Columna

ls_Columna = String(dwo.name)
Choose Case ls_Columna
	
Case  'loginsel'

		li_RowCount = This.RowCount( )
		 For li_Fila = 1 To li_RowCount
			  This.setitem( li_Fila, ls_Columna, 0 )
		 Next 
		 This.Post SetItem(row ,ls_Columna, 1 )

//Case  'tipologin'
//		If data ='U' Then   //Active Directory
//			 this.setitem(row,'codigologin',Upper(is_dominio)+'\'+is_codigoLogin)  
//		End If
//
End Choose
	
	Return AncestorReturnValue 
end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;this.setitem(ai_row,'codigousuario',is_codigousuario)
//this.setitem(ai_row,'codigologin',is_codigousuario)

this.setitem(ai_row,'codigologin',is_codigologin)

this.setitem(ai_row,'estado',1)

ii_fila_nueva		=	ai_row

this.trigger event itemchanged( ai_row,this.object.loginsel,String(1))


end event

event dw_principal::ue_poblardddw;call super::ue_poblardddw;Integer					li_Ret
Integer					li_IdArea
String		ls_parametros

datawindowchild		ldwc_Child

If	This.GetChild( as_columna, ldwc_Child ) < 1 Then Return
ldwc_Child.SetTransObject( SQLCA )


Choose case as_columna 			
	case 'TipoLogin'
		ls_parametros=String(gi_idaplicacion)+",0,0,C,TipoLogin"  
		li_Ret = ldwc_child.Retrieve(ls_parametros ,2) 
End choose
		
// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then 	ldwc_Child.Insertrow( 0 )


end event

event dw_principal::ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;String		ls_estado
Integer	li_ret
String		ls_codigousuario
String		ls_codigologin
Integer	li_idlogin

if ai_row < 1 then Return -1

if ii_fila_nueva >0 then
	gf_mensaje(gs_Aplicacion, 'Existen cambios pendientes, no se puede continuar','' ,2)
	Return -1
End if

ls_estado	=	this.getitemstring(ai_row, 'loginactivo')

if ls_estado='No' then
	if gf_mensaje(gs_Aplicacion, '¿Desea quitar la asignacion de Login al usuario?', '', 4) =1 then
		ls_codigousuario	=	dw_principal.GetItemString( ai_row, 'codigousuario')
		ls_codigologin		=	dw_principal.GetItemString( ai_row, 'codigologin')
		li_idlogin				=	dw_principal.GetItemNumber( ai_row, 'idlogin')
		li_ret	=	wf_quitar_login(ls_codigousuario,li_idlogin,ls_codigologin,0,gi_idservidor)
		if li_ret=0 then
			dw_principal.event ue_retrieve( )
		End if
	End if
else
	gf_mensaje(gs_Aplicacion, 'NO se puede quitar el registro de Login', '', 3) 
End if
Return -1
	


end event

event dw_principal::ue_retrieve;call super::ue_retrieve;// Se quita referencia de IDSERVIDOR

String	ls_ParametrosLogin
//ls_ParametrosLogin = ""+is_codigoUsuario+","+string(ii_idservidor)
//ls_ParametrosLogin = ""+is_codigoUsuario+"'"
Return this.Retrieve(1,is_codigoUsuario)
end event

event dw_principal::ue_agregar_registro_pre;call super::ue_agregar_registro_pre;if ii_fila_nueva >0 then
	gf_mensaje(gs_Aplicacion, 'Existen cambios pendientes, no se puede continuar','' ,2)
	Return -1
End if
end event

type cb_cancelar from w_response_mtto`cb_cancelar within w_usuario_loginactivo
integer x = 2386
integer y = 332
end type

event cb_cancelar::clicked;CloseWithReturn(parent,0)
end event

type cb_aceptar from w_response_mtto`cb_aceptar within w_usuario_loginactivo
integer x = 2386
integer y = 220
end type

event cb_aceptar::clicked;call super::clicked;String 			ls_codigoLogin
String				ls_tipoLogin
Long				ll_rowcount
Integer			li_fila_nueva
Integer			li_row
Integer			li_existelogin
Integer			li_rpta
Integer			li_valida
Integer			li_ret
Integer			li_ret_la
Integer			li_fila_login_sel
Integer			li_idloginactual
String				ls_codigoLogin_ant

dwItemStatus 	ldwis_Estado

dw_principal.accepttext( )

ll_rowcount	=	dw_principal.rowcount()

if ll_rowcount = 0 Then 	
	gf_mensaje(gs_Aplicacion, 'Debe ingresar un lógin para el Usuario','' ,2)
	Return
End If

li_ret				=	0
li_ret_la			=	0
li_fila_nueva		=	0
li_fila_login_sel	=	0

If	dw_principal.ModifiedCount( ) + dw_principal.DeletedCount( ) > 0  Then		//Si hay cambios, verificar nuevo registro
	For  li_row =  1 to  ll_rowcount
		ldwis_Estado = dw_principal.getitemstatus( li_row, 0, Primary! )
		If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then	
			li_fila_nueva=li_row
		End if
		if  dw_principal.GetItemNumber(li_row,'loginsel')=1 then li_fila_login_sel	=	li_row
	Next
End if	
	

if li_fila_nueva>0 then		//Nuevo Login

	ls_codigoLogin			=    dw_principal.getitemString(li_fila_nueva,'codigoLogin')  //codigousuario
	ls_tipoLogin				=    dw_principal.getitemString(li_fila_nueva,'tipologin')	   //tipo de login es S o A

	//Validar
	If len(ls_codigoLogin)= 0  or IsNull(ls_codigoLogin )  Then
		gf_mensaje(gs_Aplicacion, 'Debe ingresar un lógin de Usuario','' ,2)
		Return
	End If
		
	If len(ls_tipoLogin) = 0 Or IsNull(ls_tipoLogin) Then
		gf_mensaje(gs_Aplicacion, 'Debe seleccionar un tipo de lógin','' ,2)
		Return -1
	End If
	
	li_existelogin		=		dw_principal.find("codigoLogin = '"+ls_codigoLogin+"' and tipologin='"+ls_tipoLogin+"'", 1, ll_rowcount)
	If (li_existelogin > 0) and li_existelogin <>li_fila_nueva  Then
		gf_mensaje(gs_Aplicacion, 'Registro Duplicado porfavor ingrese un login diferente', '', 3)
		Return
	End If
	
	
	li_valida=  wf_valida_usuario_sql(ii_idservidor, ls_codigoLogin,is_codigoUsuario,ls_tipoLogin) 
	
	IF li_valida=1 then
		li_rpta	= gf_mensaje(gs_Aplicacion, 'Login ya existe en el servidor, desea registrar el login encontrado ?',ls_codigoLogin ,4)
		if li_rpta	=2 then 
			li_valida=-1
		else
			li_valida=0
		End if
	End if
	
	if li_valida=0 then	//Validacion OK
//		if gf_mensaje(gs_Aplicacion, 'Proceder con la creación del login para usuario ' + is_codigoUsuario +'  ?', '', 4) =1 then
	if gf_mensaje(gs_Aplicacion, 'Proceder con la creación del login para usuario ' + is_codigoLogin +'  ?', '', 4) =1 then
			li_ret	=	wf_crear_login(is_codigoUsuario,ls_codigoLogin,ls_tipoLogin,ii_idservidor)
			if li_ret=-1 then 
				gf_mensaje(gs_Aplicacion, 'No se pudo  crear Login ...verifique', '', 1) 
			else
				//Actualizar IDLogin en nueva fila
				dw_principal.SetItem(li_fila_nueva,'idlogin',li_ret)
				dw_principal.accepttext( )
			End if
		End if
	End if	
End if


//Login actual
if li_fila_login_sel > 0 then
	li_idloginactual	=	 dw_principal.GetItemNumber(li_fila_login_sel,'idlogin')
	ls_codigoLogin	=	 dw_principal.GetItemString(li_fila_login_sel,'codigologin')
	ls_tipoLogin		=    dw_principal.getitemString(li_fila_login_sel,'tipologin')	   //tipo de login es S o A
	if li_idloginactual   <>	 ii_idloginactual	 then
		ls_codigoLogin_ant	=	dw_principal.getitemstring(dw_principal.Find("idlogin="+String(ii_idloginactual),1,ll_rowcount) ,'codigologin')
		li_ret_la=wf_setear_login_actual(ii_idservidor,is_codigoUsuario,li_idloginactual,ls_codigoLogin,ls_tipoLogin,ls_codigoLogin_ant)
		if li_ret_la=1 then li_ret_la=5
//		ii_idloginactual=li_idloginactual
	End if
End if

li_ret	=	li_ret + li_ret_la
CloseWithReturn(parent,li_ret)

//
//For  ll_row =  1 to  dw_principal.rowcount()
//	setnull(li_loginsel) 
//	li_loginsel =  dw_principal.getitemnumber(ll_row,'LoginSel')
//	If li_loginsel = 1  Then
//			ll_IdLogin				=    dw_principal.getitemnumber(ll_row,'IdLogin')    //nuevo es cero //si existe tiene valor
//			ls_codigoUsuario		=    dw_principal.getitemString(ll_row,'codigousuario')  //codigousuario
//			ls_codigoLogin			=    dw_principal.getitemString(ll_row,'codigoLogin')  //codigousuario
//			ls_tipoLogin				=    dw_principal.getitemString(ll_row,'tipologin')	   //tipo de login es S o A
//			
//			
//			If len(ls_codigoLogin)= 0  or IsNull(ls_codigoLogin )  Then
//				gf_mensaje(gs_Aplicacion, 'Debe ingresar un lógin de Usuario','' ,2)
//				Return
//			End If
//
//			If len(ls_tipoLogin) = 0 Or IsNull(ls_tipoLogin) Then
//				gf_mensaje(gs_Aplicacion, 'Debe seleccionar un tipo de lógin','' ,2)
//				Return
//			End If
//			
//			
//		li_existelogin		=		dw_principal.find("codigoLogin = '"+ls_codigoLogin+"'", 1, dw_principal.rowcount())
//		If (li_existelogin > 0 and ll_row <> li_existelogin) Then
//			gf_mensaje(gs_Aplicacion, 'Registro Duplicado porfavor ingrese un login diferente', '', 3)
//			Return 
//		End If
//
//		li_existetipo			=		dw_principal.find("tipologin = '"+ls_tipoLogin+"'", 1, dw_principal.rowcount())
//			If (li_existetipo > 0 and ll_row <> li_existetipo ) Then
//				gf_mensaje(gs_Aplicacion, 'Registro Duplicado porfavor seleccione un Tipo diferente', '', 3)
//				Return 
//			End If
//		
//	End If
//Next 
//
//
//
//istr_Response.str_argumentos.i[1] = ll_IdLogin
//istr_Response.str_argumentos.s[1] = ls_codigoLogin
//istr_Response.str_argumentos.s[2] = ls_tipoLogin
//istr_Response.str_argumentos.b[1] = True
//
//
//dwItemStatus   ldwis_Estado
//
//ldwis_Estado 	= dw_principal.getitemstatus( dw_principal.GetRow(), 0, Primary!) 
//If	ldwis_Estado= New! Or ldwis_Estado = NewModified! Then
//	ls_modo='N' 
//	li_rpta2= gf_mensaje(gs_Aplicacion, 'Desea crear usuario a partir del Login seleccionado?',ls_codigoLogin ,4)
//		if li_rpta2=2 then 
//			li_rpta = -1
//			Return li_rpta
//			istr_Response.str_argumentos.b[1] = False
//		Else
//			li_rpta=  wf_valida_usuario_sql(ii_idservidor, ls_codigoLogin,ls_codigoUsuario,ls_tipoLogin) 
//			if ls_modo='N' then
//				if li_rpta=1 then
//					li_rpta2= gf_mensaje(gs_Aplicacion, 'Login ya existe en el servidor....desea crear usuario a partir del Login?',ls_codigoLogin ,4)
//					if li_rpta2=2 then 
//						li_rpta = -1
//						Return li_rpta
//					End if
//		//			
 
//				else
//					if gf_mensaje(gs_Aplicacion, 'Proceder con la creación del usuario?', '', 4) = 2 then	li_rpta = -1
//				End if
//			End if
//		End if
//Else    //No Modify
//	li_rpta2= gf_mensaje(gs_Aplicacion, 'Esta seguro de asignar para el Usuario el Login seleccionado?',ls_codigoLogin ,4)
//		if li_rpta2=2 then 
//			li_rpta = -1
//			istr_Response.str_argumentos.b[1] = False
//			Return li_rpta
//		End If
//End If
//
// 
//CloseWithReturn( parent , istr_Response )


end event

type st_mensaje from w_response_mtto`st_mensaje within w_usuario_loginactivo
end type

type st_titulo from statictext within w_usuario_loginactivo
boolean visible = false
integer x = 46
integer y = 32
integer width = 2080
integer height = 60
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
long textcolor = 255
long backcolor = 67108864
string text = "Titulo"
boolean focusrectangle = false
end type

