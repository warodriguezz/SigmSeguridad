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

str_dispositivo	gstr_Dispositivo 			// Almacena las variables de los dispositivos móviles, siempre y cuando la 
													// aplicación se ejecute en ese ambiente.
SMTPClient		gn_smtp						// Objeto no visual que se encarga del envío de correos

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
Boolean			gb_SegPerfilConsulta				// Para saber si entra por perfil de consulta
String				gs_IdAreaSap						// Area de usuario
String				gs_DNI								// Rol seleccionado

Integer			gi_IdServidor 						// Id del servidor, para aplicaciones NO SIGM	//v.2.0 INI
String				gs_tipo_usuario					// TIpo de usuario de la aplicacion U:Normal (SIGM) , S:SecurityAdmin (Seguridad) , A:Sysadmin (Seguridad) wrz 16-10-20
String				gs_tipo_login
uo_proc_seguridad	guo_proc_seg_login		// Objeto para trasacciones del login //v.2.0 FIN
String				gs_hostname
 String			gs_usuariodominio
 String			gs_versionapp
 Date				gd_fechaactual						//Fecha actual desde la conexion
end variables

global type sigm_inicio from application
string appname = "sigm_inicio"
string microhelpdefault = "SIGM BETA"
string dwmessagetitle = "SIGM_BETA"
string displayname = "SIGM_BETA"
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 21.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = "D:\SISTEMAS\Bnv\Seguridad2021\Img\Icono\segu.ico"
string appruntimeversion = "22.2.0.3356"
boolean manualsession = false
boolean unsupportedapierror = true
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
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
FUNCTION ulong GetFileAttributesA (ref string filename) library "Kernel32.dll" alias for "GetFileAttributesA;Ansi"

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

//v.2.0 FIN
end prototypes

type variables

end variables

forward prototypes
public function integer uf_inicializar ()
end prototypes

public function integer uf_inicializar ();String		ls_archivoini
String		ls_apli

/*Carga Variables Globales del Sistema*/
gs_ArchivoINI = 'SEGURIDAD.ini'

/* Se inicia la variable gb_MultiModulos como True*/

/* Activar esta opcion  gb_MultiModulos = False para QUE EJECUTE DIRECTO EL MODULO DESEADO*/
gb_MultiModulos = False

ls_archivoini	=	gs_ArchivoINI

/* Obtener configuración del Aplicacion     PRIMERA LECTURA*/
ls_apli	=	ProfileString(ls_archivoini,'APLICACION', 'Aplicacion', '' )

/* Obtener configuración del Aplicacion */
If	ProfileString(ls_archivoini,'APLICACION', 'Aplicacion', '' ) = '' Then
	gf_mensaje( ls_archivoini,'Error Archivo INI', 'No se encuentra la configuración para el parámetro  Aplicacion', 1)
	Return -1
Else
	 gi_idaplicacion=Integer( ProfileString( ls_archivoini, 'APLICACION', 'Aplicacion', '' ) )
End If	

gs_Aplicacion = 'SEGURIDAD'

gb_ActivarVersionBeta 	= False
gb_UsarRoles 				= True
gb_ConfigurarMenu 		= False		//Seguridad tambien requiere manejo de Perfiles
gs_tipo_usuario			= 'S'			//Por defecto SecurityAdmin

/* Almacena el tipo de dispositivo desde el que se ejecuta la aplicación*/
gs_TipoCLiente = AppeonGetClientType ( )

/* Si el tipo de dispositivo es Movil se hallán las características del dispositivo movil */
If	gs_TipoCLiente = 'MOBILE' Then gf_get_device_info( )	

Return 1
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

event open;///*Iniciando Sesión*/
Integer	 	li_Retorno
String			ls_servername

This.uf_inicializar()

//v.2.0 INI INICIO PROCESO LOGIN
guo_proc_seg_login	=	Create uo_proc_seguridad
//v.2.0 FIN

open(w_login)

Destroy guo_proc_seg_login //v.2.0 
//FIN PROCESO LOGIN

 li_Retorno = Integer(Message.DoubleParm)

 If li_Retorno <> 1 Then Halt

//v.2.0 INI INICIO PROCESO MODULOS
guo_proc_seg_login	=	Create uo_proc_seguridad

li_Retorno=guo_proc_seg_login.uf_definir_modulo(1)
 If li_Retorno <> 1 then	//No se logro procesar modulos
	Destroy guo_proc_seg_login
 	Halt
End if
 
//No APLICA obtener Rol


Destroy guo_proc_seg_login
//v.2.0 FIN PROCESO MODULOS


open( w_principal )
//Open(w_recupera_exporta_menu)


 
end event

event close;DISCONNECT USING SQLCA;

end event

