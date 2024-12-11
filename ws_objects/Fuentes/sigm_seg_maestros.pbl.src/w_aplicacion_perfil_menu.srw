$PBExportHeader$w_aplicacion_perfil_menu.srw
forward
global type w_aplicacion_perfil_menu from w_base
end type
type dw_aplicacion from uo_dwfiltro within w_aplicacion_perfil_menu
end type
type tv_perfilmenu from treeview within w_aplicacion_perfil_menu
end type
type dw_menu_add from uo_dwbase within w_aplicacion_perfil_menu
end type
type dw_menu_perfil from uo_dwbase within w_aplicacion_perfil_menu
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_aplicacion_perfil_menu
end type
type st_ultimas from statictext within w_aplicacion_perfil_menu
end type
end forward

global type w_aplicacion_perfil_menu from w_base
integer width = 7045
dw_aplicacion dw_aplicacion
tv_perfilmenu tv_perfilmenu
dw_menu_add dw_menu_add
dw_menu_perfil dw_menu_perfil
dw_filtro_servidor dw_filtro_servidor
st_ultimas st_ultimas
end type
global w_aplicacion_perfil_menu w_aplicacion_perfil_menu

type variables
Integer 	ii_idservidor
Integer	ii_IdAplicacion
Long		il_Idperfil=0
Long 		ilHandle
Integer	iiStatePictureIndex
Boolean 	ib_clonar = false
Long		iold_handle
datastore ids_Menus

Integer   il_Fila
end variables

forward prototypes
public subroutine uf_pasa_datos (datastore ads_dw, long al_rowcount)
public subroutine uf_pasa_datos_dw (datastore ads_dw, long al_rowcount)
end prototypes

public subroutine uf_pasa_datos (datastore ads_dw, long al_rowcount);
end subroutine

public subroutine uf_pasa_datos_dw (datastore ads_dw, long al_rowcount);
end subroutine

on w_aplicacion_perfil_menu.create
int iCurrent
call super::create
this.dw_aplicacion=create dw_aplicacion
this.tv_perfilmenu=create tv_perfilmenu
this.dw_menu_add=create dw_menu_add
this.dw_menu_perfil=create dw_menu_perfil
this.dw_filtro_servidor=create dw_filtro_servidor
this.st_ultimas=create st_ultimas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_aplicacion
this.Control[iCurrent+2]=this.tv_perfilmenu
this.Control[iCurrent+3]=this.dw_menu_add
this.Control[iCurrent+4]=this.dw_menu_perfil
this.Control[iCurrent+5]=this.dw_filtro_servidor
this.Control[iCurrent+6]=this.st_ultimas
end on

on w_aplicacion_perfil_menu.destroy
call super::destroy
destroy(this.dw_aplicacion)
destroy(this.tv_perfilmenu)
destroy(this.dw_menu_add)
destroy(this.dw_menu_perfil)
destroy(this.dw_filtro_servidor)
destroy(this.st_ultimas)
end on

event resize;st_fondo.x = BordeVertical
st_fondo.y = BordeHorizontal
st_fondo.width = newwidth - ( BordeVertical * 2 )
st_titulo.x = BordeVertical + 20
st_titulo.y = BordeHorizontal + 15
st_titulo.width = (newwidth - ( BordeVertical * 4 ) )/2 // la mitad del ancho

st_menuruta.width = st_titulo.width
st_menuruta.x = st_fondo.x + st_fondo.width - st_menuruta.width

il_AlturaTitulo = st_fondo.height + BordeHorizontal


If	ib_MostrarTitulo = True Then il_AlturaTitulo = st_fondo.height + BordeHorizontal

dw_filtro_servidor.y = BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x =  BordeVertical



dw_principal.y = BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
dw_principal.x = BordeVertical
dw_principal.width = dw_filtro_servidor.y + dw_filtro_servidor.width
dw_principal.height = newheight - dw_filtro_servidor.y - ( BordeHorizontal * 4 )




dw_aplicacion.x 		=   dw_principal.x + dw_principal.width + BordeHorizontal
dw_aplicacion.y 		=   dw_filtro_servidor.y 
//
dw_aplicacion.width 	=    dw_aplicacion.y + dw_aplicacion.width
dw_aplicacion.height  = 	newheight - dw_aplicacion.y - ( BordeHorizontal * 4 )


