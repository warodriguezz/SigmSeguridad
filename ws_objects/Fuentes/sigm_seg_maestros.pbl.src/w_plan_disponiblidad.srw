$PBExportHeader$w_plan_disponiblidad.srw
forward
global type w_plan_disponiblidad from w_base
end type
type st_servidores from statictext within w_plan_disponiblidad
end type
type tab_proceso from tab within w_plan_disponiblidad
end type
type tabpage_contingencia from userobject within tab_proceso
end type
type dw_control_contingencia from uo_dwbase within tabpage_contingencia
end type
type dw_usuario_contingencia from uo_dwbase within tabpage_contingencia
end type
type tabpage_contingencia from userobject within tab_proceso
dw_control_contingencia dw_control_contingencia
dw_usuario_contingencia dw_usuario_contingencia
end type
type tabpage_cambio from userobject within tab_proceso
end type
type cb_cambiologin from commandbutton within tabpage_cambio
end type
type cbx_1 from checkbox within tabpage_cambio
end type
type dw_usuario_autenticacion from uo_dwbase within tabpage_cambio
end type
type tabpage_cambio from userobject within tab_proceso
cb_cambiologin cb_cambiologin
cbx_1 cbx_1
dw_usuario_autenticacion dw_usuario_autenticacion
end type
type tab_proceso from tab within w_plan_disponiblidad
tabpage_contingencia tabpage_contingencia
tabpage_cambio tabpage_cambio
end type
end forward

global type w_plan_disponiblidad from w_base
integer width = 6354
integer height = 2980
string title = "Plan de disponibilidad de sistemas"
boolean ib_toolbarmodoconsulta = true
st_servidores st_servidores
tab_proceso tab_proceso
end type
global w_plan_disponiblidad w_plan_disponiblidad

type variables

Integer	ii_idservidor
String		is_nombreServer
String		is_linkedserver
Boolean	ib_servidordisponible
String		is_servidores
Integer	ii_idparametro
String		is_parametros[4]
Boolean	ib_confok


//String is_codigoUsuario
//Integer ii_filasseleccionadas
//
end variables

forward prototypes
public function integer wf_seleccionar_contigencia ()
end prototypes

public function integer wf_seleccionar_contigencia ();Integer	li_ret
Integer	li_Rowcount
Integer	li_fila


this.setredraw( FALSE)
li_Rowcount	=dw_principal.rowcount( )	
For li_fila	=	1 	to li_Rowcount
	if lower(dw_principal.getitemstring( li_fila, 'estado'))='contingencia' then
		dw_principal.setitem(li_fila, 'sel', '1')
	End if
Next
this.setredraw( TRUE)

Return li_fila
end function

on w_plan_disponiblidad.create
int iCurrent
call super::create
this.st_servidores=create st_servidores
this.tab_proceso=create tab_proceso
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_servidores
this.Control[iCurrent+2]=this.tab_proceso
end on

on w_plan_disponiblidad.destroy
call super::destroy
destroy(this.st_servidores)
destroy(this.tab_proceso)
end on

event resize;call super::resize;SetRedraw(False)
		
		st_servidores.y			=	BordeHorizontal + il_AlturaTitulo
		st_servidores.x			=	BordeVertical
		

		dw_principal.y 			=  st_servidores.y + st_servidores.height 
		dw_principal.x 			= st_servidores.x
		dw_principal.width		= (newwidth - ( BordeVertical * 2 )) / 3
		dw_principal.height	= ( newheight - ( BordeHorizontal * 2 ) - (il_AlturaTitulo + st_servidores.height ) ) 
	
		tab_proceso.y			=	dw_principal.y 
		tab_proceso.x			=	dw_principal.x + 	dw_principal.width + BordeVertical
		tab_proceso.width 	= 	dw_principal.width + (newwidth - ( BordeVertical * 2 )) / 2
		tab_proceso.height 	= 	dw_principal.height
	
		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.y				=	st_titulo.y /2 
		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.x 			= 	st_titulo.x /2  
		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.width		=  (newwidth - ( BordeVertical * 2 )) / 3
		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.height		=	dw_principal.height
	
		tab_proceso.tabpage_contingencia.dw_control_contingencia.y				=	tab_proceso.tabpage_contingencia.dw_usuario_contingencia.y
		tab_proceso.tabpage_contingencia.dw_control_contingencia.x 				=  	( tab_proceso.tabpage_contingencia.dw_usuario_contingencia.x + tab_proceso.tabpage_contingencia.dw_usuario_contingencia.width ) +  BordeVertical
		tab_proceso.tabpage_contingencia.dw_control_contingencia.width		=  	tab_proceso.tabpage_contingencia.dw_usuario_contingencia.width + (newwidth - ( BordeVertical * 2 )) / 3
		tab_proceso.tabpage_contingencia.dw_control_contingencia.height		=	tab_proceso.tabpage_contingencia.dw_usuario_contingencia.height


	    tab_proceso.tabpage_cambio.dw_usuario_autenticacion.y				=		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.y
		tab_proceso.tabpage_cambio.dw_usuario_autenticacion.x 				= 		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.x 
		tab_proceso.tabpage_cambio.dw_usuario_autenticacion.width			=  		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.width + (newwidth - ( BordeVertical * 2 )) / 3
		tab_proceso.tabpage_cambio.dw_usuario_autenticacion.height			=		tab_proceso.tabpage_contingencia.dw_usuario_contingencia.height

		
 SetRedraw(True)

