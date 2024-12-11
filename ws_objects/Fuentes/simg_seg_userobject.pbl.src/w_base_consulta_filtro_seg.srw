$PBExportHeader$w_base_consulta_filtro_seg.srw
$PBExportComments$Ventana base para impresiones
forward
global type w_base_consulta_filtro_seg from w_base
end type
type dw_filtro from uo_dwfiltro within w_base_consulta_filtro_seg
end type
type uo_visualizar from uo_boton within w_base_consulta_filtro_seg
end type
type dw_servidorusuario from uo_filtro_servidor_usuario within w_base_consulta_filtro_seg
end type
end forward

global type w_base_consulta_filtro_seg from w_base
integer width = 5920
integer height = 2116
string menuname = "m_mbase"
boolean resizable = false
string icon = "Img\Icono\AuditUser.ico"
boolean center = false
integer ii_modoventana = 3
boolean ib_ventanaeditable = false
boolean ib_toolbarmodoconsulta = true
event ue_cargar ( integer ai_tipo )
event ue_imprimir ( )
event type integer ue_usarfiltro ( )
event type integer ue_tipollamado ( )
event ue_regla ( )
event ue_retrieve ( )
event ue_zoommas ( )
event ue_zoommenos ( )
event ue_paginaanterior ( )
event ue_paginasiguiente ( )
event ue_100p ( )
dw_filtro dw_filtro
uo_visualizar uo_visualizar
dw_servidorusuario dw_servidorusuario
end type
global w_base_consulta_filtro_seg w_base_consulta_filtro_seg

type variables
str_arg	istr_preview
str_arg	istr_preview_arg  /* Insertar los parámetros  */
String		is_subtitulo
String 	is_tipollamado 	   /* V: ventana o M: Menú */
Boolean 	ib_usarfiltro  	   /* True/False */
Boolean 	ib_setear_todos  /* True/False */
Integer	ii_IdCompania		 // Código de compañia
Integer	ii_IdUnidadNegocio // Código de la unidad de Negocio
Integer	ii_idservidor			 // Id del servidor
Boolean	ib_dinamico=False		//Para saber si se crea un DW dinamico
String		is_sp_sintaxys			//Sp que se ejecuta para la sintxys

Integer 	ii_Anio,ii_Mes,ii_Listado
Integer	ii_nroargumentossp
String		is_datadropdown
Date		id_desde
Date		id_hasta
Boolean	ib_cambioparametros=False

Protected 	DatawindowChild idw_dropdown

end variables

forward prototypes
public function integer uf_validar_str_preview ()
public function integer uf_validar_str_argumentos ()
public function integer uf_obtener_atributo (integer a_index, ref integer a_ref_nrocolumna, ref any a_ref_datacolumna, ref integer a_ref_visiblecolumna)
public function integer uf_setear_anio_mes (string a_columna)
private function integer uf_setear_parametros (integer a_fila, string a_columna, string a_coltype, any a_valor)
public function integer wf_generar_sintaxys_dw ()
public function boolean uf_validar_datawindows ()
end prototypes

event ue_cargar(integer ai_tipo);Integer	li_fila
choose case ai_tipo
	case 300
		//Impresion de etiquetas
		For li_fila = 1 to UpperBound(istr_preview.s)
			dw_principal.insertrow(0)
			dw_principal.object.codigo[li_fila]				=istr_preview.s[li_fila]
			dw_principal.object.nombre[li_fila]			=istr_preview.s[li_fila]
			dw_principal.object.codigoexterno[li_fila]	=String(istr_preview.a[li_fila])
			if istr_preview.i[li_fila]>0 then
				dw_principal.object.posicion[li_fila]		=String(istr_preview.i[li_fila])
			else
				dw_principal.object.posicion[li_fila]		=''
			End if
			dw_principal.object.solicitud[li_fila]			=is_subtitulo
		Next
		
End choose

end event

event ue_imprimir();dw_principal.print( )
end event

event type integer ue_usarfiltro();// **********************************************************************************
//	Descripción			:	Activar o desactivar el dw_filtro
//
//	Valor de Retorno	:	li_retorno 1: Ok; -1: variable is_usarfiltro no definido
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			05/04/2017		Versión inicial
// **********************************************************************************
Integer li_retorno

If ib_usarfiltro = True Then
	//Activar a visible el dw filtro
	dw_filtro.visible = True
	uo_visualizar.visible = True
	li_retorno = 1
	
ElseIf ib_usarfiltro = False Then
	//Ocultar el dw_filtro
	dw_filtro.visible = False
	uo_visualizar.visible = False
	li_retorno = 1 
Else 
	li_retorno = -1 
End If 

Return li_retorno
end event

event type integer ue_tipollamado();// **********************************************************************************
//	Descripción			:	Definir lógica de acuerdo al tipo de llamado: Ventana/Menú
//
//	Valor de Retorno	:	li_retorno 1: Ok; -1: Tipo de llamado no definido
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			05/04/2017		Versión inicial
// **********************************************************************************
Integer li_retorno 

