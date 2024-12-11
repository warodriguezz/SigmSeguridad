$PBExportHeader$w_usuarios.srw
forward
global type w_usuarios from w_base
end type
type tab_user from tab within w_usuarios
end type
type tabpage_detalles from userobject within tab_user
end type
type dw_detalle from uo_dwbase within tabpage_detalles
end type
type dw_acceso_unidad from uo_dwbase within tabpage_detalles
end type
type tabpage_detalles from userobject within tab_user
dw_detalle dw_detalle
dw_acceso_unidad dw_acceso_unidad
end type
type tabpage_aplicaciones from userobject within tab_user
end type
type tv_perfilmenu from treeview within tabpage_aplicaciones
end type
type dw_usuaplicacion from uo_dwbase within tabpage_aplicaciones
end type
type dw_perfil from uo_dwbase within tabpage_aplicaciones
end type
type tabpage_aplicaciones from userobject within tab_user
tv_perfilmenu tv_perfilmenu
dw_usuaplicacion dw_usuaplicacion
dw_perfil dw_perfil
end type
type tabpage_acceso from userobject within tab_user
end type
type dw_basedatos from uo_dwbase within tabpage_acceso
end type
type dw_accesobd from uo_dwbase within tabpage_acceso
end type
type dw_accesovista from uo_dwbase within tabpage_acceso
end type
type tabpage_acceso from userobject within tab_user
dw_basedatos dw_basedatos
dw_accesobd dw_accesobd
dw_accesovista dw_accesovista
end type
type tab_user from tab within w_usuarios
tabpage_detalles tabpage_detalles
tabpage_aplicaciones tabpage_aplicaciones
tabpage_acceso tabpage_acceso
end type
type em_buscar from uo_edm_texto within w_usuarios
end type
type st_busqueda from statictext within w_usuarios
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_usuarios
end type
type sle_buscar from singlelineedit within w_usuarios
end type
end forward

global type w_usuarios from w_base
integer width = 5719
integer height = 2776
integer ii_modoventana = 2
long il_alturatitulo = 100
tab_user tab_user
em_buscar em_buscar
st_busqueda st_busqueda
dw_filtro_servidor dw_filtro_servidor
sle_buscar sle_buscar
end type
global w_usuarios w_usuarios

type variables
Boolean		ib_agrupado=TRUE
String			is_campobuscar='codigousuario'
String			is_codusuario
Boolean		ib_usuariook


Long					il_Idaplicacion
Long 					il_IdPerfil
Integer				ii_idbasedatos
Integer				ii_idservidor

Integer				ii_dias_clave=90
Integer				ii_dias_vista=1

Long					il_idmaxvista

uo_dsbase			ids_Menus 

Long	  				il_perfil_ant
String  				is_nombreperfil_ant
String					is_tipologin_def

String					is_dominio
string					is_asigna_unidad   	//utilizado durante la agregación y eliminación de unidad
string   				is_carga_sustento
Integer 				ii_fila_busqueda

uo_documento     iuo_documento

Integer				ii_flg_crealogin
String					is_documento_sustento
Boolean				ib_nuevo_user	
String					is_numdoc

end variables

forward prototypes
public subroutine uf_desactivar (string as_campo, datawindow ad_dw)
public subroutine uf_activar (string as_campo, integer ai_order, datawindow ad_dw)
public function integer wf_valida_usuario (string as_codusuario, string as_tipo, string as_modo)
public function integer wf_valida_usuario_sql (string as_codusuario, string as_tipo)
public function integer wf_crear_usuario_login (string as_codigousuario)
public function integer wf_valida_perfilbasedatosrol (long ll_perfil)
public function integer wf_valida_usuarioperfilbasedatosrol (long ll_perfil)
public function integer wf_usuario_loginactivo (string as_codigousuario, string as_codigologin, integer ai_id_login_actual)
public function string wf_correlativo_doc (string as_tipo)
public function integer wf_adjunta_sustento (string as_proceso, ref string as_documento_sustento, string as_codigousuario, string as_idusuario)
public function integer wf_limpiar_detalle (character ac_tipotrabajado)
public subroutine wf_ver_sustento (string as_idcarpeta)
public function integer wf_auditoria_detalle (string as_codusuario, string as_obsevacion)
end prototypes

public subroutine uf_desactivar (string as_campo, datawindow ad_dw);ad_dw.modify (as_campo + ".background.color=" + string(rgb(0,111,164)))
ad_dw.SetTabOrder (as_campo, 0)




end subroutine

public subroutine uf_activar (string as_campo, integer ai_order, datawindow ad_dw);ad_dw.modify (as_campo + ".background.color= 16777215")
ad_dw.SetTabOrder (as_campo, ai_order)
end subroutine

public function integer wf_valida_usuario (string as_codusuario, string as_tipo, string as_modo);Long ll_rowUsu
Long ll_rowDoc
String ls_numeroDocumento
String ls_Parametros
String ls_retorno[]
String	ls_ret
String ls_Error 
Integer li_retorno
Date ld_fechaalta
Date ld_fechabaja
Integer	li_retornoOUT
String	ls_tipocia
String	ls_cip

tab_user.Tabpage_detalles.dw_detalle.accepttext( )

ls_numeroDocumento = tab_user.Tabpage_detalles.dw_detalle.getitemstring( tab_user.Tabpage_detalles.dw_detalle.getrow(),'numerodocumento')
ld_fechaalta =  tab_user.Tabpage_detalles.dw_detalle.getitemdate( tab_user.Tabpage_detalles.dw_detalle.getrow(),'fechaalta')
ld_fechabaja = tab_user.Tabpage_detalles.dw_detalle.getitemdate( tab_user.Tabpage_detalles.dw_detalle.getrow(),'fechacaducidadcuenta')
ls_tipocia		=	tab_user.Tabpage_detalles.dw_detalle.getitemstring( tab_user.Tabpage_detalles.dw_detalle.getrow(),'tipocorporativo')
ls_cip			=	tab_user.Tabpage_detalles.dw_detalle.getitemstring( tab_user.Tabpage_detalles.dw_detalle.getrow(),'cip')

// validar fechas
if  ld_fechaalta >  ld_fechabaja then
	gf_mensaje(gs_Aplicacion, 'Verirficar la fecha de alta y caducidad de cuenta', '', 1)
	return  -1
end if 

//Para nuevos
if as_modo = 'N' then
	if ls_tipocia='C'   then
		if IsNull(ls_cip) or Len(ls_cip)<2 then
			gf_mensaje(gs_Aplicacion, 'Codigo CIP necesario para tipo COMPAÑIA ', '', 1)
			return -1
		End if
	End if
End if
		

Choose case as_tipo
	case 'S'		
		
		if as_modo='N' then
			
			//ll_rowUsu = dw_principal.find ("codigousuario = '"+as_codusuario+"'",1,dw_principal.rowcount())
			ll_rowDoc =  dw_principal.find ("numerodocumento = '"+ls_numeroDocumento+ "'",1,dw_principal.rowcount())
//			If ll_rowUsu > 0    then 
//				gf_mensaje(gs_Aplicacion, 'El código de usuario ya existe', '', 1)
//				return -1
//			end if 
			
			If ll_rowDoc > 0 then 
				gf_mensaje(gs_Aplicacion, 'El número de documento  ya existe ', '', 1)
				return -1
			end if 
			
		End if
	
		
	case 'U'
		//Validacion Active Directory
		//Open(w_valida_usuario_dominio)
End choose


Return 1
end function

public function integer wf_valida_usuario_sql (string as_codusuario, string as_tipo);//1.1		09/09/2024		Eliminar IdServidor

Integer	li_ret
String		ls_parametros
Integer	li_retornoOUT
String		ls_ret


// Validacion usuario en servidor SQL
//ls_Parametros = "1,"+String( ii_idservidor) + ",' ','"+as_codusuario +"','"+as_tipo+"',"+String(li_retornoOUT)
ls_Parametros = "1,"+ ",' ','"+as_codusuario +"','"+as_tipo+"',"+String(li_retornoOUT)	//1.1
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Validar",ls_Parametros)  
If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL ', '', 2)
	Return -1
End if

li_ret	=	Integer(ls_ret)

//if li_ret=0 then
//	gf_mensaje(gs_Aplicacion, 'El usuario ' +as_codusuario +' SQL aún no esta creado en el servidor ', '', 3)		
//else
//	gf_mensaje(gs_Aplicacion, 'Usuario SQL validado ', '', 1)
//End if


Return li_ret
end function

public function integer wf_crear_usuario_login (string as_codigousuario);//Crear usuario a partir de Login
Integer		li_ret=1
Integer		li_fila_new
String			ls_tipo_default='S'

li_fila_new	=	tab_user.tabpage_detalles.dw_detalle.GetRow()
if li_fila_new<1 then Return -1

//Valores por default
tab_user.tabpage_detalles.dw_detalle.setitem(li_fila_new,'tipocorporativo',ls_tipo_default)
tab_user.tabpage_detalles.dw_detalle.setitem(li_fila_new,'TipoLogin','S')   
tab_user.tabpage_detalles.dw_detalle.setitem(li_fila_new,'estado','A')
tab_user.tabpage_detalles.dw_detalle.accepttext( )


Return li_ret


end function

public function integer wf_valida_perfilbasedatosrol (long ll_perfil);// 1.1		09/19/2024		Se elimina ID Servidor
Integer	li_ret
String		ls_parametros
Integer	li_retornoOUT
String		ls_ret

// Validacion usuario en servidor SQL
//ls_parametros	=	String(il_IdAplicacion)+","+String(ll_perfil)+","+String(ii_idservidor)+","+String(li_retornoOUT)
ls_parametros	=	String(il_IdAplicacion)+","+String(ll_perfil)+","+String(li_retornoOUT)		//1.1
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_PerfilBaseDatosRol",ls_Parametros)  
If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL ', '', 2)
	Return -1
End if

li_ret	=	Integer(ls_ret)



Return li_ret
end function

public function integer wf_valida_usuarioperfilbasedatosrol (long ll_perfil);Integer	li_ret
String		ls_parametros
Integer	li_retornoOUT
String		ls_ret

// Validacion usuario en servidor SQL
ls_parametros	=	String(il_IdAplicacion)+","+String(ll_perfil)+",'"+ is_codusuario+"',"+String(li_retornoOUT)
ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_UsuarioPerfilBaseDatosRol",ls_Parametros)  
If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL ', '', 2)
	Return -1
End if

li_ret	=	Integer(ls_ret)



Return li_ret
end function

public function integer wf_usuario_loginactivo (string as_codigousuario, string as_codigologin, integer ai_id_login_actual);str_response		lstr_Response	
Integer				li_ret

/*Cargar los argumentos que se pasarán a la ventana seleccionar */
lstr_Response.b_usar_datastore  	= False									// Indica que se usará un dataobject
lstr_Response.s_titulo     			= 'Login por usuario'        			// Título de la Ventana
lstr_Response.s_dataobject 			= 'dw_usuario_loginactivo'            // Dataobject a utilizar 
lstr_Response.b_ventanaeditable	= True
lstr_Response.b_menupopup	   	= True
lstr_Response.b_activar_filtros 		= True

lstr_Response.str_argumentos.s[1] = as_codigousuario
lstr_Response.str_argumentos.s[2] = as_codigologin

lstr_Response.str_argumentos.i[1] = ii_idservidor
lstr_Response.str_argumentos.i[2] = ai_id_login_actual

Openwithparm( w_usuario_loginactivo , lstr_Response )

li_ret	 =Integer( Message.DoubleParm )

if li_ret>=5 then	//Cambio login activo
	setredraw(FALSE)
	tab_user.tabpage_detalles.dw_detalle.event ue_retrieve( )
	setredraw(TRUE)
End if

