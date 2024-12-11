$PBExportHeader$uo_modulo_seguridad.sru
forward
global type uo_modulo_seguridad from uo_modulo
end type
end forward

global type uo_modulo_seguridad from uo_modulo
end type
global uo_modulo_seguridad uo_modulo_seguridad

forward prototypes
public function integer uf_cambiar_menu (window aw_ventana)
public function long uf_usp_sysadmin_validar (readonly transaction atr_transaction, readonly string as_usuario, ref integer ai_valor)
public function long uf_usp_usuario_resetearpassword (transaction atr_transaction, string as_usuario, string as_clave, string as_linkedserver)
public function long uf_usp_usuario_desbloquear (transaction atr_transaction, string as_usuario, string as_linkedserver)
public function long uf_usp_auditoriausuarios_insert (readonly transaction atr_transaction, readonly string as_usuariosecurityadmin, readonly integer ai_idservidor, readonly string as_cod_usuario, readonly string as_accion)
end prototypes

public function integer uf_cambiar_menu (window aw_ventana);Integer li_ChangeMenu

m_menu_seguridad lm_menu
lm_menu = Create m_menu_seguridad

li_ChangeMenu = aw_ventana.ChangeMenu( lm_menu )

return li_ChangeMenu
end function

public function long uf_usp_sysadmin_validar (readonly transaction atr_transaction, readonly string as_usuario, ref integer ai_valor);Long		ll_Retorno
Integer	li_Valor

DECLARE usp_stored PROCEDURE FOR 'dbo.usp_SysAdmin_Validar'
	@cod_usuario = :as_usuario,
	@valor = :li_Valor OUTPUT
USING atr_transaction;

EXECUTE usp_stored;  

If  atr_transaction.sqlcode  < 0 Then
	gf_mensaje( gs_Aplicacion, 'Error al validar el usuario.', atr_transaction.sqlerrtext, 2 )
	ll_Retorno = -1
Else
	FETCH usp_stored INTO :li_valor;
	ll_Retorno = 1
End If 

CLOSE usp_stored;

ai_valor = li_Valor

return ll_Retorno
end function

public function long uf_usp_usuario_resetearpassword (transaction atr_transaction, string as_usuario, string as_clave, string as_linkedserver);Long ll_Retorno
 
DECLARE usp_stored PROCEDURE FOR 'dbo.usp_Usuario_ResetearPassword'
	@Usuario = :as_usuario,   
	@Clave = :as_clave,
	@servidor = :as_linkedserver
USING atr_transaction;

EXECUTE usp_stored;

If  atr_transaction.sqlcode  < 0 Then
	gf_mensaje( gs_Aplicacion, 'Error al resetear la clave del usuario: "' + as_usuario + '"', atr_transaction.sqlerrtext, 2 )
	ll_Retorno = -1
Else
	ll_Retorno = 1
End If 

CLOSE usp_stored;

return ll_Retorno
end function

public function long uf_usp_usuario_desbloquear (transaction atr_transaction, string as_usuario, string as_linkedserver);Long ll_Retorno
 
DECLARE usp_stored PROCEDURE FOR 'dbo.usp_Usuario_Desbloquear'
	@usuario = :as_usuario,
	@servidor = :as_linkedserver
USING atr_transaction;

EXECUTE usp_stored;  

If  atr_transaction.sqlcode  < 0 Then
	gf_mensaje( gs_Aplicacion, 'Error al desbloquear el usuario: "' + as_usuario + '"', atr_transaction.sqlerrtext, 2 )
	ll_Retorno = -1
Else
	ll_Retorno = 1
End If 

CLOSE usp_stored;

return ll_Retorno
end function

public function long uf_usp_auditoriausuarios_insert (readonly transaction atr_transaction, readonly string as_usuariosecurityadmin, readonly integer ai_idservidor, readonly string as_cod_usuario, readonly string as_accion);Long		ll_Retorno

DECLARE usp_stored PROCEDURE FOR 'dbo.usp_AuditoriaUsuarios_Insert'
	@UsuarioSecurityAdmin = :as_UsuarioSecurityAdmin,
	@IdServidor = :ai_IdServidor,
	@cod_usuario = :as_cod_usuario,
	@Accion = :as_Accion
USING atr_transaction;

EXECUTE usp_stored;  

If  atr_transaction.sqlcode  < 0 Then
	gf_mensaje( gs_Aplicacion, 'Error al regsitrar la auditoría.', atr_transaction.sqlerrtext, 2 )
	ll_Retorno = -1
Else
	ll_Retorno = 1
End If 

CLOSE usp_stored;

return ll_Retorno
end function

on uo_modulo_seguridad.create
call super::create
end on

on uo_modulo_seguridad.destroy
call super::destroy
end on

event constructor;call super::constructor;//String				ls_servername
//String				ls_error
//String				ls_retorno[]
//String				ls_parametros
// 
//
//ls_Parametros = "2,'"+sqlca.servername+"'"
//gf_procedimiento_ejecutar("Seguridad.usp_Servidor_Select_02",ls_parametros,ls_retorno, ls_error)
//If UpperBound(ls_retorno)<=0 Then
//	gf_mensaje(gs_Aplicacion, 'No se pudo obtener ID servidor activo', '', 1)
//	Return 1
//Else
//	 gi_idservidor = Integer(ls_retorno[1])
//End If
// 
end event

