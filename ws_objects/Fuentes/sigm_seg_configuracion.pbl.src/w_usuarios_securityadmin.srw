$PBExportHeader$w_usuarios_securityadmin.srw
forward
global type w_usuarios_securityadmin from w_base_tv
end type
type dw_usuariolocalidad from uo_dwbase within w_usuarios_securityadmin
end type
end forward

global type w_usuarios_securityadmin from w_base_tv
string tag = "usuarios_securityadmin"
string title = "Usuario (SecurityAdmin) - Servidor"
boolean ib_toolbarmenuabrir = true
dw_usuariolocalidad dw_usuariolocalidad
end type
global w_usuarios_securityadmin w_usuarios_securityadmin

type variables
String			is_cod_usuario
end variables

forward prototypes
public function integer uf_treeview_agregar_items (long al_padre, integer ai_nivel, integer ai_filas)
public subroutine uf_treeview_actualizar ()
public subroutine uf_mostrar_ocultar_objetos (integer ai_parametro)
end prototypes

public function integer uf_treeview_agregar_items (long al_padre, integer ai_nivel, integer ai_filas);// Funcion para agregar los items para el TreeView usando la data en el DataStore
Integer			li_fila //Número de fila
Treeviewitem	ltvi_nuevo //Item treeview a agregar al organigrama

tv_Principal.SetRedraw( False )
 
// Agregar cada item al TreeView
For li_fila = 1 To ai_filas

	// Configura los atributos etiqueta y data para el nuevo item desde la data del datastore
	Choose case ii_nivel
		Case 1 // Unidad de negocio 
			ltvi_nuevo.data = trim( ids_Estructura_Treview[ ai_nivel ].getitemstring( li_fila, 'cod_usuario' ) )
			ltvi_nuevo.label = trim( ids_Estructura_Treview[ ai_nivel ].getitemstring( li_fila, 'cod_usuario' ) )

	End choose

	If	ai_nivel <> ii_Ctd_datastores     Then 
		ltvi_nuevo.children = True 
	Else 
		ltvi_nuevo.children = False
	End If

	ltvi_nuevo.pictureindex = 2
	ltvi_nuevo.selectedpictureindex = 3

	// Agrega el item despues del ultimo item agregado   //insertitemsort
	If	tv_Principal.insertitemlast( al_padre, ltvi_nuevo ) < 1 Then
		gf_mensaje(gs_Aplicacion, 'Error al insertar item', '', 2)

		Return -1
	End If
Next

tv_Principal.setredraw( True )

Return ai_filas
end function

public subroutine uf_treeview_actualizar ();/* No se actualiza nada */
end subroutine

public subroutine uf_mostrar_ocultar_objetos (integer ai_parametro);Choose case ai_Parametro  
	Case 1	// Nivel Raiz 
		dw_principal.Visible = False
 		dw_usuariolocalidad.visible = False
	case else 		
		dw_principal.Visible = True
		dw_usuariolocalidad.visible = True
End Choose
end subroutine

event ue_rellenar_treeview;call super::ue_rellenar_treeview;// **********************************************************************************
//	Descripción			:	Pobla el Treview tv_principal 
//
//	Argumentos			:	Ninguno
//
//	Valor de Retorno	:	Ninguno
//
//	Control de Versión:
//
//	Versión	Autor								Fecha				Descripción
//	1.0		Wilbert Santos Mucha			19/09/2015		Versión inicial
// **********************************************************************************

TreeviewItem	ltvi_raiz //Treeview base

SetPointer( HourGlass! )
 
ltvi_raiz.children = True
ltvi_raiz.label = 'Usuarios SecurityAdmin'
ltvi_raiz.pictureindex = 1
ltvi_raiz.selectedpictureindex = 1
ltvi_raiz.bold = True

tv_Principal.insertitemlast( 0, ltvi_raiz )
 
// Agregar los items al datawindow
tv_Principal.selectitem( tv_Principal.finditem( roottreeitem!, 0) ) 
tv_Principal.expandItem( tv_Principal.finditem( roottreeitem!, 0) )

tv_Principal.setfocus( )
end event

on w_usuarios_securityadmin.create
int iCurrent
call super::create
this.dw_usuariolocalidad=create dw_usuariolocalidad
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_usuariolocalidad
end on

on w_usuarios_securityadmin.destroy
call super::destroy
destroy(this.dw_usuariolocalidad)
end on

event ue_preopen;call super::ue_preopen;ii_ultimo_nivel_treeview = 2  // Debe ser mayor en 1 a la cantidad de datastores declarado en las variables de instancia
ii_Ctd_datastores = ii_ultimo_nivel_treeview - 1
Return 1
end event

event open;call super::open;Integer	li_NroDatastore				//Número de datastore
SetPointer( hourglass! )

// Crear los datastores
For li_NroDatastore = 1 to ii_Ctd_datastores
	ids_Estructura_Treview[ li_NroDatastore ] = create uo_dsbase
	
	Choose Case li_NroDatastore
		Case 1
			ids_Estructura_Treview[ li_NroDatastore ].dataobject = 'dddw_usuarios_securityadmin'
	End Choose
	
	ids_Estructura_Treview[ li_NroDatastore ].settransobject( sqlca )
next


end event

event ue_postopen;call super::ue_postopen;Application lapp_local
lapp_local = GetApplication( )

