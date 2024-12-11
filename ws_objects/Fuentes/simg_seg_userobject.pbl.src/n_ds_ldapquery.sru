$PBExportHeader$n_ds_ldapquery.sru
forward
global type n_ds_ldapquery from datastore
end type
end forward

global type n_ds_ldapquery from datastore
end type
global n_ds_ldapquery n_ds_ldapquery

type variables
OLEObject adoCommand, adoConnection, adoRootDSE

end variables

forward prototypes
public function boolean of_connecterror (integer ai_rc, string as_conn)
public function long of_retrieve (string as_where)
end prototypes

public function boolean of_connecterror (integer ai_rc, string as_conn);String ls_errmsg

choose case ai_rc
	case 0
		// no error
		Return False
	case -1
		ls_errmsg = "Invalid Call: the argument is the Object property of a control"
	case -2
		ls_errmsg = "Class name not found"
	case -3
		ls_errmsg = "Object could not be created"
	case -4, -6
		ls_errmsg = "Could not connect to object"
	case -9
		ls_errmsg = "Other error"
	case -15
		ls_errmsg = "COM+ is not loaded on this computer"
	case -16
		ls_errmsg = "Invalid Call: this function not applicable"
	case else
		ls_errmsg = "Undefined error: " + String(ai_rc)
end choose

MessageBox("Error connecting to " + as_conn, ls_errmsg, StopSign!)

Return True

end function

public function long of_retrieve (string as_where);OLEObject adoRecordset
String ls_DNSDomain, ls_Query, ls_Name, ls_Type, ls_Value
String ls_Colname[], ls_Coltype[], ls_Date, ls_Time
Long ll_nextrow, ll_Value
Integer li_rc, li_col, li_max
DateTime ldt_Value

this.Reset()

// Setup ADO objects
li_rc = adoCommand.ConnectToNewObject("ADODB.Command")
If of_ConnectError(li_rc, "ADODB.Command") Then Return -1

li_rc = adoConnection.ConnectToNewObject("ADODB.Connection")
If of_ConnectError(li_rc, "ADODB.Connection") Then Return -1

adoConnection.Provider = "ADsDSOObject"
adoConnection.Open("Active Directory Provider")
adoCommand.ActiveConnection = adoConnection

// Determine the domain
li_rc = adoRootDSE.ConnectToObject("LDAP://RootDSE")
If of_ConnectError(li_rc, "ADODB.Connection") Then Return -1
ls_DNSDomain = adoRootDSE.Get("defaultNamingContext")

// Construct the SQL syntax query
ls_Query = "SELECT "
li_max = Integer(this.Object.DataWindow.Column.Count)
For li_col = 1 To li_max
	ls_Name = this.Describe("#" + String(li_col) + ".Name")
	ls_Type = Left(this.Describe(ls_Name + ".ColType"), 5)
	If li_col = li_max Then
		ls_Query += ls_Name + " "
	Else
		ls_Query += ls_Name + ", "
	End If
	ls_Colname[li_col] = ls_Name
	ls_Coltype[li_col] = ls_Type
Next
ls_Query +=   "FROM 'LDAP://" + ls_DNSDomain + "' "
ls_Query +=  "WHERE " + as_where

try 
	// Run the query
	adoCommand.CommandText = ls_Query
	adoRecordset = adoCommand.Execute
	// Enumerate the resulting recordset
	Do Until adoRecordset.EOF
		// Copy values from recordset to datastore
		ll_nextrow = this.InsertRow(0)
		For li_col = 1 To li_max
			ls_Name = ls_Colname[li_col]
			choose case ls_Coltype[li_col]
				case "char("
					// string value
					ls_Value = String(adoRecordset.Fields(ls_Name).Value)
					this.SetItem(ll_nextrow, ls_Name, ls_Value)
				case "numbe"
					// numeric value
					ll_Value = Long(adoRecordset.Fields(ls_Name).Value)
					this.SetItem(ll_nextrow, ls_Name, ll_Value)
				case "datet"
					// datetime value
					ls_Value = String(adoRecordset.Fields(ls_Name).Value)
					ls_Date = Left(ls_Value, Pos(ls_Value, " ") - 1)
					ls_Time = Mid(ls_Value, Pos(ls_Value, " ") + 1)
					ldt_Value = DateTime(Date(ls_Date), Time(ls_Time))
					this.SetItem(ll_nextrow, ls_Name, ldt_Value)
			end choose
		Next
		// Move to the next record in the recordset
		adoRecordset.MoveNext
	Loop
	// Close the connection
	adoRecordset.Close
catch ( oleruntimeerror orte )
	MessageBox("OLERuntimeError", orte.Text)
end try

// Close the connection
adoConnection.Close

// Apply any filter or sort
this.Filter()
this.Sort()

Return this.RowCount()

end function

on n_ds_ldapquery.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_ds_ldapquery.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;// Create objects
adoCommand    = Create OLEObject
adoConnection = Create OLEObject
adoRootDSE    = Create OLEObject

end event

event destructor;// Destroy objects
Destroy adoCommand
Destroy adoConnection
Destroy adoRootDSE

end event