tv_perfilMenu.x			= dw_principal.x + dw_principal.width + BordeHorizontal
tv_perfilMenu.y			= dw_principal.y
tv_perfilMenu.width 	=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 4)
tv_perfilMenu.height 	=   newheight - dw_filtro_servidor.y - (BordeHorizontal  * 4 )

dw_menu_add.x 			=	tv_perfilMenu.x + tv_perfilMenu.width + BordeHorizontal
dw_menu_add.y 			=  dw_principal.y
//dw_menu_add.width 	=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 3)
dw_menu_add.width 		=  st_fondo.width   - (dw_principal.width + tv_perfilmenu.width) - (BordeVertical * 2)
dw_menu_add.height 	= newheight - dw_filtro_servidor.y -  ( BordeHorizontal * 4 ) 

st_ultimas.x			=	dw_menu_add.x
st_ultimas.y   		=  dw_filtro_servidor.y 
st_ultimas.width 	=	dw_menu_add.width 	
st_ultimas.height  	=	il_AlturaTitulo / 2
end event

event ue_rellenar_treeview;call super::ue_rellenar_treeview;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

if  il_Idperfil =  0 then return 

Integer 	liFila
Integer	liNumFil
Integer  	li_handle[]
String   	ls_parametros
long 		tvi_hdl = 0
treeviewitem tv_listi

tv_perfilmenu.SetRedraw( FALSE )

//Limpiar TV
DO UNTIL tv_perfilmenu.FindItem(RootTreeItem!, 0) = -1
	tv_perfilmenu.DeleteItem(tvi_hdl)
LOOP

//Cargar DW de mantenimiento
//ls_parametros	=	String(ii_idservidor) + "," + String(ii_IdAplicacion)+","+String(il_Idperfil) 
ls_parametros	=	String(ii_IdAplicacion)+","+String(il_Idperfil) //1.0
liNumFil	=	dw_menu_perfil.retrieve(ls_parametros)

if liNumFil<1 then Return 


//Cargar DS para visualizar menu
ids_Menus = CREATE uo_dsbase
ids_Menus.dataobject = 'dw_menu_perfil'
ids_Menus.SetTransObject(SQLCA)
ids_Menus.Reset()
liNumFil	=	ids_Menus.retrieve(ls_parametros)

if liNumFil<1 then Return 
 
Integer	li_nivelMenu
Integer	li_nivel[]
String		ls_menu[]
String		ls_acceso[]
Integer	li_idmenu[]
Integer	li_idmenuAnt[]

Integer liData

li_idmenuAnt[1]=0
li_idmenuAnt[2]=0
li_idmenuAnt[3]=0
li_idmenuAnt[4]=0
 
