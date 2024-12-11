$PBExportHeader$w_tv_unidadnegocio_servidores.srw
$PBExportComments$emalcap
forward
global type w_tv_unidadnegocio_servidores from w_base_tv
end type
end forward

global type w_tv_unidadnegocio_servidores from w_base_tv
integer ii_modoventana = 1
integer ii_ctd_datastores = 2
end type
global w_tv_unidadnegocio_servidores w_tv_unidadnegocio_servidores

type variables
Integer 	ii_IdCompania			// Código de la Compañia 
Integer	ii_IdUnidadnegocio		// Código de la Unidad de Negocio
Integer	ii_IdServidor		   // Código de servidor

TreeviewItem itv_actual



end variables

forward prototypes
public function integer uf_treeview_agregar_items (long al_padre, integer ai_nivel, integer ai_filas)
public subroutine uf_treeview_actualizar ()
public subroutine uf_mostrar_ocultar_objetos (integer ai_parametro)
end prototypes

public function integer uf_treeview_agregar_items (long al_padre, integer ai_nivel, integer ai_filas);// Funcion para agregar los items para el TreeView usando la data en el DataStore
Integer			li_fila //Número de fila
Integer			li_picture
Treeviewitem	ltvi_nuevo //Item treeview a agregar al organigrama

tv_Principal.SetRedraw( False )
 

// Agregar cada item al TreeView
For li_fila = 1 To ai_filas

	// Configura los atributos etiqueta y data para el nuevo item desde la data del datastore
	Choose case ii_nivel
		Case 1 // Unidad de negocio 
			ltvi_nuevo.data = string( ids_Estructura_Treview[ ai_nivel ].getitemnumber( li_fila, 'idcompania' ) ) +"-"+ string( ids_Estructura_Treview[ ai_nivel ].getitemnumber( li_fila, 'idunidadnegocio' ) )
			ltvi_nuevo.label = Upper( trim( ids_Estructura_Treview[ ai_nivel ].getitemstring( li_fila, 'abreviatura' ) )  )
		Case 2 // Agregar items del Tercer Nivel
			ltvi_nuevo.data = string( ids_Estructura_Treview[ ai_nivel ].getitemnumber( li_fila, 'idServidor' ) )
			ltvi_nuevo.label = trim( ids_Estructura_Treview[ ai_nivel ].getitemstring( li_fila, 'nombreservidor' ) ) 
			 if ids_Estructura_Treview[ ai_nivel ].getitemnumber( li_fila, 'estado' ) <> 1	then 
				li_picture = 5
			else
				if trim(ids_Estructura_Treview[ ai_nivel ].getitemstring( li_fila, 'conexion' )) = '1' then
					li_picture	=	4
				else
					li_picture	=	6
				End if
			End if
	End choose

	If	ai_nivel <> ii_Ctd_datastores     Then 
		ltvi_nuevo.children = True 
	Else 
		ltvi_nuevo.children = False
	End If

	Choose case ai_nivel
		case 1
				ltvi_nuevo.pictureindex = 2
				ltvi_nuevo.selectedpictureindex = 3
		case 2
				ltvi_nuevo.pictureindex = li_picture
				ltvi_nuevo.selectedpictureindex = 7
	End choose
	

	// Agrega el item despues del ultimo item agregado   //insertitemsort
	If	tv_Principal.insertitemlast( al_padre, ltvi_nuevo ) < 1 Then
		gf_mensaje(gs_Aplicacion, 'Error al insertar item', '', 2)
		Return -1
	End If
Next

tv_Principal.setredraw( True )

Return ai_filas
end function

public subroutine uf_treeview_actualizar ();Long				ll_ControlActual				// Item treeview current(actual)
Long				ll_ControlPadre 			// Item treeview padre 
TreeviewItem	ltvi_Item 						// Item Treeview donde se registra el valor y la descripción a mostrar en el treeview.

ll_ControlActual = tv_Principal.FindItem( CurrentTreeItem!, 0 )

/* Si se está ejecutando la eliminación, se procede a eliminar el item del treeview
	y el elemento del datastore */
If	ib_Eliminando = True Then
     If	ii_Nivel = 2 Then
