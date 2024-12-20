$PBExportHeader$sigm_inicio.sra
$PBExportComments$Generated Application Object
forward
global type sigm_inicio from application
end type
global uo_transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
/* CONSTANTES DEL FRAMEWORK **********************************************************/
CONSTANT	Integer BordeHorizontal 	= PixelsToUnits( 8, XPixelsToUnits!)
CONSTANT	Integer BordeVertical 		= PixelsToUnits( 9, YPixelsToUnits!)
CONSTANT	Integer MenuVentana		= 4

/* VARABLES DEL FRAMEWORK ************************************************************/
Boolean			gb_ActivarVersionBeta 	// Identifica si la aplicación esta en modo Desarrollo/Test, 
													// permite mostrar en el reporte las marcas de agua "Documento no valido"
Boolean			gb_ConfigurarMenu		// Identifica si se aplicará la configuración de los menús
Boolean			gb_MultiModulos			// Si es True la aplicación maneja varios módulos (SIGM). 
													// Si es False la aplicación solo cuenta con un único módulo.
String				gs_Usuario					// Usuario
String				gs_Clave						// Contraseña del usuario
String				gs_TipoCLiente				// Identifica el entorno en el que se está ejecutando la aplicación: PB, WEB, MOBILE
String				gs_ArchivoINI	    			// Dirección y Nombre del archivo INI
Boolean			gb_UsarRoles				// Indica si la aplicación usará roles o no
Integer			gi_IdRol						// Rol seleccionado
Boolean				Gb_sysadmin				= FALSE
str_dispositivo	gstr_Dispositivo 			// Almacena las variables de los dispositivos móviles, siempre y cuando la 
													// aplicación se ejecute en ese ambiente.
n_smtp 			gn_smtp						// Objeto no visual que se encarga del envío de correos

/* VARABLES GLOBALES A NIVEL DE MODULOS*******************************************************/
String 			gs_ObjetoModulo 			// Nombre del Objeto Modulo de cada Aplicación
													// Se usa en aplicaciones que necesiten cambiar de módulos (Ejm: SIGM)
String				gs_ArchivoAyuda    		// Ruta del archivo de ayuda "chm"
String				gs_ArchivoAyudaWeb     // Ruta del Web Server de ayuda "html"
String 			gs_Esquema				// Nombre del esquema
String				gs_Aplicacion				// Nombre de la aplicación

Integer			gi_IdAplicacion				// Código de la aplicación

Datastore		gds_menu					// Menus por aplicacion

/* VARIABLES DE LA APLICACIÓN ***********************************************************/
Integer			gi_IdServidor 

String				gs_IdAreaSap				// Area de usuario
String				gs_DNI						// Rol seleccionado

end variables
global type sigm_inicio from application
string appname = "sigm_inicio"
string microhelpdefault = "SIGM BETA"
string dwmessagetitle = "SIGM_BETA"
string displayname = "SIGM_BETA"
end type
global sigm_inicio sigm_inicio

type prototypes
/*Permite abrir ejectuar diferentes operaciones con el explorador de windows: abrir archivos, ejecutar un batch, copiar un archivo*/
Public function long ShellExecuteA(long hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, long nShowCmd) LIBRARY "SHELL32.DLL" alias for "ShellExecuteA;Ansi"
/*********************************/


/*Hallar la versión de OS*/
FUNCTION long IsWow64Process(long hwnd, ref  boolean Wow64Process) LIBRARY "Kernel32.DLL"
FUNCTION long GetCurrentProcess ()  LIBRARY "KERNEL32.DLL"
/***************************/

/*Permite controlar el teclado por codigo*/
SUBROUTINE keybd_event( int bVk, int bScan, int dwFlags, int dwExtraInfo) LIBRARY "user32.dll"
/*********************************/

 FUNCTION ulong GlobalSize(ulong hMem) Library "kernel32.dll"
 
 
 //Get del status de Teclas virtuales 
Function Integer GetKeyState(Integer nVirtKey) LIBRARY "user32.dll" 

//v.2.0 Incluyen funciones para la copia de archivos 
//*Copia archivos */
FUNCTION boolean CopyFileA(string cfrom, string cto, boolean flag ) LIBRARY "Kernel32.dll" alias for "CopyFileA;Ansi"

// Legeo de usuarios
FUNCTION boolean LogonUser(&
    string lpszUserName, &
    string lpszDomain, &
    string lpszPassword, &
    long dwLogonType, &
    long dwLogonProvider, &
    ref long phToken &
) LIBRARY "advapi32.dll" alias for "LogonUserA;Ansi"

//Impersonalizacion de usuario
FUNCTION boolean ImpersonateLoggedOnUser(&
    long IntPtr &
) LIBRARY "advapi32.dll" alias for "ImpersonateLoggedOnUser;Ansi"
//Reversa de la impersonalizacion
Function boolean RevertToSelf() LIBRARY "advapi32.dll" alias for "RevertToSelf;Ansi"
//Cerrar la conexion de usuario
FUNCTION boolean CloseHandle(ulong w_handle) LIBRARY "Kernel32.dll"
end prototypes

type variables

end variables

forward prototypes
public function integer uf_conectar (integer ai_intentos)
public function integer uf_inicializar ()
public function integer uf_validar_servidor (string as_usuario)
end prototypes