//if IsValid(lstr_Response)=False then Return -1
//
//If lstr_Response.str_argumentos.b[1] = False Then Return -1
// 
// li_idLogin 		= lstr_Response.str_argumentos.i[1]
// ls_codigoLogin = lstr_Response.str_argumentos.s[1]
// ls_tipoLogin   	= lstr_Response.str_argumentos.s[2]
// 
//
//if isnull(li_idLogin) Then li_idLogin = 0
//
//li_fila_new	=	tab_user.tabpage_detalles.dw_detalle.GetRow()
//if li_fila_new<1 then Return -1
//
//	ls_codigoLogin_ant  = tab_user.tabpage_detalles.dw_detalle.getitemstring(li_fila_new,'codigologin')  
//	
//	tab_user.tabpage_detalles.dw_detalle.setitem(li_fila_new,'LoginActivo',li_idLogin)
//	tab_user.tabpage_detalles.dw_detalle.setitem(li_fila_new,'codigologin', ls_codigoLogin)   //campo store LoginName  campo rsp = ls_codigoLogin
//	tab_user.tabpage_detalles.dw_detalle.setitem(li_fila_new,'tipologin', ls_tipoLogin)  
//
//
////		//cambios de Login permisos por usuario
//////		If li_rpta > 0 Then
//////				ls_Parametros = string(il_Idaplicacion)+","+string(ll_perfil_New)+","+string(il_perfil_ant)+","+string(is_codusuario)+","+string(ii_idservidor)
////				ls_Parametros = string(is_codusuario)+","+string(ls_codigoLogin)+","+string(ls_codigoLogin_ant)+","+string(ii_idservidor)
//			
//			ls_Parametros =  "'"+is_codusuario +"','"+ls_codigoLogin +"','"+ls_tipoLogin +"','"+ls_codigoLogin_ant+"',"+String( ii_idservidor) 
//			
//			li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_UsuarioLoginPerfilBaseDatosRol", ls_Parametros, ls_retorno, ls_Error)
//////				If li_retorno < 0 Then  Return -1
//////		End If
//
//	This.ib_editando=true
//	If this.event ue_grabar( ) <> 1 Then Return -1
//


RETURN 1
	
			

end function

public function string wf_correlativo_doc (string as_tipo);String		ls_documentocorr
String		ls_tipo	

ls_tipo	="'"+trim(as_tipo)+"'"
ls_documentocorr		=	gf_objetobd_ejecutar(sqlca, 'Seguridad.ufn_CorrelativoDocumento', ls_tipo)

Return ls_documentocorr
end function

public function integer wf_adjunta_sustento (string as_proceso, ref string as_documento_sustento, string as_codigousuario, string as_idusuario);//Se agregan sustentos.

String		ls_Parametros
String		ls_ret
Integer	li_accion
String		ls_tipo

str_response lstr_Response
is_documento_sustento=''

IF is_carga_sustento = 'N' Then Return 1

Choose case Upper(as_proceso)
	case 'ALTA'
		li_accion=1
	case 'BAJA'
		li_accion=0
	case 'MODIFIACION'
		li_accion=3
End choose

ls_tipo=as_proceso

lstr_Response.b_usar_datastore		= False
lstr_Response.s_dataobject 				= 'dw_carga_documentos'
lstr_Response.s_titulo     				= 'Subida de Documentos  '   + as_proceso
lstr_Response.s_titulos_columnas		= "" 
lstr_Response.l_ancho					= 6000
lstr_Response.l_alto						= 2000
lstr_Response.b_ventanaeditable		= True
lstr_Response.b_menupopup 			= True 
//lstr_Response.b_redim_ventana		= True
lstr_Response.b_redim_controles		= True
lstr_Response.s_mensaje				= "El archivo seleccionado, NO debe existir en la carpeta del usuario, válide un nombre único"
lstr_Response.str_argumentos.s[1]  	= ls_tipo
lstr_Response.str_argumentos.s[2] 	= as_codigousuario
lstr_Response.str_argumentos.s[3] 	= as_idusuario



OpenWithParm(w_carga_documentos,	lstr_Response)

lstr_Response = message.powerobjectparm 

If lstr_Response.str_argumentos.b[1] = False Then Return -1 
as_documento_sustento = lstr_Response.str_argumentos.s[1]
is_documento_sustento  = as_documento_sustento
If  isnull(as_documento_sustento) or len (as_documento_sustento) = 0 Then 
	gf_mensaje(gs_Aplicacion, 'Falta, no incluyo un documento valido para el proceso', '', 2)
	Return -1
End if

////Registrar Historico Permiso
////If ( li_sustento_perfil > 0  )  Then 
//		ls_Parametros = "'"+as_idusuario+"',"+String(li_accion) +",'"+is_documento_sustento +"'"
//		ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_Usuario_Historico_Permiso_Insert ",ls_Parametros)  //1.0
//		If ls_ret = "SQL:-1" Then 
//			gf_mensaje(gs_Aplicacion, 'No se pudo registrar la acción en el registro historico de permisos ', '', 2)
//		End if		 
////End IF

return 1
end function

public function integer wf_limpiar_detalle (character ac_tipotrabajado);Integer					li_fila
String						ls_null
Date						ld_null
datawindowchild		ldwc_Child


SetNull(ls_null)
SetNull(ld_null)

uo_dwbase		uo_dwdetalle	
li_fila	=	tab_user.tabpage_detalles.dw_detalle.GetRow()
If li_fila>0 then
	
	uo_dwdetalle=tab_user.tabpage_detalles.dw_detalle
		
	If	uo_dwdetalle.GetChild( 'tipocorporativo', ldwc_Child ) >0 Then 
		ldwc_Child.SetTransObject( SQLCA )
		is_tipologin_def=ldwc_Child.GetItemstring(ldwc_Child.GetRow(),'Valor3')
	End if

	uo_dwdetalle.SetItem(li_fila,'cip',ls_null)
	uo_dwdetalle.SetItem(li_fila,'nombre',ls_null)
	uo_dwdetalle.SetItem(li_fila,'apellidopaterno',ls_null)
	uo_dwdetalle.SetItem(li_fila,'apellidomaterno',ls_null)
	uo_dwdetalle.SetItem(li_fila,'numerodocumento',ls_null)
	uo_dwdetalle.SetItem(li_fila,'tipologin',is_tipologin_def)
	
	uo_dwdetalle.SetItem(li_fila,'nombrecompleto',ls_null)
	uo_dwdetalle.SetItem(li_fila,'area',ls_null)
	uo_dwdetalle.SetItem(li_fila,'area_sup',ls_null)
	uo_dwdetalle.SetItem(li_fila,'cargo',ls_null)
	uo_dwdetalle.SetItem(li_fila,'email',ls_null)
	uo_dwdetalle.SetItem(li_fila,'fechaalta',ld_null)
	uo_dwdetalle.SetItem(li_fila,'fechabaja',ld_null)
	uo_dwdetalle.SetItem(li_fila,'idcarpeta',ls_null)

End if
Return 1














end function

public subroutine wf_ver_sustento (string as_idcarpeta);String ls_NombreArchivo
String ls_Parametros
string  ls_DirectorioDoc,ls_Ruta
long ll_rpta
String    ls_usuario
String  ls_dominio
String ls_clave
Long il_Token
String     ls_ParametroWS_LogonUser
String    ls_retorno4[]
string   ls_error

IF NOT IsValid(iuo_documento) THEN iuo_documento = CREATE uo_documento

//*Paramteros*//
ls_Parametros = ",0,0,'RutaArchivoSustento',1"

//ls_ParametroWS_LogonUser = string(gi_IdAplicacion)+",0,0,'WS_LogonUser',1"
//gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",ls_ParametroWS_LogonUser,ls_retorno4, ls_Error)
//If UpperBound(ls_retorno4)<=0 Then
//	gf_mensaje(gs_Aplicacion, 'No se encontro el parametro WS_LogonUser ,comuniquese con el Area de Sistemas', '', 3)
//	RETURN
//Else
//	ls_dominio= ls_retorno4[1]
//	ls_usuario = ls_retorno4[2]
//	ls_clave     = ls_retorno4[3]
//End If

////Impersonalizacion
//il_Token = iuo_documento.uf_Impersonalizar(ls_usuario, ls_dominio, ls_clave)   
//IF il_Token = 0 THEN  RETURN 
//
//Obtener directorio de parametros
ll_rpta = iuo_documento.uf_obtener_directorio( ls_Parametros, ls_DirectorioDoc)
IF ll_rpta = -1 THEN RETURN 


ls_Ruta  = ls_DirectorioDoc +"\"+as_idcarpeta

	
ll_rpta = iuo_documento.uf_abrir_archivo(ls_Ruta)
IF ll_rpta = 2 THEN
	gf_mensaje(gs_Aplicacion, 'No existe archivo en la ruta especificada', '', 3)
//	IF il_Token >0 THEN
//		RevertToSelf()
//		CloseHandle(il_Token)	
//	END IF
//	Return
END IF

//IF il_Token >0 THEN
//	RevertToSelf()
//	CloseHandle(il_Token)	
//END IF
	

Return
end subroutine

public function integer wf_auditoria_detalle (string as_codusuario, string as_obsevacion); //Auditoria por usuarios
//Se agregan sustentos.

String			ls_Parametros
String			ls_ret
Integer		li_accion
String			ls_tipo
DateTime	ldt_fechahoraactual
Date			ldt_fechaactual

SQLCA.uf_usp_fechahora_select(ldt_fechahoraactual)
ldt_fechaactual	=	Date(ldt_fechahoraactual)

str_response lstr_Response

lstr_Response.b_usar_datastore		= False
lstr_Response.s_dataobject 				= 'dw_usuario_auditoria'
lstr_Response.s_titulo     				= 'Auditoria de usuario  ' + as_codusuario
lstr_Response.s_titulos_columnas		= "" 
lstr_Response.l_ancho					= 4300
lstr_Response.l_alto						= 2000
lstr_Response.b_ventanaeditable		= True
lstr_Response.b_menupopup 			= False
lstr_Response.b_redim_ventana		= True
lstr_Response.b_redim_controles		= False
lstr_Response.b_usariconos				= False
lstr_Response.s_accionalabrir			= 'R'
lstr_Response.str_argumentos.s[1]  	= as_codusuario
lstr_Response.str_argumentos.s[2]  	=String(Year(ldt_fechaactual))+String(Month(ldt_fechaactual))+"01"
lstr_Response.str_argumentos.s[3]  	= String(ldt_fechaactual ,"yyyymmdd")
lstr_Response.str_argumentos.s[4]  	=  as_obsevacion

OpenWithParm(w_consulta_detalle_usuario,	lstr_Response)

lstr_Response = message.powerobjectparm 
Return 1

end function

on w_usuarios.create
int iCurrent
call super::create
this.tab_user=create tab_user
this.em_buscar=create em_buscar
this.st_busqueda=create st_busqueda
this.dw_filtro_servidor=create dw_filtro_servidor
this.sle_buscar=create sle_buscar
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_user
this.Control[iCurrent+2]=this.em_buscar
this.Control[iCurrent+3]=this.st_busqueda
this.Control[iCurrent+4]=this.dw_filtro_servidor
this.Control[iCurrent+5]=this.sle_buscar
end on

on w_usuarios.destroy
call super::destroy
destroy(this.tab_user)
destroy(this.em_buscar)
destroy(this.st_busqueda)
destroy(this.dw_filtro_servidor)
destroy(this.sle_buscar)
end on

