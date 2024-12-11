$PBExportHeader$w_carga_documentos.srw
forward
global type w_carga_documentos from w_response_mtto
end type
type st_titulo from statictext within w_carga_documentos
end type
end forward

global type w_carga_documentos from w_response_mtto
integer width = 3666
integer height = 1060
string title = "Subida Documentos"
st_titulo st_titulo
end type
global w_carga_documentos w_carga_documentos

type variables
string 	is_codigousuario
string		is_codigocarpeta
string 	is_tipo_carga
string 	is_Nombre_archivado
String		is_extensionsblock

uo_documento     iuo_documento
str_response 		istr_Response



 

 
end variables

forward prototypes
public function long wf_obtener_directorio (string as_parametro, ref string as_directorio)
public function long wf_copiar_archivo (string as_rutaorigen, string as_rutadestino, string as_archivo, ref string as_mensaje)
public function long wf_crear_archivo (string as_ruta, string as_archivo, string as_contenido)
public function integer wf_crear_directorio ()
end prototypes

public function long wf_obtener_directorio (string as_parametro, ref string as_directorio);Long 		ll_retorno
String		ls_Parametros, ls_Error
String     ls_retorno[]

//Obtener directorios desde parametros de aplicacion
ll_retorno = 0
as_directorio = ''
ls_Parametros = string(gi_IdAplicacion)+as_parametro
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",ls_Parametros,ls_retorno, ls_Error)

If UpperBound(ls_retorno)<=0 Then
	  gf_mensaje(gs_Aplicacion, 'No se encontro el parametro ,comuniquese con el Area de Sistemas', '', 3)
	  ll_retorno = -1
Else
	  as_directorio = String(ls_retorno[1])
	  ll_retorno = 1
End If

RETURN ll_retorno
end function

public function long wf_copiar_archivo (string as_rutaorigen, string as_rutadestino, string as_archivo, ref string as_mensaje);Long 		ll_retorno
String 	ls_RutaDestinoArchivo
String		ls_rutadestino
String		ls_rutaorigen
String		ls_rutadestinoverificado

ls_RutaDestinoArchivo = as_rutadestino + '\'+ as_archivo

ls_rutadestino	= Trim(ls_RutaDestinoArchivo)
ls_rutaorigen	=	Trim(as_rutaorigen)

if FileExists ( ls_rutaorigen ) then
	ls_rutadestinoverificado = gf_verifypath(ls_rutadestino) 
	if Len(ls_rutadestinoverificado)>3 then
		if pos(right(ls_rutaorigen,3),is_extensionsblock)<1 then
			ll_retorno = FileCopy(ls_rutaorigen,ls_rutadestinoverificado, TRUE)
		End if
	End if
End if

CHOOSE CASE ll_retorno  
	CASE 1 
		as_mensaje = 'Success'
	CASE -1 
		as_mensaje = 'Error opening sourcefile'
	CASE -2
		as_mensaje = 'Error writing targetfile'
END CHOOSE
	
RETURN ll_retorno
end function

public function long wf_crear_archivo (string as_ruta, string as_archivo, string as_contenido);//	1.1	Cambios por vulnerabilidad	5/7/2024
Integer 	ll_retorno
Integer	li_IdArchivo
Integer	li_ArchivoVerificado
String 	ls_ArchivoCrear
Boolean 	lb_Exist
String		ls_contenido
// Abrir archivo

ls_contenido	=as_contenido
ll_retorno = 1
ls_ArchivoCrear = as_ruta +'\' +as_archivo

lb_Exist = FileExists(ls_ArchivoCrear)

li_IdArchivo = FileOpen(ls_ArchivoCrear, LineMode!, Write!, LockWrite!, Append!)

IF li_IdArchivo = -1 or IsNull(li_IdArchivo) Then
	ll_retorno = -1
	gf_mensaje(gs_Aplicacion, ' Error al crear el archivo '+as_archivo, '', 3)
	Return ll_retorno