//      li_Fila = ids_Estructura_Treview[1].find( "IdFlowsheet="+string(ii_IdFlowsheet) , 1, ids_Estructura_Treview[1].rowcount( ) )
//		If li_Fila > 0 Then ids_Estructura_Treview[1].deleterow( li_Fila )
     End If
	 
     tv_Principal.DeleteItem( ll_ControlActual )
     Return
End if

/**  Para un nuevo registro **/
If	ib_Insertando = True Then
	
	ll_ControlPadre = tv_Principal.FindItem( CurrentTreeItem!, 0 )

	// Configura los atributos etiqueta y data para el nuevo item desde la data del datastore
	Choose case ii_nivel
	  Case 2 // Segundo Nivel
			 ltvi_Item.data =  string( dw_principal.object.idservidor[ dw_principal.getrow( ) ] )
			 ltvi_Item.label = dw_principal.object.nombreservidor[ dw_principal.getrow( ) ]
	End choose

	If	ii_nivel = ( ii_Ctd_datastores ) Then
		ltvi_Item.children = False
	Else
		ltvi_Item.children = True
	End If
	
	ltvi_Item.pictureindex = 2
	ltvi_Item.selectedpictureindex = 3
	
	/* Agrega el item despues del ultimo item agregado   */
	If	tv_Principal.FindItem( ChildTreeItem!, ll_ControlPadre ) > 0 Then
		/*Usar InsertItemLast o InsertItemSort Segun la necesidad */
		ll_ControlActual = tv_Principal.InsertItemLast( ll_ControlPadre, ltvi_Item )
//		ll_ControlActual = tv_Principal.InsertItemSort( ll_ControlPadre, ltvi_Item )
		If	ll_ControlActual < 1 Then
			gf_mensaje(gs_Aplicacion, 'Error al insertar item', '', 2)
		Else
			tv_Principal.selectitem( ll_ControlActual )
		End If
	Else
		tv_Principal.ExpandItem( ll_ControlPadre )
		tv_Principal.SelectItem( tv_Principal.FindItem( ChildTreeItem!, ll_ControlPadre ) )
	End If
	
/**  En el caso de actualización actualizar el texto de la propiedad label **/
Else
	tv_Principal.GetItem( ll_ControlActual, ltvi_Item )
	
	
	Choose case ii_nivel
		Case 2 // Tercer Nivel
			// ltvi_Item.label = dw_principal.object.codigo[ dw_principal.getrow( ) ]
		Case 3 // Cuarto Nivel
			ltvi_Item.label = dw_principal.object.nombreservidor[ dw_principal.getrow( ) ]
	End choose
	tv_Principal.SetItem( ll_ControlActual, ltvi_Item )
	
End If

end subroutine

public subroutine uf_mostrar_ocultar_objetos (integer ai_parametro);Choose case ai_Parametro  
	Case 1	// Nivel Raiz 
		dw_principal.Visible = False
 
	Case 2	// Segundo Nivel
		dw_principal.Visible = True

	Case 3	// Nivel
		dw_principal.Visible = True
		
	case else 		
		dw_principal.Visible = True
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
ltvi_raiz.label = 'Catálogo'
ltvi_raiz.pictureindex = 1
ltvi_raiz.selectedpictureindex = 1
ltvi_raiz.bold = True

tv_Principal.insertitemlast( 0, ltvi_raiz )
 
// Agregar los items al datawindow
tv_Principal.selectitem( tv_Principal.finditem( roottreeitem!, 0) ) 
tv_Principal.expandItem( tv_Principal.finditem( roottreeitem!, 0) )

tv_Principal.setfocus( )
end event

on w_tv_unidadnegocio_servidores.create
call super::create
end on

on w_tv_unidadnegocio_servidores.destroy
call super::destroy
end on

event ue_preopen;call super::ue_preopen;ii_ultimo_nivel_treeview = 3  // Debe ser mayor en 1 a la cantidad de datastores declarado en las variables de instancia
ii_Ctd_datastores = ii_ultimo_nivel_treeview - 1
Return 1
end event

event open;call super::open;Integer			li_NroDatastore				//Número de datastore
SetPointer( hourglass! )