end event

event ue_eliminar;call super::ue_eliminar;return -1
end event

event open;call super::open;String				ls_parametros
String				ls_estado
DateTime		ldt_fecha

uo_dsbase		lds_query

//dw_control.scrolltorow(dw_control.Insertrow(0))
Tab_proceso.tabpage_cambio.cb_cambiologin.Enabled = False

tab_proceso.tabpage_contingencia.dw_control_contingencia.scrolltorow(tab_proceso.tabpage_contingencia.dw_control_contingencia.Insertrow(0))

ib_confok	=	True

//Obtiene Id del parametro a controlar
ls_parametros		=	String(gi_idaplicacion)+",0,0,C,PlanContingencia"
lds_query			= 	gf_Procedimiento_Consultar("Framework.usp_ParametroAplicacion_Select_03 '"+ls_parametros+"',3" ,SQLCA) 

if IsVaLid(lds_query) = False then
	ib_confok	=	False
Else
	if lds_query.rowcount( ) < 1 then
		ib_confok	=	False
	Else
		if Integer(lds_query.GetItemnumber( 1,1))=0 or lds_query.GetItemstring( 1,2)='!' then
			ib_confok	=	False
		End if
	End if
End if

//dw_control.event ue_iniciar( )
tab_proceso.tabpage_contingencia.dw_control_contingencia.event ue_iniciar( )


if ib_confok	then

	is_parametros[1]=String(lds_query.GetItemnumber( 1,1))	//Id
	is_parametros[2]=lds_query.GetItemstring( 1,2)	//Estado
	is_parametros[3]=lds_query.GetItemstring( 1,3)	//Fecha ini
	is_parametros[4]=lds_query.GetItemstring( 1,4)	//Fecha fin
	
	ii_idparametro	= Integer(is_parametros[1])
	ls_estado		= is_parametros[2]
	
	ldt_fecha			=	DateTime(gf_remplazar_carateres(is_parametros[3],'_', ':'))
	
	If ls_estado='S' then
		tab_proceso.tabpage_contingencia.dw_control_contingencia.object.t_iniciar.text			=  'DETENER'
		tab_proceso.tabpage_contingencia.dw_control_contingencia.Object.t_iniciar.Color		= 	Rgb(255,0,0)
		tab_proceso.tabpage_contingencia.dw_control_contingencia.SetItem(1,'fehcainicio',ldt_fecha)
	Else
		tab_proceso.tabpage_contingencia.dw_control_contingencia.object.t_iniciar.text			='INICIAR'
		tab_proceso.tabpage_contingencia.dw_control_contingencia.Object.t_iniciar.Color		= 	Rgb(0,255,100)
	End if
End if




end event

event ue_postopen;call super::ue_postopen;if ib_confok=False then 	gf_mensaje(gs_aplicacion,"No se encontró el parametro de configuración 'PlanContingencia'..NO se puede CONFIGURAR",'', 3)
end event

event ue_vistaprevia;Return  
end event

type st_titulo from w_base`st_titulo within w_plan_disponiblidad
end type

type st_fondo from w_base`st_fondo within w_plan_disponiblidad
end type

