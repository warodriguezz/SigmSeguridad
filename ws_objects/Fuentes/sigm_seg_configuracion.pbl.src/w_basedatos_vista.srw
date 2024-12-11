$PBExportHeader$w_basedatos_vista.srw
$PBExportComments$emalcap
forward
global type w_basedatos_vista from w_base
end type
type dw_vistabd from uo_dwbase within w_basedatos_vista
end type
type uo_leyenda from uo_leyenda_color within w_basedatos_vista
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_basedatos_vista
end type
end forward

global type w_basedatos_vista from w_base
integer width = 4832
integer height = 2300
dw_vistabd dw_vistabd
uo_leyenda uo_leyenda
dw_filtro_servidor dw_filtro_servidor
end type
global w_basedatos_vista w_basedatos_vista

type variables
Integer 	ii_IdServidor 
Integer	ii_IdBaseDatos
Long		il_idmaxbd=0
//Long		il_idmaxesquema=0
Long		il_idmaxvista=0
Long		il_idmaxrol=0
String		is_FilasSeleccionadas 
Long 		il_Fila
end variables

on w_basedatos_vista.create
int iCurrent
call super::create
this.dw_vistabd=create dw_vistabd
this.uo_leyenda=create uo_leyenda
this.dw_filtro_servidor=create dw_filtro_servidor
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_vistabd
this.Control[iCurrent+2]=this.uo_leyenda
this.Control[iCurrent+3]=this.dw_filtro_servidor
end on

on w_basedatos_vista.destroy
call super::destroy
destroy(this.dw_vistabd)
destroy(this.uo_leyenda)
destroy(this.dw_filtro_servidor)
end on

event resize;call super::resize;If	ib_MostrarTitulo = True Then il_AlturaTitulo = st_fondo.height + BordeHorizontal

dw_filtro_servidor.y				= BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x 				= BordeVertical

dw_principal.x 				= BordeVertical
dw_principal.y 				= BordeHorizontal + dw_filtro_servidor.y + dw_filtro_servidor.height
dw_principal.width 		=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 2)
dw_principal.height 		=  (newheight - ( (dw_filtro_servidor.y + 1 * BordeHorizontal ) + il_AlturaTitulo))

dw_vistabd.x			= dw_principal.x + dw_principal.width + BordeHorizontal
dw_vistabd.y			= dw_principal.y
dw_vistabd.width 	=  ((st_fondo.width  - (1 * BordeHorizontal) ) / 2)
dw_vistabd.height 	= (newheight -  (  dw_principal.y + 1  * BordeHorizontal)  ) 

uo_leyenda.y		=	dw_filtro_servidor.y - BordeHorizontal	

//dw_rolbd.x					= dw_vistabd.x	
//dw_rolbd.y					= dw_vistabd.y + (dw_vistabd.height) + BordeHorizontal
//dw_rolbd.width 			= dw_vistabd.width
//dw_rolbd.height 			= dw_vistabd.height

end event

event ue_grabar_post;call super::ue_grabar_post;dw_principal.event rowfocuschanged(il_Fila)
return 1

end event

event ue_nuevo_pre;call super::ue_nuevo_pre;Return -1
end event

event ue_eliminar_pre;call super::ue_eliminar_pre;Return -1
end event

type st_titulo from w_base`st_titulo within w_basedatos_vista
string tag = "Base de Datos"
string text = "Base de Datos"
end type

type st_fondo from w_base`st_fondo within w_basedatos_vista
end type