FOR liFila = 1 TO liNumFil

	//***********Primer Nivel***************
	li_nivelMenu						= 1
	li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel1' )
	ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu1' )
	ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu1' ))
	li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id1' )
	if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
	
	//Item , Solo una vez
	if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
		if Upperbound(li_handle)>0 then tv_perfilmenu.ExpandAll(li_handle[li_nivelMenu])  //Expandir todos los hijos al terminar cada menu en nivel 1
		li_idmenuAnt[li_nivelMenu]= li_idmenu[li_nivelMenu]
		li_handle[li_nivelMenu]	  = tv_perfilmenu.InsertItemLast( 0, ls_menu[li_nivelMenu],li_nivelMenu )
		tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
		tv_listi.Data 						= li_idmenu[li_nivelMenu]
		tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
		tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
	End if

	//***********Segundo Nivel***************
	If Not IsNull(ids_Menus.GetItemNumber( liFila, 'Nivel2' )) and ids_Menus.GetItemNumber( liFila, 'Nivel2' )>0 then
			li_nivelMenu						= 2
			li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel2' )
			ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu2' )
			ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu2' ))
			li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id2' )
			if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
			
			//Item , Solo una vez
			if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
				li_idmenuAnt[li_nivelMenu]	= li_idmenu[li_nivelMenu]
				li_handle[li_nivelMenu] 		= tv_perfilmenu.InsertItemLast( li_handle[1] , ls_menu[li_nivelMenu],li_nivelMenu )
				tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
				tv_listi.Data 						= li_idmenu[li_nivelMenu]
				tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
				tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
			End if
	End if

	
	//***********Tercer Nivel***************
	If Not IsNull(ids_Menus.GetItemNumber( liFila, 'Nivel3' )) and ids_Menus.GetItemNumber( liFila, 'Nivel3' )>0 then
			li_nivelMenu						= 3
			li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel3' )
			ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu3' )
			ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu3' ))
			li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id3' )
			if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
			
			//Item , Solo una vez
			if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
				li_idmenuAnt[li_nivelMenu]	= li_idmenu[li_nivelMenu]
				li_handle[li_nivelMenu] 		= tv_perfilmenu.InsertItemLast( li_handle[2] , ls_menu[li_nivelMenu],li_nivelMenu )
				tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
				tv_listi.Data 						= li_idmenu[li_nivelMenu]
				tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
				tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
			End if
	End if
	
		//***********Cuarto Nivel***************
	If Not IsNull(ids_Menus.GetItemNumber( liFila, 'Nivel4' )) and ids_Menus.GetItemNumber( liFila, 'Nivel4' )>0 then
			li_nivelMenu						= 4
			li_nivel[li_nivelMenu]			=   ids_Menus.GetItemNumber( liFila, 'Nivel4' )
			ls_menu[li_nivelMenu]		=   ids_Menus.GetItemString( liFila, 'Menu4' )
			ls_acceso[li_nivelMenu]		=  String( ids_Menus.GetItemNumber( liFila, 'AccesoMenu4' ))
			li_idmenu[li_nivelMenu]		=   ids_Menus.GetItemNumber( liFila, 'id4' )
			if isnull(ls_acceso[li_nivelMenu]) then ls_acceso[li_nivelMenu] = '0'
			
			//Item , Solo una vez
			if li_idmenu[li_nivelMenu] <> li_idmenuAnt[li_nivelMenu] then
				li_idmenuAnt[li_nivelMenu]	= li_idmenu[li_nivelMenu]
				li_handle[li_nivelMenu] 		= tv_perfilmenu.InsertItemLast( li_handle[3] , ls_menu[li_nivelMenu],li_nivelMenu )
				tv_perfilmenu.GetItem( li_handle[li_nivelMenu], tv_listi)
				tv_listi.Data 						= li_idmenu[li_nivelMenu]
				tv_listi.StatePictureIndex		= Integer(ls_acceso[li_nivelMenu])
				tv_perfilmenu.SetItem( li_handle[li_nivelMenu], tv_listi )
			End if
	End if
	
NEXT
tv_perfilmenu.ExpandAll(li_handle[1])  //Ultimo nivel que quedo en handle, no entra en el for

tv_perfilmenu.SetRedraw( TRUE )
end event

event ue_nuevo_pre;call super::ue_nuevo_pre; if isnull(ii_IdAplicacion) or  ii_IdAplicacion =  0 then
	gf_mensaje(gs_Aplicacion, 'Seleccione Aplicación', '', 1)
	return -1
 end if 	

end event

event ue_vistaprevia;Return 
end event

event ue_grabar_post;call super::ue_grabar_post;dw_principal.event rowfocuschanged(il_Fila)
return 1

end event

type st_titulo from w_base`st_titulo within w_aplicacion_perfil_menu
boolean visible = true
string text = "Perfiles por aplicación"
end type

type st_fondo from w_base`st_fondo within w_aplicacion_perfil_menu
end type