/* Realiza el llamado a la función cambiar modulo de la aplicación*/
//lapp_local. dynamic function uf_configurar_menu( This )
end event

event resize;// No  hereda código 
Long		ll_AlturaMedia

ll_AlturaMedia = ( newheight - BordeHorizontal * 3 ) / 2

tv_Principal.x = BordeVertical
tv_Principal.y = BordeHorizontal
tv_Principal.height = newheight - ( BordeHorizontal * 2 )

dw_principal.y = BordeHorizontal
dw_principal.x = BordeVertical + tv_Principal.x + tv_Principal.width
dw_principal.width = newwidth - dw_principal.x - BordeVertical
dw_principal.height = ll_AlturaMedia

dw_usuariolocalidad.y = dw_principal.y + dw_principal.height + BordeHorizontal
dw_usuariolocalidad.x = dw_principal.x
dw_usuariolocalidad.width = dw_principal.width
dw_usuariolocalidad.height = ll_AlturaMedia
end event

type st_titulo from w_base_tv`st_titulo within w_usuarios_securityadmin
end type

type st_fondo from w_base_tv`st_fondo within w_usuarios_securityadmin
end type

type dw_principal from w_base_tv`dw_principal within w_usuarios_securityadmin
integer width = 1189
integer height = 916
string dataobject = "dw_usuarioservidor"
boolean ib_editar = false
boolean ib_mostrarmensajeantesdeeliminarregistro = true
end type

event dw_principal::ue_poblardddw;call super::ue_poblardddw;Integer                         li_ret
datawindowchild          ldwc_child

If     This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna
     case 'id_servidor'
          li_ret = ldwc_child.Retrieve( )  //1: Muestra las unidades de medida activas

End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If     li_ret < 1 Then      ldwc_child.Insertrow( 0 )

end event

event dw_principal::ue_retrieve;call super::ue_retrieve;Return This.retrieve( is_cod_usuario )
end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;This.object.cod_usuario[ ai_row ] = is_cod_usuario
end event

type st_menuruta from w_base_tv`st_menuruta within w_usuarios_securityadmin
end type

type tv_principal from w_base_tv`tv_principal within w_usuarios_securityadmin
string picturename[] = {"Library!","Custom039!","Custom050!"}
end type

event tv_principal::itempopulate;call super::itempopulate;/* Poblar el árbol con sus elementos hijos */
Integer			li_Filas 				// Número de filas de datastore
TreeviewItem	ltvi_Actual			// TreeView Item actual

SetPointer( hourglass! )

/* Determinar el nivel */
This.GetItem( handle, ltvi_Actual )
ii_Nivel = ltvi_Actual.level

/*	Si se alcanza el último nivel no se recupera data */
If ii_Nivel = ii_ultimo_nivel_treeview  Then Return

/* Resetear el datastore según el nivel */
ids_Estructura_Treview[ ii_Nivel ].reset( )

/*  Recuperar la data */
Choose case ii_Nivel 
	Case 1 // Recuperar Segundo Nivel
		li_Filas = ids_Estructura_Treview[ ii_Nivel ].retrieve( 5,'')
End Choose

uf_treeview_agregar_items( handle, ii_Nivel, li_Filas ) 		// Por cada elemento seleccionado agrega los elementos "hijos"

This.SetRedraw( True )

end event

event tv_principal::selectionchanged;call super::selectionchanged;TreeviewItem		ltvi_Nuevo						// Item Treeview seleccionado

Parent.SetRedraw( False )

/* Almacena el nivel del item seleccionado */
This.GetItem( newhandle, ltvi_Nuevo )
ii_Nivel = ltvi_Nuevo.level

Parent.uf_mostrar_ocultar_objetos( ii_nivel )

Choose case ii_nivel  
	Case 1
 		// parent.tag = // Establecer el Tag que servira para generar la ayuda
		dw_principal.reset( )
 		// dw_principal.dataobject=''
	Case 2
 		// parent.tag = // Establecer el Tag que servira para generar la ayuda
		is_cod_usuario = ltvi_Nuevo.data
End Choose

dw_principal.event ue_retrieve()
dw_usuariolocalidad.event ue_retrieve()

Parent.SetRedraw( True )


 

end event

type dw_usuariolocalidad from uo_dwbase within w_usuarios_securityadmin
integer x = 1266
integer y = 968
integer taborder = 20
boolean bringtotop = true
string dataobject = "dw_usuariolocalidad"
end type

event ue_poblardddw;call super::ue_poblardddw;Integer                         li_ret
datawindowchild          ldwc_child

If     This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna
     case 'nombre'
          li_ret = ldwc_child.Retrieve( )  //1: Muestra las unidades de medida activas

End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If     li_ret < 1 Then      ldwc_child.Insertrow( 0 )

end event

event ue_retrieve;call super::ue_retrieve;Return This.retrieve( is_cod_usuario )
end event

event itemchanged;call super::itemchanged;Choose Case dwo.name
	Case 'nombre'
			This.object.compania[ row ] = Left( data, 3 )
			This.object.localidad[ row ] = Right( data, 3 )
End Choose
end event

event ue_agregar_registro_post;call super::ue_agregar_registro_post;This.object.cod_usuario[ ai_row ] = is_cod_usuario
end event

