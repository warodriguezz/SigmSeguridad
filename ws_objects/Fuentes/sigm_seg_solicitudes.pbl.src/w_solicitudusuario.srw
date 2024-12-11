$PBExportHeader$w_solicitudusuario.srw
forward
global type w_solicitudusuario from w_base
end type
type tab_detalle from tab within w_solicitudusuario
end type
type tabpage_accesos from userobject within tab_detalle
end type
type dw_modulos from uo_dwbase within tabpage_accesos
end type
type dw_unidades from uo_dwbase within tabpage_accesos
end type
type tabpage_accesos from userobject within tab_detalle
dw_modulos dw_modulos
dw_unidades dw_unidades
end type
type tab_detalle from tab within w_solicitudusuario
tabpage_accesos tabpage_accesos
end type
type cbx_anulados from checkbox within w_solicitudusuario
end type
type cbx_aprobados from checkbox within w_solicitudusuario
end type
end forward

global type w_solicitudusuario from w_base
integer width = 6194
string title = "SEGURIDAD - Solicitud usuario"
windowdockstate windowdockstate = windowdockstatetabbeddocument!
boolean ib_activarworkflow = true
boolean ib_toolbarmenuabrir = true
tab_detalle tab_detalle
cbx_anulados cbx_anulados
cbx_aprobados cbx_aprobados
end type
global w_solicitudusuario w_solicitudusuario

type variables
Datetime idt_fecha_actual

uo_transaction		itr_operacioneswf

Boolean	ib_carga

long	il_nrosolicitud

Boolean ib_nuevo
end variables

forward prototypes
public subroutine wf_cargar_modulos ()
public subroutine wf_cargar_unidades ()
public subroutine wf_actualiza_nrosolicitud ()
public subroutine wf_resetear_datos ()
end prototypes

public subroutine wf_cargar_modulos ();uo_dsbase lds_modulos
Long ll_row, ll_rows

lds_modulos = create uo_dsbase
lds_modulos	= gf_procedimiento_consultar( "Seguridad.usp_CargarModulosUsuario '" + dw_principal.object.usuario[1] +"'",itr_operacioneswf)	

tab_detalle.tabpage_accesos.dw_modulos.reset()
ll_rows = lds_modulos.rowcount( )

