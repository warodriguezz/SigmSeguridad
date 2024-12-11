$PBExportHeader$uo_edm_texto.sru
forward
global type uo_edm_texto from editmask
end type
end forward

global type uo_edm_texto from editmask
integer width = 896
integer height = 88
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
textcase textcase = upper!
borderstyle borderstyle = stylelowered!
maskdatatype maskdatatype = stringmask!
string mask = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
boolean autoskip = true
event ue_keydown pbm_keydown
event ue_escape pbm_custom02
event ue_enter ( )
end type
global uo_edm_texto uo_edm_texto

type variables
string 			is_key
String 			is_text
String				is_filtro
String				is_texbus
Integer 			ii_keyest=1
Integer			ii_nrocol
str_busqueda 	istr_bus
 

end variables

forward prototypes
public function integer uf_busca ()
end prototypes

event ue_keydown;// Estados de la Tecla
// 0 -> Enter 
// 1 => Alfanumerico
// 2 => BackSpace
// 3 => Delete
// 4 => Flechas de Movimiento
// 5 => No Valida
Integer li_pos

is_key    = ""
ii_keyest = 1
If keyflags <> 0 Then Return

Choose Case key
	Case KeyA!
		is_key = "A"
	Case KeyB!
		is_key = "B"
	Case KeyC!
		is_key = "C"
	Case KeyD!
		is_key = "D"
	Case KeyE!
		is_key = "E"
	Case KeyF!
		is_key = "F"
	Case KeyG!
		is_key = "G"
	Case KeyH!
		is_key = "H"
	Case KeyI!
		is_key = "I"
	Case KeyJ!
		is_key = "J"
	Case KeyJ!
		is_key = "K"
	Case KeyL!
		is_key = "L"
	Case KeyM!
		is_key = "M"
	Case KeyN!
		is_key = "N"
	Case KeyO!
		is_key = "O"
	Case KeyP!
		is_key = "P"
	Case KeyQ!
		is_key = "Q"
	Case KeyR!
		is_key = "R"
	Case KeyS!
		is_key = "S"
	Case KeyT!
		is_key = "T"
	Case KeyU!
		is_key = "U"
	Case KeyV!
		is_key = "V"
	Case KeyW!
		is_key = "W"
	Case KeyX!
		is_key = "X"
	Case KeyY!
		is_key = "Y"
	Case KeyZ!
		is_key = "Z"
	Case Key0!,KeyNumPad0!
		is_key = "0"
	Case Key1!,KeyNumPad1!
		is_key = "1"
	Case Key2!,KeyNumPad2!
		is_key = "2"
	Case Key3!,KeyNumPad3!
		is_key = "3"
	Case Key4!,KeyNumPad4!
		is_key = "4"
	Case Key5!,KeyNumPad5!
		is_key = "5"
	Case Key6!,KeyNumPad6!
		is_key = "6"
	Case Key7!,KeyNumPad7!
		is_key = "7"
	Case Key8!,KeyNumPad8!
		is_key = "8"
	Case Key9!,KeyNumPad9!
		is_key = "9"
	Case KeyQuote!
		is_key = "'"
	Case KeyEqual!
		is_key = "="
	Case KeyComma!
		is_key = ","
	Case	KeyDash!
		is_key = "-"
	Case KeyPeriod!
		is_key = "."
	Case KeySlash!
		is_key = "/"
	Case KeyBackQuote!
		is_key = "Ñ"
	Case KeyLeftBracket!	
		is_key = "["
	Case KeyBackSlash!
		is_key = "\"
	Case KeyRightBracket!
		is_key = "]"
	Case KeySemiColon!
		is_key = ";"
	Case KeyMultiply!
		is_key = "*"
	Case KeyAdd!
		is_key = "+"
	Case KeySubtract!
		is_key = "-"
	Case KeyDecimal! 
		is_key = "."
	Case KeyDivide! 
		is_key = "/"
   Case KeySpaceBar!		
		is_key = " "
	Case KeyBack!
		is_key = ""
		ii_keyest = 2
	Case KeyDelete!
		is_key = ""
		ii_keyest = 3
	Case KeyUpArrow!
		this.istr_bus.dw_datawin.setfocus()
		Return
	Case KeyEnd!,KeyHome!,KeyLeftArrow!,KeyUpArrow!,KeyRightArrow!,KeyDownArrow!		
		is_key = ""
		ii_keyest = 4
	Case keyEnter!
		this.TriggerEvent("ue_enter")
		is_key = ""	
		ii_keyest = 0
	case KeyEscape!
		this.TriggerEvent("ue_escape")
		is_key = ""	
		ii_keyest = 0
	Case KeyTab!
		is_key = ""
	Case KeyF1!,KeyF2!,KeyF3!,KeyF4!,KeyF5!,KeyF6!,KeyF7!,KeyF8!,KeyF9!,KeyF10!,KeyF11!,KeyF12!	
      is_key = "" 		
	Case KeyPageUp!,KeyPageDown!
      is_key = ""		
	Case Else
		ii_keyest = 5
End Choose

Choose Case ii_keyest
	Case 1
    	 is_text = This.Text + is_key
	Case 2
	  is_text = Mid( is_text, 1, Len(is_text) - 1 ) 
	Case 3  
	  li_pos = This.Position()
	  If li_pos > 0 Then
   		  is_text = Mid( is_text, 1, li_pos - 1) + Mid( is_text, li_pos +1, 100)
	  End if 	  
End Choose

If Key <> KeySpaceBar! Then
	is_text = trim(is_text)
