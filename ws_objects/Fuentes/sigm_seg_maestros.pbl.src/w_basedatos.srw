$PBExportHeader$w_basedatos.srw
$PBExportComments$emalcap
forward
global type w_basedatos from w_base
end type
type uo_btnactualizar from uo_boton within w_basedatos
end type
type dw_esquemasbd from uo_dwbase within w_basedatos
end type
type dw_rolbd from uo_dwbase within w_basedatos
end type
type uo_leyenda from uo_leyenda_color within w_basedatos
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_basedatos
end type
type dw_esquemaroldb from uo_dwbase within w_basedatos
end type
type st_opcion from statictext within w_basedatos
end type
end forward

global type w_basedatos from w_base
integer width = 6181
integer height = 2424
uo_btnactualizar uo_btnactualizar
dw_esquemasbd dw_esquemasbd
dw_rolbd dw_rolbd
uo_leyenda uo_leyenda
dw_filtro_servidor dw_filtro_servidor
dw_esquemaroldb dw_esquemaroldb
st_opcion st_opcion
end type
global w_basedatos w_basedatos

type variables
Integer 	ii_IdServidor 
Integer	ii_IdBaseDatos
Long		il_idmaxbd=0
Long		il_idmaxesquema=0
Long		il_idmaxrol=0
String		is_FilasSeleccionadas 

Integer 	il_Fila 

Integer  ii_idEsquema



end variables

on w_basedatos.create
int iCurrent
call super::create
this.uo_btnactualizar=create uo_btnactualizar
this.dw_esquemasbd=create dw_esquemasbd
this.dw_rolbd=create dw_rolbd
this.uo_leyenda=create uo_leyenda
this.dw_filtro_servidor=create dw_filtro_servidor
this.dw_esquemaroldb=create dw_esquemaroldb
this.st_opcion=create st_opcion
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.uo_btnactualizar
this.Control[iCurrent+2]=this.dw_esquemasbd
this.Control[iCurrent+3]=this.dw_rolbd
this.Control[iCurrent+4]=this.uo_leyenda
this.Control[iCurrent+5]=this.dw_filtro_servidor
this.Control[iCurrent+6]=this.dw_esquemaroldb
this.Control[iCurrent+7]=this.st_opcion
end on

on w_basedatos.destroy
call super::destroy
destroy(this.uo_btnactualizar)
destroy(this.dw_esquemasbd)
destroy(this.dw_rolbd)
destroy(this.uo_leyenda)
destroy(this.dw_filtro_servidor)
destroy(this.dw_esquemaroldb)
destroy(this.st_opcion)
end on

event resize;call super::resize;If	ib_MostrarTitulo = True Then il_AlturaTitulo = st_fondo.height + BordeHorizontal

dw_filtro_servidor.y				= BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x 				= BordeVertical

dw_principal.x 				= BordeVertical
dw_principal.y 				= BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
dw_principal.width 		=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 2.5)
dw_principal.height 		=  (newheight - ( (dw_filtro_servidor.y + 1 * BordeHorizontal ) + il_AlturaTitulo))

dw_esquemasbd.x			= dw_principal.x + dw_principal.width + BordeHorizontal
dw_esquemasbd.y			= dw_principal.y
dw_esquemasbd.width 	=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 3 )
dw_esquemasbd.height 	= (newheight -  (  dw_principal.y - 10  * BordeHorizontal)  )  / 2

dw_rolbd.x					= dw_esquemasbd.x	 + dw_esquemasbd.width + BordeHorizontal
dw_rolbd.y					= dw_esquemasbd.y	
dw_rolbd.width 			=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 3.8 )
dw_rolbd.height 			= dw_esquemasbd.height

st_opcion.y  							=  dw_esquemasbd.y + (dw_esquemasbd.height) + BordeHorizontal
st_opcion.x  							=  dw_esquemasbd.x	
st_opcion.width							= ((st_fondo.width  - (1 * BordeHorizontal) ) / 1 )

dw_esquemaroldb.y					=	st_opcion.y + st_opcion.height
dw_esquemaroldb.x					=	st_opcion.x

dw_esquemaroldb.width				=	 ((st_fondo.width  - (1 * BordeHorizontal) ) / 3 )        

dw_esquemaroldb.height 			=  (newheight -     st_opcion.y  ) - (BordeHorizontal * 2.5)

