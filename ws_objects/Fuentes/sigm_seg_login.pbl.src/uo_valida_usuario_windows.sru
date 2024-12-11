$PBExportHeader$uo_valida_usuario_windows.sru
forward
global type uo_valida_usuario_windows from nonvisualobject
end type
end forward

global type uo_valida_usuario_windows from nonvisualobject
end type
global uo_valida_usuario_windows uo_valida_usuario_windows

type prototypes
Function ulong GetComputerNameEx( &
	string NameType, &
	ref string lpBuffer, &
	ref ulong lpnSize &
	) Library "kernel32.dll" Alias For "GetComputerNameExW"
	
Function boolean CloseHandle ( &
	ulong hObject &
	) Library "kernel32.dll"

Function ulong WNetGetUser( &
	string lpname, &
	ref string lpusername, &
	ref ulong buflen &
	) Library "mpr.dll" Alias For "WNetGetUserW"

Function boolean LogonUser ( &
	string lpszUsername, &
	string lpszDomain, &
	string lpszPassword, &
	ulong dwLogonType, &
	ulong dwLogonProvider, &
	ref ulong phToken &
	) Library "advapi32.dll" Alias For "LogonUserW"


end prototypes

forward prototypes
public function integer uf_validar_login (string as_dominio, string as_userid, string as_password)
public function string uf_devolver_usuario (unsignedlong aul_buflen)
public function string uf_devolver_dominio ()
end prototypes

public function integer uf_validar_login (string as_dominio, string as_userid, string as_password);Constant ULong LOGON32_LOGON_NETWORK = 3
Constant ULong LOGON32_PROVIDER_DEFAULT = 0
String ls_domain, ls_username, ls_password
ULong lul_token
Boolean lb_result

ls_domain   = as_dominio
ls_username = as_userid
ls_password = as_password

lb_result = LogonUser( ls_username, ls_domain, &
						ls_password, LOGON32_LOGON_NETWORK, &
						LOGON32_PROVIDER_DEFAULT, lul_token )
If lb_result Then
	CloseHandle(lul_token)
	return 0
Else
	return -1
End If

end function

public function string uf_devolver_usuario (unsignedlong aul_buflen);String ls_usrid
Ulong lul_result

ls_usrid =  Space(aul_buflen)

lul_result =  WNetGetUser("", ls_usrid, aul_buflen)

If lul_result = 0 then
	return (ls_usrid)
End If
end function

public function string uf_devolver_dominio ();String 		ls_domain
Int 			ls_return
OleObject  	LDAP

LDAP = CREATE OleObject  

ls_return = LDAP.ConnectToNewObject( "WScript.Network" )

if ls_return = 0 then
	ls_domain = string(LDAP.UserDomain)
	return ls_domain
Else
	messagebox ("Error", "Error al conectarse al objeto OLE: " + string(ls_return))
End If
end function

on uo_valida_usuario_windows.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_valida_usuario_windows.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

