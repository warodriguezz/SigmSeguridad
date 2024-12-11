$PBExportHeader$w_acceso_vista.srw
forward
global type w_acceso_vista from w_response_mtto
end type
type dw_basedatos from uo_dwfiltro within w_acceso_vista
end type
end forward

global type w_acceso_vista from w_response_mtto
integer width = 3474
dw_basedatos dw_basedatos
end type
global w_acceso_vista w_acceso_vista

type variables
uo_dsbase			ids_acceso_vista
str_arg				istr_arg



DataWindowChild 	     idwch_DataBase,idwch_Vista,idwch_Servidor,idwch_basedatos
//DataWindowChild    	idwch_DataBaseq      

Integer ii_idBaseDatos,ii_IdServidor


str_arg		istr_recibido
String		is_codusuario
end variables

on w_acceso_vista.create
int iCurrent
call super::create
this.dw_basedatos=create dw_basedatos
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_basedatos
end on

on w_acceso_vista.destroy
call super::destroy
destroy(this.dw_basedatos)
end on

event open;call super::open;istr_recibido 	= istr_parametros.str_Argumentos
is_codusuario 	= istr_recibido.s[1]
ii_idservidor		= istr_recibido.i[1]

dw_basedatos.event ue_poblardddw('idbasedatos')


end event

type cbx_filtros from w_response_mtto`cbx_filtros within w_acceso_vista
end type

type dw_principal from w_response_mtto`dw_principal within w_acceso_vista
integer x = 18
integer y = 188
integer width = 3424
integer height = 1144
string dataobject = "dw_acceso_vista"
end type

event dw_principal::clicked;call super::clicked;this.setrow(row)
this.scrolltorow(row)


end event

event dw_principal::ue_poblardddw;call super::ue_poblardddw;Integer	li_ret
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


this.setcolumn("fechabaja")
this.setfocus( )





end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;
This.object.idbasedatos[ ai_row ] = ii_idBaseDatos
This.object.idservidor[ ai_row ] = ii_IdServidor
This.object.codigousuario[ ai_row ]   =is_codusuario








end event

event dw_principal::ue_agregar_registro_pre;call super::ue_agregar_registro_pre;

if IsNull(ii_IdServidor) or ii_IdServidor = 0  then 
	gf_mensaje(gs_Aplicacion, 'No ha seleccionado Servidor para las Vistas ..verifique', '', 3)
	Return -1
End if

if IsNull(ii_idBaseDatos) or ii_idBaseDatos = 0  then 
	gf_mensaje(gs_Aplicacion, 'No ha seleccionado Base Datos  para las Vistas ..verifique', '', 3)
	Return -1
End if


end event

event dw_principal::ue_validar;call super::ue_validar;Integer 	li_CtdFilas,li_vista
Integer 	li_For
DateTime ldt_fechabaja
Integer li_FilaLaborDuplicada
string ls_buscar

If AncestorReturnValue <> 1 Then Return AncestorReturnValue

li_CtdFilas = This.Rowcount()
For li_For=1 To li_CtdFilas
	li_vista = This.getitemNumber(li_For,"idvista")
	ldt_fechabaja = This.getitemDatetime(li_For,"fechabaja")
	
		If li_vista = 0  Or IsNull(li_vista) Then
			This.setcolumn("idvista")
			This.setrow(li_For)
			gf_mensaje(gs_Aplicacion,"El campo Nombre Vista es obligatorio en la Fila "+String(li_For),"",2)
			Return -1
		End If
		
		If IsNull(ldt_fechabaja) Then
			This.setcolumn("fechabaja")
			This.setrow(li_For)
			gf_mensaje(gs_Aplicacion,"El campo Fecha Baja  es necesario en la Fila "+String(li_For),"",2)
			Return -1
		End If
		
		If date(ldt_fechabaja)  < today() Then
			This.setcolumn("fechabaja")
			This.setrow(li_For)
			gf_mensaje(gs_Aplicacion,"La  Fecha Baja no puede ser menor a la Fecha Actual "+String(li_For),"",2)
			Return -1
		End If
		
		
Next



		
		


Return 1
end event

event dw_principal::getfocus;call super::getfocus;Parent.tag=This.tag
end event

event dw_principal::itemchanged;call super::itemchanged;Integer ll_fila
Choose case dwo.name
	Case	'idvista'
		
	ll_fila = dw_principal.Find("idvista = "+string(data),1,dw_principal.RowCount())
	if ll_fila > 0 then
			gf_mensaje(gs_aplicacion, 'No se permite registros duplicados.', '',1)
			dw_principal.deleterow(0)
			Return 
	end if
End Choose



	
end event

event dw_principal::ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;return -1

end event

type cb_cancelar from w_response_mtto`cb_cancelar within w_acceso_vista
integer x = 2999
integer y = 1360
end type

type cb_aceptar from w_response_mtto`cb_aceptar within w_acceso_vista
integer x = 2569
integer y = 1360
end type

event cb_aceptar::clicked;call super::clicked;dw_Principal.AcceptText()

If dw_Principal.event ue_validar() <> 1 Then Return
If dw_Principal.event ue_grabar() <> 1 Then Return
Close( Parent )
end event

type dw_basedatos from uo_dwfiltro within w_acceso_vista
integer x = 18
integer y = 24
integer width = 1582
integer height = 108
integer taborder = 20
boolean bringtotop = true
string dataobject = "dwf_basedatos"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;Integer li_null
SetNull(li_null)

This.accepttext( )


ii_idBaseDatos  =  integer(data)

dw_principal.retrieve(ii_IdServidor,ii_idBaseDatos, is_codusuario )
dw_principal.event ue_poblardddw('idvista')








end event

event ue_poblardddw;call super::ue_poblardddw;Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idbasedatos' 
		li_ret = ldwc_child.Retrieve(ii_idservidor) // recuperar las bd
  
End Choose



// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )

end event

event ue_retrieve;call super::ue_retrieve;return 1

end event

