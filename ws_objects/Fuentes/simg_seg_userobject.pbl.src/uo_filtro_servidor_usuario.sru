$PBExportHeader$uo_filtro_servidor_usuario.sru
forward
global type uo_filtro_servidor_usuario from uo_dwfiltro
end type
end forward

global type uo_filtro_servidor_usuario from uo_dwfiltro
integer width = 1522
integer height = 112
string title = ""
string dataobject = "dwf_servidores_usuario"
boolean border = false
end type
global uo_filtro_servidor_usuario uo_filtro_servidor_usuario

type variables
PUBLIC:
Integer	ii_idservidorfiltro					//ID del servidor
String		is_LinkedServerfiltro				//Nombre del Linked Server asociado
String		is_NombreServerfiltro				//Nombre del Server
Boolean	ib_ServerDisponible=False		//Indica si el servidor esta disponible (Server actual o Linked creado)
end variables

forward prototypes
public function integer wf_servidor_disponible (string as_servidor, string as_servidorlinked)
end prototypes

public function integer wf_servidor_disponible (string as_servidor, string as_servidorlinked);Integer	li_disponible=0
String		ls_ret
String		ls_parametros

//ls_parametros	=	"'"+as_servidor+"','"+as_servidorlinked+"'"
//ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.ufn_ValidarServidor",ls_parametros)
//
//If ls_ret = "SQL:-1" Then 
//	Return -1
//End if
//
ls_ret='1'
Return Integer(ls_ret)
end function

on uo_filtro_servidor_usuario.create
call super::create
end on

on uo_filtro_servidor_usuario.destroy
call super::destroy
end on

event constructor;call super::constructor;This.post event ue_retrieve( )
end event

event ue_retrieve;call super::ue_retrieve;If	This.ii_nrofilas > 0 Then
	/* Inserta el primer código de la unidad que se obtiene del datawindowchild */
	This.object.idservidor[ 1 ] = Integer(This.idwc_child.GetItemNumber( 1, 'idservidor' ))
	
	/* Invoca el evento Itemchaged */
	This.event itemchanged( 1, This.object.idservidor, String(This.idwc_child.GetItemNumber( 1, 'idservidor' ) )  )
	Return 1
End If


end event

event ue_poblardddw;call super::ue_poblardddw;If	This.GetChild( as_columna, This.idwc_child ) < 1 Then Return

This.idwc_child.SetTransObject( SQLCA )

Choose case as_columna 
	case 'idservidor'
		ii_nrofilas = This.idwc_child.Retrieve(gs_usuario )  //Servidores por usuario
End Choose

// Si el datawindowChild no tiene elementos se inserta un registro en blanco
If	ii_nrofilas < 1 Then This.idwc_child.Insertrow( 0 )

end event

event itemchanged;call super::itemchanged;/*	Verificar que no existan cambio pendientes en ningún datawindow */
If	iw_VentanaPadre.uf_cambios_pendientes( ) < 1 Then 
	If	MessageBox( 'CONFIRMACIÓN', "Existen cambios sin actualizar. ¿Desea actualizarlos?", Question!, YesNo! ) = 2 Then 
		iw_VentanaPadre.event ue_cancelar() /*	Ejecuta el evento ue_cancelar */
	Else		
		iw_VentanaPadre.event ue_grabar()	/*	Ejecuta el evento ue_grabar */
	End If
End If

/* Almacena los códigos de Compañia y Unidad */
ii_idservidorfiltro 		 = Integer( This.idwc_child.getitemnumber( This.idwc_child.getrow(),'idservidor'))
is_linkedserverfiltro	 = String( This.idwc_child.GetItemString( This.idwc_child.getrow(),'nombrelinkedserver'))
is_nombreServerfiltro	 = String( This.idwc_child.GetItemString( This.idwc_child.getrow(),'nombreservidor'))
if IsNull(is_linkedserverfiltro) or is_linkedserverfiltro='null' then is_linkedserverfiltro=''
ib_ServerDisponible	=	(wf_servidor_disponible(is_nombreServerfiltro,is_linkedserverfiltro)>0)


end event