/*  Tipo de llamado desde la ventana */
If is_tipollamado = 'V' Then 
	//Setear los valores de acuerdo a los parámetros enviados desde la ventana
	
	li_retorno = 1 

/*  Tipo de llamado desde el menú */
ElseIf is_tipollamado = 'M' Then 
	//Setear los valores "Todos" en los dddw
	
	li_retorno = 1 

/*  Tipo de llamado no definido */
Else
	li_retorno =  -1
End If 

Return li_retorno 
end event

event ue_retrieve();dw_principal.event ue_retrieve( )

end event

public function integer uf_validar_str_preview ();// **********************************************************************************
//	Descripción			:	uf_validar_str_preview: Validar que los parámetros de la estructura tengan valores
//
//	Argumentos			:   Ninguno
//
//	Valor de Retorno	:	li_retorno; 1 Ok, -1 No pasa validación
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			06/04/2017		Versión inicial
// **********************************************************************************
Integer li_retorno
 
If (Len(istr_preview.titulo) = 0  Or IsNull(istr_preview.tipo) Or Len(istr_preview.tipollamado) = 0 Or IsNull(istr_preview.usarfiltro)) Then
	li_retorno = -1	
Else
	li_retorno = 1	
End If 	

If li_retorno=1 then
	//Validar que existan argumentos para tipo 3, crear DW dinamico
	if istr_preview.tipo=3  and (Integer(Upperbound(istr_preview.s[])) - 9) < 1 then	//Los argumentos comienzan en 10  
		li_retorno = -1		
	End if
End if

Return li_retorno


end function

public function integer uf_validar_str_argumentos ();// **********************************************************************************
//	Descripción			:	uf_validar_str_argumentos: Validar que los valores de la estructura tengan valores
//
//	Argumentos			:   Ninguno
//
//	Valor de Retorno	:	li_retorno; 1 Ok, -1 No pasa validación
//
//	Control de Versión:	
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			06/04/2017		Versión inicial
// **********************************************************************************
Integer li_retorno,li_cont
String   ls_cadena
Integer li_nrocolumna, li_visiblecolumna
Any	  la_valor

If (istr_preview.nargumentos > 0) Then 
	
	For li_cont = 1 To istr_preview.nargumentos	
		la_valor 		   = istr_preview.a[li_cont]
		li_nrocolumna = li_cont
		ls_cadena 	   = String(la_valor)
		
		If Len(ls_cadena) > 0 Then 
			li_visiblecolumna = 1 
		Else
			li_visiblecolumna = 0
		End If				
				
		/* Evaluar los valores[nrocolumna,datacolumna,visiblecolumna] sean válidos */		
		If li_nrocolumna > 0 and (li_visiblecolumna = 0 or li_visiblecolumna = 1) Then
			/* Insertar los parámetros */
			istr_preview_arg.a[li_cont] =  la_valor
			li_retorno = 1
		Else 
			li_retorno = -1
		End If 
	
		/* No hay argumentos válidos para continuar */
		If li_retorno = -1	Then Return li_retorno	
	Next	
Else /* No hay argumentos para procesar */
	li_retorno = -1
End If

Return li_retorno


end function

public function integer uf_obtener_atributo (integer a_index, ref integer a_ref_nrocolumna, ref any a_ref_datacolumna, ref integer a_ref_visiblecolumna);// **********************************************************************************
//	Descripción			:	uf_obtener_atributo: Obtener el atributo de una cadena: Orden, valor, visible
//
//	Argumentos			:	a_cadena, N: nrocolumna,D: Data de la columna, V: Visible   1,1,0
//								La cadena debe tener el formato: 'N, D, V'
//
//	Valor de Retorno	:	a_ref_nrocolumna, a_ref_datacolumna, a_ref_visiblecolumna
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			05/04/2017		Versión inicial
// **********************************************************************************
String 	ls_valor 
Integer   li_orden,li_retorno
Any		la_nrocolumna,la_datacolumna, la_visiblecolumna

// Estructura de la cadena: Orden, valor, visible
 
la_datacolumna = istr_preview.a[a_index]
la_nrocolumna  = a_index

ls_valor = String(la_datacolumna)

If Len(ls_valor) > 0 Then 	
	la_visiblecolumna = 1
Else
	la_visiblecolumna = 0
End If

//a_tipo: N: nrocolumna, D: Data de la columna, V: Visible 0/1
li_retorno = 1
If li_retorno = 1 Then 			
	a_ref_nrocolumna 	= Int(la_nrocolumna)
	a_ref_datacolumna 	= 	la_datacolumna
	a_ref_visiblecolumna 	= Int(la_visiblecolumna)
End If

Return li_retorno

end function