End IF

// Insertar data en el archivo 
li_ArchivoVerificado	=gf_verifypathhandle(li_IdArchivo)
ll_retorno = FileWriteEx(li_ArchivoVerificado, ls_contenido)		//1.1
//ll_retorno = FileWrite(li_IdArchivo, as_contenido)
IF ll_retorno = -1 Then
	gf_mensaje(gs_Aplicacion, ' Error al generar el contenido del archivo '+as_archivo, '', 3)
	Return ll_retorno
End IF

// Cerrar archivo
ll_retorno = FileClose(li_IdArchivo)

RETURN ll_retorno
end function

public function integer wf_crear_directorio ();Long ll_rpta

////*Crear directorio por Usuario
//	ls_RutaDestinoUser = ls_directorio_doc+"\"+is_codigousuario
//	ll_rpta = iuo_documento.uf_crear_directorio(ls_RutaDestinoUser)
//	IF ll_rpta = -1 THEN RETURN 
//	
//	
//	//*Crear directorio por cada acción 
//	ls_RutaDestino  = ls_RutaDestinoUser
//	ls_RutaDestino  = ls_RutaDestino+"\"+is_tipo_carga
//	ll_rpta = iuo_documento.uf_crear_directorio(ls_RutaDestino)
//	IF ll_rpta = -1 THEN RETURN 

return ll_rpta
	
	
end function

on w_carga_documentos.create
int iCurrent
call super::create
this.st_titulo=create st_titulo
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_titulo
end on

on w_carga_documentos.destroy
call super::destroy
destroy(this.st_titulo)
end on

event open;call super::open;is_extensionsblock='comexedllsysini'
is_tipo_carga = istr_parametros.str_argumentos.s[1]
is_codigousuario = istr_parametros.str_argumentos.s[2]		
is_codigocarpeta = istr_parametros.str_argumentos.s[3]		//DNI


st_titulo.text ='Subir documento para el proceso de '+ is_tipo_carga + ' de : '+is_codigocarpeta
cb_aceptar.Enabled = False 



end event

event close;call super::close;If Len(is_Nombre_archivado) > 0 Then Return

istr_Response.str_argumentos.b[1] = false
CloseWithReturn( This , istr_Response )
end event

type p_cbcancelar from w_response_mtto`p_cbcancelar within w_carga_documentos
integer x = 2638
integer y = 624
end type

type p_cbaceptar from w_response_mtto`p_cbaceptar within w_carga_documentos
integer x = 2354
integer y = 616
end type

type cbx_filtros from w_response_mtto`cbx_filtros within w_carga_documentos
integer x = 0
integer y = 860
end type

type dw_principal from w_response_mtto`dw_principal within w_carga_documentos
integer x = 32
integer y = 172
integer width = 3584
integer height = 600
string dataobject = "dw_carga_documentos"
end type

event dw_principal::doubleclicked;call super::doubleclicked;String 	ls_Parametros
string 	ls_DirectorioDoc
String     ls_DirectorioDocTemp
string 	ls_RutaCompleta
String 	ls_NombreArchivo
Long   	ll_Tamaño
String  	ls_RutaDestino
long 		ll_rpta
String  	ls_RutaDestinoUser
Integer 	ll_existearchivo
String		ls_directorioactual

if Row = 0 then Return


String   	 ls_usuario
String  	ls_dominio
String 	ls_clave
Long		il_Token
String   	ls_ParametroWS_LogonUser
String    	ls_retorno4[]
String    	ls_Error

ls_directorioactual	=	GetCurrentDirectory()		//Wrz regresamos al directorio actual


ls_ParametroWS_LogonUser = string(gi_IdAplicacion)+",0,0,'WS_LogonUser',1"
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",ls_ParametroWS_LogonUser,ls_retorno4, ls_Error)
If UpperBound(ls_retorno4)<=0 Then
	  gf_mensaje(gs_Aplicacion, 'No se encontro el parametro WS_LogonUser ,comuniquese con el Area de Sistemas', '', 3)
	 RETURN