// Crear los datastores
For li_NroDatastore = 1 to ii_Ctd_datastores
	ids_Estructura_Treview[ li_NroDatastore ] = create uo_dsbase
	
	Choose Case li_NroDatastore
		Case 1
			ids_Estructura_Treview[ li_NroDatastore ].dataobject = 'dddw_unidadnegocio'
		Case 2 // Datastore para el segundo nivel
			ids_Estructura_Treview[ li_NroDatastore ].dataobject = 'dddw_servidores'
		Case 3  // Datastore para el tercer nivel
			// ids_Estructura_Treview[ li_NroDatastore ].dataobject = 
			
	End Choose
	
	ids_Estructura_Treview[ li_NroDatastore ].settransobject( sqlca )
next



end event

event ue_nuevo_pre;/* No se podrá insertar data al nivel de las unidades de negocio ( Nivel 2 ) */
If	ii_Nivel = 1 Then Return -1

If	ii_Nivel = ii_ultimo_nivel_treeview Then
	gf_mensaje(gs_Aplicacion, 'Se ha llegado al último nivel, no es posible insertar registros.', '', 1)
	Return  -1
End If

dw_principal.dataobject =    'dw_servidor'
dw_principal.SetTransObject( SQLCA )

Return 1
end event

event ue_nuevo;call super::ue_nuevo;if ii_nivel > 2 then Return
If	ii_nivel = 2 Then uf_mostrar_ocultar_objetos(3)
end event

event resize;call super::resize;If	ib_MostrarTitulo = True Then il_AlturaTitulo = st_fondo.height + BordeHorizontal

dw_principal.y = il_AlturaTitulo + BordeHorizontal 
dw_principal.x = st_fondo.x
dw_principal.width = newwidth - dw_principal.x - BordeVertical
dw_principal.height = newheight - dw_principal.y - BordeHorizontal
end event

event ue_cancelar;tv_Principal.Event SelectionChanged( 1, tv_Principal.FindItem( CurrentTreeItem! , 0 ) )

This.ib_Editando = False
This.Event ue_editar( )	
end event

event ue_vistaprevia;//nada
end event

event ue_eliminar_pre;call super::ue_eliminar_pre;
if tv_Principal.FindItem( ChildTreeItem!, tv_Principal.FindItem( CurrentTreeItem!, 0 ) ) > 0 then
	// Lo hace el FW
else
	If ii_nivel=2 Then
		gf_mensaje(gs_Aplicacion,'No se puede eliminar este elemento, verifique', '', 1)
		Return -1
	End if
End If
end event

event ue_grabar_post;call super::ue_grabar_post;
ii_idservidor = dw_principal.GetItemNumber(dw_principal.Getrow(),'idservidor')
itv_actual.data =  String(ii_idservidor)
itv_actual.Label = dw_principal.GetItemString(dw_principal.Getrow(),'nombreservidor') 
tv_principal.setitem(itv_actual.itemhandle , itv_actual)
Return 1
end event

type st_titulo from w_base_tv`st_titulo within w_tv_unidadnegocio_servidores
string text = "Servidor"
end type

type st_fondo from w_base_tv`st_fondo within w_tv_unidadnegocio_servidores
end type