event resize;call super::resize;SetRedraw(False)

	dw_filtro_servidor.y			=	BordeHorizontal + il_AlturaTitulo
	dw_filtro_servidor.x			=	BordeVertical
	dw_filtro_servidor.width 	 	=	newwidth - ( newwidth - 1550)
	dw_filtro_servidor.height  	=   il_AlturaTitulo -  BordeHorizontal  
	
	st_busqueda.x			=	(dw_filtro_servidor.x	+ dw_filtro_servidor.width)
	st_busqueda.y			=	dw_filtro_servidor.y
	
	sle_buscar.y			=	dw_filtro_servidor.y
	sle_buscar.x			=	(st_busqueda.x	+ st_busqueda.width) + 10
	sle_buscar.width 	 	= 1550
	sle_buscar.height 		= 	dw_filtro_servidor.height


	dw_principal.y = ( dw_filtro_servidor.y + dw_filtro_servidor.height ) + BordeHorizontal
	dw_principal.x = BordeVertical
	dw_principal.width = (newwidth - ( BordeVertical * 2 )) / 2
	dw_principal.height = ( newheight - ( BordeHorizontal * 2 ) - il_AlturaTitulo ) - dw_filtro_servidor.height
	
	tab_user.y		=	dw_principal.y 
	tab_user.x		=	dw_principal.x + 	dw_principal.width + BordeVertical
	tab_user.width  = (newwidth - ( BordeVertical * 2 )) / 2
	tab_user.height = dw_principal.height
	
	
	//cambios
	
	tab_user.tabpage_acceso.dw_basedatos.x = tab_user.x
	tab_user.tabpage_acceso.dw_basedatos.y = tab_user.y
	tab_user.tabpage_acceso.dw_basedatos.width =  (1111 - ( BordeVertical * 2 )) / 2
	tab_user.tabpage_acceso.dw_basedatos.height = 1892 
	
	
	
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.y 			= tab_user.tabpage_aplicaciones.y
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.x 			= tab_user.tabpage_aplicaciones.x
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.height 		= dw_principal.height /2   
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.width		= tab_user.width /2 


	
	tab_user.tabpage_aplicaciones.dw_perfil.y 						= tab_user.tabpage_aplicaciones.dw_usuaplicacion.y + tab_user.tabpage_aplicaciones.dw_usuaplicacion.height
	tab_user.tabpage_aplicaciones.dw_perfil.x 						= tab_user.tabpage_aplicaciones.dw_usuaplicacion.x
	tab_user.tabpage_aplicaciones.dw_perfil.height 				= (dw_principal.height /2) - 260  
	tab_user.tabpage_aplicaciones.dw_perfil.width 				= tab_user.width /2 
	
//	tab_user.tabpage_aplicaciones.dw_usuaplicacion.y =tab_user.tabpage_aplicaciones.dw_perfil.y + tab_user.tabpage_aplicaciones.dw_perfil.height
//	tab_user.tabpage_aplicaciones.dw_usuaplicacion.x =tab_user.tabpage_aplicaciones.dw_perfil.x
//	tab_user.tabpage_aplicaciones.dw_usuaplicacion.height = (dw_principal.height /2) - 260  
//	tab_user.tabpage_aplicaciones.dw_usuaplicacion.width = tab_user.width /2 
	
	
	tab_user.tabpage_aplicaciones.tv_perfilmenu.y = tab_user.tabpage_aplicaciones.dw_usuaplicacion.y 
	tab_user.tabpage_aplicaciones.tv_perfilmenu.x = tab_user.tabpage_aplicaciones.dw_usuaplicacion.x  +  tab_user.tabpage_aplicaciones.dw_usuaplicacion.width                       
	tab_user.tabpage_aplicaciones.tv_perfilmenu.height = dw_principal.height   -  260  
	tab_user.tabpage_aplicaciones.tv_perfilmenu.width = ( tab_user.width /2 ) -50

//cambios

	//Dimensionar TAB
	gf_resize_tab (tab_user)


SetRedraw(True)

end event

event ue_nuevo_pre;call super::ue_nuevo_pre;if dw_filtro_servidor.ib_ServerDisponible=False then Return -1

tab_user.selectedtab=1
tab_user.tabpage_acceso.enabled=False
tab_user.tabpage_aplicaciones.enabled=False
tab_user.tabpage_detalles.dw_acceso_unidad.enabled=False

tab_user.tabpage_detalles.dw_detalle.event ue_agregar_registro( )

Return -1	//Los registros nuevos se controlan en el detalle
end event

event open;call super::open;String		ls_retorno[]
String		ls_error
String		ls_retornotipo
String		ls_parametros

ids_Menus = CREATE uo_dsbase
ids_Menus.dataobject = 'dw_menu_perfil'
ids_Menus.SetTransObject(SQLCA)

//Parametros
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",string(gi_IdAplicacion)+",0,0,'DiasVctoCuenta',1",ls_retorno, ls_Error)
if upperbound(ls_retorno)>0 then 
	ii_dias_clave=Integer(ls_retorno[1])
End if

gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",string(gi_IdAplicacion)+",0,0,'DiasAccesoVista',1",ls_retorno, ls_Error)
if upperbound(ls_retorno)>0 then 
	ii_dias_vista=Integer(ls_retorno[1])
End if


//Parametros
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",string(gi_IdAplicacion)+",0,0,'CargaSustento',1",ls_retorno, ls_Error)
if upperbound(ls_retorno)>0 then 
	is_carga_sustento=ls_retorno[1]
End if

////Tipo login def
//ls_parametros			= "'"+String(gi_IdAplicacion)+",TipoLogin,C'"
//ls_retornotipo			= Trim(gf_objetobd_ejecutar( SQLCA,"Framework.ufn_ParametroTipoLogin_Default", ls_parametros))
//If ls_retornotipo = 'N' Then 
//	 is_tipologin_def = 'S'
//Else
//	is_tipologin_def = ls_retornotipo
//End If
					
//Parametro dominio
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",string(gi_IdAplicacion)+",0,0,'Dominio',1",ls_retorno, ls_Error)
if upperbound(ls_retorno)>0 then 
	is_dominio=ls_retorno[1]
Else
	is_dominio		=	'CMBSAA'	
End if

// Busqueda
em_buscar.istr_bus.uodw_datawin    =	 dw_principal
em_buscar.istr_bus.b_secuencial 		= 	TRUE
em_buscar.istr_bus.s_columna    		=	 'codigologin'  //* codigousuario
em_buscar.istr_bus.s_tipobusca		=	'N'

is_tipologin_def='U'



end event

event ue_cancelar;call super::ue_cancelar;this.ib_Editando = False
this.Event ue_editar( )	
this.setfocus( )


if idw_dwactual = dw_principal then
	dw_principal.event ue_retrieve( )
End if
end event

event ue_grabar_post;call super::ue_grabar_post;tab_user.tabpage_aplicaciones.enabled=true
if idw_dwactual=tab_user.tabpage_detalles.dw_detalle then
	dw_principal.event ue_retrieve( )


Else
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.event ue_retrieve( )
End if
return  1
end event

event ue_rellenar_treeview;call super::ue_rellenar_treeview;if  il_IdPerfil =  0 then return 

Integer 			liFila
Integer 			liNumFil
String				ls_parametros
long				tvi_hdl = 0
Integer  			li_handle[]
treeviewitem 	tv_listi

tab_user.tabpage_aplicaciones.tv_perfilmenu.SetRedraw( FALSE )

DO UNTIL tab_user.tabpage_aplicaciones.tv_perfilmenu.FindItem(RootTreeItem!, 0) = -1
	tab_user.tabpage_aplicaciones.tv_perfilmenu.DeleteItem(tvi_hdl)
LOOP

ids_Menus.Reset()
//ls_parametros	=	String(ii_idservidor)+","+String(il_IdAplicacion)+","+String(il_IdPerfil)
ls_parametros	=	String(il_IdAplicacion)+","+String(il_IdPerfil)
liNumFil =  ids_Menus.retrieve(ls_parametros)
 
Integer	li_nivelMenu
Integer	li_nivel[]
String		ls_menu[]
String		ls_acceso[]
Integer	li_idmenu[]
Integer	li_idmenuAnt[]

Integer liData

 li_idmenuAnt[1]=0
 li_idmenuAnt[2]=0
 li_idmenuAnt[3]=0
 li_idmenuAnt[4]=0
 
FOR liFila = 1 TO liNumFil

	//***********Primer Nivel***************
	li_nivelMenu						= 1
	li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel1' )
	ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu1' )
	ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu1' ))
	li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id1' )
	if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
	
	//Item , Solo una vez
	if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
		if Upperbound(li_handle)>0 then tab_user.tabpage_aplicaciones.tv_perfilmenu.ExpandAll(li_handle[li_nivelMenu])  //Expandir todos los hijos al terminar cada menu en nivel 1
		li_idmenuAnt[li_nivelMenu]= li_idmenu[li_nivelMenu]
		li_handle[li_nivelMenu]	  = tab_user.tabpage_aplicaciones.tv_perfilmenu.InsertItemLast( 0, ls_menu[li_nivelMenu],li_nivelMenu )
		tab_user.tabpage_aplicaciones.tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
		tv_listi.Data 						= li_idmenu[li_nivelMenu]
		tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
		tab_user.tabpage_aplicaciones.tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
	End if

	//***********Segundo Nivel***************
	If Not IsNull(ids_Menus.GetItemNumber( liFila, 'Nivel2' )) and ids_Menus.GetItemNumber( liFila, 'Nivel2' )>0 then
			li_nivelMenu						= 2
			li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel2' )
			ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu2' )
			ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu2' ))
			li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id2' )
			if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
			
			//Item , Solo una vez
			if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
				li_idmenuAnt[li_nivelMenu]	= li_idmenu[li_nivelMenu]
				li_handle[li_nivelMenu] 		= tab_user.tabpage_aplicaciones.tv_perfilmenu.InsertItemLast( li_handle[1] , ls_menu[li_nivelMenu],li_nivelMenu )
				tab_user.tabpage_aplicaciones.tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
				tv_listi.Data 						= li_idmenu[li_nivelMenu]
				tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
				tab_user.tabpage_aplicaciones.tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
			End if
	End if

	
	//***********Tercer Nivel***************
	If Not IsNull(ids_Menus.GetItemNumber( liFila, 'Nivel3' )) and ids_Menus.GetItemNumber( liFila, 'Nivel3' )>0 then
			li_nivelMenu						= 3
			li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel3' )
			ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu3' )
			ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu3' ))
			li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id3' )
			if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
			
			//Item , Solo una vez
			if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
				li_idmenuAnt[li_nivelMenu]	= li_idmenu[li_nivelMenu]
				li_handle[li_nivelMenu] 		= tab_user.tabpage_aplicaciones.tv_perfilmenu.InsertItemLast( li_handle[2] , ls_menu[li_nivelMenu],li_nivelMenu )
				tab_user.tabpage_aplicaciones.tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
				tv_listi.Data 						= li_idmenu[li_nivelMenu]
				tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
				tab_user.tabpage_aplicaciones.tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
			End if
	End if
NEXT
tab_user.tabpage_aplicaciones.tv_perfilmenu.ExpandAll(li_handle[1])  //Ultimo nivel que quedo en handle, no entra en el for
tab_user.tabpage_aplicaciones.tv_perfilmenu.SetRedraw( TRUE )
end event

event ue_eliminar_pre;call super::ue_eliminar_pre;return -1
end event

event ue_grabar_pre;call super::ue_grabar_pre;Integer li_ret=1
li_ret= tab_user.tabpage_aplicaciones.dw_perfil.event ue_validar( )
Return li_ret
end event

event ue_vistaprevia;Return  
end event

type st_titulo from w_base`st_titulo within w_usuarios
integer y = 36
string text = ""
end type

type st_fondo from w_base`st_fondo within w_usuarios
integer x = 69
integer y = 4
integer width = 4000
end type