Else
	  ls_dominio= ls_retorno4[1]
	  ls_usuario = ls_retorno4[2]
	  ls_clave     = ls_retorno4[3]
End If

		
//*Paramteros*//  ---> \\l-srvdestools\Documentos\Seguridad
IF NOT IsValid(iuo_documento) THEN iuo_documento = CREATE uo_documento
ls_Parametros = ",0,0,'RutaArchivoSustento',1"  			

ll_rpta = iuo_documento.uf_obtener_directorio( ls_Parametros, ls_DirectorioDoc)
IF ll_rpta = -1 THEN RETURN 
//*Paramteros*//  -


//*Paramteros Directorio Temporal *//  ---> \\l-srvdestools\Documentos\Seguridad
IF NOT IsValid(iuo_documento) THEN iuo_documento = CREATE uo_documento
ls_Parametros = ",0,0,'RutaArchivoSustentoTemporal',1"  			

ll_rpta = iuo_documento.uf_obtener_directorio( ls_Parametros, ls_DirectorioDocTemp)
IF ll_rpta = -1 THEN RETURN 
//*Paramteros Temporal*//  -



//Abrir archivos de sustento PDF y se obtiene el tamaño
ll_rpta = iuo_documento.uf_abrir_directorio(ls_RutaCompleta, ls_NombreArchivo, ll_Tamaño)
IF ll_rpta = -1 THEN RETURN 


If Len(ls_NombreArchivo) > 60 then
	gf_mensaje(gs_Aplicacion, 'Longitud de nombre de archivo es mayor a 60. Seleccione otro y/o modifique su longitud ', '', 3)
	ChangeDirectory ( ls_directorioactual )
	RETURN 
End If

//*Crear directorio por Usuario
ls_RutaDestinoUser = ls_DirectorioDoc+"\"+is_codigocarpeta
//*Crear directorio por cada acción 
ls_RutaDestino  = ls_RutaDestinoUser
ls_RutaDestino = ls_RutaDestino+"\"+is_tipo_carga

//Identificar Nombre de Archivo Duplicado
ll_existearchivo			=		dw_principal.find("archivo = '"+ls_NombreArchivo+"'", 1, dw_principal.rowcount())
If ll_existearchivo > 0  Then
	gf_mensaje(gs_Aplicacion, 'Registro Duplicado porfavor seleccionar otro archivo '+ls_NombreArchivo, '', 3)
	ChangeDirectory ( ls_directorioactual )
	RETURN 
End If


//Impersonalizacion
il_Token = iuo_documento.uf_Impersonalizar(ls_usuario, ls_dominio, ls_clave)   
IF il_Token = 0 THEN  RETURN 
		

//Identificar Nombre de Archivo Duplicado en el Directorio Destino
ll_rpta = iuo_documento.uf_existe_archivo(ls_RutaDestino,ls_NombreArchivo)
IF ll_rpta = -1 THEN 
	ChangeDirectory ( ls_directorioactual )
	RETURN 
End if

IF il_Token >0 THEN
					RevertToSelf()
					CloseHandle(il_Token)	
				END IF
				
				
ls_RutaDestino = ls_RutaDestino + '\'+ls_NombreArchivo



this.SetItem( row,'archivo', ls_NombreArchivo)
this.SetItem( row,'Ruta', ls_RutaDestino)
this.setitem(row,'DirectorioOrigen', ls_RutaCompleta)
this.setitem(row,'DirectorioDestino', ls_RutaDestino)
this.setitem(row,'DirectorioDoc', ls_DirectorioDoc  )
this.setitem(row,'DirectorioDocTemp', ls_DirectorioDocTemp  )

ChangeDirectory ( ls_directorioactual )

