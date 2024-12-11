$PBExportHeader$w_importar_menus_excel.srw
forward
global type w_importar_menus_excel from w_response_mtto
end type
type cb_buscar from uo_boton within w_importar_menus_excel
end type
type st_ruta from statictext within w_importar_menus_excel
end type
type uo_leyenda from uo_leyenda_color within w_importar_menus_excel
end type
type st_1 from statictext within w_importar_menus_excel
end type
type st_nombreaplicacion from statictext within w_importar_menus_excel
end type
type cb_desactivar from uo_boton within w_importar_menus_excel
end type
type uo_nv_dwmenu_in from uo_dsbase within w_importar_menus_excel
end type
type uo_nv_dwmenu from uo_dsbase within w_importar_menus_excel
end type
end forward

global type w_importar_menus_excel from w_response_mtto
integer width = 4137
integer height = 2052
string title = "Importaciones Menu"
cb_buscar cb_buscar
st_ruta st_ruta
uo_leyenda uo_leyenda
st_1 st_1
st_nombreaplicacion st_nombreaplicacion
cb_desactivar cb_desactivar
uo_nv_dwmenu_in uo_nv_dwmenu_in
uo_nv_dwmenu uo_nv_dwmenu
end type
global w_importar_menus_excel w_importar_menus_excel

type variables
Integer		ii_idservidor	
Integer 		ii_IdAplicacion 
Integer 		il_IdMenu
String 		is_nombreObjeto 
String 		is_nombreArchivo
String 		is_menuAplicacion
String 		is_nombrePBL
String			is_NombreAplicacion
//
Integer iiNivel 
Integer iiIDPadre
Integer iiIDMenu
Integer iiSecuencia

//
String is_PathFileName
String is_FileName

Integer ii_newUpd = 0







 

 
end variables

forward prototypes
public function integer uf_comparamenus ()
public function integer uf_menudelete ()
public function integer uf_cargar_validar_excel ()
end prototypes

public function integer uf_comparamenus ();Long		ll_filaClass 
Long 		ll_rowClass 
Long 		ll_rowDB
Long	 	ll_found
Long	 	ll_rowCount
Long       ll_delete
String  	ls_NombreMenu
String ls_nombreExcel
String ls_descripcionmenu
String ls_tagExcel
String ls_tag


ii_newUpd = 0
ll_rowClass  =   dw_principal.RowCount() 
ll_rowDB      =   uo_nv_dwmenu.RowCount() 


if ll_rowDB  <= 0   then 
	
	For ll_filaClass =  1 to ll_rowClass
			
			dw_principal.setitem( ll_filaClass,'tiporesgistro','A')
			
			uo_nv_dwmenu_in.InsertRow(0)
			uo_nv_dwmenu_in.SetItem(ll_filaClass,	'IdAplicacion',ii_IdAplicacion)			
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'IdMenuObjeto',dw_principal.getitemnumber(ll_filaClass,'id_menu'))
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'IdMenuObjetoPadre',dw_principal.getitemnumber(ll_filaClass,'id_menu_padre'))
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'Secuencia',dw_principal.getitemnumber(ll_filaClass,'secuencia'))
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'Nivel',dw_principal.getitemnumber(ll_filaClass,'nivel'))
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'DescripcionMenu',dw_principal.getitemstring(ll_filaClass,'nombre'))
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'NombreMenu',dw_principal.getitemstring(ll_filaClass,'menu'))		
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'Tag',dw_principal.getitemstring(ll_filaClass,'tag'))
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'RegistroActivo',1)
			uo_nv_dwmenu_in.SetItem(ll_filaClass,'idServidor',ii_idservidor)
			uo_nv_dwmenu_in.SetItemStatus(ll_found, 0, Primary!, new!)
			ii_newUpd ++
	next 	