type dw_principal from w_base`dw_principal within w_plan_disponiblidad
string tag = "<MenuAdicional:S>"
integer x = 46
integer y = 252
integer width = 2167
integer height = 992
string title = ""
string dataobject = "dw_servidor_plan"
boolean hscrollbar = true
boolean ib_editar = false
boolean ib_actualizar = false
boolean ib_activarfiltros = false
boolean ib_menupopup = false
boolean ib_menufiltrar = true
boolean ib_activareventoeditaraleliminarregistro = false
end type

event dw_principal::ue_retrieve;call super::ue_retrieve;return this.retrieve(4,'')
 
end event

event dw_principal::ue_agregar_registro_pre;call super::ue_agregar_registro_pre;//	1.0		Walther Rodriguez		10/07/2024		No se usa IDSERVIDOR

String 			ls_codigousuario
Integer			 li_retorno
String				ls_retorno[]
string 			ls_Parametros,ls_Error

uo_dsbase		luo_ds_query
str_response    lstr_Response

str_arg  				lstr_Enviar

//if dw_principal.Getrow()<1 or dw_principal.Getrow()<1 then Return -1

//luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2," + String(ii_idservidor) , SQLCA)	
luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2" , SQLCA)	//1.0

	If luo_ds_query.rowcount() < 1 then Return -1

		lstr_response.b_usar_datastore		= 	True
		lstr_response.ds_datastore    			= 	luo_ds_query
		lstr_response.s_titulo      				= 	'Listado de Usuarios' 
		lstr_response.b_seleccion_multiple	= 	FALSE
		lstr_response.b_mostrar_contador		= 	False
		lstr_response.s_titulos_columnas		=	'1:Usuario'
		lstr_response.b_redim_ventana		= 	True
		lstr_response.l_ancho					= 	1000
		lstr_response.l_alto						= 	1780
		lstr_response.str_argumentos			= lstr_Enviar
	  
		OpenWithParm(w_reponse_selecionar_usuario ,	lstr_Response)

		IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
		IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1
		
		ls_codigousuario 				=  luo_ds_query.getitemstring(luo_ds_query.ii_filasseleccionadas[1],'Usuario')

		ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',2,1"
		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Rol_Sevidor", ls_Parametros, ls_retorno, ls_Error)

		dw_principal.event ue_retrieve()

	Return -1




end event

event dw_principal::ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;// Si se elige la opción 2 se cancela la solicitud de eliminación
String ls_codigousuario,ls_Parametros
Integer li_retorno
String ls_retorno[]
String ls_Error

IF gf_mensaje( 'Confirmación','Está seguro de eliminar este registro.','', 4) = 2 Then
	Return -1
Else
//	If dw_servidores.rowcount() >   0 Then 
//		gf_mensaje(gs_Aplicacion, 'Existen Servidores asociados', '', 3)
//		Return -1
//	Else
//		ls_codigousuario 				=  dw_principal.getitemstring( ai_row ,'codigousuario')
//		ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',2,2"
//		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Usuario_Rol_Sevidor", ls_Parametros, ls_retorno, ls_Error)
//		this.deleterow( ai_row)
//		dw_principal.event ue_retrieve()
	End If
	
//End If

Return -1
end event

event dw_principal::rowfocuschanged;call super::rowfocuschanged;Integer	li_ret
if currentrow > 0 then
	ii_idservidor			=	this.getitemnumber(currentrow, 'idservidor')
	is_nombreServer	=	this.getitemstring(currentrow, 'nombreservidor')
	is_linkedserver		=	this.getitemstring(currentrow, 'nombrelinkedserver')
else
	ii_idservidor			=	0
	is_nombreServer	=	''
	is_linkedserver		=	''
End if

//dw_usuarios.reset()

tab_proceso.tabpage_contingencia.dw_usuario_contingencia.reset()   
tab_proceso.tabpage_cambio.dw_usuario_autenticacion.reset()   
	
if IsNull(is_nombreServer) then is_nombreServer=''
if isnull(is_linkedserver) then is_linkedserver=''
ib_servidordisponible = (f_servidor_disponible(is_nombreServer,is_linkedserver) > 0)
//if ib_servidordisponible then	dw_usuarios.event ue_retrieve( )

if ib_servidordisponible then	tab_proceso.tabpage_contingencia.dw_usuario_contingencia.event ue_retrieve( )
if ib_servidordisponible then	tab_proceso.tabpage_cambio.dw_usuario_autenticacion.event ue_retrieve( )
//.triggerevent("ue_retrieve")   

end event

event dw_principal::ue_post_retrieve;call super::ue_post_retrieve;if is_parametros[2]='S' then wf_seleccionar_contigencia()
end event

type st_menuruta from w_base`st_menuruta within w_plan_disponiblidad
end type

type st_servidores from statictext within w_plan_disponiblidad
integer x = 55
integer y = 160
integer width = 453
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
long backcolor = 67108864
string text = "Servidores"
boolean focusrectangle = false
end type