uo_btnactualizar.y	=	dw_filtro_servidor.y - BordeHorizontal
uo_btnactualizar.x=	dw_filtro_servidor.x + dw_filtro_servidor.Width + BordeHorizontal

uo_leyenda.y		=	dw_filtro_servidor.y - BordeHorizontal	
uo_leyenda.x		=	dw_esquemasbd.x



end event

event ue_nuevo_pre;call super::ue_nuevo_pre;gf_Mensaje(gs_aplicacion,"No se pudo crear nuevo registro, utilice [Obtener BD] ","",1)
Return -1
end event

event ue_grabar_post;call super::ue_grabar_post;dw_principal.event rowfocuschanged(il_Fila)
return 1

end event

type st_titulo from w_base`st_titulo within w_basedatos
string tag = "Base de Datos"
string text = "Base de Datos"
end type

type st_fondo from w_base`st_fondo within w_basedatos
end type

type dw_principal from w_base`dw_principal within w_basedatos
integer x = 69
integer y = 392
integer width = 2647
integer height = 1868
string dataobject = "dw_basedatos"
boolean controlmenu = true
boolean hscrollbar = true
boolean resizable = true
boolean ib_menuexportar = true
boolean ib_menufiltrar = true
boolean ib_activareventoeditaraleliminarregistro = false
boolean ib_menuedicionvisible = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;// 1.1		03/12/2024		Se omite el uso de IDSERVIDOR
if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

dw_esquemasbd.reset()
dw_rolbd.reset()

return retrieve(3,'')
//return retrieve()
end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post; Long			ll_idbasedatos=0
 String		ls_tabla
 String		ls_ValoresPK
 Integer		li_valorRetorno
 Long			ll_id=0
 Integer		li_idservidor 
 
 if  String(il_idmaxbd)='null'or il_idmaxbd=0 or IsNull(il_idmaxbd)  then
	ls_Tabla 		= 'Maestros.BaseDatos'
	ls_ValoresPK= ""
	li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro
	
	/* Generar el ID */
	li_ValorRetorno = sqlca.usp_generarid(li_idservidor, ls_Tabla, ls_ValoresPK, ll_id )	
	il_idmaxbd		=	ll_id
	If	il_idmaxbd = 0 or IsNull( il_idmaxbd ) Then
		Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
		Return  
	End If	
Else
	il_idmaxbd	=	il_idmaxbd +1
End if

ii_IdBaseDatos	=	il_idmaxbd

This.Setitem(ai_row,'idservidor',ii_idservidor)
This.Setitem(ai_row,'idbasedatos',ii_IdBaseDatos)
This.accepttext( )
 
end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;if currentrow>0  and this.rowcount( ) > 0 then

		ii_idbasedatos	=	this.getitemnumber(currentrow,'idbasedatos')
		If isnull(ii_idbasedatos) then ii_idbasedatos = 0
		dw_esquemasbd.triggerevent("ue_retrieve")	
		dw_rolbd.triggerevent("ue_retrieve")
		
		dw_esquemaroldb.reset( )
//		dw_esquemasbd.event rowfocuschanged(dw_esquemasbd.getrow())
		
		il_Fila  =  currentrow

		parent.ib_Editando = False
		parent.event ue_editar( )

End if



end event

type st_menuruta from w_base`st_menuruta within w_basedatos
end type

type uo_btnactualizar from uo_boton within w_basedatos
integer x = 1632
integer y = 152
integer taborder = 10
boolean bringtotop = true
string is_imagen = "Img\Icono\reprocesar.png"
string is_texto = "Obtener BD"
string is_textooltiptext = "Recuperar desde el servidor"
end type

on uo_btnactualizar.destroy
call uo_boton::destroy
end on

event ue_clicked;call super::ue_clicked;str_response			lstr_response
String						ls_nombrebd
Integer					li_filanew=0
Integer					li_fila
Integer					li_filasel

if dw_filtro_servidor.ib_ServerDisponible=False then Return

uo_dsbase			ids_query
ids_query			= gf_Procedimiento_Consultar("Seguridad.usp_SQL_BaseDatos_Select " + String(ii_idservidor) ,SQLCA) 

if ids_query.rowcount()<1 then Return -1