type dw_principal from w_base`dw_principal within w_basedatos_vista
string tag = "<MenuAdicional:N>"
integer x = 69
integer y = 392
integer width = 2697
integer height = 1756
string title = ""
string dataobject = "dw_basedatos"
boolean controlmenu = true
boolean hscrollbar = true
borderstyle borderstyle = stylebox!
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_menuexportar = true
boolean ib_menufiltrar = true
boolean ib_activareventoeditaraleliminarregistro = false
boolean ib_menuedicionvisible = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;if dw_filtro_servidor.ib_ServerDisponible=False then Return 0

//return retrieve(ii_IdServidor)
return retrieve(3,'')
end event

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre; return  1
  

end event

event dw_principal::ue_agregar_registro_post;call super::ue_agregar_registro_post; Integer		li_idbasedatos
 String		ls_tabla
 String		ls_ValoresPK
 Integer		li_valorRetorno
 Integer		li_idservidor
 
 if IsNull(il_idmaxbd) or il_idmaxbd=0 then
	ls_Tabla 		= 'Maestros.BaseDatos'
	ls_ValoresPK= ""
	li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro
	
	/* Generar el ID */
	li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, il_idmaxbd )	
	
	If	IsNull( il_idmaxbd ) OR il_idmaxbd = 0 Then
		Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
		Return  
	End If	
Else
	il_idmaxbd	=	il_idmaxbd +1
End if

li_idbasedatos	=	il_idmaxbd

This.Setitem(ai_row,'idservidor',ii_IdServidor)
This.Setitem(ai_row,'idbasedatos',li_idbasedatos)

 

end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;if currentrow>0 then 
	ii_idbasedatos	=	this.getitemnumber(currentrow,'idbasedatos')
	dw_vistabd.triggerevent("ue_retrieve")
	il_Fila  =  currentrow
End if
end event

type st_menuruta from w_base`st_menuruta within w_basedatos_vista
end type

type dw_vistabd from uo_dwbase within w_basedatos_vista
string tag = "<MenuAdicional:S,Validar con servidor:S,Informacion:S>"
integer x = 2885
integer y = 404
integer width = 1755
integer height = 1764
integer taborder = 20
boolean bringtotop = true
string title = ""
string dataobject = "dw_basedatos_vista"
boolean hscrollbar = true
boolean ib_mostrarmensajeantesdeeliminarregistro = true
end type

event ue_retrieve;call super::ue_retrieve;il_idmaxvista	=	0
Return this.retrieve(ii_idbasedatos,ii_idservidor)
end event

event ue_menu_detalle_adicional;call super::ue_menu_detalle_adicional;uo_dsbase				lds_query
String						ls_nombrebd
Integer					li_rowbd
Integer					li_totalobjbd
Integer					li_cont
String						ls_suma_ok
dwItemStatus			litmst_estado
Integer					li_fila
String						ls_estado
String						ls_vista
String						ls_texto
String						ls_mensaje

li_rowbd		=	dw_principal.GetRow()

If li_rowbd<1 then Return 


ls_nombrebd	=	dw_principal.getitemstring(li_rowbd, 'nombrebd')
		
Choose Case as_menutexto
		
	Case 'Informacion'
		if this.GetRow()<1 then Return
		ls_vista			=	this.Getitemstring(this.GetRow() , 'nombrevista')
		lds_query 		=  gf_procedimiento_consultar( "Framework.usp_ObjetoTexto 2,'"+ ls_nombrebd +  "','" + ls_vista+"'" , sqlca)	//Obtener descripcion de la vista
		if  not isvalid(lds_query)  then return 
		li_totalobjbd		=	lds_query.rowcount( )
		For li_fila	=	1	to li_totalobjbd
			ls_texto		=	lds_query.getitemstring(li_fila,'texto')
			ls_mensaje	=  ls_mensaje   + '~n' + ls_texto
		Next
		gf_Mensaje(gs_aplicacion,ls_mensaje ,"",1)
		
	Case 'Validar con servidor'
		lds_query 		=  gf_procedimiento_consultar( "Seguridad.usp_SQL_BaseDatosVista_Comparar " +String(ii_idbasedatos), sqlca)
		if  not isvalid(lds_query)  then return 
			
		li_totalobjbd		=	lds_query.Rowcount()
		if li_totalobjbd<1 then
			gf_Mensaje(gs_aplicacion,"No se pudo recuperar información de vistas desde el servidor","",1)
			Return
		End if	
		
		