end if

is_texbus = is_text 
if this.istr_bus.b_secuencial then uf_busca()

end event

event ue_enter();if not this.istr_bus.b_secuencial then uf_busca()

end event

public function integer uf_busca ();uo_dwbase 		idw_activa
String       		ls_busca
String				ls_colsort
String				ls_cadfind=""
Integer     		li_narg
Long        		li_found

//messagebox("buscaini", is_texbus)
//
//If ii_keyest = 4 or ii_keyest = 5 Then Return -1
//
//idw_activa=this.istr_bus.uodw_datawin
//
//messagebox("busca1", is_texbus)
//
//if idw_activa.Object.DataWindow.Retrieve.AsNeeded='yes' then
//   //Busqueda con Retrieve
//	if this.text = "" Then is_texbus = ""
//	is_texbus = Trim(is_texbus)
//	li_narg   = UpperBound(this.istr_bus.s_argumentos[])
//	if li_narg < 1 then Return -1
//	istr_bus.s_argumentos[istr_bus.i_arg] = is_texbus + '%'
//	choose case li_narg
//		case 1
//			return idw_activa.Retrieve(istr_bus.s_argumentos[1])
//		case 2
//			return idw_activa.Retrieve(istr_bus.s_argumentos[1],istr_bus.s_argumentos[2])
//		case 3
//			return idw_activa.Retrieve(istr_bus.s_argumentos[1],istr_bus.s_argumentos[2],istr_bus.s_argumentos[3])
//		case 4
//			return idw_activa.Retrieve(istr_bus.s_argumentos[1],istr_bus.s_argumentos[2],istr_bus.s_argumentos[3],istr_bus.s_argumentos[4])
//		case 5
//			return idw_activa.Retrieve(istr_bus.s_argumentos[1],istr_bus.s_argumentos[2],istr_bus.s_argumentos[3],istr_bus.s_argumentos[4],istr_bus.s_argumentos[5])
//		case 6
//			return idw_activa.Retrieve(istr_bus.s_argumentos[1],istr_bus.s_argumentos[2],istr_bus.s_argumentos[3],istr_bus.s_argumentos[4],istr_bus.s_argumentos[5],istr_bus.s_argumentos[6])
//	end choose
//else
//	messagebox("busca2", is_texbus)
//	if this.istr_bus.s_tipobusca="N" THEN //Busqueda NORMAL (FIND)
//		//Busqueda con Find
//		If this.text = "" Then is_texbus = ""
//		If Trim(is_texbus) = "" Then
//	   		If idw_activa.RowCount() > 0 Then idw_activa.ScrollToRow(1)
//				Return 1
//		Else	
//		   ls_colsort = this.istr_bus.s_columna
//			messagebox("ls_colsort", ls_colsort)
//      		Choose Case Lower(Left(idw_activa.Describe(ls_colsort + ".Coltype"), 3))
//				Case 'dec'
//					ls_cadfind = "Cast( " + ls_colsort + " as Varchar(15)) LIKE "+ "'" + trim(is_texbus) + "%'"
//				Case 'dat'
//					ls_cadfind = "Convert( Char(10), " + ls_colsort + ",103) LIKE "+ "'" + trim(is_texbus) + "%'"
//				Case Else
//					ls_cadfind = "Upper(" + ls_colsort +") LIKE "+ "'" + trim(is_texbus) + "%'"
//			End Choose
//			//ls_cadfind = "Upper(String(" + ls_colsort + ")) LIKE "+ "'" + trim(is_texbus) + "%'"
//			messagebox("info",ls_cadfind)
//			li_found = idw_activa.find( ls_cadfind, 1, idw_activa.RoWCount())		
//		   If li_found > 0 Then idw_activa.ScrollToRow(li_found)
//		   Return li_found
//		End if	
//	Else //Busqueda CON FILTRO (FILTER)
//		If this.text = "" Then is_texbus = ""
//		If Trim(is_texbus) = "" Then
//	   		If idw_activa.RowCount() > 0 Then idw_activa.ScrollToRow(1)
//				Return 1
//		Else	
//		   ls_colsort = this.istr_bus.s_columna
//      		Choose Case Lower(Left(idw_activa.Describe(ls_colsort + ".Coltype"), 3))
//				Case 'dec'
//					ls_cadfind = "Cast( " + ls_colsort + " as Varchar(15)) LIKE "+ "'%" + trim(is_texbus) + "%'"
//				Case 'dat'
//					ls_cadfind = "Convert( Char(10), " + ls_colsort + ",103) LIKE "+ "'%" + trim(is_texbus) + "%'"
//				Case Else
//					ls_cadfind = "Upper(" + ls_colsort +") LIKE "+ "'%" + trim(is_texbus) + "%'"
//			End Choose
//			
//			ls_cadfind = "Upper(String(" + ls_colsort + ")) LIKE "+ "'%" + trim(is_texbus) + "%'"
//			idw_activa.SetFilter(ls_cadfind)	
//			li_found = idw_activa.filter()
//		   	If li_found > 0 Then idw_activa.ScrollToRow(li_found)
//		    Return li_found
//		End if		
//	End if
//end if
return 1

end function

on uo_edm_texto.create
end on

on uo_edm_texto.destroy
end on

event getfocus;this.selecttext(len(this.text)+1,0)
end event

event constructor;//Valores por defecto
this.istr_bus.b_secuencial=False
this.istr_bus.s_tipobusca='N'
is_text=''
is_texbus=''
end event