type dw_principal from w_base_tv`dw_principal within w_tv_unidadnegocio_servidores
integer x = 1285
string title = ""
string dataobject = "dw_servidor"
boolean border = false
boolean ib_menupopup = false
boolean ib_menuedicionvisible = false
end type

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre;String				ls_Tabla
String				ls_ValoresPK
Long				ll_Id = 0
Integer			li_idservidor
String				ls_valor

if this.Describe("idservidor.Edit.DisplayOnly") ='yes' then

		li_idservidor		=	0	
		
		dwItemStatus	ldwis_Estado
		
		ldwis_Estado 	= This.getitemstatus(1,0, Primary!)
		
		/* No ejecuta el código si se está actualizando o eliminando el registro */
		If	( ldwis_Estado = New! OR ldwis_Estado = NewModified! ) And This.rowcount() > 0 Then
			 
			  ls_Tabla = 'Seguridad.Servidor'
			  ls_ValoresPK=''
		
			/* Generar el ID */
			Integer								li_ValorRetorno
			
			li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, ll_Id )	
		
			  If	IsNull( ll_Id ) OR ll_Id = 0 Then
					Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
					Return -1
			  End If
		
				ii_IdServidor							= ll_Id
				This.object.idservidor[ 1 ] 			= ii_IdServidor	
						
			return 1
			
		End If

End if

Return 1
end event

event dw_principal::ue_retrieve;call super::ue_retrieve;String ls_Paramtros
long row 

Choose Case ii_Nivel
	Case 2			 
		ls_Paramtros = String( ii_IdCompania)+','+string(ii_IdUnidadnegocio)		
		return This.Retrieve(1,ls_Paramtros)	
	
	Case 3
		return This.Retrieve(	ii_IdCompania,ii_IdUnidadnegocio,ii_IdServidor)	
		if this.getrow()>0 then 	this.object.idservidor.edit.DisplayOnly = True
End Choose 


end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;  This.object.idcompania[ai_row] 			= ii_IdCompania	
  This.object.idunidadnegocio[ ai_row ] 	= ii_IdUnidadnegocio	 
end event

event dw_principal::ue_validar;call super::ue_validar;Integer	li_idservidor
if this.GetRow()<1 then Return 1
li_idservidor	=	this.GetItemNumber(Getrow(),'idservidor')
if li_idservidor=gi_idservidor then
	if Len(Trim(this.GetItemString(Getrow(),'nombrelinkedserver')))>0 then
		gf_mensaje(gs_Aplicacion, 'Servidor activo NO debe tener Linked Server', '', 3)
		Return -1
	End if
End if

Return 1
end event

event dw_principal::doubleclicked;call super::doubleclicked;if dwo.name='t_idservidor' and gs_tipo_usuario<>'U' then
	this.object.idservidor.edit.DisplayOnly = FALSE
End if

end event

event dw_principal::buttonclicked;call super::buttonclicked;string  ls_linkedserver

ls_linkedserver = dw_principal.getitemstring(row,'nombrelinkedserver')
uo_dsbase		luo_ds_query
str_response    lstr_Response

str_arg  				lstr_Enviar

If Len(ls_linkedserver)<1 then
	gf_mensaje(gs_Aplicacion, 'Debe ingresar un nombre de Linked Server', '', 3)
	Return 
End if

Choose case dwo.name
	Case 		'b_linkedserver'
		

if dw_principal.Getrow()<1  then Return -1

luo_ds_query			= gf_Procedimiento_Consultar(" Seguridad.usp_Servidor_Select_03   " +String(ii_IdCompania)+","+String(ii_IdUnidadnegocio)+","+String(ii_IdServidor), sqlca)


if luo_ds_query.rowcount() < 1 then Return -1

lstr_response.b_usar_datastore		= 	True
lstr_response.ds_datastore    			= 	luo_ds_query
lstr_response.s_titulo      				= 	'Listado de Linked' 
lstr_response.b_seleccion_multiple	= 	False
lstr_response.b_mostrar_contador		= 	False
lstr_response.s_titulos_columnas		=	'4:Nombre Servidor:600, 5:Nombre Linked Server:700'
lstr_response.b_redim_ventana		= 	True
lstr_response.l_ancho						= 	1750
lstr_response.l_alto						= 	780
lstr_response.str_argumentos			= lstr_Enviar
	  
OpenWithParm(w_reponse_linkedserver ,	lstr_Response)



End Choose

end event

type st_menuruta from w_base_tv`st_menuruta within w_tv_unidadnegocio_servidores
end type