type tab_proceso from tab within w_plan_disponiblidad
integer x = 2222
integer y = 184
integer width = 3730
integer height = 2276
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
integer selectedtab = 1
tabpage_contingencia tabpage_contingencia
tabpage_cambio tabpage_cambio
end type

on tab_proceso.create
this.tabpage_contingencia=create tabpage_contingencia
this.tabpage_cambio=create tabpage_cambio
this.Control[]={this.tabpage_contingencia,&
this.tabpage_cambio}
end on

on tab_proceso.destroy
destroy(this.tabpage_contingencia)
destroy(this.tabpage_cambio)
end on

event selectionchanged;dw_principal.event ue_retrieve()
end event

type tabpage_contingencia from userobject within tab_proceso
string tag = "R2DWH2"
integer x = 18
integer y = 112
integer width = 3694
integer height = 2148
long backcolor = 67108864
string text = "Usuario Contingencia"
long tabtextcolor = 33554432
string picturename = "Custom076!"
long picturemaskcolor = 536870912
dw_control_contingencia dw_control_contingencia
dw_usuario_contingencia dw_usuario_contingencia
end type

on tabpage_contingencia.create
this.dw_control_contingencia=create dw_control_contingencia
this.dw_usuario_contingencia=create dw_usuario_contingencia
this.Control[]={this.dw_control_contingencia,&
this.dw_usuario_contingencia}
end on

on tabpage_contingencia.destroy
destroy(this.dw_control_contingencia)
destroy(this.dw_usuario_contingencia)
end on

type dw_control_contingencia from uo_dwbase within tabpage_contingencia
event ue_iniciar ( )
integer x = 1637
integer width = 2203
integer height = 1296
integer taborder = 30
boolean bringtotop = true
string dataobject = "dwe_control"
boolean vscrollbar = false
boolean livescroll = false
boolean ib_actualizar = false
boolean ib_activarfiltros = false
boolean ib_resaltarfila = false
end type

event ue_iniciar();this.Setredraw( False)

Datetime	ldt_null
SetNull(ldt_null)

this.object.t_valservidores.visible		=False
this.object.t_valservidores.Color		= Rgb(20,185,59)
this.object.p_valservidores.visible		=False
this.object.p_valservidores.Filename 	="img\Icono\check.png"

this.object.t_valusuarios.visible			=False
this.object.t_valusuarios.Color			= Rgb(20,185,59)
this.object.p_valusuarios.visible		=False
this.object.p_valusuarios.Filename 	="img\Icono\check.png"

this.object.t_finproceso.visible			=False	
this.object.t_finproceso.Color			= Rgb(20,185,59)
this.object.p_finproceso.visible			=False	
this.object.p_finproceso.Filename 		="img\Icono\check.png"

this.object.t_servidores.visible			=False
this.object.t_servidores.Color			=Rgb(20,185,59)
this.object.p_servidores.visible			=False	
this.object.p_servidores.Filename 		="img\Icono\check.png"

this.setitem( 1, 'fehcainicio',ldt_null)
this.setitem( 1, 'fechafin',ldt_null)

this.Setredraw( True)
 



end event

event clicked;call super::clicked;Integer		li_cont
Integer		li_rowcount
String			ls_Servidores
Integer		li_retorno
String			ls_parametros
String			ls_retorno[]
String			ls_error
Integer		li_ret
String			ls_mensaje
Boolean		lb_validacionok
DateTime	ldt_fechaactual
String			ls_accion
String			ls_valor
String			ls_ret
String			ls_estado
DateTime	ldt_fecha
String			ls_fechainicio
String			ls_fechafinal
DateTime	ldt_null


SetNull(ldt_null)

this.accepttext( )

