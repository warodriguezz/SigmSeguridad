$PBExportHeader$w_usuario_servidor.srw
forward
global type w_usuario_servidor from w_base
end type
type dw_servidores from uo_dwbase within w_usuario_servidor
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_usuario_servidor
end type
type tab_user from tab within w_usuario_servidor
end type
type tabpage_administrador from userobject within tab_user
end type
type dw_administrador from uo_dwbase within tabpage_administrador
end type
type tabpage_administrador from userobject within tab_user
dw_administrador dw_administrador
end type
type tabpage_consulta from userobject within tab_user
end type
type dw_consulta from uo_dwbase within tabpage_consulta
end type
type tabpage_consulta from userobject within tab_user
dw_consulta dw_consulta
end type
type tab_user from tab within w_usuario_servidor
tabpage_administrador tabpage_administrador
tabpage_consulta tabpage_consulta
end type
end forward

global type w_usuario_servidor from w_base
integer width = 4219
integer height = 2056
string title = "Usuario servidor"
dw_servidores dw_servidores
dw_filtro_servidor dw_filtro_servidor
tab_user tab_user
end type
global w_usuario_servidor w_usuario_servidor

type variables
Long	 	ii_idservidor
String		is_codigoUsuario
Integer	ii_filasseleccionadas

end variables

on w_usuario_servidor.create
int iCurrent
call super::create
this.dw_servidores=create dw_servidores
this.dw_filtro_servidor=create dw_filtro_servidor
this.tab_user=create tab_user
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_servidores
this.Control[iCurrent+2]=this.dw_filtro_servidor
this.Control[iCurrent+3]=this.tab_user
end on

on w_usuario_servidor.destroy
call super::destroy
destroy(this.dw_servidores)
destroy(this.dw_filtro_servidor)
destroy(this.tab_user)
end on

event resize;call super::resize;SetRedraw(False)
		dw_filtro_servidor.y			=	BordeHorizontal + il_AlturaTitulo
		dw_filtro_servidor.x			=	BordeVertical
		dw_filtro_servidor.width 	 	=	newwidth - ( newwidth - 1550)
		dw_filtro_servidor.height  	=   il_AlturaTitulo -  BordeHorizontal  		
	
	
		tab_user.y = BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
		tab_user.x = BordeVertical
		tab_user.width =  (newwidth - ( BordeVertical * 2 )) / 2
		tab_user.height = newheight - dw_filtro_servidor.y - ( BordeHorizontal * 4 )


		tab_user.tabpage_administrador.dw_administrador.width = (newwidth - ( BordeVertical * 2 )) / 2
		tab_user.tabpage_administrador.dw_administrador.height = newheight - dw_filtro_servidor.y - ( BordeHorizontal * 4 )
		
		tab_user.tabpage_consulta.dw_consulta.width = (newwidth - ( BordeVertical * 2 )) / 2
		tab_user.tabpage_consulta.dw_consulta.height = newheight - dw_filtro_servidor.y - ( BordeHorizontal * 4 )


	
		dw_servidores.x		=		tab_user.width + tab_user.x + BordeVertical
		dw_servidores.y		=		tab_user.y	
		dw_servidores.height = 		( newheight - ( BordeHorizontal * 2 ) - il_AlturaTitulo ) - dw_filtro_servidor.height
		dw_servidores.width	=		(newwidth - ( BordeVertical * 2 )) / 2
		 SetRedraw(True)

end event

event ue_nuevo_pre;call super::ue_nuevo_pre; return  -1
end event

event ue_eliminar;call super::ue_eliminar;return -1
end event

type st_titulo from w_base`st_titulo within w_usuario_servidor
end type

type st_fondo from w_base`st_fondo within w_usuario_servidor
end type