elseif ll_rowDB  > 0   then
	
	
	for ll_filaClass =  1 to  ll_rowClass 
		
		ls_NombreMenu =   dw_principal.getitemstring(ll_filaClass,'menu')		
		ll_found =  0		
		ll_found = uo_nv_dwmenu.find("NombreMenu='"+ls_NombreMenu+"'",1,uo_nv_dwmenu.RowCount())
		 // es nuevo Registro
		If isnull(ll_found) or ll_found =  0 then
			ii_newUpd ++
			
			dw_principal.setitem( ll_filaClass,'tiporesgistro','A')
			uo_nv_dwmenu_in.InsertRow(0)
			ll_rowCount  = 	 	uo_nv_dwmenu_in.rowcount()
			
			//Messagebox('fghgfh',dw_principal.getitemnumber(ll_filaClass,'id_menu'))			
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'IdAplicacion',ii_IdAplicacion)		
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'IdMenuObjeto',dw_principal.getitemnumber(ll_filaClass,'id_menu'))
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'IdMenuObjetoPadre',dw_principal.getitemnumber(ll_filaClass,'id_menu_padre'))
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'Secuencia',dw_principal.getitemnumber(ll_filaClass,'secuencia'))
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'Nivel',dw_principal.getitemnumber(ll_filaClass,'nivel'))
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'DescripcionMenu',dw_principal.getitemstring(ll_filaClass,'nombre'))
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'NombreMenu',dw_principal.getitemstring(ll_filaClass,'menu'))		
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'Tag',dw_principal.getitemstring(ll_filaClass,'tag'))
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'RegistroActivo',1)	
			uo_nv_dwmenu_in.SetItem(ll_rowCount,'idServidor',ii_idservidor)
			uo_nv_dwmenu_in.SetItemStatus(ll_found, 0, Primary!, new!)
		end if 
		
		//Verifica si  se ha modificado  descripcion y tag 
		If ll_found >  0 then
			
				ls_nombreExcel = dw_principal.getitemstring(ll_filaClass,'nombre')
				ls_descripcionmenu = uo_nv_dwmenu.getitemString(ll_found,'descripcionmenu')
				ls_tagExcel = dw_principal.getitemstring(ll_filaClass,'tag')
				ls_tag = uo_nv_dwmenu.getitemString(ll_found,'tag')
			
				dw_principal.setitem( ll_filaClass,'tiporesgistro','O')			
			
			 If trim(ls_nombreExcel)<> Trim(ls_descripcionmenu) then  
				dw_principal.setitem( ll_filaClass,'tiporesgistro','M')
				ii_newUpd ++
				// Messagebox('',ls_nombreExcel +'~r'+ls_descripcionmenu)
			end if 
			 If len(trim(ls_nombreExcel)) >  0 and isnull(ls_descripcionmenu) then
				dw_principal.setitem( ll_filaClass,'tiporesgistro','M')					
				ii_newUpd ++
				// Messagebox('',ls_nombreExcel +'~r'+ls_descripcionmenu)
			end if 						
			  			
			if trim(ls_tagExcel)	 <> 	trim(ls_tag) then 
				dw_principal.setitem( ll_filaClass,'tiporesgistro','M')	
				ii_newUpd ++
				//Messagebox('',ls_tagExcel +'~r'+ls_tag)	
			end if
			If  len( trim(ls_tagExcel)) > 0 and Isnull(ls_tag)  then
				dw_principal.setitem( ll_filaClass,'tiporesgistro','M') 
				ii_newUpd ++
			end if			
		end if 	
	next	
	// Eliminar
	ll_delete =  uf_menudelete()
	ii_newUpd = ii_newUpd + ll_delete
	
end if 


if ii_newUpd = 0 then return 0



return 1
end function

