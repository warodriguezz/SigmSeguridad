$PBExportHeader$w_esquema.srw
forward
global type w_esquema from w_base
end type
end forward

global type w_esquema from w_base
end type
global w_esquema w_esquema

type variables
Integer ii_IdEsquema

Boolean ib_new = false 
Integer ii_NewRow 


end variables

on w_esquema.create
call super::create
end on

on w_esquema.destroy
call super::destroy
end on

event ue_cancelar;call super::ue_cancelar; ib_new  = false 
 ii_NewRow  = 0
end event

type st_titulo from w_base`st_titulo within w_esquema
end type

type st_fondo from w_base`st_fondo within w_esquema
end type

type dw_principal from w_base`dw_principal within w_esquema
string tag = "Esquema  Base de Datos"
string dataobject = "dw_esquema"
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;return retrieve()
end event

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre;String				ls_Tabla
String				ls_ValoresPK
Long				ll_Id = 0
Integer			li_idservidor	

li_idservidor	=	 0

If  ib_New Then  
	 
	ls_Tabla = 'Seguridad.Esquema'
	ls_ValoresPK= ""	
	/* Generar el ID */
	Integer	li_ValorRetorno	
	
	li_ValorRetorno = sqlca.usp_generarid(li_idservidor, ls_Tabla, ls_ValoresPK, ll_Id )	
	
	If	IsNull( ll_Id ) OR ll_Id = 0 Then
		Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
		Return -1
	End If
	
	ii_IdEsquema	 = ll_Id	  
	This.SetItem(ii_NewRow,'idesquema',ii_IdEsquema)  	
 return  1
  
End If

return 1
end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post; ib_new = true 
 ii_NewRow  =  ai_row
 


end event

type st_menuruta from w_base`st_menuruta within w_esquema
end type