type dw_principal from w_base`dw_principal within w_usuario_servidor
string tag = "<MenuAdicional:S>"
boolean visible = false
integer y = 244
integer width = 361
integer height = 1556
string title = ""
boolean hscrollbar = true
boolean ib_editar = false
boolean ib_menudetalle = true
boolean ib_menufiltrar = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

dw_servidores.reset( )
return this.retrieve(2,ii_idservidor)
 
end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;
if currentrow >  0 then 
	
	  is_codigoUsuario =   this.getitemString(currentrow,'codigoUsuario')
	  dw_servidores.event ue_retrieve()

end if 




end event

event dw_principal::ue_agregar_registro_pre;call super::ue_agregar_registro_pre;//	1.0		Walther Rodriguez		10/07/2024		No se usa IDSERVIDOR

String 			ls_codigousuario
Integer			 li_retorno
String				ls_retorno[]
string 			ls_Parametros,ls_Error

uo_dsbase		luo_ds_query
str_response    lstr_Response

str_arg  				lstr_Enviar

//if dw_principal.Getrow()<1 or dw_principal.Getrow()<1 then Return -1

//luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2," + String(ii_idservidor) , SQLCA)
luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2"  , SQLCA) //1.0

	If luo_ds_query.rowcount() < 1 then Return -1

		lstr_response.b_usar_datastore		= 	True
		lstr_response.ds_datastore    			= 	luo_ds_query
		lstr_response.s_titulo      				= 	'Listado de Usuarios' 
		lstr_response.b_seleccion_multiple	= 	FALSE
		lstr_response.b_mostrar_contador		= 	False
		lstr_response.s_titulos_columnas		=	'1:Usuario'
		lstr_response.b_redim_ventana		= 	True
		lstr_response.l_ancho					= 	1000
		lstr_response.l_alto						= 	1780
		lstr_response.str_argumentos			= lstr_Enviar
	  
		OpenWithParm(w_reponse_selecionar_usuario ,	lstr_Response)

		IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
		IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1
		
		ls_codigousuario 				=  luo_ds_query.getitemstring(luo_ds_query.ii_filasseleccionadas[1],'CodigoLogin')
	
		ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',2,1"
		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Rol_Sevidor", ls_Parametros, ls_retorno, ls_Error)

		dw_principal.event ue_retrieve()

	Return -1




end event

event dw_principal::ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;// Si se elige la opción 2 se cancela la solicitud de eliminación
String ls_codigousuario,ls_Parametros
Integer li_retorno
String ls_retorno[]
String ls_Error

IF gf_mensaje( 'Confirmación','Está seguro de eliminar este registro.','', 4) = 2 Then
	Return -1
Else
	If dw_servidores.rowcount() >   0 Then 
		gf_mensaje(gs_Aplicacion, 'Existen Servidores asociados', '', 3)
		Return -1
	Else
		ls_codigousuario 				=  dw_principal.getitemstring( ai_row ,'codigologin')
		ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',2,2"
		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Rol_Sevidor", ls_Parametros, ls_retorno, ls_Error)
		this.deleterow( ai_row)
		dw_principal.event ue_retrieve()
	End If
	
End If

Return -1
end event

type st_menuruta from w_base`st_menuruta within w_usuario_servidor
end type

type dw_servidores from uo_dwbase within w_usuario_servidor
integer x = 2405
integer y = 244
integer width = 1344
integer height = 1564
integer taborder = 20
boolean bringtotop = true
string title = ""
string dataobject = "dw_usuario_servidorx"
boolean ib_activarfiltros = false
boolean ib_menudetalle = true
end type

event ue_retrieve;call super::ue_retrieve;return  this.retrieve(is_codigoUsuario)
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;Integer 			li_fila
Integer	 		li_filasel
Integer 			li_idservidor
Integer 			li_filanew
String 			ls_nombreServidor
uo_dsbase		luo_ds_query
str_response    lstr_Response