public function integer uf_menudelete ();Long  	ll_rowClass
Long  	ll_rownenudb
Long  	ll_row
String ls_NombreMenu
Long   ll_found
long   ll_rowprin
Long ll_rowcount =  0
	   
	ll_rowClass = dw_principal.rowcount()
	ll_rownenudb =  uo_nv_dwmenu.rowCount()
	
	for ll_row =  1 to  ll_rownenudb 
			
	 		 ls_NombreMenu =   uo_nv_dwmenu.getitemstring(ll_row,'nombremenu')	
			  ll_found =  0
			  ll_found = dw_principal.find("menu='"+ls_NombreMenu+"'",1,dw_principal.RowCount())
			  
			  if isnull(ll_found) or ll_found = 0 then
				
				dw_principal.insertRow(0)				
				ll_rowprin =dw_principal.rowcount()  
				dw_principal.SetItem(ll_rowprin,'id_menu',uo_nv_dwmenu.getitemnumber(ll_row,'IdMenuObjeto'))	
				dw_principal.SetItem(ll_rowprin,'id_menu_padre',uo_nv_dwmenu.getitemnumber(ll_row,'IdMenuObjetoPadre'))
				dw_principal.SetItem(ll_rowprin,'secuencia',uo_nv_dwmenu.getitemnumber(ll_row,'secuencia'))	
				dw_principal.SetItem(ll_rowprin,'nivel',uo_nv_dwmenu.getitemnumber(ll_row,'nivel'))	
				dw_principal.setitem(ll_rowprin,'nombre',uo_nv_dwmenu.getitemstring(ll_row,'DescripcionMenu'))
				dw_principal.setitem(ll_rowprin,'menu',uo_nv_dwmenu.getitemstring(ll_row,'nombremenu'))
				dw_principal.setitem(ll_rowprin,'tag',uo_nv_dwmenu.getitemstring(ll_row,'tag'))
				dw_principal.setitem(ll_rowprin,'tiporesgistro','Q')
				ll_rowcount = ll_rowcount + 1 
								
			
			  end if 
		next 
return  ll_rowcount


end function

public function integer uf_cargar_validar_excel ();Integer li_ret
Long ll_rc
String ls_err
String ls_err_celdas
String ls_nombreMenu
OLEObject loo_excel

If GetFileOpenName("Elija el nombre del archivo Excel", is_PathFileName, is_FileName, "XLS", "Archivo Excel (*.xls),*.xls") < 1 Then return -1 

ls_nombreMenu  = left(is_FileName,Pos(is_FileName,".")-1)
If is_menuAplicacion <> ls_nombreMenu Then
	gf_mensaje(gs_Aplicacion, 'El nombre del archivo es diferente al nombre del menú', '', 1)
	return -1
end if

if isnull(is_PathFileName)  or trim(is_PathFileName) =''  then 
	gf_mensaje(gs_Aplicacion, 'Ruta NO válida', '', 1)
	return -1
End if

SetPointer( HourGlass! )

loo_excel = CREATE OLEObject
li_ret = loo_excel.ConnectToObject("excel.application")

if li_ret <> 0 then
	li_ret = loo_excel.ConnectToNewObject("excel.application")
end if

Choose Case li_ret
		case 0
				ls_err='Conexión Satisfactoria con OLE (Excel)'
		case -1
				ls_err='Error. Llamada Inválida a objeto OLE (Excel)'
		case -2
				ls_err='Error. Nombre de la clase no encontrada con OLE (Excel)'
		case -3
				ls_err='Error. El objeto OLEObject no puede ser creado (Excel)'
		case -4
				ls_err='Error. No se puede conectar con el objeto (EXCEL)'
		case -5
				ls_err='Error no tratado (EXCEL)'
		case else
				ls_err='Error desconocido: '+string(li_ret)+'(EXCEL)'
End Choose

if li_ret < 0 Then
	gf_mensaje(gs_Aplicacion, ls_err, '', 1)
	return -1
end if 


if li_ret <> 0 then// Se desconecta el objeto OLE y se destruye
		clipboard('')
		loo_excel.workbooks.close()
		loo_excel.Application.Quit
		loo_excel.disconnectobject()
	DESTROY loo_excel
	return -1
	
end if

//
loo_excel.workbooks.open( is_PathFileName )

loo_excel.visible = false

loo_excel.ActiveCell.CurrentRegion.Select()

loo_excel.Application.DisplayAlerts = False

loo_excel.Selection.Copy()
ll_rc = dw_principal.ImportClipBoard (2)