type dw_principal from w_base`dw_principal within w_usuarios
event type integer ue_actualizar_registro ( integer ai_fila )
integer x = 37
integer y = 224
integer width = 2670
integer height = 2084
string title = ""
string dataobject = "dw_listausuarios"
boolean hscrollbar = true
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_menufiltrar = true
end type

event type integer dw_principal::ue_actualizar_registro(integer ai_fila);Integer	li_ret
Integer	li_row
String		ls_login_activo

li_row	=	this.GetRow()
li_ret	=	1

if li_row < 1 or ai_fila < 1  then
	Return 0
End if

ls_login_activo	=	  tab_user.tabpage_detalles.dw_detalle.GetItemString(ai_fila,'estado' )
if ls_login_activo='A' then
	ls_login_activo='Si'
else
	ls_login_activo='No'
End if

this.setitem(li_row,'estado',  tab_user.tabpage_detalles.dw_detalle.GetItemString(ai_fila,'estado' ))		//Estado

if len(tab_user.tabpage_detalles.dw_detalle.GetItemString(ai_fila,'tipologin' ))  >0  then
	this.setitem(li_row,'tipologin',  tab_user.tabpage_detalles.dw_detalle.GetItemString(ai_fila,'tipologin' ))		//Estado
End if

if len(tab_user.tabpage_detalles.dw_detalle.GetItemString(ai_fila,'codigologin' ))  >1  then
	this.setitem(li_row,'codigologin',  tab_user.tabpage_detalles.dw_detalle.GetItemString(ai_fila,'codigologin' ))		//Estado
End If

this.setitem(li_row,'login_activo',ls_login_activo)	//login_activo	


this.accepttext( )

Return li_ret
end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;Integer	li_null
String		ls_estado

SetNull(li_null)

 
if currentrow>0 then

	is_codusuario	=	this.getitemstring(currentrow, 'codigousuario')
	ib_usuariook	=	True
	ls_estado		=	''
	

	if this.getitemstring(currentrow,'Estado')='I' then ib_usuariook=False
	if this.getitemstring(currentrow,'Sql_Login')='No' then 	ib_usuariook=False
	
	
	tab_user.tabpage_detalles.dw_detalle.triggerevent("ue_retrieve")

	tab_user.tabpage_detalles.dw_acceso_unidad.triggerevent("ue_retrieve")
	
	tab_user.tabpage_acceso.dw_basedatos.triggerevent("ue_retrieve")
	tab_user.tabpage_acceso.dw_accesobd.triggerevent("ue_retrieve")
	tab_user.tabpage_acceso.dw_accesovista.triggerevent("ue_retrieve")
	
	tab_user.tabpage_aplicaciones.dw_perfil.reset()
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.triggerevent("ue_retrieve")
	ids_Menus.reset()
	
	

	//Nulear aplicacion seleccionada
//	tab_user.tabpage_aplicaciones.dw_aplicacion.object.idaplicacion[1]=li_null
	
	
	tab_user.tabpage_acceso.enabled = true
	tab_user.tabpage_aplicaciones.enabled = true
	tab_user.tabpage_detalles.dw_acceso_unidad.enabled = true
Else


	ls_estado		=	''
	is_codusuario	=  ''
	ib_usuariook	=	False
	sle_buscar.text =  ''
	
End if






end event

event dw_principal::ue_retrieve;call super::ue_retrieve;//	V 1.1		Se omite el uso de idservidor	03/10/2024
if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

//Return this.retrieve(1,ii_idservidor)	1.1
Return this.retrieve(1)



end event

event dw_principal::ue_poblardddw;call super::ue_poblardddw;Integer					li_Ret
Integer					li_IdArea
datawindowchild		ldwc_Child

If	This.GetChild( as_columna, ldwc_Child ) < 1 Then Return
ldwc_Child.SetTransObject( SQLCA )
String		ls_parametros

Choose case as_columna 			
	case 'tipocorporativo'
		ls_parametros=String(gi_idaplicacion)+",0,0,C,TipoUsuario"
		li_Ret = ldwc_child.Retrieve(ls_parametros ) 
End choose
		
// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then 	ldwc_Child.Insertrow( 0 )




end event

type st_menuruta from w_base`st_menuruta within w_usuarios
integer x = 3598
integer y = 36
end type

type tab_user from tab within w_usuarios
integer x = 2752
integer y = 228
integer width = 2834
integer height = 2392
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
boolean boldselectedtext = true
integer selectedtab = 1
tabpage_detalles tabpage_detalles
tabpage_aplicaciones tabpage_aplicaciones
tabpage_acceso tabpage_acceso
end type

on tab_user.create
this.tabpage_detalles=create tabpage_detalles
this.tabpage_aplicaciones=create tabpage_aplicaciones
this.tabpage_acceso=create tabpage_acceso
this.Control[]={this.tabpage_detalles,&
this.tabpage_aplicaciones,&
this.tabpage_acceso}
end on

on tab_user.destroy
destroy(this.tabpage_detalles)
destroy(this.tabpage_aplicaciones)
destroy(this.tabpage_acceso)
end on

type tabpage_detalles from userobject within tab_user
string tag = "RH75"
integer x = 18
integer y = 112
integer width = 2798
integer height = 2264
long backcolor = 67108864
string text = "Detalles"
long tabtextcolor = 128
string picturename = "Custom076!"
long picturemaskcolor = 536870912
dw_detalle dw_detalle
dw_acceso_unidad dw_acceso_unidad
end type

on tabpage_detalles.create
this.dw_detalle=create dw_detalle
this.dw_acceso_unidad=create dw_acceso_unidad
this.Control[]={this.dw_detalle,&
this.dw_acceso_unidad}
end on

on tabpage_detalles.destroy
destroy(this.dw_detalle)
destroy(this.dw_acceso_unidad)
end on

type dw_detalle from uo_dwbase within tabpage_detalles
integer x = 46
integer width = 2729
integer height = 1768
integer taborder = 20
boolean bringtotop = true
string title = ""
string dataobject = "dwf_usuarios_detalle"
richtexttoolbaractivation richtexttoolbaractivation = richtexttoolbaractivationalways!
boolean controlmenu = true
boolean hscrollbar = true
boolean border = false
boolean ib_activarfiltros = false
boolean ib_resaltarfila = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			20/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

String		ls_parametros
//ls_parametros	=	is_codusuario+","+String(ii_idservidor)
ls_parametros	=	is_codusuario	//1.0

this.event ue_poblardddw('TipoLogin')

Return this.retrieve(ls_parametros)

Return 1
end event

event ue_agregar_registro_post;call super::ue_agregar_registro_post;// 1.0		Walther Rodriguez		09/07/2024		No usar IDSERVIDOR
DateTime 	ldt_fechaset
DateTime	ldt_fechaactual
Date			ld_fecha
String			ls_tipotrabajador

sqlca.uf_usp_fechahora_select(ldt_fechaactual)

ld_fecha			=	 RelativeDate ( date(ldt_fechaactual) , ii_dias_clave )
ldt_fechaset		=	DateTime(ld_fecha,now())


//this.setitem( ai_row, 'idservidor', ii_idservidor)			//1.0
//this.setitem( ai_row, 'fechaalta', ldt_fechaactual)
this.setitem( ai_row, 'fechaaltausuario', ldt_fechaactual)
this.setitem( ai_row, 'fechacaducidadcuenta', ldt_fechaset)
this.setitem( ai_row, 'tipologin', is_tipologin_def)
this.setcolumn('tipocorporativo')
dw_acceso_unidad.reset()
 
end event

event ue_validar;call super::ue_validar;// 	1.1	8-11-2024		Se utiliza nro documento como codigo para usuario de sustento

Integer			li_rpta=1
Integer			li_rpta2=1
String				ls_tiplogin
String				ls_modo='U'		//Modo update U
Integer			li_retval
String				ls_codusuario
String				ls_nombrecompleto
 String			ls_tipousuario
 String 			ls_nombre
 String			ls_apellidopaterno
 String			ls_apellidomaterno
 String			ls_numerodocumento
 Integer			li_ret
 String			ls_numdoc

 String   			ls_codigologin


tab_user.tabpage_detalles.dw_detalle.accepttext( )

dwItemStatus 	ldwis_Estado

//Para saber si es un registro NUEVO, modo=N
ldwis_Estado = This.getitemstatus( this.GetRow(), 0, Primary! )
If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then ls_modo='N'
		

//ls_tipou					=	this.GetitemString(this.GetRow(),'tipoacceso')
ls_tiplogin					=	this.GetitemString(this.GetRow(),'tipologin')
ls_codigologin				=  this.GetitemString(This.Getrow(),'codigologin')

ls_codusuario				=	this.GetitemString(this.GetRow(),'codigousuario')

ls_nombre					=	this.GetitemString(this.GetRow(),'nombre')
ls_apellidopaterno			=  this.GetitemString(this.GetRow(),'apellidopaterno') 
ls_apellidomaterno		=  this.GetitemString(this.GetRow(),'apellidomaterno') 
ls_numerodocumento		=  this.GetitemString(this.GetRow(),'numerodocumento') 

ls_nombrecompleto		=  this.GetitemString(this.GetRow(),'nombrecompleto') 
ls_tipousuario				=	this.GetItemString(this.GetRow(),'tipocorporativo')
ls_numdoc					=	this.GetItemString(this.GetRow(),'numerodocumento')	

ib_nuevo_user				=	False

if ls_modo='N' then
	


	If ls_tipousuario='C' then
		if IsNull(ls_nombrecompleto) or ls_nombrecompleto='null' or Len(ls_nombrecompleto) < 1  then
			gf_mensaje(gs_Aplicacion, 'No se encontro información Success Factor para nuevo usuario', 'Utilice la opción de validación, para completar los datos', 2)
			li_rpta=-1
			Return li_rpta
		End if
	End if
	
	if IsNull(ls_codigologin) or ls_codigologin='null' or Len(ls_codigologin) < 1  then
			gf_mensaje(gs_Aplicacion, 'Debe ingresar un código de Login','' ,2)
			li_rpta=-1
			Return li_rpta
	End if
	
	String		ls_documento_sustento
	
	If wf_adjunta_sustento('ALTA',ls_documento_sustento,is_codusuario,ls_numdoc)<0 then		//1.1
		li_rpta=-1
		Return li_rpta
	End if
	
	is_documento_sustento=ls_documento_sustento		
	this.SetItem(this.GetRow(),'docaltausuario',is_documento_sustento)	
	ib_nuevo_user=True
	
Else
	
//	if IsNull(ls_codusuario) or ls_codusuario='null' or Len(ls_codusuario) < 1  then
//		gf_mensaje(gs_Aplicacion, 'Debe ingresar el código de Usuario','' ,2)
//		li_rpta=-1
//		Return li_rpta
//	End if

	
		
	//No validar DATOS PERSONALES para usuario de SERVICIO (S)
	
	if ls_tipousuario<>'S' then
	
				if IsNull(ls_nombre) or ls_nombre='null' or Len(ls_nombre) < 1  then
					gf_mensaje(gs_Aplicacion, 'Debe ingresar el Nombre','' ,2)
					li_rpta=-1
					Return li_rpta
				End if
				
				if IsNull(ls_apellidopaterno) or ls_apellidopaterno='null' or Len(ls_apellidopaterno) < 1  then
					gf_mensaje(gs_Aplicacion, 'Debe ingresar el Apellido Paterno','' ,2)
					li_rpta=-1
					Return li_rpta
				End if
				
				if IsNull(ls_apellidomaterno) or ls_apellidomaterno='null' or Len(ls_apellidomaterno) < 1  then
					gf_mensaje(gs_Aplicacion, 'Debe ingresar el Apellio Materno','' ,2)
					li_rpta=-1
					Return li_rpta
				End if
				
				if IsNull(ls_numerodocumento) or ls_numerodocumento='null' or Len(ls_numerodocumento) < 1  then
					gf_mensaje(gs_Aplicacion, 'Debe ingresar el número de documento','' ,2)
					li_rpta=-1
					Return li_rpta
				End if
		

				
	End if
	
end if

//li_rpta=  wf_valida_usuario_sql(ls_codusuario,ls_tiplogin) 
	


Return li_rpta

