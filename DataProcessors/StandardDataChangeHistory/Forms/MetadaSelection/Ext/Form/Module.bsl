
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	ValueToFormAttribute(FormDataToValue(Parameters.AvailableMetadata, Type("ValueTree")), "AvailableMetadata");
	CurrentSelection = Parameters.CurrentSelection;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	SetCurrentSelection(AvailableMetadata.GetItems(), CurrentSelection);
	
EndProcedure

&AtClient
Procedure SetCurrentSelection(Rows, RequiredSelection)
Var Row;

	For Each Row In Rows Do
		If Row.Value = RequiredSelection Then
			Items.AvailableMetadata.CurrentRow = Row.GetID();
			Return;
		EndIf;
		SetCurrentSelection(Row.GetItems(), RequiredSelection);
	EndDo;
	
EndProcedure

&AtClient
Procedure CloseOK(Command)
	
	MakeChoice();
		
EndProcedure

&AtClient
Procedure AvailableMetadataSelection(Item, SelectedRow, Field, StandardProcessing)

	StandardProcessing = False;
	MakeChoice();
	
EndProcedure

&AtClient
Procedure AvailableMetadataValueChoice(Item, Value, StandardProcessing)
	
	StandardProcessing = False;
	MakeChoice();
		
EndProcedure

&AtClient
Procedure MakeChoice()
Var curData;

	If Items.AvailableMetadata.CurrentData <> Undefined AND Items.AvailableMetadata.CurrentData.Value <> Undefined Then
		curData = Items.AvailableMetadata.CurrentData;
		resultItem = New Structure("ObjectType, Presentation, UseTypeRestriction", curData.Value, curData.Presentation, curData.UseTypeRestriction);
		NotifyChoice(resultItem);
	EndIf;
		
EndProcedure
