$PBExportHeader$w_controlestado_usuario.srw
forward
global type w_controlestado_usuario from w_base
end type
type dw_filtro_servidor from uo_filtro_servidor_usuario within w_controlestado_usuario
end type
type cb_1 from commandbutton within w_controlestado_usuario
end type
end forward

global type w_controlestado_usuario from w_base
integer ii_modoventana = 2
dw_filtro_servidor dw_filtro_servidor
cb_1 cb_1
end type
global w_controlestado_usuario w_controlestado_usuario

type variables
Integer 	ii_IdControlEstado
Long		il_idmaxControlEstado
//Integer ii_newRow
Integer ii_IdServidor
Integer ii_IdServidorCnx
Integer ii_idBaseDatos
//Boolean ib_new = false 

DataWindowChild      idwch_servidor
DataWindowChild 	    idwch_idSer
DataWindowChild    	idwch_DataBase            
DataWindowChild		idwch_NombreT 
DataWindowChild		idwch_NombreC
DataWindowChild		idwch_NombreCR

String is_nombretabla
end variables

on w_controlestado_usuario.create
int iCurrent
call super::create
this.dw_filtro_servidor=create dw_filtro_servidor
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_filtro_servidor
this.Control[iCurrent+2]=this.cb_1
end on

on w_controlestado_usuario.destroy
call super::destroy
destroy(this.dw_filtro_servidor)
destroy(this.cb_1)
end on

event ue_grabar_pre;call super::ue_grabar_pre;//if  dw_principal.event ue_validar() < 0 then return  -1
return 1


end event

event resize;call super::resize;SetRedraw(False)

st_fondo.x = BordeVertical
st_fondo.y = BordeHorizontal
st_fondo.width = newwidth - ( BordeVertical * 2 )
st_titulo.x = BordeVertical + 20
st_titulo.y = BordeHorizontal + 15
st_titulo.width = (newwidth - ( BordeVertical * 4 ) )/2 // la mitad del ancho

st_menuruta.width = st_titulo.width
st_menuruta.x = st_fondo.x + st_fondo.width - st_menuruta.width
 	 
dw_filtro_servidor.y				= BordeHorizontal + il_AlturaTitulo
dw_filtro_servidor.x 				= BordeVertical

dw_principal.y =  (dw_filtro_servidor.y	+ dw_filtro_servidor.height) 
dw_principal.x = BordeVertical
dw_principal.width = newwidth -   BordeVertical  
//dw_principal.height = newheight -   (BordeHorizontal  - il_AlturaTitulo) - (dw_filtro_servidor.y	+ dw_filtro_servidor.height) 
dw_principal.height 	=	 (newheight - ( (dw_filtro_servidor.y + 1  * BordeHorizontal ) + il_AlturaTitulo))


SetRedraw(True)
end event

event open;call super::open;dw_principal.ib_dddwpoblado=False



end event

event ue_cancelar;call super::ue_cancelar;This.Event ue_recuperar( )
This.ib_Editando = False
This.Event ue_editar( )	
end event

type st_titulo from w_base`st_titulo within w_controlestado_usuario
end type

type st_fondo from w_base`st_fondo within w_controlestado_usuario
end type