type dw_principal from w_base`dw_principal within w_aplicacion_perfil_menu
string tag = "<MenuAdicional:N,Clonar Perfil Menu:S>"
integer x = 59
integer y = 256
integer width = 1696
integer height = 1640
string dataobject = "dw_perfil"
boolean hscrollbar = true
boolean ib_mostrarmensajeantesdeeliminarregistro = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

if isnull(ii_IdAplicacion) then  ii_IdAplicacion =  0
//return retrieve(ii_idservidor,ii_IdAplicacion)
return  retrieve( ii_IdAplicacion)	//1.0
end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post;This.Setitem(ai_row,'idaplicacion',ii_IdAplicacion)
This.Setitem(ai_row,'idservidor',ii_idservidor)

if ai_row = 1 then			//Para los nuevos registros 
	this.event rowfocuschanged( 1)
End if

 
 


end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;If currentrow > 0 and this.RowCount()>0 then
	
	il_Fila  =  currentrow
	
	if IsNull(this.GetItemnumber(currentrow,'idperfil')) =False then
		il_Idperfil =  this.GetItemnumber(currentrow,'idperfil')
		parent.event ue_rellenar_treeview() 	 
	Else
		il_Idperfil=0
		tv_perfilmenu.SetRedraw( FALSE )
		DO UNTIL tv_perfilmenu.FindItem(RootTreeItem!, 0) = -1
			tv_perfilmenu.DeleteItem(0)
		LOOP
		tv_perfilmenu.SetRedraw( TRUE )		
	End if
	
Else
	il_Idperfil=0
	tv_perfilmenu.SetRedraw( FALSE )
	DO UNTIL tv_perfilmenu.FindItem(RootTreeItem!, 0) = -1
		tv_perfilmenu.DeleteItem(0)
	LOOP
	tv_perfilmenu.SetRedraw( TRUE )		
End If




end event

event dw_principal::ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;String		ls_nombreClonar
Integer 	li_perfirClonar
Integer	li_row
Integer 	li_contar
Integer	li_retorno
String		ls_parametros
String		ls_retorno[]
String		ls_error

If this.getrow()= 0 then return 

li_contar =  0
Choose Case as_menutexto
		
	Case 'Clonar Perfil Menu'
		
			ls_nombreClonar =  this.getitemstring(this.getrow(),'nombreperfil')
			li_perfirClonar 	   =  this.getitemnumber(this.getrow(),'idperfil')
			
			ls_nombreClonar	=	f_alltrim(ls_nombreClonar)  
			if isnull(ls_nombreClonar) or ls_nombreClonar = "" then return 
			
			//Verificar menus asignados
			li_contar	=dw_menu_perfil.Find("accesomenu=2",1,dw_menu_perfil.Rowcount())
				
			If li_contar = 0 then 
				gf_mensaje(gs_Aplicacion, 'El perfil seleccionado no tiene menús asignados para clonar', '', 1)
				return 
			end if 			
			
			If gf_mensaje(gs_Aplicacion, 'Esta seguro de clonar el perfil: ' +ls_nombreClonar,'', 4)=2 then
				Return 
		  	end if 		
			
			//ls_Parametros = string(li_perfirClonar) +","+string(ii_IdAplicacion)+","+trim(ls_nombreClonar)+","+String(ii_idservidor)
			ls_Parametros = string(li_perfirClonar) +","+string(ii_IdAplicacion)+","+String(ii_idservidor)
			li_retorno	= gf_Procedimiento_Ejecutar("Seguridad.usp_PerfilMenuPerfilClonar_Insert",ls_Parametros,ls_retorno, ls_Error)

			if upperbound(ls_retorno)>0 then
			
			if Integer(ls_retorno[1])=1 then
				dw_principal.event ue_retrieve()
			end if 
			
		End if 



			
	
End Choose 
end event

event dw_principal::ue_eliminar_registro;// Si se elige la opción 2 se cancela la solicitud de eliminación
IF gf_mensaje( 'Confirmación','Está seguro de eliminar este registro.','', 4) = 2 Then
	Return -1
Else
	this.deleterow( ai_row)
	this.update( )
	parent.event ue_recuperar( )
End If

end event

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre;String				ls_Tabla
String				ls_ValoresPK
Long				ll_Id = 0
Integer			li_row
Integer			li_idservidor	

dwItemStatus 	ldwis_Estado
li_row				=	this.Getrow()

ls_Tabla = 'Seguridad.Perfil'
ls_ValoresPK= ""

li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro

ldwis_Estado = This.getitemstatus( li_row, 0, Primary! )

If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then
		/* Generar el ID */
		Integer li_ValorRetorno	
			li_ValorRetorno = sqlca.usp_generarid( li_idservidor , ls_Tabla, ls_ValoresPK, ll_Id )
		
		If	IsNull( ll_Id ) OR ll_Id = 0 Then
			Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
			Return -1
		End If  	  
		
	il_Idperfil	 = ll_Id	
	
	This.SetItem( li_row,'idperfil', il_Idperfil )
	
End if 



end event

event dw_principal::itemchanged;call super::itemchanged;String 		ls_Columna
long 			ll_total_filas
Long 			ll_find

ls_Columna = String(dwo.name)

choose case ls_Columna
	case 'nombreperfil'
		ll_total_filas				=	dw_principal.RowCount()
		ll_find 					= dw_principal.Find("nombreperfil='" +String(data)+"'" , 1, ll_total_filas)
		If ll_find > 0 Then
			gf_mensaje("Validación","No se permte un Perfil duplicado :  Revisar Fila Nº "+String(row),"",1)
			Return 2
		End If

End Choose


end event

type st_menuruta from w_base`st_menuruta within w_aplicacion_perfil_menu
end type