Choose Case ll_rc
		case -1
				ls_err_celdas ='No hay filas o el valor de la fila inicial es mayor que el número de filas en la cadena..!!'
		case -3
				ls_err_celdas ='Error. Argumento Inválido..!!'
		case -4
				ls_err_celdas ='Error. Entrada Inválida..!!'
		case -13
				ls_err_celdas ='Error. Datawindows no soporta importación de datos..!!'
		case -14
				ls_err_celdas ='Error. Al resolver Datawindows anidado..!!'
End Choose


if ll_rc < 0 then	// Se desconecta el objeto OLE y se destruye
		clipboard('')
		loo_excel.workbooks.close()
		
		loo_excel.Application.DisplayAlerts = True
		loo_excel.Application.Quit
		loo_excel.disconnectobject()
		
		DESTROY loo_excel
	
		gf_mensaje(gs_Aplicacion, ls_err_celdas, '', 1)
	
		return -1 
end if




clipboard('')
loo_excel.workbooks.close()
loo_excel.Application.Quit
loo_excel.disconnectobject()

DESTROY loo_excel

Return 1
end function

on w_importar_menus_excel.create
int iCurrent
call super::create
this.cb_buscar=create cb_buscar
this.st_ruta=create st_ruta
this.uo_leyenda=create uo_leyenda
this.st_1=create st_1
this.st_nombreaplicacion=create st_nombreaplicacion
this.cb_desactivar=create cb_desactivar
this.uo_nv_dwmenu_in=create uo_nv_dwmenu_in
this.uo_nv_dwmenu=create uo_nv_dwmenu
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_buscar
this.Control[iCurrent+2]=this.st_ruta
this.Control[iCurrent+3]=this.uo_leyenda
this.Control[iCurrent+4]=this.st_1
this.Control[iCurrent+5]=this.st_nombreaplicacion
this.Control[iCurrent+6]=this.cb_desactivar
end on

on w_importar_menus_excel.destroy
call super::destroy
destroy(this.cb_buscar)
destroy(this.st_ruta)
destroy(this.uo_leyenda)
destroy(this.st_1)
destroy(this.st_nombreaplicacion)
destroy(this.cb_desactivar)
destroy(this.uo_nv_dwmenu_in)
destroy(this.uo_nv_dwmenu)
end on

event open;call super::open;uo_leyenda.Visible = false 

str_arg		lstr_Recep
lstr_Recep = istr_parametros.str_argumentos
  

ii_idservidor				=  lstr_Recep.i[1]
ii_IdAplicacion 			=  lstr_Recep.i[2]

is_nombreObjeto  		=  lstr_Recep.s[1] 
is_menuAplicacion		=  lstr_Recep.s[2] 
is_NombreAplicacion	=  lstr_Recep.s[3] 

st_nombreaplicacion.text = is_NombreAplicacion

uo_nv_dwmenu.Event ue_retrieve()
cb_aceptar.Enabled = false 


return 1
end event

event resize;call super::resize;dw_principal.y = BordeHorizontal + st_nombreaplicacion.y + st_nombreaplicacion.height
dw_principal.x = BordeVertical
dw_principal.width = newwidth - ( BordeVertical * 2 )
dw_principal.height = newheight - st_nombreaplicacion.y - BordeHorizontal


dw_principal.y = BordeHorizontal + st_ruta.y + st_ruta.height
dw_principal.x = BordeVertical
dw_principal.width = newwidth - ( BordeVertical * 2 )
dw_principal.height = newheight - (st_ruta.y  * 3) - BordeHorizontal 

cb_buscar.y	=	st_nombreaplicacion.y + BordeHorizontal
uo_leyenda.y	=	dw_principal.y + dw_principal.height + BordeHorizontal



end event

type p_cbcancelar from w_response_mtto`p_cbcancelar within w_importar_menus_excel
end type

type p_cbaceptar from w_response_mtto`p_cbaceptar within w_importar_menus_excel
end type

type cbx_filtros from w_response_mtto`cbx_filtros within w_importar_menus_excel
integer x = 3534
integer y = 1824
end type

type dw_principal from w_response_mtto`dw_principal within w_importar_menus_excel
integer x = 37
integer y = 224
integer width = 4041
integer height = 1544
string dataobject = "dw_menuitems"
end type