public function integer uf_setear_anio_mes (string a_columna);// **********************************************************************************
//	Descripción			:	Función que permite setear de valores a las columnas año y mes del dw_filtro
//
//	Valor de Retorno	:	1: Ok, -1: Error
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			18/04/2017		Versión inicial
// **********************************************************************************
Integer li_retorno
Datetime ld_FechaActual		// 	Fecha Actual

sqlca.uf_usp_fechahora_select(ld_FechaActual)

ii_Anio	=	Year(Date(ld_FechaActual))
ii_Mes	=	Month(Date(ld_FechaActual))

Choose Case a_columna
	Case 'anio','año'
		dw_filtro.SetItem(1,a_columna,ii_Anio)
		li_retorno = 1
	Case 'mes'
		dw_filtro.SetItem(1,a_columna,ii_Mes)
		li_retorno = 1
	Case 'desde'
		If Isnull(dw_filtro.object.desde[dw_filtro.GetRow()]) then 
			id_desde	=	Date(ld_FechaActual)
		else
			id_desde	=	Date((dw_filtro.object.desde[dw_filtro.GetRow()]))
		End if
		dw_filtro.SetItem(1,a_columna,id_desde)
		li_retorno = 1
	case 'hasta'
		If Isnull(dw_filtro.object.hasta[dw_filtro.GetRow()]) then
			id_hasta	=	Date(ld_FechaActual)
		else
			id_hasta	=	Date(dw_filtro.object.hasta[dw_filtro.GetRow()])
		End if
		dw_filtro.SetItem(1,a_columna,id_hasta)
		li_retorno = 1
End Choose

Return li_retorno
end function

private function integer uf_setear_parametros (integer a_fila, string a_columna, string a_coltype, any a_valor);// **********************************************************************************
//	Descripción			:	uf_setear_parametros: Setear los valores  en dw
//
//	Argumentos			:   a_fila, a_columna, a_coltype, a_valor
//
//	Valor de Retorno	:	li_retorno; 1 Ok, -1 No pasa validación
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			06/04/2017		Versión inicial
// **********************************************************************************
Integer			li_valor_todos = 0
String				ls_type 
Integer 			li_retorno
DWObject 		ldwo

/* Realizar la conversión del tipo de dato a Integer o String */
Choose Case a_coltype
	Case 'number' , 'long', 'int', 'real' , 'decimal' , 'dec'
		ls_type = 'N'
		li_retorno = 1
	Case 'date', 'datetime'
		ls_type='F'
		li_retorno = 1
	Case Else
		ls_type = 'T'
		li_retorno = 1
End Choose		

If li_retorno = 1 Then
//	/*M: Si es llamado desde el menú entonces enviar el parámetro la_valor_todos */
//	If is_tipollamado = 'M' Then 
//		If ls_type = 'T' Then // Cadena de texto
//			 dw_filtro.SetItem(a_fila,a_columna,String(li_valor_todos))
//		Else
//			dw_filtro.SetItem(a_fila,a_columna,li_valor_todos)
//		End If 
//		
//	/*V: Si es llamado desde la ventana entonces enviar el parámetro la_valor_final */
//	Else
		If ls_type = 'T' Then // Cadena de texto
			 dw_filtro.SetItem(a_fila,a_columna,String(a_valor))
		Elseif ls_type='F' then //Fechas
			dw_filtro.SetItem(a_fila,a_columna,Date(a_valor))
		else
			dw_filtro.SetItem(a_fila,a_columna,Integer(a_valor))
		End If 
//	End If 
End If

Return li_retorno



end function

public function integer wf_generar_sintaxys_dw ();//Obtener la sintaxis en el dw
// Walther		Rodriguez			04-12-2018				Ejecutar la sintaxys tomando los parametros desde la ventana

String 					ls_SintaxisDW
String						ls_campo
String						ls_parametros=''
String						ls_coltype
Integer					li_cont
Integer					li_nrocontrol
String						ls_valor
String						ls_existeCampo
String						ls_error
Long						ll_valor
Decimal					ld_valor
Integer					li_ret=1
uo_Dsbase  				lds_Datastore
Integer					li_ini_arg_sp=10
Boolean					lb_parametrosventana=False
Boolean					lb_parametrocadena


IF  is_tipollamado = 'V' and ib_usarfiltro = False THEN
	lb_parametrosventana=TRUE
