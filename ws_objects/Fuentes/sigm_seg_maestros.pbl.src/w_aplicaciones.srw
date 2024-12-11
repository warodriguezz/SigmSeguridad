$PBExportHeader$w_aplicaciones.srw
forward
global type w_aplicaciones from w_base
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_aplicaciones
end type
end forward

global type w_aplicaciones from w_base
string title = "Aplicaciones"
integer ii_modoventana = 3
dw_filtro_servidor dw_filtro_servidor
end type
global w_aplicaciones w_aplicaciones

type variables
Integer	ii_IdAplicacion
Integer	ii_idservidor
//Boolean ib_new = false 
//Integer ii_newRow = 0 

 
 

end variables

on w_aplicaciones.create
int iCurrent
call super::create
this.dw_filtro_servidor=create dw_filtro_servidor
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_filtro_servidor
end on

on w_aplicaciones.destroy
call super::destroy
destroy(this.dw_filtro_servidor)
end on

event ue_vistaprevia;Return  
end event

event resize;call super::resize;dw_principal.width = newwidth - ( BordeVertical * 2 )
dw_principal.height = newheight - ( BordeHorizontal * 2 ) - il_AlturaTitulo


end event

type st_titulo from w_base`st_titulo within w_aplicaciones
string text = "Aplicaciones"
end type

type st_fondo from w_base`st_fondo within w_aplicaciones
end type