event dw_principal::retrieverow;call super::retrieverow;this.accepttext( )
Long ll_IdMenu
Long ll_IdMenuPadre
ll_IdMenu =  this.getitemnumber(row,'id_menu') 
ll_IdMenuPadre = this.getitemnumber(row, 'id_menu_padre')

this.SetItem(row,'id_menu' ,ll_IdMenu +10000)
If ll_IdMenuPadre <> 0 then this.SetItem(row,'id_menu_padre' ,ll_IdMenuPadre + 10000)

end event

event dw_principal::ue_validar;call super::ue_validar;Long ll_row 
Long ll_rowH
Long ll_id_menu
String ls_nombreMenuP
String ls_nombreMenuH
Long ll_cout =  0

uo_dsbase lds_Menus 

lds_Menus = CREATE uo_dsbase
lds_Menus.dataobject = 'dw_menuitems'
lds_Menus.SetTransObject(SQLCA)
lds_Menus.Reset()

this.RowsCopy(this.GetRow(), this.RowCount(), Primary!, lds_Menus, 1, Primary!)

for ll_row =  1 to this.rowcount()
	
	if  this.getitemnumber(ll_row,'id_menu_padre') = 0 then 
		
		ll_id_menu =  this.getitemnumber(ll_row,'id_menu')	
		ls_nombreMenuP =  this.getitemstring(ll_row,'nombre')	 
		
		lds_Menus.SetFilter( "id_menu_padre ="+string(ll_id_menu) ) 
		lds_Menus.Filter()	
		
		 for  ll_rowH = 1 to  lds_Menus.rowcount()
			ls_nombreMenuH =  lds_Menus.getitemstring(ll_rowH,'nombre')	
				if (isnull(ls_nombreMenuP) or  ls_nombreMenuP = "") and len(ls_nombreMenuH) > 0 then ll_cout = ll_cout + 1
				
		 next 
				lds_Menus.SetFilter("")  
				lds_Menus.Filter()
	end if 

next 

if ll_cout > 0 then 	
	gf_mensaje(gs_Aplicacion, 'Existe  menu Ancestros sin nombre', '', 1)
	return  -1
end if 

return 1
end event

type cb_cancelar from w_response_mtto`cb_cancelar within w_importar_menus_excel
integer x = 2665
integer y = 1820
end type

event cb_cancelar::clicked;Double	ll_ret=0
CloseWithReturn(parent,ll_ret)
end event

type cb_aceptar from w_response_mtto`cb_aceptar within w_importar_menus_excel
integer x = 2181
integer y = 1820
end type

event cb_aceptar::clicked;call super::clicked; if dw_principal.RowCount() = 0 then 
	 CloseWithReturn(parent,0)
else
	if  dw_principal.event ue_validar()  =  -1 then CloseWithReturn(parent,-1)
	if uo_nv_dwmenu_in.Event ue_grabar_pre() = -1 then   CloseWithReturn(parent,-1)
	if uo_nv_dwmenu.Event ue_grabar_pre()= -1 then   CloseWithReturn(parent,-1)
End if
CloseWithReturn(parent,1)
			
			
//actualizar existentes
//cb_aceptar.Enabled = false 
//


end event