End if
	
	
For li_cont = li_ini_arg_sp To (li_ini_arg_sp +  ii_nroargumentossp )
		//Obtener el campo de argumento
		li_nrocontrol				=	0 
		lb_parametrocadena	=	False
		If li_cont<=Int(UpperBound(istr_preview.s[])) then
			
			If IsNull(istr_preview.s[li_cont]) =True then Continue
			ls_campo		=	Trim(Lower(istr_preview.s[li_cont]))
			
			If lb_parametrosventana then
				If Long(ls_campo) <1 	then
					if Pos(ls_campo,",")>0 then lb_parametrocadena=True
				End if
				ls_valor	= ls_campo
			else
					//Verificar que exista en el DW
					if ls_campo='idcompania' or ls_campo='idunidadnegocio'  or ls_campo = 'idservidor' then
						ls_existeCampo		=	"1"
					else
						ls_existeCampo		=	dw_filtro.describe(ls_campo+".id")
					End if
					
					 if ls_existeCampo <> '!' then li_nrocontrol		=	Integer(ls_existeCampo)
					 if li_nrocontrol>0 then	//Si existe en el DW, obtener su data
						Choose case ls_campo
							case 'idservidor'
								ii_idservidor=7
								ls_valor	= String(ii_idservidor)
							case 'idcompania'
								ls_valor	= String(ii_idcompania)
							case 'idunidadnegocio'
								ls_valor	= String(ii_idunidadnegocio)
							case 'desde'
								ls_valor	=	String(id_desde,"yyyymmdd")
								lb_parametrocadena	= True
							case 'hasta'
								ls_valor	=	String(id_hasta,"yyyymmdd")
								lb_parametrocadena	= True
							case else
								ls_coltype 	= dw_filtro.Describe(ls_campo+'.coltype')
								 Choose case ls_coltype
									case 'number' , 'long', 'int'
										ll_valor	=dw_filtro.getitemnumber(1, ls_campo)	
										ls_valor	= Trim(String(ll_valor,"0##"))
									case 'real' , 'decimal' , 'dec'
										ld_valor	=dw_filtro.getitemdecimal(1, ls_campo)	
										ls_valor	= Trim(String(ld_valor,"0##.0#"))
									case else
										lb_parametrocadena	= True
										ls_valor	=dw_filtro.GetItemString(1, ls_campo)		
								End choose	
						End choose
					 End if
			End if		
			If ls_valor='%' or lb_parametrocadena =true then
				ls_parametros=trim(ls_parametros) + ",'" + ls_valor+"'"
			else
				ls_parametros=trim(ls_parametros) + "," + ls_valor
			End if
		Else
			Exit
		End if
Next


ls_parametros=Right(ls_parametros,Len(ls_parametros)-1)
//EJECUTAR PROCEDIMIENTO
lds_Datastore  		=gf_procedimiento_consultar(is_sp_sintaxys+ ' ' +ls_parametros ,sqlca)
If IsValid(lds_Datastore)=False then
	gf_mensaje(gs_Aplicacion, 'No se pudo obtener la  sintaxis para DW' , 'Verifique los datos requeridos', 1)
	li_ret = -1
	Return li_ret
End if
If lds_Datastore.RowCount() > 0 Then
	ls_SintaxisDW	=	lds_Datastore.getitemstring( 1, 1)
	clipboard(ls_SintaxisDW)
	if Len(ls_SintaxisDW)>10 and IsNull(ls_SintaxisDW)=False then
		If  dw_principal.Create( ls_SintaxisDW, ls_Error ) = -1 then
			gf_mensaje(gs_Aplicacion, 'Verifique la sintaxis generada para DW' , '', 1)
			 li_ret=-1
		Else
			dw_principal.SetTransObject( SQLCA )
			li_ret=1
		End if
	else
		gf_mensaje(gs_Aplicacion, 'No se pudo obtener la  sintaxis para DW' , 'Verifique los datos requeridos', 1)
		li_ret = -1
	End if
Else
	gf_mensaje(gs_Aplicacion, 'No se pudo crear la  sintaxis para DW' , 'Verifique los datos requeridos', 1)
	li_ret = -1
End if


Return li_ret


end function

public function boolean uf_validar_datawindows ();//Validar Fechas
Boolean		lb_validacionOK=True
DateTime	ldt_fechaactual
String			ls_existedesde
String			ls_existehasta

//Verificar si existen los campos
ls_existedesde		=	dw_filtro.describe("desde.id")
ls_existehasta		=	dw_filtro.describe("hasta.id")

If ls_existedesde <> '!' and IsNull(id_desde)=False then
	if Len(String(id_desde,"yyyymmdd"))=8 then
		//Hay desde
		if  ls_existehasta <> '!' and  IsNull(id_hasta)=False then
			if Len(String(id_hasta,"yyyymmdd"))=8 then
			//Hay hasta
			if id_desde>id_hasta then
				gf_mensaje( gs_Aplicacion,'Fecha DESDE no puede ser mayor a fecha HASTA','', 1)
				lb_validacionOK=False
			End if
			End if
		End if
	End if
end if

If lb_validacionOK then
		If IsNull(ii_anio)=False then
			if ii_anio<>0 then
				sqlca.uf_usp_fechahora_select(ldt_fechaactual)
				//Hay año
				If ii_anio>Year(Date(ldt_fechaactual)) then
					gf_mensaje( gs_Aplicacion,'Año no puede ser mayor al año actual','', 1)
					lb_validacionOK=False
				End if
			End if
		End if