//		//Cargando los resultados de la comparacion
		this.SetRedraw(FALSE)
		this.Reset()
		lds_query.rowscopy( 1, li_totalobjbd, Primary!,this,1,Primary!)
		il_idmaxvista=0
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
Long  		li_idvista = 0
Integer	li_idservidor	 

li_rowcount	=	this.rowcount()
li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro
 
for li_cont = 1 to li_rowcount
	if this.GetItemString(li_cont,'estado')='A' then

		
		if IsNull(il_idmaxvista) or il_idmaxvista=0 then
			ls_Tabla 		= 'Seguridad.BaseDatosVista'
			ls_ValoresPK= String(ii_idbasedatos)

			
			/* Generar el ID */
			li_ValorRetorno = sqlca.usp_generarid(li_idservidor, ls_Tabla, ls_ValoresPK, li_idvista )	
			il_idmaxvista  =  li_idvista
			If	IsNull( il_idmaxvista ) OR il_idmaxvista = 0 Then
				Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
				Return  -1
			End If	
		Else
			il_idmaxvista	=	il_idmaxvista +1
		End if
		
		This.Setitem(li_cont,'idbasedatos',ii_idbasedatos)
		this.Setitem(li_cont,'idvista',il_idmaxvista)
		
	End if
next
this.accepttext( )


Return 1
end event

event doubleclicked;call super::doubleclicked;Integer li_idvista


uo_dsbase		lds_query

str_response    lstr_Response


li_idvista = dw_vistabd.getitemNumber(this.getrow(),'idvista' )

/*Cargar los argumentos  se pasarán a la ventana seleccionar */

//Recuperar las muestras
lds_query  		=gf_procedimiento_consultar( "Seguridad.usp_BaseDatosVistaUsuario_Select "+ string(ii_IdServidor)+","+String(ii_idbasedatos)+","+String(li_idvista)  ,sqlca)
if lds_query.rowcount( )<1 then Return


lstr_Response.b_usar_datastore				= True								// 1 : Indica que se usará Datastore, 2 : Indica que se usara un Dw
lstr_Response.ds_datastore    					= lds_query                		// Datastore creado dinámicamente
lstr_Response.s_titulo      						= 'Permisos Vistas por Usuarios'  		// Título de la Ventana
lstr_Response.s_titulos_columnas    			= "1:Usuario:400,2:Estado:400"  
lstr_Response.l_alto      							= 1500								// Ancho de la ventana
lstr_Response.l_ancho      						= 1200								// Alto de la ventana
lstr_Response.b_redim_ventana		      	= True	
lstr_Response.b_ocultar_botones				= True
lstr_Response.b_redim_controles				= True

/*Abrir la ventana response: seleccionar */
OpenWithParm( w_response_base,lstr_Response)




end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;String ls_estado
//Q es color rojo
//O es color Azul
//A es color Verde

ls_estado  =  This.getitemstring(ai_row, 'estado')
if  ( Len(trim(ls_estado))<1 or   ls_estado='O' or  ls_estado='A' )   then 
	gf_mensaje(gs_Aplicacion, 'NO se puede eliminar el registro', '', 3) 
	Return -1
ElseIf ls_estado='' Then
	Return -1
End if

Return AncestorReturnValue
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;Return -1
end event

type uo_leyenda from uo_leyenda_color within w_basedatos_vista
integer x = 3177
integer y = 148
integer width = 1330
integer height = 140
integer taborder = 10
boolean bringtotop = true
end type

on uo_leyenda.destroy
call uo_leyenda_color::destroy
end on

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_basedatos_vista
integer x = 69
integer y = 152
integer taborder = 10
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor	=	ii_idservidorfiltro
//Administrar solo los servidores LinKed o el servidor con conexion
if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	dw_principal.reset( )
	dw_vistabd.reset( )
	Return -2
Else
	dw_principal.event ue_retrieve( )
End if



end event

