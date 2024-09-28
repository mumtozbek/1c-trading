
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
Var UserArray, dbUser, filterUser, NewStr, result, Row;
	
	SetPrivilegedMode(True);
	UserArray = InfoBaseUsers.GetUsers();
	For Each dbUser In UserArray Do
		NewStr = UserList.Add();
		NewStr.ID = dbUser.UUID;
		NewStr.Name = dbUser.Name;
		NewStr.FullName = dbUser.FullName;
	EndDo;
	For Each filterUser In Parameters.UserSelection Do
		If ValueIsFilled(filterUser.Value) Then
			result = UserList.FindRows(New Structure("ID", filterUser.Value));
		Else
			result = UserList.FindRows(New Structure("FullName", filterUser.Presentation));
		EndIf;
		If result.Count() <> 0 Then
			For Each Row In result Do
				Row.Check = True;
			EndDo;
		Else
			Row = UserList.Add();
			Row.Check = True;
			Row.FullName = filterUser;
		EndIf;
	EndDo;
EndProcedure

&AtClient
Procedure AddUser(Command)
Var Row;

	If Not IsBlankString(UserName) Then
		Row = UserList.Add();
		Row.Check = True;
		Row.FullName = UserName;
		UserName = "";
	EndIf;
	
EndProcedure

&AtClient
Procedure OKCommand(Command)
Var Result, SelectedUsers;

	Result = New ValueList;
	SelectedUsers = UserList.FindRows(New Structure("Check", True));
	For Each SelectedUser In SelectedUsers Do
		Result.Add(SelectedUser.ID, SelectedUser.FullName);
	EndDo;
	Close(Result);
	
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, MessageText, StandardProcessing)
	
	Close(Undefined);
	
EndProcedure