type dw_principal from w_base`dw_principal within w_aplicaciones
string tag = "<MenuAdicional:S,Aplicación Menus:S,Aplicación Versiones:S,Ruta Archivo:S>"
integer y = 252
integer height = 840
string dataobject = "dw_aplicaciones"
boolean ib_mostrarmensajeantesdeeliminarregistro = true
end type

event dw_principal::ue_poblardddw;call super::ue_poblardddw;Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idesquema' 
		li_ret = ldwc_child.Retrieve(ii_idservidor) 
  
End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )
end event

event dw_principal::ue_retrieve;call super::ue_retrieve;Return retrieve(ii_idservidor)

end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;Long					ll_Id = 0
String					ls_tabla
String					ls_ValoresPK
Integer				li_ValorRetorno	
Integer				li_idservidor
Long					li_cont

dwItemStatus 	ldwis_Estado
li_cont	=	this.rowcount()

ls_Tabla 		= 'Seguridad.Aplicacion'
ls_ValoresPK= ""
li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro

ldwis_Estado = This.getitemstatus( li_cont, 0, Primary! )

If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then

/* Generar el ID */
li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, ll_Id )	

If	IsNull( ll_Id ) OR ll_Id = 0 Then
	Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
	Return
End If

ii_IdAplicacion		=	ll_Id 
//Seteando valores
This.SetItem(ai_row,'idaplicacion', ii_IdAplicacion)	
this.setitem( ai_row, 'estadoaplicacion','S')
this.setitem( ai_row, 'idServidor',ii_idservidor)
this.setitem( ai_row, 'usuarioRegistro',gs_Usuario)

	this.accepttext( )
end if 
end event

event dw_principal::ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;Integer 				li_idAplicacion
String 				ls_nombreAplicacion
String					ls_MenuAplicacion
String 				ls_nombreObjeto 
String					ls_estadoapp
String					ls_ruta
String					ls_ruta_ant
Integer				li_row
str_arg  				lstr_Enviar
str_response  		lstr_Argumentos


li_row						=	this.getrow( )

if li_row<1 then Return

li_idAplicacion 			=  This.getitemnumber(li_row, 'idaplicacion') 
ls_nombreAplicacion 	=  This.getitemstring(li_row, 'nombreaplicacion')  
ls_nombreObjeto 		=  This.getitemstring(li_row, 'objetoaplicacion')  
ls_MenuAplicacion  	=  This.getitemstring(li_row, 'menuaplicacion') 
ls_estadoapp		 	=  This.getitemstring(li_row, 'estadoaplicacion') 

if ls_estadoapp<>'S' then
	gf_mensaje(gs_Aplicacion, 'Aplicación ' +ls_nombreAplicacion+ ' NO esta ACTIVA' , '', 1)	
	Return
End if
	
Choose Case as_menutexto
	Case 'Aplicación Versiones'			
									
		lstr_Enviar.i[1] = ii_idservidor
		lstr_Enviar.i[2] = li_idAplicacion
		lstr_Enviar.s[1]	= dw_filtro_servidor.is_nombreServerfiltro  
						
		//lstr_Argumentos.b_usar_datastore		= False
		lstr_Argumentos.s_dataobject 				= 'dw_aplicacionversion'
		lstr_Argumentos.s_titulo     				 	= 'Versiones de la Aplicación: ' +ls_nombreAplicacion  //+ ls_nombreanalito + ' /' + ls_nombremetodo + '.' 
		lstr_Argumentos.s_titulos_columnas		= ls_nombreObjeto 
		lstr_Argumentos.l_ancho						= 4000
		lstr_Argumentos.l_alto						= 3000
		lstr_Argumentos.b_ventanaeditable		= True
		lstr_Argumentos.str_argumentos			= lstr_Enviar
		lstr_Argumentos.b_menupopup = true 
				
		OpenWithParm(w_aplicacion_version,	lstr_Argumentos)
							
		
	Case 'Aplicación Menus'					
			
		If isnull(ls_MenuAplicacion) Or trim(ls_MenuAplicacion) = '' then
			gf_mensaje(gs_Aplicacion, 'Ingresar el nombre del Menú Aplicación', '', 1)	
			Return 
		end if 
		lstr_Enviar.i[1]   =  ii_idservidor
		lstr_Enviar.i[2]   =  li_idAplicacion
		lstr_Enviar.s[1]  =  ls_nombreObjeto
		lstr_Enviar.s[2]  =  ls_MenuAplicacion
		lstr_Enviar.s[3]  =  ls_NombreAplicacion

		lstr_Argumentos.s_dataobject 				= 'dw_menuitems_import'
		lstr_Argumentos.s_titulo     				 	= 'Importación de Menús '+ls_nombreAplicacion
		lstr_Argumentos.b_redim_ventana			= True
		lstr_Argumentos.b_redim_controles		=	True
		lstr_Argumentos.l_ancho						= 4330
		lstr_Argumentos.l_alto						= 2080

		lstr_Argumentos.str_argumentos			= lstr_Enviar
				
		OpenWithParm(w_importar_menus_excel,	lstr_Argumentos)
		
		if Integer(message.doubleparm) =1 then this.event ue_retrieve()
	
	Case 'Ruta Archivo'
		
		ls_ruta_ant	 	= This.getitemstring(li_row, 'rutaarchivo') 
		if IsNull(ls_ruta_ant) or ls_ruta_ant='null' then ls_ruta_ant=''
		ls_ruta			 =	gf_inputbox("Ruta aplicación","Ruta archivo ejecutable:", "V",ls_ruta_ant,TRUE)
		
		if ls_ruta_ant<> ls_ruta then
			this.setitem(li_row,'rutaarchivo',ls_ruta)
			this.accepttext( )
			
			//Modo edicion
			iw_ventanapadre.ib_editando=True
			iw_ventanapadre.event ue_editar( )

		End if
End Choose
		
		
end event

event dw_principal::clicked;call super::clicked;Choose case dwo.name
	Case 'b_menu'		
		if  ib_editando  then
				gf_mensaje(gs_Aplicacion, 'Usted debe registrar la modificación realizada', '', 1)
		return 
	end if 
		
      This.Event ue_menu_detalle_adicional  ("Aplicación Menus")	
		
End Choose 
 
end event

event dw_principal::ue_validar;call super::ue_validar;Integer					li_rowcount
Integer					li_fila
dwItemStatus			ldwis_Estado

li_rowcount	=	this.rowcount( )

For li_fila = 1 to li_rowcount
	
	ldwis_Estado = This.getitemstatus( li_fila, 0, Primary! )
	
	If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then
		if (Isnull(this.getitemstring(li_fila, 'nombreaplicacion')) or Len(this.getitemstring(li_fila, 'nombreaplicacion'))<1) OR  (Isnull(this.getitemstring(li_fila, 'objetoaplicacion')) or Len(this.getitemstring(li_fila, 'objetoaplicacion'))<1)   OR  (Isnull(this.getitemstring(li_fila, 'menuaplicacion')) or Len(this.getitemstring(li_fila, 'menuaplicacion'))<1) then
			gf_Mensaje(gs_aplicacion,"Debe registrar Nombre , Objeto Aplicación y Menu Aplicación ","Fila :" + String(li_fila),3)
			Return -1
		End if
	End if
	
Next
Return 1
end event

type st_menuruta from w_base`st_menuruta within w_aplicaciones
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_aplicaciones
integer x = 46
integer y = 140
integer taborder = 10
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible.', '', 3)
	dw_principal.reset( )
	Return -2
Else
	dw_principal.event ue_retrieve( )
	dw_principal.event ue_poblardddw('idesquema')
End if
end event