lstr_response.b_usar_datastore		= True
lstr_response.ds_datastore    			= ids_query
lstr_response.s_titulo      				= 'Listado de base de datos por servidor' 
lstr_response.b_seleccion_multiple	= TRUE
lstr_response.b_mostrar_contador		= False
lstr_response.s_titulos_columnas		='1:NOMBRE'
lstr_response.b_redim_ventana		= True
lstr_response.l_ancho						= 1000
lstr_response.l_alto						= 2000
		
OpenWithParm(w_response_seleccionar,lstr_response)
		
IF UpperBound(ids_query.ii_filasseleccionadas)<1 then	Return -1
IF ids_query.ii_filasseleccionadas[1]=0 then Return -1

for li_fila= 1 to Integer(upperbound(ids_query.ii_filasseleccionadas[]))
	li_filasel			=	ids_query.ii_filasseleccionadas[li_fila]
	ls_nombrebd	=	ids_query.Getitemstring(li_filasel,'NOMBRE')
	If dw_principal.find("nombrebd='"+ls_nombrebd+"'",1,dw_principal.RowCount())=0 then
		li_filanew		=	dw_principal.InsertRow(0)
		dw_principal.setItem(li_filanew,'nombrebd',ls_nombrebd)
		dw_principal.event ue_agregar_registro_post( li_filanew)
	End if
Next

//Activar Edicion
parent.ib_editando=true
parent.event ue_editar( ) 

end event

type dw_esquemasbd from uo_dwbase within w_basedatos
string tag = "<MenuAdicional:S,Validar con servidor:S>"
integer x = 2743
integer y = 392
integer width = 1751
integer height = 804
integer taborder = 20
boolean bringtotop = true
string title = ""
string dataobject = "dw_basedatos_esquema"
boolean hscrollbar = true
end type

event ue_retrieve;call super::ue_retrieve;il_idmaxesquema	=	0
this.retrieve(ii_idbasedatos,ii_idservidor)

Return  1
end event

event ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;//	1.0		Walther Rodriguez		10/07/2024		No se usa IDSERVIDOR

uo_dsbase				lds_query
String						ls_nombrebd
Integer					li_rowbd
Integer					li_totalobjbd
Integer					li_cont
String						ls_nombreesquema
String						ls_suma_ok
dwItemStatus			litmst_estado
Integer					li_fila
String						ls_estado

li_rowbd					=	dw_principal.GetRow()
 


If li_rowbd<1   then Return 

Choose Case as_menutexto
	Case 'Validar con servidor'
		
//		if parent.ib_editando=true then
//			gf_Mensaje(gs_aplicacion,"Registro de datos en progreso, imposible recuperar datos del servidor","",3)
//			Return
//		End if
		
		ls_nombrebd	=	dw_principal.getitemstring(li_rowbd, 'nombrebd')
		//lds_query 		=  gf_procedimiento_consultar( "Seguridad.usp_SQL_BaseDatosEsquema_Comparar " +String(ii_idbasedatos)+","+String(ii_idservidor), sqlca)
		lds_query 		=  gf_procedimiento_consultar( "Seguridad.usp_SQL_BaseDatosEsquema_Comparar " +String(ii_idbasedatos), sqlca) //1.0

		if  not isvalid(lds_query)  then return 
	
		li_totalobjbd		=	lds_query.Rowcount()
		if li_totalobjbd<1 then
			gf_Mensaje(gs_aplicacion,"No se pudo recuperar información de esquemas desde el servidor","",3)
			Return
		End if			
		//Cargando los resultados de la comparacion
		this.SetRedraw(FALSE)
		this.Reset()
		lds_query.rowscopy( 1, li_totalobjbd, Primary!,this,1,Primary!)
		il_idmaxesquema=0
		this.SetRedraw(TRUE)
		this.accepttext( )
		this.RESETupdate( )
		
		//Actualizando el estado del datawindow
		For li_fila = 1 to li_totalobjbd
			ls_estado 	=	this.GetItemString(li_fila, 'estado')
			Choose case ls_estado
				case 'O'
					litmst_estado	=	NotModified!
				case 'Q'
					litmst_estado	=	DataModified!
				case 'A'
					litmst_estado	=	NewModified!
			End choose
			this.SetItemStatus(li_fila, 0, Primary!,litmst_estado)
		Next
		this.accepttext( )
		
		ls_suma_ok ="sum( if(Estado ='O', 1, 0) )"
		ls_suma_ok= this.Describe('Evaluate("' + ls_suma_ok + '", 0)')

		if  li_totalobjbd<> Integer(ls_suma_ok)  then
			iw_ventanapadre.ib_editando = true
			iw_ventanapadre.event ue_editar()
		End if


		