cb_aceptar.Enabled = true 
		
end event

event dw_principal::ue_validar;call super::ue_validar;Integer 	li_CtdFilas
Integer 	li_For
String 	ls_archivo

If AncestorReturnValue <> 1 Then Return AncestorReturnValue

li_CtdFilas = This.Rowcount()
For li_For=1 To li_CtdFilas
	ls_archivo = This.getitemstring(li_For,"archivo")
	If Trim(ls_archivo) = "" Or IsNull(ls_archivo) Then
		This.setcolumn("archivo")
		This.setrow(li_For)
		gf_mensaje(gs_Aplicacion,"El campo archivo es obligatorio en la Fila "+String(li_For),"",2)
		Return -1
	End If
Next

Return 1
end event

type cb_cancelar from w_response_mtto`cb_cancelar within w_carga_documentos
integer x = 1106
integer y = 820
end type

event cb_cancelar::clicked;istr_Response.str_argumentos.b[1] = false
CloseWithReturn( Parent , istr_Response )



end event

type cb_aceptar from w_response_mtto`cb_aceptar within w_carga_documentos
integer x = 622
integer y = 820
end type

event cb_aceptar::clicked;call super::clicked;Long 		ll_rpta
string 	ls_NombreArchivo
String 	ls_RutaArchivo
String 	ls_directorio_origen
String 	ls_directorio_origen_local
String 	ls_directorio_destino
String 	ls_directorio_doc
String    	ls_directorio_docTemp
string 	ls_RutaDestinoUser
String    	ls_RutaDestinoUserTemp
string 	ls_RutaDestino
String		ls_NombreArchivoOriginal
string 	ls_mensaje
Long		li_fila
String   	ls_usuario
String  	ls_dominio
String 	ls_clave
Long 		il_Token
String     ls_ParametroWS_LogonUser
String    	ls_retorno4[]
String    	ls_Error
String 	ls_RutaDestinoTemp


If dw_Principal.event ue_validar() <> 1 Then Return

ls_ParametroWS_LogonUser = string(gi_IdAplicacion)+",0,0,'WS_LogonUser',1"
gf_Procedimiento_Ejecutar("Framework.usp_ParametroAplicacion_Select_01",ls_ParametroWS_LogonUser,ls_retorno4, ls_Error)
If UpperBound(ls_retorno4)<=0 Then
	  gf_mensaje(gs_Aplicacion, 'No se encontro el parametro WS_LogonUser ,comuniquese con el Area de Sistemas', '', 3)
	 RETURN
Else
	  ls_dominio= ls_retorno4[1]
	  ls_usuario = ls_retorno4[2]
	  ls_clave     = ls_retorno4[3]
End If