type st_mensaje from w_response_mtto`st_mensaje within w_importar_menus_excel
end type

type cb_buscar from uo_boton within w_importar_menus_excel
integer x = 1783
integer y = 76
integer width = 681
integer height = 124
integer taborder = 20
boolean bringtotop = true
string is_imagen = "Img\Icono\buscar.png"
string is_texto = "Seleccionar Archivo"
end type

on cb_buscar.destroy
call uo_boton::destroy
end on

event ue_clicked;call super::ue_clicked;String					ls_pathactual
Integer				li_ret
ls_pathactual	=	GetCurrentDirectory()
dw_principal.Reset()

li_ret= uf_cargar_validar_excel() 
Changedirectory(ls_pathactual)

if li_ret=-1 then Return -1

st_ruta.text = is_PathFileName

if dw_principal.Rowcount() > 0 then uo_leyenda.Visible = true 
If  uf_comparamenus() = 1 then cb_Aceptar.enabled = true 

return 1

end event

type st_ruta from statictext within w_importar_menus_excel
integer x = 37
integer y = 132
integer width = 1691
integer height = 76
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean border = true
boolean focusrectangle = false
end type

type uo_leyenda from uo_leyenda_color within w_importar_menus_excel
integer x = 50
integer y = 1792
integer width = 1371
integer height = 140
integer taborder = 20
boolean bringtotop = true
end type

on uo_leyenda.destroy
call uo_leyenda_color::destroy
end on

type st_1 from statictext within w_importar_menus_excel
integer x = 50
integer y = 44
integer width = 311
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388608
long backcolor = 67108864
string text = "Aplicación:"
boolean focusrectangle = false
end type

type st_nombreaplicacion from statictext within w_importar_menus_excel
integer x = 357
integer y = 40
integer width = 1056
integer height = 64
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 134217731
boolean border = true
long bordercolor = 10789024
boolean focusrectangle = false
end type

type cb_desactivar from uo_boton within w_importar_menus_excel
integer x = 2551
integer y = 80
integer width = 681
integer height = 124
integer taborder = 30
boolean bringtotop = true
string is_imagen = "Img\Icono\quitar.png"
string is_texto = "Desactivar opciones de menu"
end type

event ue_clicked;call super::ue_clicked;//	1.1		Walther Rodriguez		10/07/2024			No se usa IDSERVIDOR
Integer 	li_rpta
String		ls_parametros
String		ls_retorno
String		ls_ret

li_rpta=gf_mensaje(gs_Aplicacion, 'Este proceso inhabilitará TODAS las opciones del menú de la aplicación...deberá cargar un menú completo...Continuar?' , '', 4)	

if li_rpta<>1 then Return

//ls_Parametros = String(ii_IdAplicacion)+","+String( ii_idservidor) 
ls_Parametros = String(ii_IdAplicacion)		//1.1
ls_retorno		= Trim( gf_objetobd_ejecutar(sqlca, "Seguridad.usp_Menu_Deshabilitar_Opciones", ls_parametros ) )
If Left( ls_retorno,3 ) = 'SQL' then
	ls_ret=mid(ls_retorno,5,10)
	If Integer(ls_ret)<>100 then
		gf_mensaje(gs_aplicacion, "Error al deshabilitar opciones del menu", "", 2 )
		Return 
	end if
End if

gf_mensaje(gs_aplicacion, "Proceso ejecutado", ls_retorno, 1 )
end event

on cb_desactivar.destroy
call uo_boton::destroy
end on

type uo_nv_dwmenu_in from uo_dsbase within w_importar_menus_excel descriptor "pb_nvo" = "true" 
event type integer ue_actualiza_exist ( )
string dataobject = "dw_menu"
boolean ib_actualizar = true
end type

on uo_nv_dwmenu_in.create
call super::create
end on

on uo_nv_dwmenu_in.destroy
call super::destroy
end on

event ue_grabar;call super::ue_grabar;this.accepttext( )


if this.update() = 1 then 
	Commit ;
	return 1
else
	Rollback ;
	gf_mensaje(gs_Aplicacion, 'Error Al registrar los nuevos registros.', '', 1)	
	return  -1
end if 

end event

event ue_grabar_pre;call super::ue_grabar_pre;String	ls_Tabla
String	ls_ValoresPK
Long	ll_Id = 0
Long	ll_row 
String	ls_servidor

ls_servidor	= String(sqlca.servername)

 for ll_row = 1 to  this.rowcount( )

		if  Isnull(ll_Id) Or ll_Id =  0 Then   
			ls_Tabla = 'Seguridad.Menu'   
			ls_ValoresPK= string(ii_IdAplicacion)+":"
			/* Generar el ID */
			Integer	li_ValorRetorno	
			li_ValorRetorno = sqlca.usp_generarid(0,  ls_Tabla, ls_ValoresPK, ll_Id )	
		
			If	IsNull( ll_Id ) OR ll_Id = 0 Then
				Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
				Return -1
			End If  
		
		Else 
			ll_Id = ll_Id +1
		End if 
		
		  il_IdMenu	= ll_Id	 
		  
		 This.SetItem( ll_row,'idmenu', il_IdMenu )

Next 

this.event ue_grabar()
 
return  1
end event

type uo_nv_dwmenu from uo_dsbase within w_importar_menus_excel descriptor "pb_nvo" = "true" 
event type integer ue_actualizarexist ( )
event type integer ue_retrieve ( )
string dataobject = "dw_menu"
boolean ib_actualizar = true
end type

event type integer ue_retrieve(); this.reset()
 retrieve(ii_IdAplicacion,ii_idservidor) 
return  1
end event

on uo_nv_dwmenu.create
call super::create
end on

on uo_nv_dwmenu.destroy
call super::destroy
end on

event ue_grabar_pre;call super::ue_grabar_pre;Long		ll_filaClass
Long		ll_filaDb
Long 		ll_rowClass 
Long 		ll_rowDB
Long	 	ll_found
String  	ls_NombreMenu
String      ls_tiporegistro 

uo_nv_dwmenu.reset()
uo_nv_dwmenu.retrieve(ii_IdAplicacion,ii_idservidor)

ll_rowClass  =   dw_principal.RowCount() 
ll_rowDB      =   uo_nv_dwmenu.RowCount() 
	
	
	if ll_rowDB  > 0   and  ll_rowClass > 0 then
	
		for ll_filaClass =  1 to  ll_rowClass 			
			ls_NombreMenu =   dw_principal.getitemstring(ll_filaClass,'menu')	
			ls_tiporegistro   = dw_principal.getitemstring( ll_filaClass,'tiporesgistro')
			
			ll_found =  0		
			ll_found = uo_nv_dwmenu.find("NombreMenu='"+ls_NombreMenu+"'",1,uo_nv_dwmenu.RowCount())	
			
				If  ll_found >  0 then					
					
					uo_nv_dwmenu.SetItem(ll_found,'IdMenuObjeto',dw_principal.getitemnumber(ll_filaClass,'id_menu'))
					uo_nv_dwmenu.SetItem(ll_found,'IdMenuObjetoPadre',dw_principal.getitemnumber(ll_filaClass,'id_menu_padre'))
					uo_nv_dwmenu.SetItem(ll_found,'Secuencia',dw_principal.getitemnumber(ll_filaClass,'secuencia'))
					uo_nv_dwmenu.SetItem(ll_found,'Nivel',dw_principal.getitemnumber(ll_filaClass,'nivel'))			
					uo_nv_dwmenu.SetItem(ll_found,'NombreMenu',dw_principal.getitemstring(ll_filaClass,'menu'))	
					uo_nv_dwmenu.SetItem(ll_found,'DescripcionMenu',dw_principal.getitemstring(ll_filaClass,'nombre'))
					uo_nv_dwmenu.SetItem(ll_found,'Tag',dw_principal.getitemstring(ll_filaClass,'tag'))					
					uo_nv_dwmenu.SetItem(ll_found,'RegistroActivo',1)
					uo_nv_dwmenu.SetItem(ll_found,'idServidor',ii_idservidor)
					if ls_tiporegistro = 'Q' then uo_nv_dwmenu.SetItem(ll_found,'RegistroActivo',0)
					//forzar para actualizar
				     uo_nv_dwmenu.SetItemStatus(ll_found, 0, Primary!, DataModified!)					
				end if			
		next	
	
	end if 
	
	This.event ue_grabar()


return 1
end event

event ue_grabar;call super::ue_grabar;uo_nv_dwmenu.accepttext( )

if uo_nv_dwmenu.update() = 1 then 
	Commit ;
		gf_mensaje(gs_Aplicacion, 'Proceso realizado con éxito.', '', 1)	
	return 1
else
	Rollback ;
		gf_mensaje(gs_Aplicacion, 'Error Al registrar los nuevos registros.', '', 1)	
	return  -1
end if 

end event