end event

event itemchanged;call super::itemchanged;String		ls_valor
String		ls_mensaje=''
string  	ls_tipousuario
Integer	col

setnull(ls_valor)

col	=	this.getcolumn( )

Choose Case dwo.name 
		Case 'tipocorporativo'

				DWItemStatus ldws_item_estado
				ldws_item_estado = This.getitemstatus( This.ii_filanueva, 'tipocorporativo', Primary!)
				if IsNull(ldws_item_estado)=False then
					If ldws_item_estado = New! or  ldws_item_estado =DataModified!  then
						wf_limpiar_detalle(data)
						if data ='C' then
							this.setcolumn('cip')
							this.setfocus()
						End if
						is_numdoc=wf_correlativo_doc(data)
						This.setitem(1,'numerodocumento', is_numdoc)
						This.setitem(1,'idcarpeta', is_numdoc)
					end if
				Else
					if String(This.Object.Data.Original[ row, col ])='C' then	ls_mensaje='El código CIP sera liberado y ya no estará asociado al usuario'
					If gf_mensaje(gs_Aplicacion, 'Está seguro de modificar el Tipo Usuario ?',ls_mensaje ,4 ) = 1  Then
						this.setitem(1,'cip',ls_valor)
					Else
						This.setitem(1,'tipocorporativo',This.Object.Data.Original[ row, col ])
						Return 2
					End If
				End if

End Choose


end event

event buttonclicked;call super::buttonclicked;// 1.1			Walther Rodriguez					20/06/2024		Se quito el parametro IDServidor de Seguridad.usp_SQL_Usuario_Validar
// 1.2			Walther Rodriguez					26/06/2024		Se quito el parametro IDServidor de Seguridad.usp_SQL_Usuario_Baja
// 1.3			Walther Rodriguez					10/11/2024		Validar CIP cuando no este activo

String 			ls_cip
String 			ls_codigoUsuario
Integer 			li_ret
Integer			li_rowcount
String				ls_modo='U'		//Actualizacion
String				ls_tipologin
Integer			li_rowcip
Integer			li_regm4
String				ls_tipousuario
Integer			li_rpta
String				ls_codigometa4
String				ls_estado
String				ls_nuevo_estado
Integer			li_id_login_activo
String				ls_tipo_sustento
Integer			li_accion

String				ls_Parametros
String				ls_ret
Integer			li_retornoOUT

String				ls_retorno[]
String				ls_error

str_arg			lstr_arg
str_response  	lstr_Argumentos
String 			ls_documento_sustento
String 			ls_codigologin
String				ls_codigo_login_nuevo
String				ls_idcarpeta
String				ls_numdoc
String				ls_observacion
String				ls_usuarioencontrado

dwItemStatus 	ldwis_Estado
uo_dsbase		lds_PersonaMeta4


//this.accepttext( )
//dw_principal.accepttext( )

ls_tipologin			= 	this.GetItemString(this.getrow(),'tipologin')    //se cambia ls_tipoAcceso por ls_tipologin
ls_codigologin		= 	this.GetItemString(this.getrow(),'codigologin')  //usuario Login

ls_codigoUsuario	= 	this.GetItemString(this.getrow(),'codigousuario')
ls_cip 				= 	this.GetItemString(this.getrow(),'cip')
ls_tipousuario		=	this.GetItemString(row,'tipocorporativo')
ls_estado			=	this.GetItemString(this.getrow(),'estado')
li_id_login_activo	=	this.GetItemNumber(this.getrow(),'loginactivo')
ls_numdoc			=	this.GetItemString(this.GetRow(),'numerodocumento')	
ls_idcarpeta			=	this.GetItemString(this.GetRow(),'IdCarpeta')	
ls_observacion		=  this.GetItemString(this.GetRow(),'observacion')	

li_rowcount			= dw_principal.rowcount()

ii_fila_busqueda  =  dw_principal.getrow()
		
		
if IsNull(ls_codigoUsuario) then	ls_codigoUsuario ='' 
if IsNull(ls_codigologin) then	ls_codigologin   ='' 
if IsNull(li_id_login_activo) then	li_id_login_activo   =0

//hch
//If Len(ls_codigoUsuario)<1 then
//	gf_mensaje(gs_Aplicacion, 'Debe ingresar un codigo de usuario a validar', '', 3)
//	Return 
//End if
//hch


Choose case dwo.name
	Case		 'b_registros'
		
		li_ret	= wf_auditoria_detalle(is_codusuario,ls_observacion)
		
	Case 		'b_usuario'
		
		//Validar USUARIO
	
		if ls_estado='I' then Return -1
		
		//Para saber si es un registro NUEVO, modo=N
		ldwis_Estado = This.getitemstatus( row, 0, Primary! )
		If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then ls_modo='N'
	
		li_ret	=	wf_valida_usuario(ls_codigoUsuario,ls_tipologin,ls_modo)	
		if li_ret<0 then Return	


		//Validar CIP
		li_rowcip = dw_principal.find ("cip = '"+ls_cip+"' and estado='A'",1,li_rowcount) 		//1.3 Validar CIP si esta activo
		
		if ls_modo='N' then
			if li_rowcip>0 then
				ls_usuarioencontrado=dw_principal.GetItemString(li_rowcip,'codigousuario')
				gf_mensaje(gs_Aplicacion, 'Codigo CIP ya asignado al usuario '+ls_usuarioencontrado , '', 1)
				Return -1
			End if
		End if
		
		lds_PersonaMeta4 = gf_procedimiento_consultar( "Seguridad.usp_vista_persona_meta4 0 arg:string "  , sqlca)
		li_regm4	=	lds_PersonaMeta4.retrieve(ls_cip)	  
	
		if  li_regm4> 0 then 
			If ls_modo='N' then
			//	gf_mensaje(gs_Aplicacion, 'Se han encontrado datos Success Factor para este código' , '', 3)	
				li_rpta=1
			Else
				li_rpta=gf_mensaje(gs_Aplicacion, 'Se han encontrado datos Success Factor para este código...desea importar estos datos' , '', 4)	
			End if
			if  li_rpta=1 then
				//Actualizando desde meta4
				ls_codigometa4	=Lower(lds_PersonaMeta4.getitemstring(1,'id_usered'))
				If IsNull(ls_codigometa4) = False and ls_codigometa4<>'null' and Len(ls_codigometa4)>6 then
						If IsNull(ls_codigoUsuario) = False and ls_codigoUsuario<>'null' and Len(ls_codigoUsuario)>6 then
							this.setitem(row,'codigousuario',ls_codigometa4)
						End if
				End if
				this.setitem(row,'numerodocumento',lds_PersonaMeta4.getitemstring(1,'docnum'))	
				this.setitem(row,'apellidopaterno',lds_PersonaMeta4.getitemstring(1,'apepat'))
				this.setitem(row,'apellidomaterno',lds_PersonaMeta4.getitemstring(1,'apemat'))
				this.setitem(row,'nombre',lds_PersonaMeta4.getitemstring(1,'nombres'))
				this.setitem(row,'nombrecompleto',lds_PersonaMeta4.getitemstring(1,'NombreCompleto'))			
				this.setitem(row,'fechaalta',lds_PersonaMeta4.getitemdatetime(1,'Fecha_alta'))
				this.setitem(row,'FechaBaja',lds_PersonaMeta4.getitemdatetime(1,'Fecha_Cese'))		
				this.setitem(row,'dsc_tipotrabajador',lds_PersonaMeta4.getitemstring(1,'dsc_tipotrabajador'))
				this.setitem(row,'area',lds_PersonaMeta4.getitemstring(1,'Area'))
				this.setitem(row,'area_sup',lds_PersonaMeta4.getitemstring(1,'Area_Sup'))
				this.setitem(row,'cargo',lds_PersonaMeta4.getitemstring(1,'cargo'))		
				this.setitem(row,'email',lds_PersonaMeta4.getitemstring(1,'email'))
				this.setitem(row,'codigousuario',lds_PersonaMeta4.getitemstring(1,'id_usered'))
				this.setitem(row,'IdCarpeta',lds_PersonaMeta4.getitemstring(1,'docnum'))
				is_numdoc=lds_PersonaMeta4.getitemstring(1,'docnum')
				//Modo edicion
				iw_ventanapadre.ib_editando=True
				iw_ventanapadre.event ue_editar( )
			End if			
		Else
			if ls_modo='N'  and ls_tipousuario='C' then
				gf_mensaje(gs_Aplicacion, 'No se encontro registro en Success Factor' , '', 1)
				Return -1
			End if
		End if

		 Destroy lds_PersonaMeta4
		 
	Case  'b_baja'
		
		if ls_estado='I'  then 
			Return -1
		End if
		
		if ls_codigologin='' then
			gf_mensaje(gs_Aplicacion, 'No se encontro un login asignado', '', 3)
			Return -1
		End if
	
		If gf_mensaje(gs_Aplicacion, 'Al proceder con la baja se realizará la inhabilitación de los accesos a las base de datos, asi como la eliminación del login ...¿Desea continuar?' , '', 4) = 2	Then
			return -1
		End if
				
		ls_tipo_sustento	=	'BAJA'
		ls_nuevo_estado	=	'I'
		li_accion		=	0
		li_retornoOUT	=	0

		// Validacion Login en servidor SQL
		ls_Parametros = "1,"+ ",' ','"+ls_codigoUsuario +"','"+ls_tipologin+"',"+String(li_retornoOUT)	//1.1
		li_ret = gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Validar ",ls_Parametros,ls_retorno, ls_Error)

//		End if
//		ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Validar",ls_Parametros)  
//		If ls_ret = "SQL:-1" Then 
//			gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL ', '', 2)
//			Return -1
//		End if	
//		li_ret	=	Integer(ls_ret)

		If li_ret=0 then
			if upperbound(ls_retorno)>0 then  li_retornoOUT= Integer(ls_retorno[1]) 
		
//			if li_retornoOUT<1 then
//				gf_mensaje(gs_Aplicacion, 'No se pudo encontrar el Login en el servidor', '', 2)
//				Return -1
//			End if
			
			//***Rsp***//		
			If wf_adjunta_sustento(ls_tipo_sustento,ls_documento_sustento,is_codusuario,ls_idcarpeta) > 0 then
				
				//Llamar a procedimiento de baja
				//ls_Parametros =String( ii_idservidor) + ",'"+ls_codigoUsuario +"','"+ls_documento_sustento +"'"	NO USAR ID SERVIDOR  26/06/2024
				ls_Parametros ="'"+ls_codigoUsuario +"','"+ls_documento_sustento +"'"
				ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Baja ",ls_Parametros)  
				If ls_ret = "SQL:-1" Then 
					gf_mensaje(gs_Aplicacion, 'No se pudo ejecutar proceso de baja de usuario', '', 2)
					Return -1
				End if
				
			
				//hch