tab_detalle.tabpage_accesos.dw_modulos.event ue_poblardddw('estado')
If ll_rows = 0 Then return
ib_carga = True
tab_detalle.tabpage_accesos.dw_modulos.setredraw( False)
For ll_row = 1 to ll_rows
	tab_detalle.tabpage_accesos.dw_modulos.event ue_agregar_registro( )
	tab_detalle.tabpage_accesos.dw_modulos.object.idaplicacion[ll_row] = lds_modulos.object.idaplicacion[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.nombreaplicacion[ll_row] = lds_modulos.object.nombreaplicacion[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.idperfil[ll_row] = lds_modulos.object.idperfil[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.nombreperfil[ll_row] = lds_modulos.object.nombreperfil[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.idrol[ll_row] = lds_modulos.object.idrol[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.nombrerol[ll_row] = lds_modulos.object.nombrerol[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.accion[ll_row] = lds_modulos.object.accion[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.estado[ll_row] = lds_modulos.object.estado[ll_row]
	tab_detalle.tabpage_accesos.dw_modulos.object.keyuser[ll_row] = lds_modulos.object.keyuser[ll_row]
Next
ib_carga = False
tab_detalle.tabpage_accesos.dw_modulos.setredraw( True)

end subroutine

public subroutine wf_cargar_unidades ();uo_dsbase lds_unidades
Long ll_row, ll_rows

lds_unidades = create uo_dsbase
lds_unidades	= gf_procedimiento_consultar( "Seguridad.usp_CargarUnidadesUsuario '" + dw_principal.object.usuario[1] +"'",itr_operacioneswf)	

tab_detalle.tabpage_accesos.dw_unidades.reset()
ll_rows = lds_unidades.rowcount( )
If ll_rows = 0 Then return
tab_detalle.tabpage_accesos.dw_unidades.setredraw( False)
ib_carga = True
For ll_row = 1 to ll_rows
	tab_detalle.tabpage_accesos.dw_unidades.event ue_agregar_registro( )
	tab_detalle.tabpage_accesos.dw_unidades.object.idcompania[ll_row] = lds_unidades.object.idcompania[ll_row]
	tab_detalle.tabpage_accesos.dw_unidades.object.idunidadnegocio[ll_row] = lds_unidades.object.idunidadnegocio[ll_row]
	tab_detalle.tabpage_accesos.dw_unidades.object.abreviatura[ll_row] = lds_unidades.object.abreviatura[ll_row]
	tab_detalle.tabpage_accesos.dw_unidades.object.accion[ll_row] = lds_unidades.object.accion[ll_row]
	tab_detalle.tabpage_accesos.dw_unidades.object.estado[ll_row] = lds_unidades.object.estado[ll_row]
Next
ib_carga = False
tab_detalle.tabpage_accesos.dw_unidades.setredraw( True)


end subroutine

public subroutine wf_actualiza_nrosolicitud ();Long	ll_nrosolicitud
Long	ll_row

ll_nrosolicitud = dw_principal.object.nrosolicitud[dw_principal.getrow()] 

For ll_row = 1 To tab_detalle.tabpage_accesos.dw_modulos.rowcount( )
	tab_detalle.tabpage_accesos.dw_modulos.object.NroSolicitud[ll_row] = ll_nrosolicitud
Next

For ll_row = 1 To tab_detalle.tabpage_accesos.dw_unidades.rowcount( )
	tab_detalle.tabpage_accesos.dw_unidades.object.NroSolicitud[ll_row] = ll_nrosolicitud
Next

il_nrosolicitud = ll_nrosolicitud
end subroutine

public subroutine wf_resetear_datos ();dw_principal.object.motivo[1] = ''
dw_principal.object.tipo[1] = ''
dw_principal.object.t_nombre.text = ''
dw_principal.object.t_area.text = ''
dw_principal.object.t_cargo.text = ''
dw_principal.accepttext( )
tab_detalle.tabpage_accesos.dw_modulos.reset( )
tab_detalle.tabpage_accesos.dw_unidades.reset( )

end subroutine

on w_solicitudusuario.create
int iCurrent
call super::create
this.tab_detalle=create tab_detalle
this.cbx_anulados=create cbx_anulados
this.cbx_aprobados=create cbx_aprobados
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_detalle
this.Control[iCurrent+2]=this.cbx_anulados
this.Control[iCurrent+3]=this.cbx_aprobados
end on

on w_solicitudusuario.destroy
call super::destroy
destroy(this.tab_detalle)
destroy(this.cbx_anulados)
destroy(this.cbx_aprobados)
end on

event open;call super::open;gf_definir_atributo(dw_principal,"Ent",'SolicitudUsuario') //Asignar entidad

//gf_definir_atributo(tab_detalle.tabpage_accesos.dw_modulos ,"Ent",'SolicitudModulo') //Asignar entidad Modulo

sqlca.uf_usp_fechahora_select( idt_fecha_actual)
gf_resize_tab(tab_detalle)

dw_principal.event ue_poblardddw('estado')

end event

event resize;call super::resize;
tab_detalle.height 		= newheight - tab_detalle.y 
//tab_detalle.width  		= newwidth - tab_detalle.x 
gf_resize_tab(tab_detalle)
end event

event ue_preopen;call super::ue_preopen;Integer li_ret
itr_operacioneswf	= Create uo_transaction
	
if lower(sqlca.database) = "bvn_seguridad" or lower(sqlca.database) = "bvn_seguridad_lima" then
	li_ret=gf_conectar_db( itr_operacioneswf, gs_archivoini, 'WorkFlowRol', gs_usuario, gs_clave, 1)
	 if li_ret<>1 then
		Messagebox("Seguridad","Problemas con la conexion de framework" )
	End if
Else
	itr_operacioneswf	=	sqlca
End if

dw_principal.settransobject(itr_operacioneswf)
tab_detalle.tabpage_accesos.dw_modulos.settransobject(itr_operacioneswf)
tab_detalle.tabpage_accesos.dw_unidades.settransobject(itr_operacioneswf)

ii_ModoVentana = 2
Return 1
end event

event ue_abrir;call super::ue_abrir;//String					ls_veranulados='X'
String					ls_verterminados='X'
Integer 				li_filasel
str_response   		lstr_Argumentos
uo_dsbase			lds_consulta

//if cbx_anulados.checked then ls_veranulados='S'
if cbx_aprobados.checked then ls_verterminados='S'

String ls_login

If gi_idrol = 254 OR gi_idrol <> 1 Then
	ls_login = '0'
Else 
	ls_login = gs_Usuario
End If
lds_Consulta=gf_Procedimiento_Consultar("Seguridad.usp_SolicitudUsuario_Select_01 '"+ls_login+"','"+ls_verterminados+"'",itr_operacioneswf)
if lds_Consulta.RowCount()>0 then

	lstr_Argumentos.b_usar_datastore		= True
	lstr_Argumentos.ds_datastore    			= lds_Consulta
	lstr_Argumentos.s_titulo      				= 'Listado de Solicitudes registradas' 
	lstr_Argumentos.s_titulos_columnas		='1:Solicitud:350,2:Usuario:450,3:Solicitado por:450,4:Motivo:1000,5:Fecha:450,6:Estado:620'
	lstr_Argumentos.b_redim_ventana        	= True
	lstr_Argumentos.l_alto      					= 1600	
	lstr_Argumentos.l_ancho						= 3800 // Ancho de la ventana
	lstr_Argumentos.b_activar_filtros			= True
// 	lstr_Argumentos.w_ventanapadre			= This
	 
	OpenWithParm(w_response_seleccionar,lstr_Argumentos)
	
	IF UpperBound(lds_Consulta.ii_filasseleccionadas)<1 then Return
	IF lds_Consulta.ii_filasseleccionadas[1]=0 then Return
	
	li_filasel				 = lds_Consulta.ii_filasseleccionadas[1]
	il_nrosolicitud = lds_Consulta.getitemnumber(li_filasel ,'nrosolicitud')
	
	tab_detalle.tabpage_accesos.dw_modulos.settransobject(itr_operacioneswf)
	tab_detalle.tabpage_accesos.dw_unidades.settransobject(itr_operacioneswf)
	dw_principal.event ue_retrieve( )
	This.ib_Editando = False
	This.event ue_editar( )
	ib_nuevo =False
else
	gf_mensaje(gs_Aplicacion, 'No se encontraron datos', '', 3)
End if
end event

event ue_workflow;call super::ue_workflow;String	ls_ValoresPK
String ls_parametros
String	ls_nuevoestado
String		ls_genauto
Integer	li_find=0
DataWindowChild	ldwc_child


ls_parametros	= '0'
gf_definir_atributo(dw_principal,"Parametros",ls_parametros)

ls_ValoresPK	=	String(il_nrosolicitud)
gf_definir_atributo(dw_principal,"ValPK",ls_ValoresPK)

ls_nuevoestado = uf_workflow(dw_principal) 




end event

event ue_workflow_historial;call super::ue_workflow_historial;String		ls_ValoresPK
ls_ValoresPK	=	String(il_nrosolicitud)
gf_definir_atributo(dw_principal,"ValPK",ls_ValoresPK)
This.uf_workflow_historial(dw_principal)
end event

event ue_cancelar;call super::ue_cancelar;If	ib_nuevo  Then 
	this.event ue_nuevo( )
Else 
	this.event ue_recuperar( )
End If
end event

event ue_vistaprevia;//
end event

event ue_nuevo;call super::ue_nuevo;ib_nuevo = True

end event

event ue_eliminar;//
Return 1
end event

type st_titulo from w_base`st_titulo within w_solicitudusuario
string text = "SOLICITUD USUARIO"
end type

type st_fondo from w_base`st_fondo within w_solicitudusuario
end type

type dw_principal from w_base`dw_principal within w_solicitudusuario
event ue_itemchanged ( )
integer width = 4544
integer height = 500
string dataobject = "dw_solicitudusuario"
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event dw_principal::ue_itemchanged();uo_dsbase			lds_usuario
String ls_data

ls_data = this.object.usuario[this.getrow( ) ]
this.object.usuario.protect = 1
lds_usuario = create uo_dsbase
lds_usuario	= gf_procedimiento_consultar( "Seguridad.usp_Consulta_Usuario '" + ls_data +"', 1",itr_operacioneswf)	
this.object.t_nombre.text = lds_usuario.object.nombres[1]
this.object.t_area.text = lds_usuario.object.nombrearea[1]
this.object.t_cargo.text = lds_usuario.object.cargo[1]
tab_detalle.tabpage_accesos.dw_modulos.event ue_retrieve( )
tab_detalle.tabpage_accesos.dw_unidades.event ue_retrieve( )

end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;this.object.fecha[this.getrow()] = idt_fecha_actual
this.object.usuariosolicita[this.getrow()] = gs_usuario
this.object.estado[this.getrow()] =  'R'
this.object.t_nombre.text = ''
this.object.t_area.text = ''
this.object.t_cargo.text = ''
Accepttext()
dw_principal.object.datawindow.readonly='No'
ib_VentanaEditable = True
uo_dsbase lds_return

lds_return = gf_procedimiento_consultar("Seguridad.usp_SolicitudUsuario_Correlativo ", itr_operacioneswf)

If lds_return.rowcount( ) > 0 Then

	this.object.nrosolicitud[this.getrow()] =  lds_return.object.NroSolicitud[1]
End if
this.object.usuario.protect = 0
this.setcolumn('usuario')
ib_nuevo =True
tab_detalle.tabpage_accesos.dw_modulos.reset( )
tab_detalle.tabpage_accesos.dw_unidades.reset( )
end event

event dw_principal::ue_poblardddw;call super::ue_poblardddw;datawindowchild		ldwc_Child
Integer					li_Ret

If	This.GetChild( as_columna, ldwc_Child ) < 1 Then Return
ldwc_Child.SetTransObject( itr_operacioneswf )

If as_columna =  'estado' Then
	li_Ret = ldwc_child.Retrieve(gi_IdAplicacion, gf_obtener_atributo(This,"Ent") , "" )
End If
end event

event dw_principal::itemchanged;call super::itemchanged;String		ls_parametros
uo_dsbase			lds_usuario

Accepttext()

If String(dwo.name) = 'usuario' Then
	ls_parametros	=	data+","+String(gi_idservidor)
	lds_usuario = create uo_dsbase
	lds_usuario	= gf_procedimiento_consultar( "Seguridad.usp_Consulta_Usuario '" + data +"',0",itr_operacioneswf)	
	If lds_usuario.rowcount( ) > 0 Then
		If lds_usuario.object.tipo[1] <> 'E' Then
			this.object.t_nombre.text = lds_usuario.object.nombres[1]
			this.object.t_area.text = lds_usuario.object.nombrearea[1]
			this.object.t_cargo.text = lds_usuario.object.cargo[1]
			this.object.tipo[1] = lds_usuario.object.tipo[1]
			wf_cargar_modulos()
			wf_cargar_unidades()
		Else
			wf_resetear_datos()
			gf_mensaje(gs_Aplicacion, 'Existe una solicitud en proceso, por favor verificar', '', 1)
		End If
	Else
		wf_resetear_datos()
		gf_mensaje(gs_Aplicacion, 'No se encontró el usuario en Meta4, por favor verificar', '', 1)
	End If
End If

end event

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre;uo_dsbase lds_return
dwItemStatus 	ldwis_Estado
Integer li_modulos
Integer li_perfil
Integer li_rol
Integer li_unidades

If this.object.t_nombre.text = '' Then
	gf_mensaje(gs_aplicacion, 'No se registró un usuario válido', '', 3)
	return -1
End If

If tab_detalle.tabpage_accesos.dw_modulos.rowcount( )= 0 Then
	gf_mensaje(gs_aplicacion, 'Se deben asignar Aplicaciones', '', 3)
	return -1
End If

If tab_detalle.tabpage_accesos.dw_unidades.rowcount( )= 0 Then
	gf_mensaje(gs_aplicacion, 'Se deben asignar Unidades', '', 3)
	return -1
End If

li_perfil = tab_detalle.tabpage_accesos.dw_modulos.find("accion<>'N' and accion<>'E' and isnull(idperfil)", 1, tab_detalle.tabpage_accesos.dw_modulos.rowcount())
li_rol = tab_detalle.tabpage_accesos.dw_modulos.find("accion<>'N' and accion<>'E' and isnull(idrol)", 1, tab_detalle.tabpage_accesos.dw_modulos.rowcount())
li_unidades = tab_detalle.tabpage_accesos.dw_unidades.find("accion<>'N'", 1, tab_detalle.tabpage_accesos.dw_unidades.rowcount())
li_modulos = tab_detalle.tabpage_accesos.dw_modulos.find("accion<>'N'", 1, tab_detalle.tabpage_accesos.dw_modulos.rowcount())

If li_perfil > 0 Then
	gf_mensaje(gs_aplicacion, 'Se debe registrar el perfil', '', 3)
	return -1
End If

If li_rol > 0 Then
	gf_mensaje(gs_aplicacion, 'Se debe registrar el rol', '', 3)
	return -1
End If

If li_unidades = 0  and li_modulos = 0 Then
	gf_mensaje(gs_aplicacion, 'Se debe solicitar al menos un cambio', '', 3)
	return -1
End If

ldwis_Estado = This.getitemstatus(1,0, Primary!)

If	(ldwis_Estado  = New! OR ldwis_Estado = NewModified!) And This.rowcount()>0  Then 

	lds_return = gf_procedimiento_consultar("Seguridad.usp_SolicitudUsuario_Correlativo ", itr_operacioneswf)
	
	If lds_return.rowcount( ) > 0 Then
	
		this.object.nrosolicitud[this.getrow()] =  lds_return.object.NroSolicitud[1]
		Accepttext()
		wf_actualiza_nrosolicitud()
	Else
		Messagebox( 'Error', 'Error al generar la clave primaria', stopsign! )
		Return -1
	End if
End If
end event

event dw_principal::ue_retrieve;call super::ue_retrieve;this.retrieve(il_nrosolicitud )
this.event ue_itemchanged( )

return 1
end event

event dw_principal::ue_grabar;call super::ue_grabar;dw_principal.object.usuario.protect = 1

Return AncestorReturnValue
end event

type st_menuruta from w_base`st_menuruta within w_solicitudusuario
end type

type tab_detalle from tab within w_solicitudusuario
integer x = 50
integer y = 672
integer width = 5915
integer height = 1056
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
integer selectedtab = 1
tabpage_accesos tabpage_accesos
end type

on tab_detalle.create
this.tabpage_accesos=create tabpage_accesos
this.Control[]={this.tabpage_accesos}
end on

on tab_detalle.destroy
destroy(this.tabpage_accesos)
end on

type tabpage_accesos from userobject within tab_detalle
string tag = "RV70"
integer x = 18
integer y = 108
integer width = 5879
integer height = 932
long backcolor = 67108864
string text = "Accesos"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
dw_modulos dw_modulos
dw_unidades dw_unidades
end type

on tabpage_accesos.create
this.dw_modulos=create dw_modulos
this.dw_unidades=create dw_unidades
this.Control[]={this.dw_modulos,&
this.dw_unidades}
end on

on tabpage_accesos.destroy
destroy(this.dw_modulos)
destroy(this.dw_unidades)
end on

type dw_modulos from uo_dwbase within tabpage_accesos
integer x = 55
integer y = 48
integer taborder = 20
string dataobject = "dw_solicitudusuario_modulos"
boolean ib_menudetalle = true
boolean ib_menudetalleinsertar = true
end type

event doubleclicked;call super::doubleclicked;Str_response		lstr_Response
// Recepciona valores de la ventana Buscar
Integer 				li_FilasSeleccionadas     //  Numero de filas seleccionadas
Integer				li_FilaSeleccionada        //  Fila actual de datastoreuo_dsbase			lds_busqueda2
String 			ls_parametros
uo_dsbase			lds_busqueda2
Integer			li_aplicacion
String 		ls_rol
String		ls_perfil

if row = 0 Then return
If  NOT ib_VentanaEditable Then Return

If dwo.name = "nombreperfil" Then
	li_aplicacion = this.object.IdAplicacion[row]
	ls_Parametros =  string(li_aplicacion) 
	lds_busqueda2 = gf_procedimiento_consultar( "SEGURIDAD.usp_Perfil_Select "+ ls_Parametros , itr_operacioneswf)
	
	/* Cargar los argumentos  se pasarán a la ventana seleccionar */
	lstr_Response.b_usar_datastore		= True										// 1 : Indica que se usará Datastore, 2 : Indica que se usara un Dw
	lstr_Response.ds_datastore    			= lds_busqueda2                				// Datastore creado dinámicamente
	lstr_Response.s_titulo      				= 'Perfiles del módulo'  // Título de la Ventana
	lstr_Response.s_titulos_columnas    	= "3:Nombre:700,6:Descripcion:700"
			  
	lstr_Response.b_redim_ventana		= True										// Redimensionar ventana
	lstr_Response.b_mostrar_contador	= False										// No Mostrar contador de Filas
	lstr_Response.l_alto      					= 1300										// Ancho de la ventana
	lstr_Response.l_ancho      				= 1800										// Alto de la ventana
	lstr_Response.b_activar_filtros			= True
	lstr_Response.b_mostrar_filtros		= True
	
	/*Abrir la ventana response: seleccionar */
	OpenWithParm( w_response_seleccionar,lstr_Response)
	
	/* Recuperar la cantidad de filas seleccionadas*/
	li_FilasSeleccionadas = Integer( message.doubleparm )
	
	/* De no haberse seleccionado ninguna fila no se realiza ninguna acción*/ 
	If li_FilasSeleccionadas = 0 Then 
		Return
	End If
	
	li_FilaSeleccionada 	=lds_busqueda2.ii_filasseleccionadas[1]
	ls_perfil = this.object.NombrePerfil[row]
	If IsNull(ls_perfil) Then ls_perfil = ""
	If ls_perfil  	<> lds_busqueda2.object.NombrePerfil[li_FilaSeleccionada] Then
		this.object.NombrePerfil[row]  	= lds_busqueda2.object.NombrePerfil[li_FilaSeleccionada]
		this.object.IdPerfil[row]  	= lds_busqueda2.object.IdPerfil[li_FilaSeleccionada]	
		If this.object.accion[row] = 'N' Then this.object.accion[row] = 'M'	
		this.object.estado[row] = dw_principal.object.estado[dw_principal.getrow( )]
		iw_ventanapadre.ib_editando = true
		iw_ventanapadre.event ue_editar( )
	End If
End If	

If dwo.name = "nombrerol" Then
	li_aplicacion = this.object.IdAplicacion[row]
	ls_Parametros =  string(li_aplicacion)+ ",1" 
	lds_busqueda2 = gf_procedimiento_consultar( "Framework.usp_Rol_Select_01_lista_roles "+ ls_Parametros , itr_operacioneswf)
	
	/* Cargar los argumentos  se pasarán a la ventana seleccionar */
	lstr_Response.b_usar_datastore		= True										// 1 : Indica que se usará Datastore, 2 : Indica que se usara un Dw
	lstr_Response.ds_datastore    			= lds_busqueda2                				// Datastore creado dinámicamente
	lstr_Response.s_titulo      				= 'Roles del módulo'  // Título de la Ventana
	lstr_Response.s_titulos_columnas    	= "3:Nombre:700,5:Descripcion:700"
			  
	lstr_Response.b_redim_ventana		= True										// Redimensionar ventana
	lstr_Response.b_mostrar_contador	= False										// No Mostrar contador de Filas
	lstr_Response.l_alto      					= 1300										// Ancho de la ventana
	lstr_Response.l_ancho      				= 1800										// Alto de la ventana
	lstr_Response.b_activar_filtros			= True
	lstr_Response.b_mostrar_filtros		= True
	
	/*Abrir la ventana response: seleccionar */
	OpenWithParm( w_response_seleccionar,lstr_Response)
	
	/* Recuperar la cantidad de filas seleccionadas*/
	li_FilasSeleccionadas = Integer( message.doubleparm )
	
	/* De no haberse seleccionado ninguna fila no se realiza ninguna acción*/ 
	If li_FilasSeleccionadas = 0 Then 
		Return
	End If
	
	li_FilaSeleccionada 	=lds_busqueda2.ii_filasseleccionadas[1]
	ls_rol = this.object.NombreRol[row]
	If IsNull(ls_rol) Then ls_rol = ""
	If ls_rol  	<> lds_busqueda2.object.Nombre[li_FilaSeleccionada] Then
		this.object.NombreRol[row]  	= lds_busqueda2.object.Nombre[li_FilaSeleccionada]
		this.object.IdRol[row]  	= lds_busqueda2.object.IdRol[li_FilaSeleccionada]	
		If this.object.accion[row] = 'N' Then this.object.accion[row] = 'M'	
		this.object.estado[row] = dw_principal.object.estado[dw_principal.getrow( )]
		iw_ventanapadre.ib_editando = true
		iw_ventanapadre.event ue_editar( )
	End If
End If	
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

Integer 			li_fila
Integer	 		li_filasel
Integer 			li_filanew
Integer			li_idaplicacion
String				ls_nombreaplicacion
uo_dsbase		luo_ds_query
str_response    lstr_Response

if gi_idaplicacion<1 then Return -1
If ib_carga Then Return -1


//luo_ds_query			= gf_Procedimiento_Consultar("Seguridad.usp_Aplicacion_Select_03  " +String(gi_idservidor), sqlca)
luo_ds_query			= gf_Procedimiento_Consultar("Seguridad.usp_Aplicacion_Select_03" , sqlca) //1.0
if luo_ds_query.rowcount() < 1 then Return -1

lstr_response.b_usar_datastore		= 	TRUE
lstr_response.ds_datastore    			= 	luo_ds_query
lstr_response.s_titulo      				= 	'Listado de Apliciones' 
lstr_response.b_seleccion_multiple	= 	FALSE
lstr_response.b_mostrar_contador		= 	FALSE
lstr_response.s_titulos_columnas		=	'3:Nombre aplicación'
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
this.object.accion[li_filanew] = 'A'
this.object.keyuser[li_filanew] = luo_ds_query.getitemstring(li_filasel,'KeyUser')
this.event ue_agregar_registro_post( li_filanew)
 
this.scrolltorow(li_filanew)

Destroy luo_ds_query

//Activar Edicion
iw_ventanapadre.ib_editando=true
iw_ventanapadre.event ue_editar( ) 
	
return -1
end event

event ue_agregar_registro_post;call super::ue_agregar_registro_post;this.ii_filanueva=ai_row
this.setitemstatus(ai_row,0,Primary!,New!)
end event

event ue_eliminar_registro;If this.object.accion[ai_row] <> "A" Then
	this.object.accion[ai_row] = "E"
Else
	If	This.Event ue_eliminar_registro_pre( ai_row ) = -1 Then
		Return -1
	Else
		This.DeleteRow( ai_row )
		Return 1
	End If
End If
Return 1
end event

event ue_retrieve;call super::ue_retrieve;return this.retrieve(il_nrosolicitud)
end event

event clicked;call super::clicked;str_response		lstr_parametros	

If row <= 0 then return
If dwo.name <> 'cmp_vermenu' then return

lstr_parametros.str_argumentos.i[1] = this.object.idAplicacion[row]
lstr_parametros.str_argumentos.i[2] = this.object.idPerfil[row]

OpenWithParm(w_vermenu, lstr_parametros)

end event

event ue_poblardddw;call super::ue_poblardddw;datawindowchild		ldwc_Child
Integer					li_Ret

If	This.GetChild( as_columna, ldwc_Child ) < 1 Then Return
ldwc_Child.SetTransObject( itr_operacioneswf )

If as_columna =  'estado' Then
	li_Ret = ldwc_child.Retrieve(gi_IdAplicacion, gf_obtener_atributo(This,"Ent") , "" )
End If
end event

type dw_unidades from uo_dwbase within tabpage_accesos
event type integer ue_agregar_unidad ( string as_codigo,  string as_nombre )
integer x = 1705
integer y = 48
integer taborder = 10
string dataobject = "dw_solicitudusuario_unidades"
boolean ib_menudetalle = true
boolean ib_menudetalleinsertar = true
end type

event type integer ue_agregar_unidad(string as_codigo, string as_nombre);Integer		li_idcompania
Integer		li_idunidadnegocio
Integer		li_filanew
String			ls_filtro

if this.find("String(idcompania) + '-' + String(idunidadnegocio)='"+as_codigo+"'",1, this.RowCount())>0 then Return 0

li_idcompania			=	Integer(Left(as_codigo,Pos(as_codigo,'-') -1))
li_idunidadnegocio		=	Integer(Mid(as_codigo,Pos(as_codigo,'-') + 1 , 2) )

li_filanew										=	this.insertrow(0)
this.object.idcompania[li_filanew]			=	li_idcompania
this.object.idunidadnegocio[li_filanew]	=	li_idunidadnegocio
this.object.abreviatura[li_filanew]			=	as_nombre
this.object.Accion[li_filanew]		=	'A'
this.object.Estado[li_filanew]		=	'0'


this.event ue_agregar_registro_post(li_filanew)

Return 1
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;Integer			li_filasel
Integer			li_fila
String				ls_codigo
String				ls_nombre
Uo_dsbase		lds_companiaunidad
str_response    lstr_Response

If ib_carga Then Return -1

//if ib_usuariook=False then 
//	gf_mensaje(gs_Aplicacion, 'Uusario no disponible...verifique', '', 3)
//	Return -1
//End if


//Para las unidades
String ls_login

ls_login = gs_usuario

//If gs_tipo_usuario <> 'S' Then 
ls_login = '0'
	
lds_companiaunidad 			= gf_Procedimiento_Consultar("Maestros.usp_UnidadNegocio_Select_02 '"+ls_login + "'" ,SQLCA)

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

event ue_agregar_registro_post;call super::ue_agregar_registro_post;this.ii_filanueva=ai_row
this.setitemstatus(ai_row,0,Primary!,New!)
end event

event ue_eliminar_registro;If this.object.accion[ai_row] <> "A" Then
	this.object.accion[ai_row] = "E"
Else
	If	This.Event ue_eliminar_registro_pre( ai_row ) = -1 Then
		Return -1
	Else
		This.DeleteRow( ai_row )
		Return 1
	End If
End If
Return 1
end event

event ue_retrieve;call super::ue_retrieve;return this.retrieve(il_nrosolicitud)
end event

type cbx_anulados from checkbox within w_solicitudusuario
boolean visible = false
integer x = 4722
integer y = 76
integer width = 494
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Ver anulados"
end type

type cbx_aprobados from checkbox within w_solicitudusuario
integer x = 4722
integer y = 192
integer width = 494
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Ver aprobados"
end type