//if tab_user.tabpage_administrador.dw_administrador.Getrow()  = 0 then return -1 
//
//
//if tab_user.tabpage_administrador.dw_administrador.getitemstring(tab_user.tabpage_administrador.dw_administrador.Getrow(), 'estado')<>'A' then 
//	gf_Mensaje(gs_aplicacion,"Usuario INACTIVO","",3)
//	Return -1
//End if
//
//luo_ds_query			= gf_Procedimiento_Consultar(" Seguridad.usp_UsuarioServidor_select " +string(ii_idservidor)+","+'0'  ,SQLCA) 
//
//if luo_ds_query.rowcount() < 1 then Return -1
//
//lstr_response.b_usar_datastore		= 	True
//lstr_response.ds_datastore    			= 	luo_ds_query
//lstr_response.s_titulo      				= 	'Listado de servidores' 
//lstr_response.b_seleccion_multiple	= 	TRUE
//lstr_response.b_mostrar_contador		= 	False
//lstr_response.s_titulos_columnas		=	'2:Servidor'
//lstr_response.b_redim_ventana		= 	True
//lstr_response.l_ancho						= 	1000
//lstr_response.l_alto						= 	1780
//	  
//OpenWithParm(w_response_seleccionar,	lstr_Response)
//
//IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
//IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1
//
//for li_fila= 1 to Integer(upperbound(luo_ds_query.ii_filasseleccionadas[]))
//	li_filasel			=	luo_ds_query.ii_filasseleccionadas[li_fila]
//	li_idservidor	=	luo_ds_query.getitemnumber(li_filasel,'idServidor')
//	ls_nombreServidor =  luo_ds_query.getitemstring(li_filasel,'nombreServidor')
//	
//
//	If dw_servidores.find("idServidor="+String(li_idservidor),1,dw_servidores.RowCount()) = 0 then
//		li_filanew		=	dw_servidores.InsertRow(0)
//		dw_servidores.setItem(li_filanew,'idServidor',li_idservidor)
//		dw_servidores.setItem(li_filanew,'nombreServidor',ls_nombreServidor)
//		dw_servidores.setItem(li_filanew,'codigoUsuario',is_codigoUsuario)
//		dw_servidores.setItem(li_filanew,'idservidorreg',ii_idservidor)
//	End if
//	
//Next

//Activar Edicion
parent.ib_editando=true
parent.event ue_editar( ) 
	


return -1
end event

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_usuario_servidor
integer x = 55
integer y = 132
integer taborder = 10
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;
ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
		tab_user.tabpage_administrador.dw_administrador.reset( )
		tab_user.tabpage_consulta.dw_consulta.reset( )
		dw_servidores.reset()
	Return -2
Else
	tab_user.tabpage_administrador.dw_administrador.event ue_retrieve( )
	tab_user.tabpage_consulta.dw_consulta.event ue_retrieve( )
End if

end event

type tab_user from tab within w_usuario_servidor
event create ( )
event destroy ( )
integer x = 50
integer y = 240
integer width = 2336
integer height = 1568
integer taborder = 30
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
tabpage_administrador tabpage_administrador
tabpage_consulta tabpage_consulta
end type

on tab_user.create
this.tabpage_administrador=create tabpage_administrador
this.tabpage_consulta=create tabpage_consulta
this.Control[]={this.tabpage_administrador,&
this.tabpage_consulta}
end on

on tab_user.destroy
destroy(this.tabpage_administrador)
destroy(this.tabpage_consulta)
end on

event selectionchanged;is_codigoUsuario	=  ''

IF newindex  = 1 Then
	tab_user.tabpage_administrador.dw_administrador.triggerevent("ue_retrieve")
Else
	tab_user.tabpage_consulta.dw_consulta.triggerevent("ue_retrieve")
End If
	
end event

type tabpage_administrador from userobject within tab_user
event create ( )
event destroy ( )
string tag = "RH75"
integer x = 18
integer y = 112
integer width = 2299
integer height = 1440
long backcolor = 67108864
string text = "Administración"
long tabtextcolor = 128
string picturename = "Custom076!"
long picturemaskcolor = 536870912
dw_administrador dw_administrador
end type

on tabpage_administrador.create
this.dw_administrador=create dw_administrador
this.Control[]={this.dw_administrador}
end on

on tabpage_administrador.destroy
destroy(this.dw_administrador)
end on

type dw_administrador from uo_dwbase within tabpage_administrador
integer x = 9
integer y = 32
integer width = 2263
integer height = 1376
integer taborder = 10
boolean bringtotop = true
string title = ""
string dataobject = "dw_listausuarios"
richtexttoolbaractivation richtexttoolbaractivation = richtexttoolbaractivationalways!
boolean hscrollbar = true
boolean ib_activarfiltros = false
boolean ib_menudetalle = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event rowfocuschanged;call super::rowfocuschanged;
if currentrow >  0 then 
	
	  is_codigoUsuario =   this.getitemString(currentrow,'codigoUsuario')
	  dw_servidores.event ue_retrieve()