//				ls_Parametros =String( ii_idservidor) + ",'"+ls_codigoUsuario +"'"
//				ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Eliminar_UserBaseDatos ",ls_Parametros)  
//				If ls_ret = "SQL:-1" Then 
//					gf_mensaje(gs_Aplicacion, 'No se pudo ejecutar proceso de Eliminación de User por Base Datos', '', 2)
//					Return -1
//				End if
//				//hch	
//				
//				ls_Parametros =String( ii_idservidor) + ",'"+ls_codigoUsuario +"'"
//				ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Eliminar_Login",ls_Parametros)  
//				If ls_ret = "SQL:-1" Then 
//					gf_mensaje(gs_Aplicacion, 'No se pudo ejecutar proceso de Eliminación de Login', '', 2)
//					Return -1
//				End if
//				
//				ls_Parametros =String( ii_idservidor) + ",'"+ls_codigoUsuario +"',"+String(li_accion)+",'"+ls_documento_sustento +"'"
//				ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Habilitar_Deshabilitar ",ls_Parametros)  
//				If ls_ret = "SQL:-1" Then 
//					gf_mensaje(gs_Aplicacion, 'No se pudo ejecutar proceso de habilitación ', '', 2)
//					Return -1
//				End if
//					
				li_ret	=	Integer(ls_ret)
				if li_ret=1 then
					gf_mensaje(gs_Aplicacion, 'Estado de usuario '+ls_codigologin +' actualizado satisfactoriamente', '', 1)
					parent.setredraw(FALSE)
					this.event ue_retrieve( )
					parent.setredraw(TRUE)

					dw_principal.event ue_actualizar_registro(row)						
				End if
			End if
		Else
			gf_mensaje(gs_Aplicacion, 'No se pudo Validar usuario', '', 2)
			Return -1
		End if
	
	Case 'b_ver'	
				wf_ver_sustento(ls_idcarpeta)

	Case 'b_loginactivo'
			//Para saber si es un registro NUEVO, modo=N
			ldwis_Estado = This.getitemstatus( row, 0, Primary! )
			If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then 
				//Solicitar nuevo Login
				if ls_codigologin='' then
					if is_tipologin_def='S' then
						ls_codigo_login_nuevo=ls_codigoUsuario
					else
						//ls_codigo_login_nuevo=is_dominio+'\'+ls_codigoUsuario
						ls_codigo_login_nuevo=ls_codigoUsuario
					End if
				Else
					ls_codigo_login_nuevo	=	ls_codigologin
				End if
				ls_codigologin	=	gf_inputbox("Registro de usuario","Codigo de login:", "V", ls_codigo_login_nuevo,True)
				if Len(ls_codigologin)> 1 then
					this.setitem(row,'codigologin',ls_codigologin)		
					this.setitem(row,'loginactivo',1)
				End if
			else
				//Mostrar ventana para gestion de Login
				li_ret = wf_usuario_loginactivo( ls_codigoUsuario, ls_codigologin, li_id_login_activo) 
				If li_ret< 0 then
					Return -1
				Else
					dw_principal.event ue_actualizar_registro(row)
				End if
			End if
End Choose 
end event

event retrieveend;call super::retrieveend;if this.getitemstring(this.getrow(),'Estado')='I'  then
	this.Object.b_baja.Visible = false
	this.Object.p_baja.Visible = false
	
Else
	this.Object.b_baja.Visible = true
	this.Object.p_baja.Visible = true	
end if


end event

event ue_poblardddw;call super::ue_poblardddw;Integer					li_Ret
Integer					li_IdArea
datawindowchild		ldwc_Child

If	This.GetChild( as_columna, ldwc_Child ) < 1 Then Return
ldwc_Child.SetTransObject( SQLCA )
String		ls_parametros

Choose case as_columna 			
	case 'tipocorporativo'
		ls_parametros=String(gi_idaplicacion)+",0,0,C,TipoUsuario"
		//li_Ret = ldwc_child.Retrieve(ls_parametros ,2) 
		li_Ret = ldwc_child.Retrieve(ls_parametros) 

	case 'tipologin'
		ls_parametros=String(gi_idaplicacion)+",0,0,C,TipoLogin"
		li_Ret = ldwc_child.Retrieve(ls_parametros ) 
		
End choose
		
// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then 	ldwc_Child.Insertrow( 0 )




end event

event ue_grabar;call super::ue_grabar;//String				ls_ret
//String				ls_parametros
//String				ls_codigousuario
// 
//If	ib_nuevo_user then
//	ls_codigoUsuario	=	'+'
//	ls_Parametros ="'"+ls_codigoUsuario +"',"+String( ii_idservidor) + ",1,'"+is_documento_sustento+"'"
//	ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_Usuario_Historico_Permiso_Insert ",ls_Parametros)  	
//	is_documento_sustento=''
//	ib_nuevo_user=False
//	If ls_ret = "SQL:-1" Then 
//		gf_mensaje(gs_Aplicacion, 'No se pudo ejecutar registro de fecha alta de usuario', '', 2)
//	//	Return -1
//	End if
//
//End if
//
Return AncestorReturnValue
end event

type dw_acceso_unidad from uo_dwbase within tabpage_detalles
event type integer ue_agregar_unidad ( string as_codigo,  string as_nombre )
integer x = 37
integer y = 1836
integer width = 2747
integer height = 436
integer taborder = 30
string dataobject = "dw_lista_unidadusuario"
boolean hscrollbar = true
boolean ib_activarfiltros = false
boolean ib_menudetalle = true
boolean ib_menudetalleinsertar = true
boolean ib_mostrarmensajeantesdeeliminarregistro = true
end type

event type integer ue_agregar_unidad(string as_codigo, string as_nombre);Integer		li_idcompania
Integer		li_idunidadnegocio
Integer		li_filanew
String			ls_filtro

if this.find("cmp_codigo='"+as_codigo+"'",1, this.RowCount())>0 then Return 0

li_idcompania			=	Integer(Left(as_codigo,Pos(as_codigo,'-') -1))
li_idunidadnegocio		=	Integer(Mid(as_codigo,Pos(as_codigo,'-') + 1 , 2) )

li_filanew										=	this.insertrow(0)
this.object.codigousuario[li_filanew]		=	is_codusuario
this.object.idcompania[li_filanew]			=	li_idcompania
this.object.idunidadnegocio[li_filanew]	=	li_idunidadnegocio
this.object.abreviatura[li_filanew]			=	as_nombre
this.object.idservidor[li_filanew]			=	ii_idservidor
this.object.RegistroActivo[li_filanew]		=	1

this.event ue_agregar_registro_post(li_filanew)

Return 1
end event

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			20/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

//Return this.retrieve(ii_idservidor,is_codusuario)	//1.0
Return this.retrieve(is_codusuario)	//1.0
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

Integer			li_filasel
Integer			li_fila
String				ls_codigo
String				ls_nombre
Uo_dsbase		lds_companiaunidad
str_response    lstr_Response

//if ib_usuariook=False then 
//	gf_mensaje(gs_Aplicacion, 'Uusario no disponible...verifique', '', 3)
//	Return -1
//End if

//Para las unidades
//lds_companiaunidad 			= gf_Procedimiento_Consultar("Maestros.usp_UnidadNegocio_Select_03 1,0,"+String(ii_idservidor),SQLCA)
lds_companiaunidad 			= gf_Procedimiento_Consultar("Maestros.usp_UnidadNegocio_Select_03 1,0",SQLCA)	//1.0

lstr_Response.b_usar_datastore		= True
lstr_Response.ds_datastore    			= lds_companiaunidad
lstr_Response.s_titulo      				= 'Listado de Unidades' 
lstr_Response.b_seleccion_multiple	= True
lstr_Response.s_titulos_columnas		='3:UNIDAD NEGOCIO:600'
lstr_Response.b_redim_ventana		= True
lstr_Response.l_ancho					= 1000
lstr_Response.l_alto						= 1500
lstr_Response.b_activar_filtros			= True
	
OpenWithParm(w_response_seleccionar,lstr_Response)

IF UpperBound(lds_companiaunidad.ii_filasseleccionadas)<1 then Return -1
IF lds_companiaunidad.ii_filasseleccionadas[1]=0 then Return -1
	
/* Recuperar la cantidad de filas seleccionadas*/

for li_fila= 1 to Integer(upperbound(lds_companiaunidad.ii_filasseleccionadas))
	li_filasel				= lds_companiaunidad.ii_filasseleccionadas[li_fila]
	ls_codigo				=  lds_companiaunidad.GetItemString(li_filasel ,'Codigo')
	ls_nombre			=  lds_companiaunidad.GetItemString(li_filasel ,'Abreviatura')
	this.event ue_agregar_unidad(ls_codigo,ls_nombre)
Next

if li_fila>0 then
	iw_ventanapadre.ib_editando = true
	iw_ventanapadre.event ue_editar( )
End if

Return -1

end event

event ue_grabar_pre;call super::ue_grabar_pre;// 1.0		Walther Rodriguez		09/07/2024		No usar IDSERVIDOR

String ls_documento_sustento
String ls_Parametros
String ls_ret
Integer li_sustento_perfil
String	 ls_idcarpeta				

ls_idcarpeta	=	dw_detalle.GetItemString(dw_detalle.GetRow(),'idcarpeta')	
//sustento

//	is_asigna_unidad = 'PERMISO'  ; Agregar o Elimina Unidad = 2 //Nombre Modificación
li_sustento_perfil  =  wf_adjunta_sustento('MODIFICACION',ls_documento_sustento,is_codusuario,ls_idcarpeta)
		
If ( li_sustento_perfil > 0  )  Then 
		ls_Parametros = "'"+is_codusuario+"',2,'"+ls_documento_sustento +"'"
		ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_Usuario_Historico_Permiso_Insert ",ls_Parametros)  //1.0
//		ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_Usuario_Historico_Permiso_Insert ",ls_Parametros)  
		If ls_ret = "SQL:-1" Then 
			gf_mensaje(gs_Aplicacion, 'No se pudo adjuntar el documento para el sustento ', '', 2)
			Return -1
		End if		
Else
	Return -1
End IF
//sustento				
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;return 1
end event

type tabpage_aplicaciones from userobject within tab_user
string tag = "R3DWH3"
integer x = 18
integer y = 112
integer width = 2798
integer height = 2264
long backcolor = 67108864
string text = "Aplicaciones"
long tabtextcolor = 128
string picturename = "RegistrationDir!"
long picturemaskcolor = 536870912
tv_perfilmenu tv_perfilmenu
dw_usuaplicacion dw_usuaplicacion
dw_perfil dw_perfil
end type

on tabpage_aplicaciones.create
this.tv_perfilmenu=create tv_perfilmenu
this.dw_usuaplicacion=create dw_usuaplicacion
this.dw_perfil=create dw_perfil
this.Control[]={this.tv_perfilmenu,&
this.dw_usuaplicacion,&
this.dw_perfil}
end on

on tabpage_aplicaciones.destroy
destroy(this.tv_perfilmenu)
destroy(this.dw_usuaplicacion)
destroy(this.dw_perfil)
end on

type tv_perfilmenu from treeview within tabpage_aplicaciones
integer x = 1623
integer y = 4
integer width = 1166
integer height = 1884
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 15793151
borderstyle borderstyle = stylelowered!
boolean linesatroot = true
boolean checkboxes = true
string picturename[] = {"Menu!","Menu5!","DosEdit!"}
long picturemaskcolor = 536870912
long statepicturemaskcolor = 536870912
end type

event clicked;return  2
end event

type dw_usuaplicacion from uo_dwbase within tabpage_aplicaciones
integer x = 14
integer width = 1591
integer height = 664
integer taborder = 40
boolean bringtotop = true
string dataobject = "dw_usuario_aplicacion"
boolean hscrollbar = true
boolean ib_actualizar = false
boolean ib_activarfiltros = false
boolean ib_menudetalle = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

String ls_paramtro 
//ls_paramtro =is_codusuario+','+String(ii_idservidor)
ls_paramtro =is_codusuario	//1.0
this.retrieve(1,ls_paramtro)
this.ii_filanueva=0

tab_user.tabpage_acceso.dw_basedatos.triggerevent("ue_retrieve")

return 1
end event

event rowfocuschanged;call super::rowfocuschanged;Integer					li_idaplicacion
Integer					li_filaaplicacion
Integer	li_null
SetNull(li_null)

DataWindowChild		ldwc_child

if currentrow>0 then
	li_idaplicacion		=	Integer(this.Getitemnumber( currentrow, 'idaplicacion'))
//	If	tab_user.tabpage_aplicaciones.dw_aplicacion.GetChild('idaplicacion', ldwc_child ) < 1 Then Return
//	li_filaaplicacion	=	ldwc_child.find("idaplicacion="+String(li_idaplicacion),1,ldwc_child.rowcount())
	if li_idaplicacion>0 then
		il_Idaplicacion	=	li_idaplicacion
		tab_user.tabpage_aplicaciones.dw_perfil.event ue_retrieve( )