//Confirmado los Registros se procede a copiar en los Destinos
For li_fila = 1 to dw_principal.rowcount()

	ls_NombreArchivo  			= 	dw_principal.getitemstring(li_fila , 'archivo')
	ls_RutaArchivo     				= 	dw_principal.getitemstring(li_fila , 'ruta')
	
	ls_directorio_origen_local	=	dw_principal.getitemstring(li_fila , 'Directorioorigen')    			//   directorio local + nombre archivo
	ls_directorio_destino  		= 	dw_principal.getitemstring(li_fila , 'Directoriodestino')				//   \\u-srvbd_clon\Documentos\Seguridad + nombre archivo
	ls_directorio_doc	    			= 	dw_principal.getitemstring(li_fila , 'DirectorioDoc')					//   \\u-srvbd_clon\Documentos\Seguridad
	ls_directorio_docTemp		= 	dw_principal.getitemstring(li_fila , 'DirectorioDocTemp')			//   \\u-srvbd_clon\Temporal\Seguridad\
	
	
	/* OPERACIONES EN RUTA TEMPORAL */
	
		//1.- CREAR DIRECTORIO CON ID DE CARPETA EN RUTA TEMPORAL
		ls_RutaDestinoUserTemp = ls_directorio_docTemp+"\"+is_codigocarpeta
		ll_rpta = iuo_documento.uf_crear_directorio(ls_RutaDestinoUserTemp)
		IF ll_rpta = -1 THEN RETURN 
				
				
		//2.- CREAR DIRECTORIO CON CODIGO DE ACCION DENTRO DE LA RUTA TEMPORAL CON CON IDCARPETA
		ls_RutaDestinoTemp  = ls_RutaDestinoUserTemp
		ls_RutaDestinoTemp  = ls_RutaDestinoTemp+"\"+is_tipo_carga
		ll_rpta = iuo_documento.uf_crear_directorio(ls_RutaDestinoTemp)
		IF ll_rpta = -1 THEN RETURN 
				
		//3.- COPIAR EL ARCHIVO DESDE LA RUTA LOCAL DEL USUARIO A LA CARPETA DEL PASO 2 (CARPETA TEMPORAL CON CODIGO DE ACCION)
		ls_NombreArchivoOriginal = ls_NombreArchivo		
		ll_rpta = iuo_documento.uf_copiar_archivo(ls_directorio_origen_local,ls_RutaDestinoTemp,ls_NombreArchivo, ls_mensaje )
		IF ll_rpta = -1 OR ll_rpta = -2  THEN  RETURN
					

	/* OPERACIONES EN RUTA FINAL*/					
					
		//Asigna nueva directorio origen //
		ls_directorio_origen  = 	ls_RutaDestinoTemp + '\'+ ls_NombreArchivo				//   \\u-srvbd_clon\Temporal\Seguridad\Usuario\alta  + Nombre Archivo
	
		//Impersonalizacion
		il_Token = iuo_documento.uf_Impersonalizar(ls_usuario, ls_dominio, ls_clave)   
		IF il_Token = 0 THEN  RETURN 
	
		//*Crear directorio por Usuario
		ls_RutaDestinoUser = ls_directorio_doc+"\"+is_codigocarpeta
		ll_rpta = iuo_documento.uf_crear_directorio(ls_RutaDestinoUser)
		IF ll_rpta = -1 THEN RETURN 
	
	
		//*Crear directorio por cada acción 
		ls_RutaDestino  = ls_RutaDestinoUser
		ls_RutaDestino  = ls_RutaDestino+"\"+is_tipo_carga
		ll_rpta = iuo_documento.uf_crear_directorio(ls_RutaDestino)
		IF ll_rpta = -1 THEN RETURN 
	
		//Mueve archivo de sustento
		ls_NombreArchivoOriginal = ls_NombreArchivo
			
		ll_rpta = iuo_documento.uf_mover_archivo(ls_directorio_origen,ls_RutaDestino,ls_NombreArchivo, ls_mensaje )
//		ll_rpta = iuo_documento.uf_copiar_archivo(ls_directorio_origen,ls_RutaDestino,ls_NombreArchivo, ls_mensaje )
		IF ll_rpta = -1 OR ll_rpta = -2  THEN 
				IF il_Token >0 THEN
					RevertToSelf()
					CloseHandle(il_Token)	
				END IF
			RETURN 
		END IF

Next

IF il_Token >0 THEN
	RevertToSelf()
	CloseHandle(il_Token)
END IF

istr_Response.str_argumentos.b[1] =true
istr_Response.str_argumentos.s[1] = ls_NombreArchivo
is_Nombre_archivado = ls_NombreArchivo
CloseWithReturn( parent , istr_Response )


end event

type st_mensaje from w_response_mtto`st_mensaje within w_carga_documentos
integer width = 3566
end type

type st_titulo from statictext within w_carga_documentos
integer x = 46
integer y = 32
integer width = 2080
integer height = 60
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
long textcolor = 255
long backcolor = 67108864
string text = "Titulo"
boolean focusrectangle = false
end type