if dwo.name='p_iniciar' then 
	
	if ib_confok=FALSE then
		gf_mensaje(gs_aplicacion,"No se encontró el parametro de configuración 'PlanContingencia'..NO se puede CONFIGURAR",'', 2)
		Return
	End if
	
	ls_accion		=	Upper(this.object.t_iniciar.text)
	li_rowcount	=	dw_principal.rowcount( )
	
	//Llenando lista de servidores
	For li_cont = 1 to li_rowcount
		if dw_principal.GetItemString(li_cont, 'sel')='1' then
			ls_servidores	=	ls_servidores + String( dw_principal.GetItemNumber(li_cont, 'idservidor') ) + '-'
		End if
	Next
	ls_servidores	=	Left(ls_servidores,Len(ls_servidores) - 1)
	
	if ls_accion='INICIAR' then

		//Iniciar imagenes
		this.event ue_iniciar( )
		
		//Realizando validaciones
		li_ret=0
		ls_Parametros	 = "'"+ls_servidores+"',"+String(li_ret)
		li_retorno		 = gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Contingencia_validar", ls_Parametros, ls_retorno, ls_Error)
		li_ret				 = Integer(ls_retorno[1])
		lb_validacionok	=	True
		if li_ret <> 1 then
			lb_validacionok=False
			choose case li_ret
				case 0
					ls_mensaje	=	'No se encontraron servidores a configurar' 
				case -1
					ls_mensaje	=	'Algunos servidores no pueden ser accedidos' 
				case -2
					ls_mensaje	=	'Agunos servidores no tienen usuarios de contingencia' 
			End choose
			gf_mensaje(gs_aplicacion,ls_mensaje,'', 3)
		End if
			
			
		if lb_validacionok=false then
			if li_ret=-1 then
				this.object.t_valservidores.visible=True
				this.object.p_valservidores.visible=True
			
				this.Object.t_valservidores.Color		= 	Rgb(255,0,0)
				this.object.p_valservidores.Filename =	"img\Icono\uncheck.png"
			Elseif  li_ret=-2 then
				this.object.t_valservidores.visible=True
				this.object.p_valservidores.visible=True
				
				this.object.t_valusuarios.visible=True
				this.object.p_valusuarios.visible=True
				
				this.Object.t_valusuarios.Color		= 	Rgb(255,0,0)
				this.object.p_valusuarios.Filename =	"img\Icono\uncheck.png"
			End if
			
			Return
		End if
			
		//Validacion Ok
		this.object.t_valservidores.visible=True
		this.object.p_valservidores.visible=True
		
		this.object.t_valusuarios.visible=True
		this.object.p_valusuarios.visible=True
		
		this.object.t_finproceso.visible =True	
		this.object.p_finproceso.visible	=True
		
		//Finalizar los procesos del servidor
		li_ret				 =0
		ls_Parametros	 = "'"+ls_servidores+"',"+String(li_ret)
		li_retorno		 = gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Contingencia_EliminarSesiones", ls_Parametros, ls_retorno, ls_Error)
		li_ret				 = li_retorno
		if li_ret = -1 then
			this.object.t_finproceso.Color			= Rgb(255,0,0)
			this.object.p_finproceso.Filename 		="img\Icono\uncheck.png"
			Return
		End if
		
		
		//Actualizar estado de los servidores
		this.object.t_servidores.visible			=True
		this.object.p_servidores.visible			=True	
		
		li_ret				=0
		ls_Parametros	 = "'"+ls_servidores+"',1,"+String(li_ret)
		li_retorno		 = gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Contingencia_estado", ls_Parametros, ls_retorno, ls_Error)
		li_ret				 =Integer(ls_retorno[1])
		if li_ret <> 1 then
			this.object.t_servidores.Color			= Rgb(255,0,0)
			this.object.p_servidores.Filename 		="img\Icono\uncheck.png"
			Return
		End if
		
		dw_principal.event ue_retrieve( )
		
		//Colocar fecha y hora
		sqlca.uf_usp_fechahora_select(ldt_fechaactual)
		this.setitem( 1, 'fehcainicio',ldt_fechaactual)
		this.setitem( 1, 'fechafin',ldt_null)
		
		this.object.t_iniciar.text			=  'DETENER'
		this.Object.t_iniciar.Color		= 	Rgb(255,0,0)
		
		ls_estado		= 'S'
		ls_fechainicio	=String(ldt_fechaactual,"dd/mm/yy HH_mm")
		ls_fechafinal		=''
	else	
		if IsNull(ls_servidores) or ls_servidores='null' or Len(ls_servidores)< 1 then	
				gf_mensaje(gs_aplicacion,'No se encontraron servidores a configurar' ,'', 3)
				Return
		End if
		
		ldt_fecha			=this.getitemdatetime(1 , 'fehcainicio')
		
		//Iniciar imagenes
		this.event ue_iniciar( )
		
		li_ret				 =0
		ls_Parametros	 = "'"+ls_servidores+"',2,"+String(li_ret)
		li_retorno		 = gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Contingencia_estado", ls_Parametros, ls_retorno, ls_Error)
		li_ret				 =Integer(ls_retorno[1])
		if li_ret <> 1 then
			gf_mensaje(gs_aplicacion,'No se pudo restablecer el estado','', 3)
			Return
		End if
		
		dw_principal.event ue_retrieve( )
		
		//Colocar fecha y hora
		sqlca.uf_usp_fechahora_select(ldt_fechaactual)
		this.setitem( 1, 'fehcainicio',ldt_fecha)
		this.setitem( 1, 'fechafin',ldt_fechaactual)
		
				
		this.object.t_iniciar.text			='INICIAR'
		this.Object.t_iniciar.Color		= 	Rgb(0,255,100)
		
		ls_estado	=	'N'
		ls_fechainicio	=String(ldt_fecha,"dd/mm/yy HH_mm") 
		ls_fechafinal		=String(ldt_fechaactual,"dd/mm/yy HH_mm")
		
	End if
	
	//Guardar parametro
	ls_valor			=	ls_estado+":"+ls_fechainicio+":"+ls_fechafinal
	ls_Parametros	= String(ii_idparametro)+","+String(gi_idaplicacion)+",'C',' ',' ','PlanContingencia','C','"+ls_valor+"','L',0,0,0.00,0.00,' ',' ','Parametro','N'"
	ls_ret				=	gf_objetobd_ejecutar(SQLCA,"Framework.usp_ParametroAplicacion_Update",ls_Parametros)  

	If ls_ret = "SQL:-1" Then 
		gf_mensaje(gs_Aplicacion, 'No se pudo guardar parametros ', '', 2)
	End if		
	