End if

Return lb_validacionOK

end function

on w_base_consulta_filtro_seg.create
int iCurrent
call super::create
if this.MenuName = "m_mbase" then this.MenuID = create m_mbase
this.dw_filtro=create dw_filtro
this.uo_visualizar=create uo_visualizar
this.dw_servidorusuario=create dw_servidorusuario
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_filtro
this.Control[iCurrent+2]=this.uo_visualizar
this.Control[iCurrent+3]=this.dw_servidorusuario
end on

on w_base_consulta_filtro_seg.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.dw_filtro)
destroy(this.uo_visualizar)
destroy(this.dw_servidorusuario)
end on

event open;call super::open;// **********************************************************************************
// Control de Versión:
//
// Versión 	Autor 			Fecha 			Descripción
// 1.0 											Versión inicial
// 1.1 		Julio Calvo 	03/12/2018 		Activar herencia 'w_base'
// 1.2			Julio Calvo 	03/12/2018 		Cargar los datawindows a sus arrays y Cargar el filtro			
// 1.3			Walther		28/01/2019		Mejoras
// **********************************************************************************

Boolean lb_validacion

ib_dinamico=False

/* Recepciona los parametros de impresión */
If	IsNull( Message.PowerObjectParm ) Then Return
istr_preview = message.powerobjectparm	

/* Programar reporte dinámico - JC - 20170417  */
/* Tipo de llamado a la ventana 
V: ventana, cargar el reporte con los parámetros en los ddw y retrieve
M: menú, los dddw debe tener el valor de todos  */  
is_tipollamado = istr_preview.tipollamado // 'V' / 'M' 

/* Usar filtro S: Si, permite hacer retrieve del dw_filtro en los dddw; No: Ocultar los filtros del dddw */
ib_usarfiltro     = istr_preview.usarfiltro    // True / False

uo_visualizar.visible 	= (ib_usarfiltro=True)
dw_filtro.visible 		=  (ib_usarfiltro=True)

/* Validar estructura */
If uf_validar_str_preview() > 0 Then
	lb_validacion = True
	
	/* Si hay argumento, validar la estructura */
	If istr_preview.nargumentos > 0 Then
		If uf_validar_str_argumentos() > 0 Then
			lb_validacion = True
			
			If ib_usarfiltro = True Then
				/* Asignar el dw filtro a la ventana */
				If len(istr_preview.dataobject_filtro )>3 then
					dw_filtro.dataobject = istr_preview.dataobject_filtro
					dw_filtro.insertrow(1)									
					dw_filtro.postevent( 'ue_setear_filtro' ) 					
				End If	
			Else
				dw_filtro.visible = False
			End If	
		Else
			lb_validacion = False
			gf_mensaje( gs_Aplicacion, "Los parámetros para visualizar el reporte es incorrecta", "", 1)
			Close(This)
		End If
	End If
Else
	lb_validacion = False
	gf_mensaje( gs_Aplicacion, "Parametros de la consulta incorrectos...verifique", "", 1)
	Close(This)
End If

If lb_validacion = False Then Return

if  istr_preview.tipo = 1 or  istr_preview.tipo=2 then
	If len(istr_preview.dataobject )<3 then Return
	dw_principal.dataobject = istr_preview.dataobject
	//v1.2 Inicio - 20181203
	/*	Cargar los datawindows a sus arrays */
	This.uf_crear_array_dw( )
End if

/* Cargar el filtro */
This.Event ue_powerfilter()
//v1.2 Fin - 20181203

This.title 		= istr_preview.titulo
is_subtitulo	= istr_preview.subtitulo

Choose Case istr_preview.tipo
	Case 1,2 //Tipo1=DW , Tipo2=DS
		dw_principal.settransobject( sqlca )
		
		/* Realiza la recuperación del datawindow */
		If is_tipollamado = 'V' and ib_usarfiltro = False Then
			This.triggerevent( 'ue_recuperar' )	
		End If
		
	Case 3 //Tipo3=Store (para DW dinamicos)
		ii_nroargumentossp	=	Integer(Upperbound(istr_preview.s[])) - 9	//Los argumentos comienzan en 10
		is_sp_sintaxys			=	istr_preview.uspnombre
		If Len(is_sp_sintaxys)>2 and Pos(is_sp_sintaxys,'.',1)>0 then
			ib_dinamico=True
		Else
			lb_validacion = False
			gf_mensaje( gs_Aplicacion, "Los parámetros para DW dinamico no son correctos", "", 1)
			Close(This)
		End if
		
		/* Realiza la recuperación del datawindow */
		If is_tipollamado = 'V' and ib_usarfiltro = False Then
			if wf_generar_sintaxys_dw()<>1 then
				gf_mensaje( gs_Aplicacion, "No se puedo generar DW dinamico", "", 1)
				Return
			End if
			This.triggerevent( 'ue_recuperar' )	
		End If
		
	Case Else