End Choose
		
		
end event

event ue_grabar_pre;call super::ue_grabar_pre;Integer	li_rowcount
Integer	li_cont
Long		ll_idmax
String		ls_tabla
String		ls_ValoresPK
Integer	li_ValorRetorno
Long		ll_id=0
Integer	li_idservidor 

li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro


li_rowcount	=	this.rowcount()

 
for li_cont = 1 to li_rowcount
	if this.GetItemString(li_cont,'estado')='A' then

		
		if IsNull(il_idmaxesquema) or il_idmaxesquema=0 then
			ls_Tabla 		= 'Seguridad.Esquema'
	
			ls_ValoresPK= ""
			
			/* Generar el ID */
			li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, ll_id )	
			il_idmaxesquema=ll_id
		
			If	IsNull( il_idmaxesquema ) OR il_idmaxesquema = 0 Then
				Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
				Return  -1
			End If	
		Else
			il_idmaxesquema	=	il_idmaxesquema +1
		End if
		
		
		
		This.Setitem(li_cont,'idbasedatos',ii_idbasedatos)
		this.Setitem(li_cont,'idesquema',il_idmaxesquema)
		
	End if
next
this.accepttext( )


Return 1
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;Return -1
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;String ls_estado
//Q es color rojo
//O es color Azul
//A es color Verde

 
ls_estado  =  This.getitemstring(ai_row, 'estado')

if  ( Len(trim(ls_estado))<1 or  ls_estado='O' or  ls_estado='A' )   then 
	gf_mensaje(gs_Aplicacion, 'NO se puede eliminar el registro', '', 3) 
	Return -1
ElseIf ls_estado='' Then
	Return -1
End if

Return AncestorReturnValue
end event

event rowfocuschanged;call super::rowfocuschanged;if currentrow >  0 then 
	st_opcion.Text ='Lista de roles por esquema - ' + this.GetItemString(currentrow,'nombreesquema')
	ii_idEsquema =  this.getitemnumber(currentrow,'idesquema')
	If isNull(ii_idEsquema) Then ii_idEsquema=0
	dw_esquemaroldb.event ue_retrieve( )
End if 


end event

type dw_rolbd from uo_dwbase within w_basedatos
string tag = "<MenuAdicional:S,Validar con servidor:S>"
integer x = 4571
integer y = 392
integer width = 1458
integer height = 804
integer taborder = 30
boolean bringtotop = true
string title = ""
string dataobject = "dw_basedatos_rol"
boolean hscrollbar = true
end type

event ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;//	1.0		Walther Rodriguez		10/07/2024		No se usa IDSERVIDOR
uo_dsbase				lds_query
Integer					li_rowbd
Integer					li_rowrol
Integer					li_idrol
Integer					li_totalobjbd
Integer					li_cont
String						ls_nombreesquema
Integer					li_CantidadFilas
String						ls_filas[]
Integer					li_fila
String						ls_parametros
String						ls_error
String						ls_retorno[]
Integer					li_ret
String						ls_tipo
String						ls_nombrerol
String						ls_suma_ok
dwItemStatus			litmst_estado
String						ls_estado

li_rowbd				=	dw_principal.GetRow()
li_CantidadFilas 	= gf_split( ls_filas[], is_FilasSeleccionadas, ',' )


If li_rowbd<1 then Return 

Choose Case as_menutexto
	Case 'Validar con servidor'
		