End if
end event

type dw_usuario_contingencia from uo_dwbase within tabpage_contingencia
integer height = 1288
integer taborder = 10
boolean bringtotop = true
string dataobject = "dw_usuario_contingencia"
boolean ib_menudetalle = true
end type

event ue_retrieve;call super::ue_retrieve;Return this.retrieve(ii_idservidor)
end event

event ue_eliminar_registro_pre;call super::ue_eliminar_registro_pre;// Si se elige la opción 2 se cancela la solicitud de eliminación
String ls_codigousuario,ls_Parametros
Integer li_retorno
String ls_retorno[]
String ls_Error

if ib_servidordisponible then	

	IF gf_mensaje( 'Confirmación','Está seguro de eliminar este registro.','', 4) = 2 Then
		Return -1
	Else
		ls_codigousuario 				=  this.getitemstring( ai_row ,'codigousuario')
		ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',2"
		li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Contingencia_Usuario", ls_Parametros, ls_retorno, ls_Error)
		this.event ue_retrieve()
	End If

End if

Return -1
end event

event ue_agregar_registro_pre;call super::ue_agregar_registro_pre;//	1.0		Walther Rodriguez		10/07/2024		No se usa IDSERVIDOR
String 			ls_codigousuario
Integer			 li_retorno
String				ls_retorno[]
string 			ls_Parametros,ls_Error
Integer			li_fila
Integer			li_filasel
uo_dsbase		luo_ds_query
str_response    lstr_Response
str_arg  			lstr_Enviar

if ib_servidordisponible then	
	
	//luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2," + String(ii_idservidor) , SQLCA)
	luo_ds_query		= gf_Procedimiento_Consultar("Seguridad.usp_Consulta_Usuario 2" , SQLCA)	//1.0

	If luo_ds_query.rowcount() < 1 then Return -1

	lstr_response.b_usar_datastore		= 	True
	lstr_response.ds_datastore    			= 	luo_ds_query
	lstr_response.s_titulo      				= 	'Listado de Usuarios' 
	lstr_response.b_seleccion_multiple	= 	TRUE
	lstr_response.b_mostrar_contador		= 	False
	lstr_response.b_activar_filtros			=	True
	lstr_response.s_titulos_columnas		=	'1:Login usuario:700,3:Unidad:1000'
	lstr_response.b_redim_ventana		= 	True
	lstr_response.l_ancho						= 	2200
	lstr_response.l_alto						= 	1780
	lstr_response.str_argumentos			= lstr_Enviar
  
	OpenWithParm(w_reponse_selecionar_usuario ,	lstr_Response)

	IF UpperBound(luo_ds_query.ii_filasseleccionadas)<1 then	Return -1
	IF luo_ds_query.ii_filasseleccionadas[1]=0 then Return -1

	for li_fila= 1 to Integer(upperbound(luo_ds_query.ii_filasseleccionadas[]))
		li_filasel				=	luo_ds_query.ii_filasseleccionadas[li_fila]
		ls_codigousuario 	=  luo_ds_query.getitemstring(luo_ds_query.ii_filasseleccionadas[li_fila],'codigousuario')
