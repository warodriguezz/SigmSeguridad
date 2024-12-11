$PBExportHeader$w_aplicacion_version.srw
forward
global type w_aplicacion_version from w_response_mtto
end type
end forward

global type w_aplicacion_version from w_response_mtto
end type
global w_aplicacion_version w_aplicacion_version

type variables
Integer ii_IdAplicacion
Integer ii_servidor

Boolean ib_new  = false 
Integer  ii_IdVersion 
Integer ii_NewRow
DateTime idt_fecha

String		is_servername
end variables

on w_aplicacion_version.create
call super::create
end on

on w_aplicacion_version.destroy
call super::destroy
end on

event open;call super::open;str_arg		lstr_Recep
lstr_Recep = istr_parametros.str_argumentos
ii_servidor 		= 	lstr_Recep.i[1]
ii_IdAplicacion 	= 	lstr_Recep.i[2]
is_servername = 	lstr_Recep.s[1]

dw_principal.event ue_retrieve()
return 1
end event

type cbx_filtros from w_response_mtto`cbx_filtros within w_aplicacion_version
end type

type dw_principal from w_response_mtto`dw_principal within w_aplicacion_version
integer height = 1208
string title = ""
string dataobject = "dw_aplicacionversion"
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;return retrieve(ii_IdAplicacion,ii_servidor)


end event

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre;String				ls_Tabla
String				ls_ValoresPK
Long				ll_Id = 0
String				ls_servidor
Integer			li_idservidor

li_idservidor	=	ii_servidor

If ib_new Then

     ls_Tabla = 'Seguridad.AplicacionVersion'
     ls_ValoresPK= string(ii_IdAplicacion)+":"
	/* Generar el ID */
	Integer								li_ValorRetorno	
	li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, ll_Id )	

     If	IsNull( ll_Id ) OR ll_Id = 0 Then
         Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
         Return -1
     End If  	  
	   ii_IdVersion	 = ll_Id	  
	  dw_principal.SetItem( ii_NewRow,'idversion', ii_IdVersion )
	   dw_principal.SetItem( ii_NewRow,'idServidor', ii_servidor)
	 
	 ib_new = false 
	 
	 Return 1
	 
	  
End If

Return 1
end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post; if ib_new then	
	gf_mensaje(gs_Aplicacion, 'Debe registrar el registro pendiente', '', 1)
	This.event ue_eliminar_registro(ai_row)	
	Return  
 end if 
	
 ib_new = True
 ii_NewRow = ai_row 
 This.Setitem(ai_row,'idaplicacion',ii_IdAplicacion)
 sqlca.uf_usp_fechahora_select(idt_fecha)
 This.Setitem(ai_row,'fechaversion',idt_fecha )
 
end event

event dw_principal::ue_validar;call super::ue_validar;Date ldt_fechaLeft
Date ldf_fecha
String ls_descripcion 

this.accepttext( )

if ii_NewRow > 1 then

	ls_descripcion 	=  this.getitemstring(ii_NewRow,'descripcion')
	ldt_fechaLeft 	=  date(this.getitemdateTime(ii_NewRow - 1,'fechaversion'))
	ldf_fecha 		=  date(this.getitemdatetime(ii_NewRow,'fechaversion'))
	
	If Trim(ls_descripcion) = '' then setnull(ls_descripcion)
	if Isnull(ls_descripcion) then 		
		gf_mensaje(gs_Aplicacion, 'Debe ingresar la descripción de la versión', '', 1)		
		return  -1
	end if 
	 
	 if ldt_fechaLeft > ldf_fecha then 
			gf_mensaje(gs_Aplicacion, 'La fecha de la versión no debe ser menor a la versión anterior', '', 1)		
			return -1
	 end if 
	
end if 
 
return  1
end event

type cb_cancelar from w_response_mtto`cb_cancelar within w_aplicacion_version
end type

type cb_aceptar from w_response_mtto`cb_aceptar within w_aplicacion_version
end type

event cb_aceptar::clicked;call super::clicked;If dw_principal.event ue_validar() = -1 Then  return 
If dw_principal.event ue_grabar_pre() = -1 Then  return 
If dw_principal.event ue_grabar() = -1 Then  return 

Close (parent)




end event