//		tab_user.tabpage_aplicaciones.dw_aplicacion.setitem( 1,'idaplicacion',li_idaplicacion)
//		tab_user.tabpage_aplicaciones.dw_aplicacion.event itemchanged(li_filaaplicacion,tab_user.tabpage_aplicaciones.dw_aplicacion.object.idaplicacion ,String(li_idaplicacion))
	Else
		tab_user.tabpage_aplicaciones.dw_perfil.reset()
	End if
else
	tab_user.tabpage_aplicaciones.dw_perfil.reset()
End if
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

Integer 			li_fila
Integer	 		li_filasel
Integer 			li_filanew
Integer			li_idaplicacion
String				ls_nombreaplicacion
uo_dsbase		luo_ds_query
str_response    lstr_Response

if il_idaplicacion<1 then Return -1

if dw_perfil.uf_cambios_pendientes()=-1 or this.uf_cambios_pendientes()=-1 then 	
	gf_mensaje(gs_Aplicacion, 'Tiene cambios por guardar, NO se puede agregar', '', 3)
	Return -1
End if

//luo_ds_query			= gf_Procedimiento_Consultar("Seguridad.usp_Aplicacion_Select_03  " +String(ii_idservidor), sqlca)
//luo_ds_query			= gf_Procedimiento_Consultar("Seguridad.usp_Aplicacion_Select_03" , sqlca)	//1.0
luo_ds_query			= gf_Procedimiento_Consultar("Seguridad.usp_Aplicacion_Select_02 2,''" , sqlca)
if luo_ds_query.rowcount() < 1 then Return -1

lstr_response.b_usar_datastore		= 	TRUE
lstr_response.ds_datastore    			= 	luo_ds_query
lstr_response.s_titulo      				= 	'Listado de Aplicaciones' 
lstr_response.b_seleccion_multiple	= 	FALSE
lstr_response.b_mostrar_contador		= 	FALSE
lstr_response.s_titulos_columnas		=	'2:Nombre aplicación'
lstr_response.b_redim_ventana		= 	TRUE
lstr_response.l_ancho						= 	1300
lstr_response.l_alto						= 	1780
	  
OpenWithParm(w_response_seleccionar,	lstr_Response)

IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1


li_filasel	=	luo_ds_query.ii_filasseleccionadas[1]
li_idaplicacion			=		luo_ds_query.getitemnumber(li_filasel,'idaplicacion')
ls_nombreaplicacion	=		luo_ds_query.getitemstring(li_filasel,'Nombreaplicacion')

//Validar que no exista
if this.find("idaplicacion="+String(li_idaplicacion),1,this.RowCount())>0 then Return -1


////Agregar
li_filanew		=	this.InsertRow(0)
this.setItem(li_filanew,'idaplicacion',li_idaplicacion)
this.setItem(li_filanew,'nombreaplicacion',ls_nombreaplicacion)
this.event ue_agregar_registro_post( li_filanew)
 
il_Idaplicacion	=	li_idaplicacion
tab_user.tabpage_aplicaciones.dw_perfil.event ue_retrieve( )

this.scrolltorow(li_filanew)

Destroy luo_ds_query

//Activar Edicion
iw_ventanapadre.ib_editando=true
iw_ventanapadre.event ue_editar( ) 
	
return -1
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;Integer	li_fila
Integer	li_filaexiste
Integer	li_rpta

if gf_mensaje("Confirmación","Está seguro de eliminar este registro.","",  4)  = 2 Then Return -1

//Buscar el registro activo y quitar
li_Fila=tab_user.tabpage_aplicaciones.dw_perfil.find("registroactivo=1",1,tab_user.tabpage_aplicaciones.dw_perfil.rowcount( ))
If li_Fila > 0 Then 
	li_filaexiste   = li_Fila
	tab_user.tabpage_aplicaciones.dw_perfil.setitem( li_Fila, 'registroactivo', 0 )
End If

If	tab_user.tabpage_aplicaciones.dw_perfil.event ue_grabar_pre( ) = -1 Then Return -1
If	tab_user.tabpage_aplicaciones.dw_perfil.event ue_grabar( )= -1 Then Return -1

this.event ue_retrieve( )

Return -1
end event

event ue_agregar_registro_post;call super::ue_agregar_registro_post;this.ii_filanueva=ai_row
this.setitemstatus(ai_row,0,Primary!,New!)
end event

event ue_validar;call super::ue_validar;Return 1
end event

type dw_perfil from uo_dwbase within tabpage_aplicaciones
integer x = 23
integer y = 692
integer width = 1591
integer height = 1116
integer taborder = 20
string dataobject = "dw_usuario_perfil"
boolean hscrollbar = true
boolean ib_activarfiltros = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

//return  this.retrieve(ii_idservidor, il_Idaplicacion,is_codusuario)
return  this.retrieve(il_Idaplicacion,is_codusuario)	//1.0
end event

event ue_grabar_pre;call super::ue_grabar_pre;// 1.0		Walther Rodriguez		09/07/2024		No usar IDSERVIDOR
Long ll_row
Long ll_perfil
string ls_nombreperfil
String  ls_codigousuario, ls_usuarioPerfil
Integer li_registroActivo
Integer li_rpta2
Integer li_rpta
Integer li_existe,li_rpta1	
Long      ll_perfil_new
String    ls_nombreperfil_new
String    ls_Parametros,ls_retorno[], ls_Error
Integer  li_retorno
String		ls_documento_sustento,ls_ret
String 	ls_accion_perfil
Integer 	li_sustento_perfil
String		ls_idcarpeta


ls_idcarpeta					=	tab_user.tabpage_detalles.dw_detalle.GetItemString(tab_user.tabpage_detalles.dw_detalle.GetRow(),'idcarpeta')	

dw_perfil.accepttext( )

for  ll_row =  1 to  dw_perfil.rowcount()
	
	setnull(li_registroActivo) 
	setnull(ls_usuarioPerfil)
	li_registroActivo =  dw_perfil.getitemnumber(ll_row,'registroactivo')
	ls_usuarioPerfil  =  dw_perfil.getitemstring(ll_row,'codigousuario') 	
	
	if ls_usuarioPerfil ='0' then setnull(ls_usuarioPerfil)
	
	if  len(trim(ls_usuarioPerfil)) >  0 then 
		 If li_registroActivo = 1  Then
			ll_perfil_new				=    dw_perfil.getitemnumber(ll_row,'Idperfil')
			ls_nombreperfil_new 		=    dw_perfil.getitemstring(ll_row,'NombrePerfil')
		End If
			ls_accion_perfil    = 'MODIFICACION'
	end if 
next 


//		sustento >>>>>   ls_accion_perfil = 'PERMISO'  ; cuando se cumpla  :    (Perfil Nuevo) -   (Perfil Modificado)
		if len(ls_accion_perfil) > 0  Then
			li_sustento_perfil  =  wf_adjunta_sustento('MODIFICACION' ,ls_documento_sustento,is_codusuario,ls_idcarpeta)
			
			If ( li_sustento_perfil > 0  )  Then    
						// Indica :  3: Modifica Perfil
//						ls_Parametros = "'"+is_codusuario+"',"+string(ii_idservidor)+",3,'"+ls_documento_sustento +"'"
						ls_Parametros = "'"+is_codusuario+"',3,'"+ls_documento_sustento +"'"		//1.0
						ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_Usuario_Historico_Permiso_Insert ",ls_Parametros)  
						If ls_ret = "SQL:-1" Then 
							gf_mensaje(gs_Aplicacion, 'No se pudo adjuntar el documento para el sustento ', '', 2)
							Return -1
						End if		
			Else
					Return -1	
			End IF
		End If
//		sustento >>>


			//verifica los accesos a bd configurados por perfil
		    li_existe=  wf_valida_Perfilbasedatosrol(ll_perfil_new)
			If ( li_existe > 0  )  Then 
					li_rpta2= gf_mensaje(gs_Aplicacion, 'Se procede con asignar configuracion de accesos de Roles por Perfil '+ ls_nombreperfil_new,"" ,1)
					li_rpta = 1
			End IF
			
			//verifica los accesos a bd configurados por perfil para usuario
			li_existe =  wf_valida_UsuarioPerfilbasedatosrol(il_perfil_ant)
			If ( li_existe > 0  )  Then 
					li_rpta2= gf_mensaje(gs_Aplicacion, 'Se procede con eliminar la configuración de roles del Perfil '+ is_nombreperfil_ant ,"" ,1)
					li_rpta = 1
			End IF


		If li_rpta > 0 Then
				//ls_Parametros = string(il_Idaplicacion)+","+string(ll_perfil_New)+","+string(il_perfil_ant)+","+string(is_codusuario)+","+string(ii_idservidor)
				ls_Parametros = string(il_Idaplicacion)+","+string(ll_perfil_New)+","+string(il_perfil_ant)+","+string(is_codusuario)	//1.0
				li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_UsuarioPerfilBaseDatosRol", ls_Parametros, ls_retorno, ls_Error)
		End If
	
  Return 1
end event

event rowfocuschanged;call super::rowfocuschanged;this.accepttext()

If currentrow > 0 then
		
	il_IdPerfil = this.GetItemnumber(this.GetRow(),'idperfil')		
     event ue_rellenar_treeview() 	   
	
Else
	SetNull( il_IdPerfil )
	tv_perfilmenu.SetRedraw( FALSE )
		DO UNTIL tv_perfilmenu.FindItem(RootTreeItem!, 0) = -1
			tv_perfilmenu.DeleteItem(0)
		LOOP
	tv_perfilmenu.SetRedraw( TRUE )		
End If

end event

event itemchanged;call super::itemchanged;Integer li_Fila

Choose Case getcolumnname()
	
Case  'registroactivo'
		li_Fila=this.find("registroactivo=1",1,this.rowcount( ))
		If li_Fila > 0 Then 
			 This.setitem( li_Fila, 'registroactivo', 0 )
		End If
		
		this.setitem( row, 'codigousuario',  is_codusuario)
				
End Choose




end event

event ue_validar;call super::ue_validar;DWItemStatus ldws_item_estado
string ls_estadouser

ls_estadouser		= tab_user.tabpage_detalles.dw_detalle.GetItemString( tab_user.tabpage_detalles.dw_detalle.getrow(),'estado')
if ls_estadouser = 'I'  then
	gf_mensaje(gs_Aplicacion, 'NO se puede registrar aplicaciones y/o perfil  para un usuario INACTIVO',"" ,3)
	Return -1
End if


ldws_item_estado = tab_user.tabpage_aplicaciones.dw_usuaplicacion.getitemstatus( tab_user.tabpage_aplicaciones.dw_usuaplicacion.ii_filanueva, 'nombreaplicacion', Primary!)
if IsNull(ldws_item_estado)=FALSE then
	If ldws_item_estado = New! or  ldws_item_estado =DataModified!  then
		if this.find("registroactivo=1", 1, this.rowcount())=0 then
			gf_mensaje(gs_Aplicacion, 'NO se ha guardado NUEVO registro de APLICACION, no ha seleccionado un perfil ',"" ,3)
			Return -1
		end if
	End if
End if




Return 1
end event

event retrieveend;call super::retrieveend;Integer li_Fila

If rowcount () > 0 Then
	li_Fila=this.find("registroactivo=1",1,this.rowcount( ))
		If li_Fila > 0 Then 
			il_perfil_ant  			=  This.GetitemNumber( li_Fila, 'idperfil')
			is_nombreperfil_ant 	=  This.Getitemstring( li_Fila, 'NombrePerfil')
		End If
End If

end event