//		if dw_usuarios.find("Codigousuario='"+ls_codigousuario+"'",1,dw_usuarios.RowCount())=0 then
		if tab_proceso.tabpage_contingencia.dw_usuario_contingencia.find("Codigousuario='"+ls_codigousuario+"'",1,tab_proceso.tabpage_contingencia.dw_usuario_contingencia.RowCount())=0 then
			ls_Parametros = string(ii_idservidor)+", '"+ls_codigousuario+"',1"
			li_retorno =  gf_Procedimiento_Ejecutar("Seguridad.usp_SQL_Contingencia_Usuario", ls_Parametros, ls_retorno, ls_Error)
		End if
	Next
	
	this.event ue_retrieve()

Else
	gf_mensaje(gs_Aplicacion, 'Servidor NO puede ser accedido', '', 3)
End if

Return -1




end event

type tabpage_cambio from userobject within tab_proceso
string tag = "RH75"
integer x = 18
integer y = 112
integer width = 3694
integer height = 2148
long backcolor = 67108864
string text = "Cambio Masivo de Autenticación"
long tabtextcolor = 33554432
string picturename = "CreateForeignKey!"
long picturemaskcolor = 536870912
cb_cambiologin cb_cambiologin
cbx_1 cbx_1
dw_usuario_autenticacion dw_usuario_autenticacion
end type

on tabpage_cambio.create
this.cb_cambiologin=create cb_cambiologin
this.cbx_1=create cbx_1
this.dw_usuario_autenticacion=create dw_usuario_autenticacion
this.Control[]={this.cb_cambiologin,&
this.cbx_1,&
this.dw_usuario_autenticacion}
end on

on tabpage_cambio.destroy
destroy(this.cb_cambiologin)
destroy(this.cbx_1)
destroy(this.dw_usuario_autenticacion)
end on

type cb_cambiologin from commandbutton within tabpage_cambio
integer x = 2848
integer y = 128
integer width = 622
integer height = 128
integer taborder = 30
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Cambio Tipo Login"
boolean default = true
end type

event clicked;// 	1.0	09/07/2204	Walther Rodriguez		No se envia IDSERVIDOR

Long li_fila, li_found,li_retorno
String ls_tipo_login
String ls_colsort
String ls_cadfind
String ls_Parametros
String ls_accion
String ls_CodigoUsuario, ls_CodigoLogin
String ls_tipo_login_actual,ls_tipo_login_nuevo,ls_ret
Integer li_idlogin_actual,li_idlogin_nuevo
Integer  li_cont
String ls_dsc_login_nuevo
String ls_parametrologin
Integer li_existe_login

If tab_proceso.tabpage_cambio.dw_usuario_autenticacion.event ue_validar() <> 1 Then Return

// descripcion <> 'SQL Server'
If tab_proceso.tabpage_cambio.dw_usuario_autenticacion.rowcount()>0 Then
	For li_fila = 1 to tab_proceso.tabpage_cambio.dw_usuario_autenticacion.rowcount()
			If tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemstring(li_fila, 'Usersel') = '1' Then
				ls_tipo_login_actual  	= tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemstring(li_fila, 'TipoLogin')
				ls_colsort	=	'TipoLogin'
				ls_cadfind = "" + ls_colsort +" <> "+ "'"+ls_tipo_login_actual+"' and Usersel = " +'"1"'  
				li_found =  tab_proceso.tabpage_cambio.dw_usuario_autenticacion.find( ls_cadfind, 1,  tab_proceso.tabpage_cambio.dw_usuario_autenticacion.RoWCount())		
				If li_found > 0 Then 
					gf_mensaje(gs_Aplicacion, 'No puede procesar usuarios con diferentes Tipo de Login', '', 3)
					  tab_proceso.tabpage_cambio.dw_usuario_autenticacion.event ue_retrieve()
					return
				Else
					li_cont = li_cont + 1
				End If
			End If
	Next
		If ls_tipo_login_actual ='S' Then 
			ls_dsc_login_nuevo ='Active Directory'
		End If
		If ls_tipo_login_actual ='U' Then 
			ls_dsc_login_nuevo ='SQL Server'
		End If
		
		
		if  gf_mensaje(gs_Aplicacion, 'Se realizara el cambio de ' + String(li_cont) +' Login por '+ls_dsc_login_nuevo+' Desea continuar ?', '', 4) = 2 then
			  tab_proceso.tabpage_cambio.dw_usuario_autenticacion.event ue_retrieve()
			return
		End If
		
End If