//		if parent.ib_editando=true then
//			gf_Mensaje(gs_aplicacion,"Registro de datos en progreso, imposible recuperar datos del servidor","",1)
//			Return
//		End if

		//lds_query 		=  gf_procedimiento_consultar( "Seguridad.usp_SQL_BaseDatosRol_Comparar " +String(ii_idbasedatos)+","+String(ii_idservidor), sqlca)
		lds_query 		=  gf_procedimiento_consultar( "Seguridad.usp_SQL_BaseDatosRol_Comparar " +String(ii_idbasedatos), sqlca) 	//1.0
		if  not isvalid(lds_query)  then return 
		
		li_totalobjbd		=	lds_query.Rowcount()
		if li_totalobjbd<1 then
			gf_Mensaje(gs_aplicacion,"No se pudo recuperar información de roles desde el servidor","",1)
			Return
		End if	
		
		//Cargando los resultados de la comparacion
		this.SetRedraw(FALSE)
		this.Reset()
		lds_query.rowscopy( 1, li_totalobjbd, Primary!,this,1,Primary!)
		il_idmaxrol=0
		this.SetRedraw(TRUE)
		this.accepttext( )
		this.RESETupdate( )
		
		//Actualizando el estado del datawindow
		For li_fila = 1 to li_totalobjbd
			ls_estado 	=	this.GetItemString(li_fila, 'estado')
			Choose case ls_estado
				case 'O'
					litmst_estado	=	NotModified!
				case 'Q'
					litmst_estado	=	DataModified!
				case 'A'
					litmst_estado	=	NewModified!
			End choose
			this.SetItemStatus(li_fila, 0, Primary!,litmst_estado)
		Next
		this.accepttext( )
		
		ls_suma_ok ="sum( if(Estado ='O', 1, 0) )"
		ls_suma_ok= this.Describe('Evaluate("' + ls_suma_ok + '", 0)')
		
		if  li_totalobjbd<> Integer(ls_suma_ok)  then
			iw_ventanapadre.ib_editando = true
			iw_ventanapadre.event ue_editar()
		End if


End Choose

	

	
end event

event ue_retrieve;call super::ue_retrieve;il_idmaxrol=	0
Return this.retrieve(ii_idbasedatos,ii_IdServidor )
end event

event ue_grabar_pre;call super::ue_grabar_pre;Integer	li_rowcount
Integer	li_cont
Long		ll_idmax
String		ls_tabla
String		ls_ValoresPK
Integer	li_ValorRetorno
Long		ll_id=0
Integer	li_idservidor 


li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro

li_rowcount	=	this.rowcount()

 
for li_cont = 1 to li_rowcount
	if this.GetItemString(li_cont,'estado')='A' then

		
		if IsNull(il_idmaxrol) or il_idmaxrol=0 then
			ls_Tabla 		= 'Seguridad.BaseDatosRol'
			ls_ValoresPK= String(ii_idbasedatos)
			
			/* Generar el ID */
			li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, ll_id )	
			il_idmaxrol=ll_id
			
			If	IsNull( il_idmaxrol ) OR il_idmaxrol = 0 Then
				Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
				Return  -1
			End If	
		Else
			il_idmaxrol	=	il_idmaxrol +1
		End if
		
		this.Setitem(li_cont,'idbasedatos',ii_idbasedatos)
		this.Setitem(li_cont,'idrol',il_idmaxrol)
		
	End if
next
this.accepttext( )


Return 1
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;Return -1

end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;String ls_estado
//Q es color rojo
//O es color Azul
//A es color Verde

 
ls_estado  =  This.getitemstring(ai_row, 'estado')

if  ( Len(trim(ls_estado))<1 or  ls_estado='O' or  ls_estado='A' )   then 
	gf_mensaje(gs_Aplicacion, 'NO se puede eliminar el registro', '', 3) 
	Return -1
ElseIf ls_estado='' Then
	Return -1
End if

Return AncestorReturnValue
end event

event doubleclicked;call super::doubleclicked;Integer	li_rol
Integer 	li_filanew

if row>0 and this.GetRow()>0 then
	li_rol	=	this.getitemnumber( row, 'idrol')
	If dw_esquemaroldb.find("idrol="+String(li_rol),1,dw_esquemaroldb.RowCount()) = 0 then
		if gf_Mensaje(gs_aplicacion,"Agregar rol seleccionado al esquema","",4)	= 1 then
			li_filanew		=	dw_esquemaroldb.InsertRow(0)
			dw_esquemaroldb.setItem(li_filanew,'idrol',li_rol)
			dw_esquemaroldb.setItem(li_filanew,'nombre',this.GetItemString( row, 'nombrerol'))
			dw_esquemaroldb.setItem(li_filanew,'idbasedatos',ii_IdBaseDatos)
			dw_esquemaroldb.setItem(li_filanew,'idesquema',ii_idEsquema)
			dw_esquemaroldb.setItem(li_filanew,'idservidor',ii_idServidor)
			//Activar Edicion
			parent.ib_editando=true
			parent.event ue_editar( ) 
		End if
	End if