type dw_aplicacion from uo_dwfiltro within w_aplicacion_perfil_menu
integer x = 1765
integer y = 124
integer width = 1435
integer height = 84
integer taborder = 30
boolean bringtotop = true
string title = ""
string dataobject = "dwf_aplicacion"
boolean border = false
borderstyle borderstyle = styleshadowbox!
boolean ib_editar = false
end type

event ue_poblardddw;call super::ue_poblardddw;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idaplicacion' 
	//	li_ret = ldwc_child.Retrieve(ii_idservidor ) // Recuepara los parámetros por ambiente	
//		li_ret = ldwc_child.Retrieve() // Recuepara los parámetros por ambiente	1.0
		li_ret = ldwc_child.Retrieve(2,'') // Recuepara los parámetros por ambiente	1.0
End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )
end event

event itemchanged;call super::itemchanged;This.accepttext( )
ii_IdAplicacion  =  integer(data)
if ii_IdAplicacion > 0 then 
	dw_principal.TriggerEvent("ue_retrieve")
	dw_menu_add.TriggerEvent("ue_retrieve")
End if



end event

type tv_perfilmenu from treeview within w_aplicacion_perfil_menu
event ue_marcar_opciones ( long alhandle,  string astipo )
event ue_verificar ( )
event ue_verificar_check ( long alhandle )
event ue_preparadatocrud ( datastore ads_perfilmenu,  boolean ab_new )
integer x = 1769
integer y = 252
integer width = 1486
integer height = 1636
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 15793151
borderstyle borderstyle = stylelowered!
boolean linesatroot = true
boolean tooltips = false
boolean checkboxes = true
string picturename[] = {"Menu!","Menu5!","DosEdit5!","DosEdit!"}
long picturemaskcolor = 15793151
long statepicturemaskcolor = 536870912
end type

event ue_marcar_opciones(long alhandle, string astipo);long 				ll_tvi, ll_tvi_child
Integer			li_total_filas
Integer			li_fila_act
TreeViewItem 	tvi, tvi2

li_total_filas	=	dw_menu_perfil.rowcount( )	

GetItem( alHandle, tvi )

If ( asTipo = 'D' ) Then
	//Actualizar item actual
	li_fila_act	=	dw_menu_perfil.find("idmenu="+String(tvi.data),1,li_total_filas)
	dw_menu_perfil.setitem(li_fila_act , 'accesomenu',  Integer(tvi.StatePictureIndex))
	dw_menu_perfil.setitem(li_fila_act , 'idperfil',  il_Idperfil)
	
	// Marca o desmarca sus descendientes
	ll_tvi = FindItem( ChildTreeItem!, alHandle )
	DO WHILE ( ll_tvi > -1 )
		GetItem( ll_tvi, tvi2 )
		tvi2.StatePictureIndex = tvi.StatePictureIndex
		SetItem( ll_tvi, tvi2 )
		
		//Actualizar item Descendiente
		li_fila_act	=	dw_menu_perfil.find("idmenu="+String(tvi2.data),1,li_total_filas)
		dw_menu_perfil.setitem(li_fila_act , 'accesomenu',  Integer(tvi2.StatePictureIndex))
		dw_menu_perfil.setitem(li_fila_act , 'idperfil',  il_Idperfil)
			
		ll_tvi_child = FindItem( ChildTreeItem!, ll_tvi )
		If ( ll_tvi_child > -1 ) Then
			Event ue_marcar_opciones( ll_tvi, 'D' )
		End If
		
		ll_tvi = FindItem( NextTreeItem!, ll_tvi )
	LOOP
Else
	//Actualizar item actual
	li_fila_act	=	dw_menu_perfil.find("idmenu="+String(tvi.data),1,li_total_filas)
	dw_menu_perfil.setitem(li_fila_act , 'accesomenu',  Integer(tvi.StatePictureIndex))
	dw_menu_perfil.setitem(li_fila_act , 'idperfil',  il_Idperfil)
		
	// Marca o desmarca sus ascendientes
	ll_tvi = FindItem( ParentTreeItem!, alHandle )

	If ( tvi.StatePictureIndex <> 1 ) Then
		GetItem( ll_tvi, tvi2 )
		tvi2.StatePictureIndex = tvi.StatePictureIndex
		SetItem( ll_tvi, tvi2 )
		
		//Actualizar item Descendiente
		if Integer(tvi2.data)>0 then 
			li_fila_act	=	dw_menu_perfil.find("idmenu="+String(tvi2.data),1,li_total_filas)
			if li_fila_act>0 then
				dw_menu_perfil.setitem(li_fila_act , 'accesomenu',  Integer(tvi2.StatePictureIndex))
				dw_menu_perfil.setitem(li_fila_act , 'idperfil',  il_Idperfil)
			End if
		End if
		
		ll_tvi_child = FindItem( ParentTreeItem!, ll_tvi )
		If ( ll_tvi_child > -1 ) Then
			Event ue_marcar_opciones( ll_tvi, 'A' )
		End If
	End If		