public function integer uf_conectar (integer ai_intentos);
// **********************************************************************************
//    Descripción            :    Ejecuta las conecciones a las bases de datos. Verifica las validaciones
//                               
//    Argumentos            :    Ninguno
//
//    Valor de Retorno    :    1 = Autenticación exitosa
//                              - 1 = Error en la Autenticación
//
//    Control de Versión:
//
//    Versión    Autor                                Fecha                Descripción
//    1.0        Wilbert Santos Mucha            09/12/2015        Versión inicial
// **********************************************************************************
String    ls_Clave
Integer li_Retorno

ls_Clave = gs_Clave

/*Conectar a la BD de seguridad*/
uo_transaction        bvn_seguridad
bvn_seguridad = create uo_transaction

li_Retorno = gf_conectar_db( bvn_seguridad, gs_ArchivoINI, 'Seguridad', gs_usuario, ls_Clave, ai_Intentos )

If	li_Retorno < 0 Then
	If	li_Retorno  = -1 Then
		Return -1
	End If

	If	li_Retorno  = -2 Then  
		Return -2
		//HALT CLOSE
	End If
End If
 
 /* Revisa las validaciones que aplican a los usuarios simples (U) o a los miembros de sysadmin o securityadmin (S) */
If    w_login.dynamic function uf_validaciones( bvn_seguridad, 'U' ) = -1 Then
  Return -1  
End If 

Destroy( bvn_seguridad )

/* Realiza la conexión a la base de datos */
If gf_conectar_db( SQLCA, 'SIGM.ini', 'SIGM', gs_usuario, gs_Clave,ai_Intentos ) = -1 Then
    gf_mensaje( 'Inicio de sesión', 'Problemas en la Conexión a la Base de Datos', SQLCA.sqlerrtext, 2 )
    HALT CLOSE
End If

//SQLCA.DBMS = "SNC SQL Native Client(OLE DB)"
//SQLCA.ServerName = "BVNLIM-E-2256"
//SQLCA.AutoCommit = False
//SQLCA.DBParm = "TrustedConnection=1,Provider='SQLNCLI11',Database='bdoperaciones'"
//connect using sqlca;

Return 1
end function

public function integer uf_inicializar ();/* Se inicia la variable gb_MultiModulos como True*/
gb_MultiModulos = True

/* Se inicia la variable gs_Aplicacion como Inicio de sesión , para motrarlo en los cuadros de error */
gs_Aplicacion = 'Inicio de sesión'

/*Carga Variables Globales del Sistema*/
gs_ArchivoINI = 'SIGM.ini'

gb_ActivarVersionBeta = False
gb_UsarRoles = True
//gb_ConfigurarMenu = True
 
/* Almacena el tipo de dispositivo desde el que se ejecuta la aplicación*/
gs_TipoCLiente = AppeonGetClientType ( )

/* Si el tipo de dispositivo es Movil se hallán las características del dispositivo movil */
If	gs_TipoCLiente = 'MOBILE' Then gf_get_device_info( )	

Return 1
end function

public function integer uf_validar_servidor (string as_usuario);// **********************************************************************************
//	Descripción			:	Valida disponibilidad del servidor

//	Control de Versión:
//
//	Versión	Autor								Fecha				Descripción
//  1.0		Walther R. 						13/06/2020		Versión inicial									
// **********************************************************************************

Integer		li_ret
String			ls_usrsrv_codigo
String			ls_usrsrv_clave
String			ls_estado
String			ls_servidor
String			ls_parametros
String			ls_retorno[]
String			ls_error
/*Conectar a la BD de seguridad*/
uo_transaction        bvn_seguridad
bvn_seguridad = create uo_transaction

ls_servidor=ProfileString( gs_ArchivoINI, 'Seguridad', 'ServerName', '' )

//Utilizar usuario de servicio para consultar
ls_usrsrv_codigo	=	'usr_seguridad'
//ls_usrsrv_clave		=	ProfileString( gs_ArchivoINI, 'Seguridad', 'Servicio', '' )
//messagebox("info",ls_usrsrv_clave)
//ls_usrsrv_clave		=Trim(gf_protege_cadena( Trim( ls_usrsrv_clave ), 2 ) )
//messagebox("info2",ls_usrsrv_clave)
ls_usrsrv_clave		=	'129:2301mnabLMij' 
 
li_ret = gf_conectar_db( bvn_seguridad, gs_ArchivoINI, 'Seguridad',  ls_usrsrv_codigo, ls_usrsrv_clave, 0 )
If	li_ret > 0 Then
	//Obtener info de login
	ls_parametros	="'" +ls_servidor +"','"+as_usuario+"'"
	li_ret=gf_procedimiento_ejecutar_tr( 'SEGURIDAD.usp_Servidor_ValidarEstado_Usuario', ls_parametros, ls_retorno, ls_error,bvn_seguridad)
	if li_ret<0 then
		Messagebox("Seguridad","No se puede validar estado del servidor")
		Return -1
	End if
	ls_estado	=	ls_retorno[1]
	if IsNull(ls_estado) or ls_estado='null' or len(ls_estado)<1 then
		li_ret	=	-1
	else
		li_ret	=	Integer(ls_estado)
	End if
Else
	li_ret	=	-1
End if	
Destroy  bvn_seguridad
Return li_ret

end function

on sigm_inicio.create
appname="sigm_inicio"
message=create message
sqlca=create uo_transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on sigm_inicio.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;/*Iniciando Sesión*/
Integer li_Retorno

This.uf_inicializar()

open(w_login)
//open(w_captura2)

 li_Retorno = Integer(Message.DoubleParm)

 If li_Retorno <> 1 Then Halt

Open(w_principal)
//Open(w_generador_datawindow)

end event

event close;DISCONNECT USING SQLCA;

end event