//		this.event ue_cargar(istr_preview.tipo)			
End Choose
	

	
/* Configura datawindow para impresión */
dw_principal.setredraw( True )

//Cambiar el tamaño de la ventana
If istr_preview.maximizar Then
	This.windowstate=Maximized!
Else
	This.windowstate=Normal!
End If	
 


/*	Cargar los datawindows y datastores a sus arrays */
This.uf_crear_array_dw( )
This.uf_crear_array_ds( )


end event

event resize;call super::resize;SetRedraw(False)
Integer	li_alto_visualizar
dw_servidorusuario.x 	=  BordeVertical
dw_servidorusuario.y		 = st_fondo.y+st_fondo.height+BordeHorizontal

li_alto_visualizar	=	0
If ib_usarfiltro = True Then
	dw_filtro.y 		 			=  dw_servidorusuario.y
	dw_filtro.x					=	dw_servidorusuario.x + dw_servidorusuario.width + BordeHorizontal
	uo_visualizar.y				=	st_fondo.y+st_fondo.height + 10
End if

dw_principal.y		 = dw_servidorusuario.y + dw_servidorusuario.height +( BordeVertical * 2 )
dw_principal.x 		= BordeVertical
dw_principal.width = newwidth - ( BordeVertical * 2 )
dw_principal.height = newheight - ( dw_servidorusuario.y + dw_servidorusuario.height + BordeVertical * 2 )


SetRedraw(True)
end event

event close;call super::close;Close( This )
end event

event ue_recuperar;// **********************************************************************************
//	Descripción			:	Evento que permite setear null a las posiciones de los argumento [nargumentos + 1].. [24] ..[25]
//
//	Valor de Retorno	:	none
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			18/04/2017		Versión inicial
// **********************************************************************************

Integer li_nro
Integer li_cont
Any	  la_null

SetNull(la_null)

/* Si hay argumentos pasar parámetros */
If istr_preview.nargumentos > 0 Then	
	
	If ib_usarfiltro = True Then
		/* Asignar argumentos del filtro a la estructura istr_preview_arg */
		dw_filtro.TriggerEvent( 'ue_asignar_argumento' )
		
		li_nro = istr_preview.nargumentos + 1
		
		For li_cont = li_nro to 25
			istr_preview_arg.a[li_cont]=la_null
		Next	
	End If	
End If	

This.TriggerEvent( 'ue_retrieve' )




end event

event ue_preopen;call super::ue_preopen;this.ii_modoventana	=	3 //Ventana con filtro
Return AncestorReturnValue
end event

type st_titulo from w_base`st_titulo within w_base_consulta_filtro_seg
boolean visible = true
integer x = 91
integer y = 12
integer width = 480
integer height = 48
end type

type st_fondo from w_base`st_fondo within w_base_consulta_filtro_seg
boolean visible = true
integer y = 0
integer width = 2784
integer height = 88
end type

type dw_principal from w_base`dw_principal within w_base_consulta_filtro_seg
integer x = 9
integer y = 332
integer width = 5134
integer height = 1576
string title = ""
string dataobject = "dw_vacio"
boolean hscrollbar = true
string icon = "AppIcon!"
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_menuexportar = true
boolean ib_menuauditoria = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_post_retrieve;call super::ue_post_retrieve;ib_cambioparametros=False
end event

type st_menuruta from w_base`st_menuruta within w_base_consulta_filtro_seg
integer x = 2309
integer y = 0
integer height = 44
end type

type dw_filtro from uo_dwfiltro within w_base_consulta_filtro_seg
event ue_setear_filtro ( )
event type integer ue_asignar_argumento ( )
event type integer ue_setear_primer_valor ( string a_colname,  string a_coltype,  string a_coldata )
event ue_post_itemchanged ( )
integer x = 1486
integer y = 164
integer width = 2309
integer height = 68
integer taborder = 10
boolean bringtotop = true
boolean border = false
borderstyle borderstyle = stylebox!
boolean ib_dwtipofiltro = true
end type

event ue_setear_filtro();// **********************************************************************************
//	Descripción			:	Evento que permite setear de valores al dw_filtro
//
//	Valor de Retorno	:	none
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			18/04/2017		Versión inicial
// **********************************************************************************

Integer	li_Columna, li_caracteres
String		ls_Columna, ls_dddw_excluir = ''
String		ls_cadena		
Integer 	li_cont, li_nrocolumna,li_visiblecolumna
Any 		la_datacolumna, la_retorno_valor
String 	ls_dddw_name,ls_dddw_displaycolumn,ls_dddw_datacolumn
String 	ls_coltype, ls_tipo
Datawindowchild ldwc_Child		//Datawindow hijo donde se carga la lista desplegable de la columna