End If

end event

event ue_verificar_check(long alhandle);treeviewitem tvi

GetItem( alHandle, tvi )

IF (iiStatePictureIndex <> tvi.StatePictureIndex) THEN
//	ibModificado = True
	Event ue_marcar_opciones( alHandle, 'D' )
	Event ue_marcar_opciones( alHandle, 'A' )
	
	this.selectitem(alhandle)

	parent.ib_editando = true
	parent.event ue_editar( )
	
END IF
end event

event clicked;Long ll_idPerfil
ilHandle = handle
TreeViewItem tvi


// verificao si existe un nuevo

//if ii_NewRow > 0 then 
//	ll_idPerfil =  dw_principal.getitemnumber(ii_NewRow,'idperfil')
//	If isnull(ll_idPerfil) or ll_idPerfil <= 0 then 
//		gf_mensaje(gs_Aplicacion, 'Debe registrar o anular el nuevo registro', '', 1)
//		Return 2
//	end if 
//end if 


GetItem( handle, tvi )
iiStatePictureIndex = tvi.StatePictureIndex
//ibModificado	=False
Post Event ue_verificar_check( handle )
//
//ib_tree = true 
end event

event selectionchanged;

treeviewitem l_tvi

GetItem( oldHandle , l_tvi )
l_tvi.Bold = FALSE
SetItem( oldHandle, l_tvi )
iold_handle	=	oldHandle

GetItem( newHandle, l_tvi)
l_tvi.Bold = TRUE
SetItem( newHandle, l_tvi )



end event

type dw_menu_add from uo_dwbase within w_aplicacion_perfil_menu
integer x = 3291
integer y = 312
integer width = 2912
integer height = 1556
integer taborder = 30
boolean bringtotop = true
string dataobject = "dw_menuperfil_add"
boolean hscrollbar = true
boolean ib_menupopup = false
end type

event ue_retrieve;call super::ue_retrieve;String ls_paramtro 
ls_paramtro = string(ii_idservidor) +","+String(ii_IdAplicacion) +','+' 999'
this.retrieve(1,ls_paramtro)

return 1
end event

type dw_menu_perfil from uo_dwbase within w_aplicacion_perfil_menu
boolean visible = false
integer x = 1531
integer y = 344
integer width = 2359
integer height = 708
integer taborder = 40
boolean bringtotop = true
boolean titlebar = true
string title = "menusito"
string dataobject = "dw_menuperfil_mant"
boolean hscrollbar = true
boolean resizable = true
boolean ib_editar = false
boolean ib_activarfiltros = false
boolean ib_resaltarfila = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_aplicacion_perfil_menu
integer x = 69
integer y = 136
integer taborder = 40
boolean bringtotop = true
string is_nombreserverfiltro = "0"
end type

event itemchanged;call super::itemchanged;Integer				li_null
Integer				li_ret
Datawindowchild	ldc_aplicacion

setnull(li_null)
ii_idservidor	=	ii_idservidorfiltro

dw_principal.reset()
dw_menu_add.reset()
if 	dw_aplicacion.GetChild('idaplicacion',ldc_aplicacion)>0 then
	ldc_aplicacion.reset( )
	dw_aplicacion.setitem(dw_aplicacion.getrow(),'idaplicacion',li_null)
End if
//Administrar solo los servidores LinKed o el servidor con conexion
if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible...verifique', '', 3)
	Return -2
Else
	dw_aplicacion.event ue_poblardddw('idaplicacion')
End if


	











end event

type st_ultimas from statictext within w_aplicacion_perfil_menu
integer x = 3323
integer y = 188
integer width = 1541
integer height = 68
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
long backcolor = 134217738
string text = "Últimas opciones agregadas"
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
end type