end if 

end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;//	1.0		Walther Rodriguez		10/07/2024		No se usa IDSERVIDOR
String 			ls_codigousuario
Integer			 li_retorno
String				ls_retorno[]
string 			ls_Parametros,ls_Error

uo_dsbase		luo_ds_query
str_response    lstr_Response

str_arg  				lstr_Enviar

//if dw_principal.Getrow()<1 or dw_principal.Getrow()<1 then Return -1

//luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2," + String(ii_idservidor) , SQLCA)
luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2" , SQLCA) //1.0

	If luo_ds_query.rowcount() < 1 then Return -1

		lstr_response.b_usar_datastore		= 	True
		lstr_response.ds_datastore    			= 	luo_ds_query
		lstr_response.s_titulo      				= 	'Listado de Usuarios' 
		lstr_response.b_seleccion_multiple	= 	FALSE
		lstr_response.b_mostrar_contador		= 	False
		lstr_response.s_titulos_columnas		=	'1:Usuario'
		lstr_response.b_redim_ventana		= 	True
		lstr_response.l_ancho					= 	1000
		lstr_response.l_alto						= 	1780
		lstr_response.str_argumentos			= lstr_Enviar
	  
		OpenWithParm(w_reponse_selecionar_usuario ,	lstr_Response)

		IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
		IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1
		
		ls_codigousuario 				=  luo_ds_query.getitemstring(luo_ds_query.ii_filasseleccionadas[1],'CodigoLogin')
	
		ls_Parametros = "'" + ls_codigousuario+"',2,1"	//1.0
		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Rol_Sevidor", ls_Parametros, ls_retorno, ls_Error)

//		dw_principal.event ue_retrieve()
		tab_user.tabpage_administrador.dw_administrador.event ue_retrieve( )
			
	Return -1




end event

event ue_retrieve;call super::ue_retrieve;if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

dw_servidores.reset( )
return this.retrieve(2,ii_idservidor)
 
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;// Si se elige la opción 2 se cancela la solicitud de eliminación
String ls_codigousuario,ls_Parametros
Integer li_retorno
String ls_retorno[]
String ls_Error

IF gf_mensaje( 'Confirmación','Está seguro de eliminar este registro.','', 4) = 2 Then
	Return -1
Else
	If dw_servidores.rowcount() >   0 Then 
		gf_mensaje(gs_Aplicacion, 'Existen Servidores asociados', '', 3)
		Return -1
	Else
		ls_codigousuario 				=  tab_user.tabpage_administrador.dw_administrador.getitemstring( ai_row ,'codigologin')
		ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',2,2"
		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Rol_Sevidor", ls_Parametros, ls_retorno, ls_Error)
		this.deleterow( ai_row)
//		dw_principal.event ue_retrieve()
		tab_user.tabpage_administrador.dw_administrador.event ue_retrieve( )
	End If
	
End If

Return -1
end event

type tabpage_consulta from userobject within tab_user
event create ( )
event destroy ( )
string tag = "RH75"
integer x = 18
integer y = 112
integer width = 2299
integer height = 1440
long backcolor = 67108864
string text = "Consulta"
long tabtextcolor = 128
string picturename = "RegistrationDir!"
long picturemaskcolor = 536870912
dw_consulta dw_consulta
end type

on tabpage_consulta.create
this.dw_consulta=create dw_consulta
this.Control[]={this.dw_consulta}
end on

on tabpage_consulta.destroy
destroy(this.dw_consulta)
end on

type dw_consulta from uo_dwbase within tabpage_consulta
integer x = 14
integer y = 16
integer width = 2267
integer height = 1424
integer taborder = 10
boolean bringtotop = true
string dataobject = "dw_perfilseguridad_consulta"
boolean hscrollbar = true
boolean ib_actualizar = false
boolean ib_activarfiltros = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

event rowfocuschanged;call super::rowfocuschanged;

if currentrow >  0 then 
	
	  is_codigoUsuario =   this.getitemString(currentrow,'codigoUsuario')
	  dw_servidores.event ue_retrieve()

end if 

end event

event ue_retrieve;call super::ue_retrieve;if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

dw_servidores.reset( )
return this.retrieve(3,ii_idservidor)
end event

