$PBExportHeader$w_reponse_selecionar_rol.srw
forward
global type w_reponse_selecionar_rol from w_response_seleccionar
end type
end forward

global type w_reponse_selecionar_rol from w_response_seleccionar
string title = "Lista Roles"
end type
global w_reponse_selecionar_rol w_reponse_selecionar_rol

type variables
Integer ii_idRol
end variables

on w_reponse_selecionar_rol.create
call super::create
end on

on w_reponse_selecionar_rol.destroy
call super::destroy
end on

event open;call super::open;str_arg		lstr_Recep
lstr_Recep = istr_parametros.str_argumentos
  
ii_idRol			=  lstr_Recep.i[1]









end event

event ue_postopen;call super::ue_postopen;Integer li_row
li_row = dw_principal.find("idrol="+String(ii_idRol),1,dw_principal.RowCount())

IF li_row > 0 THEN
//	dw_principal.setRow(li_row)
//    dw_principal.Selectrow( 0, False)
//    dw_principal.ScrollToRow(li_row)
//    dw_principal.SelectRow(li_row,True)
//	dw_principal.event clicked( 10  ,10,li_row, dw_principal.object.nombre)

	dw_principal.event ue_selecccionar( li_row)
	
end if 



end event

type cbx_filtros from w_response_seleccionar`cbx_filtros within w_reponse_selecionar_rol
end type

type dw_principal from w_response_seleccionar`dw_principal within w_reponse_selecionar_rol
event ue_selecccionar ( integer row )
end type

event dw_principal::ue_selecccionar(integer row);		String		ls_FilasSeleccionadas
		String		ls_Fila
		Integer	li_NroColumnas
		Integer	li_Columna
		String		ls_Columna
		String		ls_Valores[]
		Integer	li_CantidadFilas
		Integer	li_n
		
		If	row = 0 Then Return
		
		li_NroColumnas				= Integer(This.Object.Datawindow.Column.Count)
		ls_FilasSeleccionadas		= st_filas.tag
		ls_Fila						= String( row )
		
		If	Len( ls_FilasSeleccionadas ) > 0 And ib_SelecMultiple = True Then
			If	Pos( ',' + ls_FilasSeleccionadas + ',', ','+ ls_Fila + ',' ) > 0 Then
				li_CantidadFilas = gf_split( ls_Valores[], ls_FilasSeleccionadas, ',' )
				ls_FilasSeleccionadas = ''
				For li_n = 1 To li_CantidadFilas
					If	ls_Valores[ li_n ] <> ls_Fila Then
						ls_FilasSeleccionadas = ls_FilasSeleccionadas + ls_Valores[ li_n ] + ','
					End If
				Next
				ls_FilasSeleccionadas = Left( ls_FilasSeleccionadas, Len(ls_FilasSeleccionadas) -1 )
			Else
				ls_FilasSeleccionadas = ls_FilasSeleccionadas + ',' + ls_Fila
			End If
		Else
			ls_FilasSeleccionadas = ls_Fila
		End If
		
		st_filas.tag = ls_FilasSeleccionadas
		st_filas.text = ' Fila(s) seleccionada(s): ' + ls_FilasSeleccionadas
			
		For li_Columna = 1 To li_NroColumnas
			ls_Columna = '#' + string(li_Columna)
			This.modIfy(ls_Columna + ".Background.color='16777215~tif( getrow() in ("+ls_FilasSeleccionadas+"), 16755261, 16777215 )'")	
		Next

end event

type cb_cancelar from w_response_seleccionar`cb_cancelar within w_reponse_selecionar_rol
end type

type cb_aceptar from w_response_seleccionar`cb_aceptar within w_reponse_selecionar_rol
end type

type st_filas from w_response_seleccionar`st_filas within w_reponse_selecionar_rol
end type

type cbx_seleccionar_todo from w_response_seleccionar`cbx_seleccionar_todo within w_reponse_selecionar_rol
end type