/* La cantidad de parámetros debe ser igual a la cantidad de columnas del dddw */
If	( This.dataobject = '' or IsNull(This.object.datawindow.column.count) ) Then Return

If istr_preview.nargumentos > 0 Then
	For li_cont = 1 To istr_preview.nargumentos
		
		/* Enviar ls_cadena y obtener: número de columna, data columna, visible */
		 If uf_obtener_atributo(li_cont, li_nrocolumna, la_datacolumna, li_visiblecolumna) < 1 Then
			gf_mensaje( gs_Aplicacion, "No se ha logrado obtener los valores para visualizar el reporte", "", 1)
		End If
		
		If (li_nrocolumna < 1 ) Then Return
		ls_Columna 	= Describe( '#' + String( li_nrocolumna ) + '.name' )  
		
		ls_coltype 	= This.Describe('#' + string(li_cont) + '.coltype')
		 If IsNull(ls_coltype) or ls_coltype = '' Then Return
		 
		/* Si tiene dddw entonces continuar  */
		If ( Len( Describe( '#' + String( li_nrocolumna ) + '.DDDW.Name' ) ) > 1 ) Then 		
	
			ls_dddw_name 		   = Describe( '#' + String( li_nrocolumna ) + '.DDDW.Name' ) 		     
			ls_dddw_displaycolumn = Describe( '#' + String( li_nrocolumna ) + '.DDDW.displaycolumn' )  
			ls_dddw_datacolumn 	   = Describe( '#' + String( li_nrocolumna ) + '.DDDW.datacolumn' )    
			
			/* validar dddw dddw_unidadnegocio */
			li_caracteres = Len(Trim(ls_dddw_name))
			If li_caracteres > 17 Then
			 ls_dddw_excluir = Mid(Trim(ls_dddw_name),1,18) 
			End If 	
			
			If This.GetChild( ls_Columna, ldwc_child ) < 1 Then Return
				ldwc_child.SetTransObject( SQLCA )
							
			/* Cargar los dddw  */
			This.Event ue_poblardddw( ls_Columna )
				
			/* Excluir al dddw dddw_unidadnegocio porque está habilitado al usuario por U.N.*/
			If (ls_dddw_excluir = '') or (ls_dddw_excluir <> 'dddw_unidadnegocio') Then
				ib_setear_todos = True
				/* Setear todos a cada dddw y retorna el valor con el tipo de dato correspondiente: la_retorno_valor */ 
				la_retorno_valor = gf_agregar_todos_dddw(ldwc_child ,ls_dddw_displaycolumn, ls_dddw_datacolumn)
 			 	uf_setear_parametros(1, ls_Columna,ls_coltype,la_datacolumna)	
			Else
				ib_setear_todos = False
				/* Inserta el primer valor que se obtiene del datawindowchild */				
				This.Event ue_setear_primer_valor(ls_Columna,ls_coltype,ls_dddw_datacolumn)
			End If
		Else  
			/* Cuando no tiene dddw, setear los valores por defecto la_datacolumna */
			 uf_setear_parametros(1, ls_Columna,ls_coltype,la_datacolumna)	
			
			
			 // Setear año y mes de la fecha actual
			 uf_setear_anio_mes(ls_Columna)
  	   End If 
	Next
	This.accepttext()
End If		

// Evita error de DDDW donde no se visualiza el DysplayColumn sino el DataColumn
If This.getrow() > 0 Then This.setrow(This.getrow())



end event

event type integer ue_asignar_argumento();// **********************************************************************************
//	Descripción			:	Evento que permite asignar de valores a la estructura istr_preview_arg
//
//	Valor de Retorno	:	none
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			18/04/2017		Versión inicial
//	1.1		Julio Calvo			04/09/2018		Agregó tipo 'date', 'datetime'
// **********************************************************************************
Integer  li_nrocolumna, li_count, li_retorno = 1
String    ls_datacolumna,ls_Columna, ls_coltype
Any 	   la_valor

If ib_usarfiltro = True Then
	
	/*Si la ventana va utilizar filtro */
	li_count = Integer(This.object.datawindow.column.count) 
	
	If (li_count > 0) Then 		
		
		For li_nrocolumna = 1 To li_count	
			ls_Columna = Describe( '#' + String( li_nrocolumna ) + '.name' ) 
			ls_coltype 	= This.Describe( ls_columna + ".ColType")
			
			// Asignar valor de acuerdo al tipo de dato del dw a la estructura 	istr_preview_arg
			Choose Case ls_coltype
				Case 'number' , 'long', 'int', 'real' , 'decimal' , 'dec'
					istr_preview_arg.a[li_nrocolumna]  = This.GetItemNumber(1, ls_columna)
					li_retorno = 1
				Case 'date', 'datetime'	//Wr fechas
					istr_preview_arg.a[li_nrocolumna]  = This.GetItemDate(1, ls_columna)
					li_retorno = 1
				Case Else
					istr_preview_arg.a[li_nrocolumna]  = This.GetItemString(1, ls_columna)
					li_retorno = 1
			End Choose			  
		Next      		
		
	End If 
	