type tv_principal from w_base_tv`tv_principal within w_tv_unidadnegocio_servidores
integer x = 27
string picturename[] = {"Library!","Custom039!","Custom050!","Output!","OutputStop!","OutputNext!","DosEdit!"}
end type

event tv_principal::itempopulate;call super::itempopulate;/* Poblar el árbol con sus elementos hijos */
Integer			li_Filas 				// Número de filas de datastore
TreeviewItem	ltvi_Actual			// TreeView Item actual
TreeviewItem	ltvi_Padre			// Treeview Padre (Cia - UnidadNegocio) /* Solo utilizar si se tiene que recuperar un cuarto nivel******************/

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
	Case 1 // Recuperar Unidad de negocio
		li_Filas = ids_Estructura_Treview[ ii_Nivel ].retrieve( 1, 0)

	Case 2 // Recuperar Tercer nivel	
		/* Almacena los códigos de Compañia y Unidad */	
		
		ii_IdCompania = Integer( Left(  ltvi_Actual.data , Pos(  ltvi_Actual.data , '-' ) - 1 ) )
		ii_IdUnidadNegocio = Integer( Right(  ltvi_Actual.data , Len( string( ltvi_Actual.data)  ) - Pos(  ltvi_Actual.data , '-' ) ) )
		li_Filas = ids_Estructura_Treview[ ii_Nivel ].retrieve( ii_IdCompania , ii_IdUnidadNegocio )
		
	Case 3 // Recuperar Cuarto Nivel
		/* Solo utilizar si se tiene que recuperar un cuarto nivel******************/
		This.GetItem( This.FindItem( ParentTreeItem!, handle ), ltvi_Padre )
		ii_IdCompania = Integer( Left(  ltvi_Padre.data , Pos(  ltvi_Padre.data , '-' ) - 1 ) )
		ii_IdUnidadNegocio = Integer( Right(  ltvi_Padre.data , Len( string( ltvi_Padre.data)  ) - Pos(  ltvi_Padre.data , '-' ) ) )
		/* Solo utilizar si se tiene que recuperar un cuarto nivel******************/
End Choose
 
uf_treeview_agregar_items( handle, ii_Nivel, li_Filas ) 		// Por cada elemento seleccionado agrega los elementos "hijos"

This.SetRedraw( True )

end event

event tv_principal::selectionchanged;call super::selectionchanged;TreeviewItem		ltvi_Nuevo						// Item Treeview seleccionado
TreeviewItem		ltvi_TercerNivel					// Item Treeview del tercer nivel

Parent.SetRedraw( False )
/* Almacena el nivel del item seleccionado */
This.GetItem( newhandle, ltvi_Nuevo )
itv_actual = ltvi_Nuevo
ii_Nivel = ltvi_Nuevo.level


Parent.uf_mostrar_ocultar_objetos( ii_nivel )
Choose case ii_nivel  
		
	Case 1
 		// parent.tag = // Establecer el Tag que servira para generar la ayuda
		dw_principal.dataobject=''
 		dw_principal.reset( )
	Case 2
 		// parent.tag = // Establecer el Tag que servira para generar la ayuda
		/* Obtener el código de la Compañia y la Unidad de Negocio */
		ii_IdCompania = Integer( Left(  ltvi_Nuevo.data , Pos(  ltvi_Nuevo.data , '-' ) - 1 ) )
		ii_IdUnidadNegocio = Integer( Right(  ltvi_Nuevo.data , Len( string( ltvi_Nuevo.data)  ) - Pos(  ltvi_Nuevo.data , '-' ) ) )
  		dw_principal.dataobject = 'dw_servidorcompnego'	  
	Case 3
 		// parent.tag = // Establecer el Tag que servira para generar la ayuda
		/* Almacenar el código del Nivel actual */
		 ii_IdServidor = integer( ltvi_Nuevo.Data)
		/* Obtener el código de la Compañia y la Unidad de Negocio */
		This.GetItem( this.FindItem( ParentTreeItem!, newhandle ), ltvi_TercerNivel )
		ii_IdCompania = Integer( Left(  ltvi_TercerNivel.data , Pos(  ltvi_TercerNivel.data , '-' ) - 1 ) )
		ii_IdUnidadNegocio = Integer( Right(  ltvi_TercerNivel.data , Len( string( ltvi_TercerNivel.data)  ) - Pos(  ltvi_TercerNivel.data , '-' ) ) )
		dw_principal.dataobject = 'dw_servidor'
End Choose

dw_principal.SetTransObject( SQLCA )
dw_principal.event ue_retrieve()

Parent.SetRedraw( True )





 

end event