For li_fila = 1 to tab_proceso.tabpage_cambio.dw_usuario_autenticacion.rowcount()
	If tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemstring(li_fila, 'Usersel') = '1' Then
		ls_CodigoLogin		 	= tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemstring(li_fila, 'codigologin')
		ls_CodigoUsuario 		= tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemstring(li_fila, 'CodigoUsuario')
		ls_tipo_login_actual  	= tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemstring(li_fila, 'TipoLogin')
		li_idlogin_actual 		= tab_proceso.tabpage_cambio.dw_usuario_autenticacion.getitemNumber(li_fila, 'IdLogin')
		If ls_tipo_login_actual ='S' Then 
			ls_tipo_login_nuevo ='U'
			ls_dsc_login_nuevo ='Active Directory'
			li_idlogin_nuevo   =  2
		End If
		If ls_tipo_login_actual ='U' Then 
			ls_tipo_login_nuevo ='S'
			ls_dsc_login_nuevo ='SQL Server'
			li_idlogin_nuevo   = 1
		End If
		
		ls_parametrologin =  "'"+ls_CodigoUsuario+"','"+ls_tipo_login_nuevo+"'"
		li_existe_login		=	Integer(gf_objetobd_ejecutar(SQLCA, 'Seguridad.ufn_TipoLoginUsuario',ls_parametrologin ))
		If li_existe_login  >  0 then
			//ls_Parametros = "'"+ls_CodigoUsuario+"',"+String(li_idlogin_nuevo)+",'"+ls_CodigoLogin+"','"+ls_tipo_login_nuevo+"',"+String( ii_idservidor)
			ls_Parametros = "'"+ls_CodigoUsuario+"',"+String(li_idlogin_nuevo)+",'"+ls_CodigoLogin+"','"+ls_tipo_login_nuevo+"'" //1.0
			ls_ret	=	gf_objetobd_ejecutar(SQLCA,"Seguridad.usp_UsuarioLogin_Actual",ls_Parametros)  
			If ls_ret = "SQL:-1" Then 
				gf_mensaje(gs_Aplicacion, 'No se pudo cambiar login actual ', '', 2)
				Return -1
			Else
				//Registrar Auditoria
				if ls_tipo_login_nuevo='U' then 
					ls_accion='Z'
				else
					ls_accion='W'
				End if
				  f_auditoria_usuario( ii_idservidor, ls_CodigoUsuario, ls_accion)
			End if
		End If
	End If
Next


gf_mensaje(gs_Aplicacion, 'Finalizo el proceso de Cambio de Login', '', 3)
dw_principal.event ue_retrieve()
return



end event

type cbx_1 from checkbox within tabpage_cambio
integer x = 2848
integer y = 252
integer width = 535
integer height = 76
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Seleccionar Todo"
end type

event clicked;Integer 	li_For
Integer 	li_Filas
Integer 	li_NroColumnas
String 	ls_Filas
String		ls_Columna

li_Filas = dw_usuario_autenticacion.rowcount( )
li_NroColumnas = Integer(dw_usuario_autenticacion.Object.Datawindow.Column.Count)
 
If This.Checked Then
	For li_For=1 To li_Filas
		dw_usuario_autenticacion.setitem(li_For,'usersel','1')
		ls_Filas += String(li_for) + ","	
		
	Next 
	ls_Filas = Left(ls_Filas,Len(ls_Filas) -1) 
Else
	ls_Filas = "0" 
	For li_For=1 To li_Filas
		dw_usuario_autenticacion.setitem(li_For,'usersel','0')
	Next 
End If

For li_For = 1 To li_NroColumnas
	ls_Columna = '#' + string(li_For)
	dw_usuario_autenticacion.modIfy(ls_Columna + ".Background.color='16777215~tif( getrow() in ("+ls_Filas+"), 16755261, 16777215 )'")	

Next

end event

type dw_usuario_autenticacion from uo_dwbase within tabpage_cambio
integer x = 5
integer y = 112
integer width = 3401
integer height = 1276
integer taborder = 20
string dataobject = "dw_usuario_autenticacion"
boolean ib_menupopup = false
end type

event ue_retrieve;call super::ue_retrieve;//Return this.retrieve(4,ii_idservidor)
If this.retrieve(4,ii_idservidor) >0 Then
	
	Tab_proceso.tabpage_cambio.cb_cambiologin.Enabled = True
	return 1
End If




end event

event ue_validar;call super::ue_validar;Integer 	li_CtdFilas
Integer 	li_For,li_found
String 	ls_cadfind

If AncestorReturnValue <> 1 Then Return AncestorReturnValue
	ls_cadfind = "usersel = "+ "'1'"
	li_found =  This.find( ls_cadfind, 1,  This.RoWCount())
	If li_found = 0 Then 
		gf_mensaje(gs_Aplicacion,"Debe seleccionar un registro ","",2)
		Return -1
	End If

Return 1



end event