End If

Return li_retorno
/* If ib_usarfiltro = False Then istr_preview_arg.a[li_cont]  */
end event

event type integer ue_setear_primer_valor(string a_colname, string a_coltype, string a_coldata);// **********************************************************************************
//	Descripción			:	Setea el primer valor del dddw que se obtiene del datawindowchild
//
//	Valor de Retorno	:	1: Ok, -1: Error
//
//	Control de Versión:
//
//	Versión	Autor					Fecha				Descripción
//	1.0		Julio Calvo			18/04/2017		Versión inicial
// **********************************************************************************

Datawindowchild ldwc_Child
String ls_tipo	
Integer li_retorno
 
If This.GetChild( a_colname, ldwc_child ) < 1 Then 
	li_retorno = -1
Else
	li_retorno = 1
End If	

ldwc_child.SetTransObject( SQLCA )

 If li_retorno = 1 Then
	Choose Case a_coltype
		Case 'number' , 'long', 'int', 'real' , 'decimal' , 'dec'
			This.SetItem(1,a_colname,ldwc_child.GetItemNumber( 1, a_coldata ))
			li_retorno = 1
		Case else
			This.SetItem(1,a_colname,ldwc_child.GetItemString( 1, a_coldata ))
			li_retorno = 1
	End choose
End If
	
Return li_retorno

end event

event itemchanged;call super::itemchanged;Integer 	li_ret
String		ls_colname
String		ls_dddwname
Boolean	lb_dddw		=	False
Boolean	lb_calendar	=	False

ls_colname			=	String(dwo.name)
ls_dddwname		=	String(dwo.dddw.Name)
is_datadropdown	=	data

if Not IsNull(ls_dddwname) and Len(ls_dddwname)>0 and ls_dddwname<>'?' then lb_dddw=True
if  Describe(ls_colname+".EditMask.DDCalendar")='yes' then lb_calendar=True

If lb_dddw then
	li_ret	=	this.GetChild(ls_colname,idw_dropdown)
	if li_ret<0 then Return
	choose case ls_colname
		Case 'IdCompania'
			ii_idcompania		=	Integer(is_datadropdown)
		case 'IdUnidadNegocio'
			ii_idunidadnegocio	=	Integer(is_datadropdown)
		Case 'anio','año'
			ii_anio	=	Integer(is_datadropdown)
		Case 'mes'
			ii_mes	=	Integer(is_datadropdown)
	End choose
End if

if lb_calendar then
	Choose case ls_colname
		Case 'desde'
			id_desde=Date(is_datadropdown)
		case 'hasta'
			id_hasta=Date(is_datadropdown)
	End choose
	this.accepttext( )
End if

ib_cambioparametros=True

end event

event editchanged;call super::editchanged;Choose case lower(dwo.name)
	Case 'desde'
		is_datadropdown=data
		id_desde=Date(is_datadropdown)
	case 'hasta'
		is_datadropdown=data
		id_hasta=Date(is_datadropdown)
	case 'anio','año'
		is_datadropdown=data
		ii_anio	=	Integer(is_datadropdown)
End choose
end event

event ue_poblardddw;call super::ue_poblardddw;datawindowchild		ldwc_Child

If This.GetChild( as_columna, ldwc_Child ) < 1 Then Return

ldwc_child.SetTransObject( SQLCA )
Choose case as_columna
		Case 'mes'
			ldwc_Child.Retrieve()
		Case 'anio','año'
			ldwc_Child.Retrieve()
End choose
end event

type uo_visualizar from uo_boton within w_base_consulta_filtro_seg
integer x = 5184
integer y = 12
integer width = 677
integer taborder = 20
boolean bringtotop = true
string is_imagen = "Img\Icono\Actualizar.png"
string is_texto = "Visualizar"
string is_textooltiptext = "Visualizar"
end type

on uo_visualizar.destroy
call uo_boton::destroy
end on

event ue_postclicked;call super::ue_postclicked;/* Generar el DW si es dinamico */
If ib_dinamico then
	if ib_cambioparametros then
		//Limpiar el DW
		dw_principal.reset()
		if wf_generar_sintaxys_dw()<>1 then
			gf_mensaje(gs_Aplicacion, 'No se pudo generar la  sintaxis para DW' , 'Verifique los datos requeridos', 1)
			Return
		End if
	End if
End if


/* Realizar el retrieve al dw */
dw_filtro.accepttext( )
if uf_validar_datawindows()  then
	dw_principal.event ue_retrieve( )
End if
end event

type dw_servidorusuario from uo_filtro_servidor_usuario within w_base_consulta_filtro_seg
integer y = 160
integer width = 1504
integer height = 76
integer taborder = 30
boolean bringtotop = true
end type