End if
end event

type uo_leyenda from uo_leyenda_color within w_basedatos
integer x = 3173
integer y = 116
integer width = 1330
integer taborder = 20
boolean bringtotop = true
end type

on uo_leyenda.destroy
call uo_leyenda_color::destroy
end on

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_basedatos
integer x = 46
integer y = 176
integer taborder = 20
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	dw_principal.reset()
	dw_esquemasbd.reset()
	dw_rolbd.reset()
	dw_esquemaroldb.reset()
	Return -2
Else
	dw_principal.event ue_retrieve( )
	 
End if

end event

type dw_esquemaroldb from uo_dwbase within w_basedatos
integer x = 2743
integer y = 1480
integer width = 1778
integer height = 700
integer taborder = 30
boolean bringtotop = true
string dataobject = "dw_basedatos_esquema_rol"
boolean ib_menudetalle = true
boolean ib_mostrarmensajeantesdeeliminarregistro = true
end type

event ue_retrieve;call super::ue_retrieve;return this.retrieve(ii_IdBaseDatos,ii_IdEsquema,ii_IdServidor)

end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;Integer 			li_fila
Integer	 		li_filasel
Integer 			li_rol
Integer 			li_filanew
String 			ls_nombreRol
uo_dsbase		luo_ds_query
str_response    lstr_Response

str_arg  				lstr_Enviar

if dw_esquemasbd.Getrow()<1 or dw_rolbd.Getrow()<1 then Return -1

//luo_ds_query			= gf_Procedimiento_Consultar(" Seguridad.usp_BaseDatosRol_Select   " +String(ii_idbasedatos)+","+String(ii_idservidor), sqlca)
luo_ds_query			= gf_Procedimiento_Consultar(" Seguridad.usp_BaseDatosRol_Select   " +String(ii_idbasedatos), sqlca)

	

if luo_ds_query.rowcount() < 1 then Return -1

li_rol = dw_rolbd.getitemnumber(dw_rolbd.getRow(),'idrol')

if li_rol  > 0 then lstr_Enviar.i[1] = li_rol   //ii_idRol = 0


lstr_response.b_usar_datastore		= 	True
lstr_response.ds_datastore    			= 	luo_ds_query
lstr_response.s_titulo      				= 	'Listado de Roles' 
lstr_response.b_seleccion_multiple	= 	TRUE
lstr_response.b_mostrar_contador		= 	False
lstr_response.s_titulos_columnas		=	'3:Nombre rol BD'
lstr_response.b_redim_ventana		= 	True
lstr_response.l_ancho						= 	1000
lstr_response.l_alto						= 	1780
lstr_response.str_argumentos			= lstr_Enviar
	  
//OpenWithParm(w_response_seleccionar,	lstr_Response)
OpenWithParm(w_reponse_selecionar_rol ,	lstr_Response)

IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1

for li_fila= 1 to Integer(upperbound(luo_ds_query.ii_filasseleccionadas[]))
	li_filasel			=	luo_ds_query.ii_filasseleccionadas[li_fila]
	li_rol				=	luo_ds_query.getitemnumber(li_filasel,'idrol')
	ls_nombreRol 	=  luo_ds_query.getitemstring(li_filasel,'nombrerol')
	

	If dw_esquemaroldb.find("idrol="+String(li_rol),1,dw_esquemaroldb.RowCount()) = 0 then
		li_filanew		=	dw_esquemaroldb.InsertRow(0)
		dw_esquemaroldb.setItem(li_filanew,'idrol',li_rol)
		dw_esquemaroldb.setItem(li_filanew,'nombre',ls_nombreRol)
		dw_esquemaroldb.setItem(li_filanew,'idbasedatos',ii_IdBaseDatos)
		dw_esquemaroldb.setItem(li_filanew,'idesquema',ii_idEsquema)
		dw_esquemaroldb.setItem(li_filanew,'idservidor',ii_idServidor)
	End if
	
Next

//Activar Edicion
parent.ib_editando=true
parent.event ue_editar( ) 
	


return -1
end event

type st_opcion from statictext within w_basedatos
integer x = 2743
integer y = 1392
integer width = 1605
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
string text = "Lista de roles por esquema"
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
end type

