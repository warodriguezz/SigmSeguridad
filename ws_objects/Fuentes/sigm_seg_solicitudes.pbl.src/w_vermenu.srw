$PBExportHeader$w_vermenu.srw
forward
global type w_vermenu from window
end type
type uo_salir from uo_boton within w_vermenu
end type
type dw_menu_perfil from uo_dwbase within w_vermenu
end type
type tv_perfilmenu from treeview within w_vermenu
end type
end forward

global type w_vermenu from window
integer width = 1577
integer height = 1924
boolean titlebar = true
string title = "Menú"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
event ue_rellenar_treeview ( )
uo_salir uo_salir
dw_menu_perfil dw_menu_perfil
tv_perfilmenu tv_perfilmenu
end type
global w_vermenu w_vermenu

type variables
Integer	ii_IdAplicacion
Integer	il_Idperfil

uo_dsbase	ids_Menus

str_response		istr_parametros	

end variables

event ue_rellenar_treeview();Integer 	liFila
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
ls_parametros	=	String(gi_idservidor) + "," + String(ii_IdAplicacion)+","+String(il_Idperfil) 
liNumFil	=	dw_menu_perfil.retrieve(ls_parametros)

if liNumFil<1 then Return 


//Cargar DS para visualizar menu
ids_Menus = CREATE uo_dsbase
ids_Menus.dataobject = 'dw_menu_perfil'
ids_Menus.SetTransObject(SQLCA)
ids_Menus.Reset()
liNumFil	=	ids_Menus.retrieve(ls_parametros)
 
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

on w_vermenu.create
this.uo_salir=create uo_salir
this.dw_menu_perfil=create dw_menu_perfil
this.tv_perfilmenu=create tv_perfilmenu
this.Control[]={this.uo_salir,&
this.dw_menu_perfil,&
this.tv_perfilmenu}
end on

on w_vermenu.destroy
destroy(this.uo_salir)
destroy(this.dw_menu_perfil)
destroy(this.tv_perfilmenu)
end on

event open;istr_parametros = message.powerobjectparm

ii_IdAplicacion = istr_parametros.str_argumentos.i[1]
il_Idperfil = istr_parametros.str_argumentos.i[2]

this.event ue_rellenar_treeview( )


end event

event resize;this.height = 2500
tv_perfilmenu.height = 2200

uo_salir.y = tv_perfilmenu.y + tv_perfilmenu.height + 20
uo_salir.x = tv_perfilmenu.x + tv_perfilmenu.width - uo_salir.width
end event

type uo_salir from uo_boton within w_vermenu
integer x = 864
integer y = 1664
integer width = 686
integer taborder = 30
string is_texto = "Salir"
end type

on uo_salir.destroy
call uo_boton::destroy
end on

event ue_clicked;call super::ue_clicked;close(parent)
end event

type dw_menu_perfil from uo_dwbase within w_vermenu
boolean visible = false
integer x = 416
integer y = 464
integer width = 695
integer height = 372
integer taborder = 20
string dataobject = "dw_menuperfil_mant"
boolean ib_editar = false
boolean ib_activarfiltros = false
boolean ib_resaltarfila = false
boolean ib_menupopup = false
boolean ib_activareventoeditaraleliminarregistro = false
end type

type tv_perfilmenu from treeview within w_vermenu
integer y = 32
integer width = 1545
integer height = 1200
integer taborder = 10
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
string picturename[] = {"menu!","menu5!","dosedit5!","dosedit!"}
long picturemaskcolor = 15793151
long statepicturemaskcolor = 536870912
end type

event clicked;return 2
end event