type dw_principal from w_base`dw_principal within w_controlestado_usuario
integer y = 252
integer height = 1512
string title = ""
string dataobject = "dw_controlestado_usuario"
boolean hscrollbar = true
boolean vscrollbar = false
boolean livescroll = false
boolean ib_menudetalle = true
end type

event dw_principal::itemchanged;call super::itemchanged;String ls_Null
Integer li_Null

 setNull(ls_Null)
 setNull(li_Null)

this.accepttext()

Choose Case dwo.name 
		
	  	Case 'idservidor'
			
			 ii_IdServidor = Integer(data)
			 
			this.SetItem(row,'idbasedatos',li_Null)
			this.event   ue_poblardddw ('idbasedatos') 	

		Case 'idbasedatos'					
				ii_idBaseDatos = Integer(data)	
				
				this.SetItem(row,'nombretabla',ls_Null)
				this.event ue_poblardddw ('nombretabla') 		
		      
		Case	'nombretabla'	

				is_nombretabla = data	
				this.SetItem(row,'nombrecampo',ls_Null) 
				this.SetItem(row,'valorinactivo',ls_Null)  
				this.SetItem(row,'nombrecamporelacion',ls_Null)
			  
				this.event   ue_poblardddw ('nombrecampo') 
				this.event   ue_poblardddw ('nombrecamporelacion') 	
			
		Case 	'nombrecampo' 

    				 is_nombretabla =  this.getitemstring( row,'nombretabla')
					 	
			 	this.SetItem(row,'valorinactivo',ls_Null) 
				 
			case 'nombrecamporelacion'

			
End choose 



end event

event dw_principal::ue_agregar_registro_post;//ib_new = true
//ii_newRow =  ai_row
Integer	lid_servidor

lid_servidor	=	ii_idservidor
this.setitem(ai_row,'registroactivo', 1)
this.setitem(ai_row,'idservidor', lid_servidor)

end event

event dw_principal::ue_retrieve;call super::ue_retrieve;return this.retrieve(0)

end event

event dw_principal::ue_poblardddw;call super::ue_poblardddw;// 1.0		Walther Rodriguez			21/06/2024			Se quita  IDServidor por eliminacion de Servidores dinamicos

Integer	li_ret
datawindowchild	ldwc_child

If	This.GetChild( as_columna, ldwc_child ) < 1 Then Return
ldwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idaplicacion' 
		//li_ret = ldwc_child.Retrieve(ii_IdServidorCnx ) 1.0
		//li_ret = ldwc_child.Retrieve() 
		li_ret = ldwc_child.Retrieve(2,'') 
	case 'idservidor'
		li_ret = ldwc_child.Retrieve(0,0)
	case 'idbasedatos'
		//li_ret = ldwc_child.Retrieve(ii_IdServidor)
		li_ret = ldwc_child.Retrieve() //1.0
	case 'nombretabla'
		li_ret = ldwc_child.Retrieve(ii_IdServidor,ii_idBaseDatos)
	case 'nombrecampo' , 'nombrecamporelacion'
		li_ret = ldwc_child.Retrieve(ii_IdServidor,ii_idBaseDatos,is_nombretabla)
End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	li_ret < 1 Then ldwc_child.Insertrow( 0 )










end event

event dw_principal::ue_grabar_pre;call super::ue_grabar_pre;Integer			li_rowcount
Integer			li_cont
Long				ll_idmax
String				ls_tabla
String				ls_ValoresPK
Integer			li_ValorRetorno
Long				ll_id=0
Integer			li_idservidor 

dwItemStatus 	ldwis_Estado

li_rowcount	=	this.rowcount()
li_idservidor	=	dw_filtro_servidor.ii_idservidorfiltro
 
for li_cont = 1 to li_rowcount
	
	ldwis_Estado = This.getitemstatus( li_cont, 0, Primary! )
	
	If	ldwis_Estado = New! OR ldwis_Estado  = NewModified! Then

		
		if IsNull(il_idmaxControlEstado) or il_idmaxControlEstado=0 then
			ls_Tabla 		= 'Seguridad.ControlEstadoUsuario'
	
			ls_ValoresPK= ""
			
			/* Generar el ID */
			li_ValorRetorno = sqlca.usp_generarid( li_idservidor, ls_Tabla, ls_ValoresPK, ll_id )	
			il_idmaxControlEstado=ll_id
		
			If	IsNull( il_idmaxControlEstado ) OR il_idmaxControlEstado = 0 Then
				Messagebox( 'Error', 'Error al generar la clave primaria' + SQLCA.sqlerrtext, stopsign! )
				Return  -1
			End If	
		Else
			il_idmaxControlEstado	=	il_idmaxControlEstado +1
		End if
		
		this.Setitem(li_cont,'idcontrolestado',il_idmaxControlEstado)
		
	End if
next
this.accepttext( )


Return 1
end event

event dw_principal::clicked;call super::clicked;//If  row >  0  and  row <= rowcount() then
//	ii_IdServidor	=	this.getitemNumber( row, 'idservidor') 
//		this.event ue_poblardddw ('idservidor') 		
//	ii_idBaseDatos  =  this.getitemNumber(row, 'idBaseDatos')
//		this.event ue_poblardddw ('idBaseDatos') 		
//	is_nombretabla =  this.getitemString(row, 'nombretabla')
//		this.event ue_poblardddw ('nombretabla') 		
//		this.event   ue_poblardddw ('nombrecampo') 
//		this.event   ue_poblardddw ('nombrecamporelacion') 	
//End If
//
//
end event

type st_menuruta from w_base`st_menuruta within w_controlestado_usuario
end type

type dw_filtro_servidor from uo_filtro_servidor_usuario within w_controlestado_usuario
integer x = 64
integer y = 132
integer taborder = 10
boolean bringtotop = true
end type

event itemchanged;call super::itemchanged;ii_idservidor			=	ii_idservidorfiltro
ii_IdServidorCnx	=	ii_idservidor

if this.ib_ServerDisponible=False then
	gf_mensaje(gs_Aplicacion, 'Servidor NO disponible', '', 3)
	dw_principal.reset()
	Return -2
Else

	dw_principal.event ue_poblartodo( )
	dw_principal.TriggerEvent("ue_retrieve")

End if

end event

type cb_1 from commandbutton within w_controlestado_usuario
boolean visible = false
integer x = 1746
integer y = 124
integer width = 343
integer height = 80
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "none"
end type

event clicked;String		ls_ret
ls_ret=gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_DeshabilitarUsuario_fechaCese","")

end event

