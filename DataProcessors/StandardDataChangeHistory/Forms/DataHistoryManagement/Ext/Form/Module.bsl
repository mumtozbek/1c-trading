
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	FilterReminder = Parameters.FilterPresentation;
	DeleteDate = CurrentDate() - 86400*20;
	Items.UpdateHistory.Enabled = Parameters.FilterSet;
	Items.MakeDeleteFromAfterWrite.Enabled = Parameters.FilterSet;
EndProcedure

&AtServer
Procedure BeforeLoadDataFromSettingsAtServer(Settings)
	
	If Settings.Get("ExecuteAfterWriteVersion") = Undefined Then
		// по умолчанию настройка включена
		Settings.Insert("ExecuteAfterWriteVersion", True);
	EndIf;
	If Settings.Get("AutoDeleteFromPostProcessing") = Undefined Then
		// по умолчанию настройка включена
		Settings.Insert("AutoDeleteFromPostProcessing", True);
	EndIf;
	
EndProcedure

&AtClient
Procedure MakeDeleteFromAfterWrite(Command)
	Params = New Structure;
	Params.Insert("BorderDate", DeleteDate);
	Notify("StandardDataChangeHistory.DeleteFromAfterWrite", Params, ThisObject);
EndProcedure

&AtClient
Procedure MakeExecuteAfterWrite(Command)
	Notify("StandardDataChangeHistory.ExecuteAfterWrite", , ThisObject);
EndProcedure

&AtClient
Procedure UpdateHistory(Command)
	Params = New Structure;
	Params.Insert("ExecuteAfterWriteVersion", ExecuteAfterWriteVersion);
	Params.Insert("AutoDeleteFromPostProcessing", AutoDeleteFromPostProcessing);
	Notify("StandardDataChangeHistory.Update", Params, ThisObject);
EndProcedure