type tabpage_acceso from userobject within tab_user
event create ( )
event destroy ( )
string tag = "R3DW-V40"
integer x = 18
integer y = 112
integer width = 2798
integer height = 2264
long backcolor = 67108864
string text = "Acceso"
long tabtextcolor = 128
string picturename = "CreateForeignKey!"
long picturemaskcolor = 536870912
dw_basedatos dw_basedatos
dw_accesobd dw_accesobd
dw_accesovista dw_accesovista
end type

on tabpage_acceso.create
this.dw_basedatos=create dw_basedatos
this.dw_accesobd=create dw_accesobd
this.dw_accesovista=create dw_accesovista
this.Control[]={this.dw_basedatos,&
this.dw_accesobd,&
this.dw_accesovista}
end on

on tabpage_acceso.destroy
destroy(this.dw_basedatos)
destroy(this.dw_accesobd)
destroy(this.dw_accesovista)
end on

type dw_basedatos from uo_dwbase within tabpage_acceso
integer x = 9
integer y = 44
integer width = 1111
integer height = 1892
integer taborder = 40
boolean bringtotop = true
string title = ""
string dataobject = "dw_basedatos"
boolean hscrollbar = true
boolean ib_actualizar = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

event rowfocuschanged;call super::rowfocuschanged;if currentrow>0 then
	
	if dw_accesobd.uf_cambios_pendientes()=-1 then
			If	MessageBox( 'CONFIRMACIÓN', "Existen cambios en Roles sin actualizar. ¿Desea actualizarlos?", Question!, YesNo! ) = 2 Then 
				iw_VentanaPadre.event ue_cancelar() /*	Ejecuta el evento ue_cancelar */
			Else		
				iw_VentanaPadre.event ue_grabar()	/*	Ejecuta el evento ue_grabar */
			End If
	End if
	
	
	if dw_accesovista.uf_cambios_pendientes()=-1 then
			If	MessageBox( 'CONFIRMACIÓN', "Existen cambios en Vistas sin actualizar. ¿Desea actualizarlos?", Question!, YesNo! ) = 2 Then 
				iw_VentanaPadre.event ue_cancelar() /*	Ejecuta el evento ue_cancelar */
			Else		
				iw_VentanaPadre.event ue_grabar()	/*	Ejecuta el evento ue_grabar */
			End If
	End if
	
	
	ii_idbasedatos	=	this.getitemnumber(currentrow,'idbasedatos')
	tab_user.tabpage_acceso.dw_accesobd.TriggerEvent("ue_retrieve")
 	tab_user.tabpage_acceso.dw_accesovista.TriggerEvent("ue_retrieve")
	 
	tab_user.tabpage_acceso.dw_accesovista.event ue_poblardddw('idvista')
End if
end event

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			20/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos
//Return this.retrieve(ii_idservidor)
Return this.retrieve(1,is_codusuario)	//1.0
end event

event constructor;call super::constructor;//No editable en esta ventana
this.Modify("descripcionbd.TabSequence = 0")
end event

type dw_accesobd from uo_dwbase within tabpage_acceso
string tag = "<MenuAdicional:S,Validar con servidor:S>"
integer x = 1129
integer y = 40
integer width = 1641
integer height = 1276
integer taborder = 30
string title = ""
string dataobject = "dwtv_ususario_basedatos"
boolean hscrollbar = true
boolean ib_activarfiltros = false
boolean ib_resaltarfila = false
boolean ib_menudetalle = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

//Return this.retrieve(is_codusuario,ii_idbasedatos,0,ii_idservidor)
Return this.retrieve(is_codusuario,ii_idbasedatos,0) //1.0
end event

event itemchanged;call super::itemchanged;if dwo.name ='acceso' then
		this.setitem( row, 'codigousuario',  is_codusuario)
End if
end event

event clicked;call super::clicked;//if ib_usuariook=False then 
//	gf_mensaje(gs_Aplicacion, 'Uusario no disponible...verifique', '', 3)
//	Return 2
//End if
end event

event ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;Integer					li_totalobjbd
Integer					li_rowbd
Integer					li_cont
Integer					li_filaanombrerol
String						ls_NomnreRol

uo_dsbase				lds_DatosRolUsuario

li_rowbd		=	dw_principal.GetRow()

If li_rowbd<1 then Return 

Choose Case as_menutexto
	Case 'Validar con servidor'
		lds_DatosRolUsuario 		=  gf_procedimiento_consultar( "Seguridad.usp_SQL_BaseDatosRolUsuario_Comparar " + is_codusuario+","+String(ii_idbasedatos)+","+String(ii_idservidor)  ,sqlca)
		this.accepttext( )			
	
		li_totalobjbd		=	lds_DatosRolUsuario.Rowcount()
		
		For li_cont = 1 to li_totalobjbd
			ls_NomnreRol	=	lds_DatosRolUsuario.GetItemString(li_cont,'DatabaseRoleName')
				
			li_filaanombrerol =this.find("NombreRol='" + (ls_NomnreRol)+ "'",1,this.rowcount( ))
				
			if li_filaanombrerol>0 then
				if this.GetItemNumber(li_filaanombrerol , 'acceso')=0 then
					this.setitem( li_filaanombrerol, 'acceso',1 )
					this.setitem( li_filaanombrerol, 'codigousuario',  is_codusuario)
				End if
			End If 
		Next

		if  li_filaanombrerol > 0   then
			iw_ventanapadre.ib_editando = true
			iw_ventanapadre.event ue_editar()
		End if
		
End Choose
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;Return -1
end event

type dw_accesovista from uo_dwbase within tabpage_acceso
integer x = 1129
integer y = 1336
integer width = 1641
integer height = 608
integer taborder = 40
string title = ""
string dataobject = "dw_acceso_vista"
boolean hscrollbar = true
boolean ib_activarfiltros = false
boolean ib_menudetalle = true
boolean ib_dddwpoblado = true
end type

event ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			20/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

il_idmaxvista	=	0
//Return this.retrieve(ii_IdServidor,ii_idBaseDatos, is_codusuario )
Return this.retrieve(ii_idBaseDatos, is_codusuario ) //1.0
end event

event ue_agregar_registro_post;call super::ue_agregar_registro_post;DateTime adt_fecha
Date	ldt_fecha

sqlca.uf_usp_fechahora_select(adt_fecha)

ldt_fecha		=	 RelativeDate ( date(adt_fecha) , ii_dias_clave )
adt_fecha	=	DateTime(ldt_fecha,Time('00:00'))

This.object.idbasedatos[ ai_row ] 		=	 ii_idBaseDatos
This.object.idservidor[ ai_row ] 		= 	ii_IdServidor
This.object.codigousuario[ ai_row ]   =	is_codusuario

This.object.fechabaja[ ai_row ]   =adt_fecha

end event

event ue_poblardddw;call super::ue_poblardddw;Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idvista' 
		li_ret = ldwc_child.Retrieve(ii_IdServidor,ii_idBaseDatos ) // recuperar los servidores
  			ldwc_child.accepttext()
End Choose


// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )

end event

event ue_validar;call super::ue_validar;// 1.1			Walther Rodriguez					20/06/2024		Se quito el parametro IDServidor de Seguridad.usp_SQL_Usuario_Validar
String 	ls_Parametros
String		ls_ret
Integer	li_retorno
Integer	li_retornoOUT
String		ls_tipoLogin
String		ls_nombrebasedatos
String     ls_codigoLogin
String		ls_codigoUsuario

ls_nombrebasedatos	=	dw_basedatos.getitemstring(dw_basedatos.GetRow(),'nombrebd')
if IsNull(ls_nombrebasedatos) or Len(ls_nombrebasedatos)<2 then
	Return -1
End if

//ls_tipoAcceso		= tab_user.tabpage_detalles.dw_detalle.GetItemString( tab_user.tabpage_detalles.dw_detalle.getrow(),'tipoacceso')
//if IsNull(ls_tipoAcceso) or Len(ls_tipoAcceso)<1 then
//	Return -1
//End if

//Cambio ls_tipoAcceso por tipologin
ls_tipologin		= tab_user.tabpage_detalles.dw_detalle.GetItemString( tab_user.tabpage_detalles.dw_detalle.getrow(),'tipologin')
if IsNull(ls_tipologin) or Len(ls_tipologin)<1 then
	Return -1
End if

ls_codigoLogin	= tab_user.tabpage_detalles.dw_detalle.GetItemString( tab_user.tabpage_detalles.dw_detalle.getrow(),'CodigoLogin')
if IsNull(ls_codigoLogin) or Len(ls_codigoLogin)<1 then
	Return -1
End if

ls_codigoUsuario	= tab_user.tabpage_detalles.dw_detalle.GetItemString( tab_user.tabpage_detalles.dw_detalle.getrow(),'CodigoUsuario')
if IsNull(ls_codigoUsuario) or Len(ls_codigoUsuario)<1 then
	Return -1
End if

ls_Parametros =  "2,"+",'"+ ls_nombrebasedatos+"','" + ls_codigoUsuario +"','"+ls_tipologin+"',"+String(li_retornoOUT)	//1.1

ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_SQL_Usuario_Validar",ls_Parametros)  
If ls_ret = "SQL:-1" Then 
	gf_mensaje(gs_Aplicacion, 'No se pudo consultar usuarios SQL para validar VISTAS', '', 2)
	Return -1
End if

if Integer(ls_ret)=0 then
	gf_mensaje(gs_Aplicacion, 'El usuario ' +is_codusuario +' SQL aún no esta creado en la base de datos, NO se puede asignar VISTA ', '', 3)
	iw_ventanapadre.ib_Editando = False
	iw_ventanapadre.Event ue_editar( )	
	this.event ue_retrieve( )
	return -1
End if

Return 1
end event

event getfocus;call super::getfocus;this.setcolumn( 'fechabaja')
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;//if ib_usuariook=False then 
//	gf_mensaje(gs_Aplicacion, 'Uusario no disponible...verifique', '', 3)
//	Return -1
//End if

Return AncestorReturnValue
end event

type em_buscar from uo_edm_texto within w_usuarios
boolean visible = false
integer x = 4155
integer y = 8
integer width = 320
integer taborder = 30
boolean bringtotop = true
end type

type st_busqueda from statictext within w_usuarios
integer x = 1554
integer y = 120
integer width = 722
integer height = 56
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Buscar por Código Usuario:"
alignment alignment = right!
boolean focusrectangle = false
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_usuarios
integer x = 41
integer y = 116
integer taborder = 40
boolean bringtotop = true
boolean enabled = false
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	
	SetNull( il_IdPerfil )
	
	dw_principal.reset( )
	tab_user.tabpage_detalles.dw_detalle.reset( )
	tab_user.tabpage_detalles.dw_acceso_unidad.reset( )
	tab_user.tabpage_acceso.dw_accesobd.reset( )
	tab_user.tabpage_acceso.dw_accesovista.reset( )
	tab_user.tabpage_acceso.dw_basedatos.reset( )
//	tab_user.tabpage_aplicaciones.dw_aplicacion.reset( )
	tab_user.tabpage_aplicaciones.dw_perfil.reset( )
	tab_user.tabpage_aplicaciones.dw_usuaplicacion.reset( )

	tab_user.tabpage_aplicaciones.tv_perfilmenu.SetRedraw( FALSE )
		DO UNTIL tab_user.tabpage_aplicaciones.tv_perfilmenu.FindItem(RootTreeItem!, 0) = -1
			tab_user.tabpage_aplicaciones.tv_perfilmenu.DeleteItem(0)
		LOOP
	tab_user.tabpage_aplicaciones.tv_perfilmenu.SetRedraw( TRUE )		
	
	Return -2
Else

//	tab_user.tabpage_aplicaciones.dw_aplicacion.event ue_poblardddw('idaplicacion')

	dw_principal.event ue_retrieve( )
End if
end event

type sle_buscar from singlelineedit within w_usuarios
integer x = 2304
integer y = 116
integer width = 1559
integer height = 80
integer taborder = 30
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

