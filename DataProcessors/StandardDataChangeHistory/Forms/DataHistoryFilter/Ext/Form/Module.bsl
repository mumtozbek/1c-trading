
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
Var Processing, TypeArray, _Users, Usr, Row, filterItem, convertItem;

	Processing = FormAttributeToValue("Object");
	MetaPath = Processing.Metadata().FullName();
	Users = New FixedArray(New Array);

	ValueToFormAttribute(FormDataToValue(Parameters.AvailableMetadata, Type("ValueTree")), "AvailableMetadata");
	
	DataChangesType.Add(DataChangeType.Create, String(DataChangeType.Create), True);
	DataChangesType.Add(DataChangeType.Update, String(DataChangeType.Update), True);
	DataChangesType.Add(DataChangeType.Delete, String(DataChangeType.Delete), True);
	
	// заполним диалог текущим значением отбора
	FilterValue = Processing.ConvertStructureKeyToEn(Parameters.Filter);
	If FilterValue <> Undefined Then
		// Данные или метаданные
		If FilterValue.Property("Metadata") Then
			DataMetadata = FilterValue.Metadata;
			DataMetadataPresentation = GetMDPresentationByType(FilterValue.Metadata);
			TypeArray = New Array;
			TypeArray.Add(DataMetadata);
			Items.Data.TypeRestriction = New TypeDescription(TypeArray);
			Items.Data.ReadOnly = False;
			MakeFieldsTree(DataMetadata);
		EndIf;
		If FilterValue.Property("Data") Then
			DataData = FilterValue.Data;
		EndIf;
		// Представление данных
		If FilterValue.Property("DataPresentation") Then
			DataPresentation = FilterValue.DataPresentation;
		EndIf;
		// Отбор по пользователям
		SetPrivilegedMode(True);
		_Users = New ValueList;
		If FilterValue.Property("User") Then
			If TypeOf(FilterValue.User) = Type("Array") Then
				For Each FilterUser In FilterValue.User Do
					Usr = InfoBaseUsers.FindByUUID(FilterUser);
					If Usr = Undefined Then
						_Users.Add(Undefined, String(FilterValue), True);
					Else
						_Users.Add(Usr.UUID, Usr.FullName, True);
					EndIf;
				EndDo;
			Else
				Usr = InfoBaseUsers.FindByUUID(FilterValue.User);
				If Usr = Undefined Then
					_Users.Add(Undefined, String(FilterValue.User), True);
				Else
					_Users.Add(Usr.UUID, Usr.FullName, True);
				EndIf;
			EndIf;
		EndIf;
		If FilterValue.Property("UserFullName") Then
			If TypeOf(FilterValue.UserFullName) = Type("Array") Then
				For Each FilterUser In FilterValue.UserFullName Do
					_Users.Add(Undefined, FilterUser, True);
				EndDo;
			Else
				_Users.Add(Undefined, String(FilterValue.UserFullName), True);
			EndIf;
		EndIf;
		If FilterValue.Property("UserName") Then
			
		EndIf;
		SetPrivilegedMode(False);
		Users = _Users;
		// Комментарий
		If FilterValue.Property("Comment") Then
			Comments = FilterValue.Comment;
		EndIf;
		// Узел плана обмена
		If FilterValue.Property("Node") Then
			ExchangeNode = FilterValue.Node;
		EndIf;
		// Теперь поймем про выполняемые действия
		If FilterValue.Property("DataChangeType") Then
			DataChangesType.FillChecks(False);
			If TypeOf(FilterValue.DataChangeType) = Type("Array") Then
				For Each curDCT In FilterValue.DataChangeType Do
					Row = DataChangesType.FindByValue(curDCT);
					Row.Check = True;
				EndDo;
			Else
				Row = DataChangesType.FindByValue(FilterValue.DataChangeType);
				Row.Check = True;
			EndIf;
		EndIf;
		// Установим даты
		If FilterValue.Property("StartDate") Then
			StartDate = FilterValue.StartDate;
		EndIf;
		If FilterValue.Property("EndDate") Then
			EndDate = FilterValue.EndDate;
		EndIf;
		// Заполним отбор по полям (только изменение)
		If FilterValue.Property("FieldValuesChange") Then
			For Each filterItem In FilterValue.FieldValuesChange Do
				SetUIByCondition(filterItem);
			EndDo;
		EndIf;
		// Заполним отбор по полям (значение до/после)
		If FilterValue.Property("FieldValues") Then
			For Each filterItem In FilterValue.FieldValues Do
				convertItem = Processing.ConvertStructureKeyToEn(filterItem);
				SetUIByCondition(convertItem.Field,
					?(convertItem.Property("ValueBeforeChange"), convertItem.ValueBeforeChange, Undefined),
					?(convertItem.Property("ValueAfterChange"), convertItem.ValueAfterChange, Undefined));
			EndDo;
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure SetUIByCondition(Val FieldChange, Val FieldBefore = Undefined, Val FieldAfter = Undefined)
Var workFields, Field, Success, Row, Row2;

	workFields = StrReplace(FieldChange, ".", Chars.LF);
	Field = StrGetLine(workFields, 1);
	Success = False;
	For Each Row In Fields.GetItems() Do
		If Row.Name <> Field Then
			Continue;
		EndIf;
		If StrLineCount(workFields) = 1 And FieldBefore = Undefined And FieldAfter = Undefined Then
			// это просто поле, без проверок до/после
			Row.IsChange = True;
			Success = True;
			Break;
		ElsIf StrLineCount(workFields) = 2 And FieldBefore = Undefined And FieldAfter = Undefined Then
			// это поле в табличной части, без проверок до/после
			Field2 = StrGetLine(workFields, 2);
			For Each Row2 In Row.GetItems() Do
				If Row2.Name <> Field2 Then
					Continue;
				EndIf;
				Row2.IsChange = True;
				Success = True;
				Break;
			EndDo;
		ElsIf StrLineCount(workFields) = 1 And (FieldBefore <> Undefined Or FieldAfter <> Undefined) Then
			// это просто поле, с проверкой до/после
			If FieldBefore <> Undefined Then
				Row.IsValueBeforeChange = True;
				Row.ValueBeforeChange = FieldBefore;
			EndIf;
			If FieldAfter <> Undefined Then
				Row.IsValueAfterChange = True;
				Row.ValueAfterChange = FieldAfter;
			EndIf;
			Success = True;
			Break;
		ElsIf StrLineCount(workFields) = 2 And (FieldBefore <> Undefined Or FieldAfter <> Undefined) Then
			// это поле в табличной части, с проверкой до/после
			Field2 = StrGetLine(workFields, 2);
			For Each Row2 In Row.GetItems() Do
				If Row2.Name <> Field2 Then
					Continue;
				EndIf;
				If FieldBefore <> Undefined Then
					Row2.IsValueBeforeChange = True;
					Row2.ValueBeforeChange = FieldBefore;
				EndIf;
				If FieldAfter <> Undefined Then
					Row2.IsValueAfterChange = True;
					Row2.ValueAfterChange = FieldAfter;
				EndIf;
				Success = True;
				Break;
			EndDo;
		EndIf;
	EndDo;
	If Not Success Then
		// поле есть в отборе, но его нет в метаданных
		If FieldBefore = Undefined And FieldAfter = Undefined Then
			// это просто поле, без проверок до/после
			Row = MissedFields.GetItems().Add();
			Row.Name = FieldChange;
			Row.IsChange = True;
		ElsIf FieldBefore <> Undefined Or FieldAfter <> Undefined Then
			// это просто поле, с проверкой до/после
			Row = MissedFields.GetItems().Add();
			Row.Name = FieldChange;
			If FieldBefore <> Undefined Then
				Row.IsValueBeforeChange = True;
				Row.ValueBeforeChange = FieldBefore;
			EndIf;
			If FieldAfter <> Undefined Then
				Row.IsValueAfterChange = True;
				Row.ValueAfterChange = FieldAfter;
			EndIf;
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure MakeFieldsTree(MetadataType)
Var Processing, mdItem, Row, MetaStructure, metaFields, rootRows, metaTabSec;

	Fields.GetItems().Clear();
	rootRows = Fields.GetItems();
	If MetadataType = Undefined Then
		Return;
	EndIf;
	Processing = FormAttributeToValue("Object");
	mdItem = Metadata.FindByType(MetadataType);
	Try
		MetaStructure = Processing.ConvertStructureKeyToEn(DataHistory.GetMetadata(mdItem));
	Except
		// для данного типа нет истории
		MetaStructure = Undefined;
	EndTry;
	// common attributes are always the first
	metaFields = ?(MetaStructure <> Undefined And MetaStructure.Property("Fields"), MetaStructure.Fields, Undefined);
	FillAttributes(rootRows, mdItem, Metadata.CommonAttributes, metaFields);
	If Metadata.Constants.Contains(mdItem) Then
		// constant
		If metaFields <> Undefined Then
			Row = rootRows.Add();
			Row.Name = mdItem.Name;
			Row.Presentation = metaFields.Value;
			Row.IsDisableFilterByValue = IsComplexOrUnsupportedTypeDescription(mdItem.Type);
			Row.ValueType = mdItem.Type;
			Row.ValueAfterChange = GetEmptyValueByTypeDescription(mdItem.Type);
			Row.ValueBeforeChange = GetEmptyValueByTypeDescription(mdItem.Type);
		EndIf;
	ElsIf Metadata.InformationRegisters.Contains(mdItem) Then
		// information register
		metaFields = ?(MetaStructure <> Undefined And MetaStructure.Property("Fields"), MetaStructure.Fields, Undefined);
		FillAttributes(rootRows, mdItem, mdItem.StandardAttributes, metaFields);
		FillAttributes(rootRows, mdItem, mdItem.Dimensions, metaFields);
		FillAttributes(rootRows, mdItem, mdItem.Resources, metaFields);
		FillAttributes(rootRows, mdItem, mdItem.Attributes, metaFields);
	Else
		// other objects
		metaFields = ?(MetaStructure <> Undefined And MetaStructure.Property("Fields"), MetaStructure.Fields, Undefined);
		FillAttributes(rootRows, mdItem, mdItem.StandardAttributes, metaFields);
		FillAttributes(rootRows, mdItem, mdItem.Attributes, metaFields);
		metaTabSecs = ?(MetaStructure <> Undefined And MetaStructure.Property("TabularSections"), MetaStructure.TabularSections, Undefined);
		If metaTabSecs <> Undefined Then
			For Each mdTabularSection In mdItem.TabularSections Do
				If AccessRight("View", mdTabularSection) = False Or metaTabSec = Undefined Then
					Continue;
				EndIf;
				metaTabSec = ?(MetaStructure <> Undefined And MetaStructure.TabularSections.Property(mdTabularSection.Name), MetaStructure.TabularSections[mdTabularSection.Name], Undefined);
				Row = rootRows.Add();
				Row.Name = mdTabularSection.Name;
				Row.Presentation = ?(metaTabSec = Undefined, mdTabularSection.Presentation(), metaTabSec.Presentation);
				Row.IsDisableFilterByValue = True;
				Row.ValueType = Undefined;
				Row.ValueAfterChange = Undefined;
				Row.ValueBeforeChange = Undefined;
				metaFields = ?(MetaStructure <> Undefined And metaTabSec <> Undefined And metaTabSec.Property("Fields"), metaTabSec.Fields, Undefined);
				FillAttributes(Row.GetItems(), mdItem, mdTabularSection.StandardAttributes, metaFields, mdTabularSection.Name + ".");
				FillAttributes(Row.GetItems(), mdItem, mdTabularSection.Attributes, metaFields);
			EndDo;
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure FillAttributes(localRootRows, mdObject, mdCollection, HistoryStructure, TabularSectionName = "")
Var mdField, Row;

	For Each mdField In mdCollection Do
		If mdField.Name = "LineNumber" Or mdField.Name = "НомерСтроки" Then
			Continue;
		EndIf;
		If TypeOf(mdField) = Type("StandardAttributeDescription") Then
			If Not AccessRight("View", mdObject, , TabularSectionName + mdField.Name) Then
				Continue;
			EndIf;
		Else 
			If Not AccessRight("View", mdField) Then
				Continue;
			EndIf;
		EndIf;
		If HistoryStructure <> Undefined Then
			If Not HistoryStructure.Property(mdField.Name) Then
				// такого реквизита нет в текущей истории
				Continue;
			EndIf;
		ElsIf mdField.DataHistory <> Metadata.ObjectProperties.DataHistoryUse.Use Then
			Continue;
		EndIf;
		Row = localRootRows.Add();
		Row.Name = mdField.Name;
		Row.Presentation = ?(HistoryStructure = Undefined, mdField.Presentation(), HistoryStructure[mdField.Name]);
		Row.IsDisableFilterByValue = IsComplexOrUnsupportedTypeDescription(mdField.Type);
		Row.ValueType = mdField.Type;
		Row.ValueAfterChange = GetEmptyValueByTypeDescription(mdField.Type);
		Row.ValueBeforeChange = GetEmptyValueByTypeDescription(mdField.Type);
	EndDo;
	
EndProcedure

&AtServerNoContext
Function IsComplexOrUnsupportedTypeDescription(mdTypeDescription)
Var mdTypes;

	mdTypes = mdTypeDescription.Types();
	If mdTypes.Count() <> 1  Or mdTypes.Find(Type("ValueStorage")) <> Undefined Or mdTypes.Find(Type("UUID")) <> Undefined Then
		Return True;
	EndIf;
	Return False;
	
EndFunction

&AtServerNoContext
Function GetEmptyValueByTypeDescription(mdTypeDescription)
Var mdType;

	// complex type?
	If IsComplexOrUnsupportedTypeDescription(mdTypeDescription) Then
		Return Undefined;
	EndIf;
	mdType = mdTypeDescription.Types()[0];
	// primitive type
    If mdType = Type("Number") Then
        Return 0;
    ElsIf mdType = Type("String") Then
        Return "";
    ElsIf mdType = Type("Date") Then
        Return '00010101000000';
    ElsIf mdType = Type("Boolean") Then
        Return False;
    ElsIf mdType = Type("UUID") Then
        Return Undefined;
    ElsIf mdType = Type("AccountType") Then
        Return AccountType.ActivePassive;
    Else
    	// ref type
        Return New (mdType);
    EndIf;
EndFunction

&AtServerNoContext
Function GenerateChoiceData(Val Text, Val formChoiceList)
Var ChoiceData, ChoiceList, mdClassRow, mdItem, Presentation;
	
	ChoiceData = New ValueList;
	For Each mdClassRow In formChoiceList.GetItems() Do
		For Each mdItem In mdClassRow.GetItems() Do
			Presentation = String(mdItem.Presentation);
			If Find(Lower(Presentation), Lower(Text)) <> 0 Then
				resultItem = New Structure("ObjectType, Presentation, UseTypeRestriction", mdItem.Value, Presentation, mdItem.UseTypeRestriction);
				ChoiceData.Add(resultItem, Presentation);
				If ChoiceData.Count() = 50 Then
					Break;
				EndIf; 
			EndIf;
		EndDo;
		If ChoiceData.Count() = 50 Then
			Break;
		EndIf; 
	EndDo;
	ChoiceData.SortByPresentation();
	Return ChoiceData;
	
EndFunction

&AtServerNoContext
Function GetMDPresentationByType(Val Type)
	
	Return Metadata.FindByType(Type).Presentation();
	
EndFunction

&AtClient
Procedure OnOpen(Cancel)
	
	UsersPresentation = MakeUsersPresentation(Users);
	
EndProcedure

&AtClient
Procedure CloseOK(Command)
Var Result, arrayUsersID, arrayUsersFN, User, arrayDCT, curDCT;
Var arrayFieldChanges, arrayFieldBeforeAfter, rowField, rowField2 , rowItems;

	If DataMetadata = Undefined And DataData = Undefined Then
		Raise NStr("ru = 'Не указаны данные и метаданные. Данный отбор не может быть применен.'; SYS = 'SDHC.Filter.UndefineDataMetadata'", "ru");
	EndIf;
	Result = New Structure;
	// Данные или метаданные
	Result.Insert("Metadata", DataMetadata);
	If DataData <> Undefined And Not DataData.IsEmpty() Then
		Result.Insert("Data", DataData);
	EndIf;
	// Представление данных
	If Not IsBlankString(DataPresentation) Then
		Result.Insert("DataPresentation", DataPresentation);
	EndIf;
	// Отбор по пользователям
	If Users.Count() <> 0 Then
		arrayUsersID = New Array;
		arrayUsersFN = New Array;
		For Each User In Users Do
			If ValueIsFilled(User.Value) Then
				arrayUsersID.Add(User.Value);
			Else
				arrayUsersFN.Add(User.Presentation);
			EndIf;
		EndDo;
		If arrayUsersID.Count() = 1 Then
			Result.Insert("User", arrayUsersID[0]);
		ElsIf arrayUsersID.Count() > 1 Then
			Result.Insert("User", arrayUsersID);
		EndIf;
		If arrayUsersFN.Count() = 1 Then
			Result.Insert("UserFullName", arrayUsersFN[0]);
		ElsIf arrayUsersFN.Count() > 1 Then
			Result.Insert("UserFullName", arrayUsersFN);
		EndIf;
	EndIf;
	// Комментарий
	If Not IsBlankString(Comments) Then
		Result.Insert("Comment", Comments);
	EndIf;
	// Узел плана обмена
	If ExchangeNode <> Undefined And Not ExchangeNode.IsEmpty() Then
		Result.Insert("Node", ExchangeNode);
	EndIf;
	// Теперь поймем про выполняемые действия
	arrayDCT = New Array;
	For Each curDCT In DataChangesType Do
		If curDCT.Check Then
			arrayDCT.Add(curDCT.Value);
		EndIf;
	EndDo;
	If arrayDCT.Count() = 1 Then
		Result.Insert("DataChangeType", arrayDCT[0]);
	ElsIf arrayDCT.Count() > 1 Then
		Result.Insert("DataChangeType", arrayDCT);
	EndIf;
	// Установим даты
	If ValueIsFilled(StartDate) Then
		Result.Insert("StartDate", StartDate);
	EndIf;
	If ValueIsFilled(EndDate) Then
		Result.Insert("EndDate", EndDate);
	EndIf;
	// установим отбор по полям
	arrayFieldChanges = New Array;
	arrayFieldBeforeAfter = New Array;
	// это реальные поля
	If Fields.GetItems().Count() <> 0 Then
		For Each rowField In Fields.GetItems() Do
			If rowField.GetItems().Count() = 0 Then
				If rowField.IsChange = False
					And rowField.IsValueAfterChange = False
					And rowField.IsValueBeforeChange = False
				Then
					Continue;
				EndIf;
				CreateCondition(arrayFieldChanges, arrayFieldBeforeAfter, rowField);
			Else
				rowItems = rowField.GetItems();
				If rowField.IsChange Then
					arrayFieldChanges.Add(rowField.Name);	
				EndIf;
				If rowItems.Count() <> 0 Then
					For Each rowField2 In rowItems Do
						CreateCondition(arrayFieldChanges, arrayFieldBeforeAfter, rowField2);
					EndDo;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	// это неизвестные поля
	If MissedFields.GetItems().Count() <> 0 Then
		For Each rowField In MissedFields.GetItems() Do
			If rowField.IsChange = False
				And rowField.IsValueAfterChange = False
				And rowField.IsValueBeforeChange = False
			Then
				Continue;
			EndIf;
			CreateCondition(arrayFieldChanges, arrayFieldBeforeAfter, rowField);
		EndDo;
	EndIf;
	If arrayFieldChanges.Count() <> 0 Then
		Result.Insert("FieldValuesChange", arrayFieldChanges);
	EndIf;
	If arrayFieldBeforeAfter.Count() <> 0 Then
		Result.Insert("FieldValues", arrayFieldBeforeAfter);
	EndIf;
	Close(Result);
	
EndProcedure

&AtClient
Procedure DataMetadataOnChange(Item)

	MakeFieldsTree(DataMetadata);
	For Each Row In Fields.GetItems() Do
		If Row.GetItems().Count() <> 0 Then
			Items.Fields.Expand(Row.GetID());
		EndIf;
	EndDo;
	
EndProcedure

&AtClient
Procedure DataMetadataStartChoice(Item, ChoiceData, StandardProcessing)
Var EditorFormName, Params, Callback;
	
	StandardProcessing = False;
	// Open property editor
	EditorFormName = MetaPath+".Form.MetadaSelection";
	If EditorFormName = Undefined Then 
		Return;
	EndIf;
	
	Params = New Structure;
	Params.Insert("CloseOnChoice", True);
	Params.Insert("CurrentSelection", DataMetadata);
	Params.Insert("AvailableMetadata", AvailableMetadata);
	Callback = New NotifyDescription("DataMetadataChoiceCallback", ThisObject);
	OpenForm(EditorFormName, Params, Item, , , , Callback);
	
EndProcedure

&AtClient
Procedure DataMetadataChoiceCallback(ChoiceData, StandardProcessing) Export
	
	StandardProcessing = False;
	If TypeOf(ChoiceData) = Type("Structure") Then
		DataMetadata = ChoiceData.ObjectType;
		DataMetadataPresentation = ChoiceData.Presentation;
	EndIf;
	
EndProcedure

&AtClient
Procedure DataMetadataClearing(Item, StandardProcessing)
	
	StandardProcessing = False;
	DataMetadata = Undefined;
	DataMetadataPresentation = "";
	DataData = Undefined;
	SetTypeRestriction(Items.Data, DataMetadata);
	Items.Data.ReadOnly = True;
	MakeFieldsTree(Undefined);
	
EndProcedure

&AtClient
Procedure DataMetadataAutoComplete(Item, Text, ChoiceData, DataGetParameters, Wait, StandardProcessing)
	
	StandardProcessing = False;
	If Not IsBlankString(Text) Then
		ChoiceData = GenerateChoiceData(Lower(Text), AvailableMetadata);
	Else
		ChoiceData = New ValueList;
		ChoiceData.Add(Undefined, NStr("ru='Начните вводить имя нужного объекта';SYS='SDHC.Filter.BeginInput'", "ru"));
	EndIf;
	
EndProcedure

&AtClient
Procedure DataMetadataTextEditEnd(Item, Text, ChoiceData, DataGetParameters, StandardProcessing)
	
	StandardProcessing = False;
	ChoiceData = GenerateChoiceData(Lower(Text), AvailableMetadata);
	
EndProcedure

&AtClient
Procedure DataMetadataChoiceProcessing(Item, SelectedValue, StandardProcessing)
Var Row;

	If TypeOf(SelectedValue) = Type("Structure") Then
		DataMetadata = SelectedValue.ObjectType;
		DataMetadataPresentation = SelectedValue.Presentation;
	Else
		// это что-то неожидаемое
		DataMetadata = Undefined;
		DataMetadataPresentation = "";
		Return;
	EndIf;
	DataData = Undefined;
	If SelectedValue.UseTypeRestriction Then
		Items.Data.ReadOnly = False;
		SetTypeRestriction(Items.Data, DataMetadata);
	Else
		Items.Data.ReadOnly = True;
	EndIf;
	Items.Data.UpdateEditText();
	// вернем платформе текст, который надо показать в поле ввода (фактически - наше представление типа)
	SelectedValue = DataMetadataPresentation;
	
EndProcedure

&AtClient
Procedure UsersStartChoice(Item, ChoiceData, StandardProcessing)
Var EditorFormName, Params, Callback;
	
	StandardProcessing = False;
	EditorFormName = MetaPath+".Form.UserSelection";
	If EditorFormName = Undefined Then 
		Return;
	EndIf;
	Params = New Structure;
	Params.Insert("UserSelection", Users);
	Callback = New NotifyDescription("UsersChoiceCallback", ThisObject);
	OpenForm(EditorFormName, Params, ThisObject, , , , Callback);
	
EndProcedure

&AtClient
Procedure UsersChoiceCallback(ChoiceData, StandardProcessing) Export
	
	StandardProcessing = False;
	If ChoiceData <> Undefined Then
		Users = ChoiceData;
		UsersPresentation = MakeUsersPresentation(Users);
	EndIf;
	
EndProcedure

&AtClient
Procedure UsersClearing(Item, StandardProcessing)
	
	StandardProcessing = False;
	Users = New ValueList;
	UsersPresentation = MakeUsersPresentation(Users);
	
EndProcedure

&AtClient
Function MakeUsersPresentation(UsersList)
	
	Result = "";
	If UsersList.Count() = 0 Then
		Result = NStr("ru = '<< Список не задан >>'; SYS = 'SDHC.Filter.UsersNotChoice'", "ru");
	Else
		UsersCount = UsersList.Count()-1;
		For Index = 0 To UsersCount Do
			Result = Result + UsersList[Index].Presentation + ?(Index = UsersCount, "", ", ");
		EndDo;
	EndIf;
	Return Result;
	
EndFunction

&AtClient
Procedure CreateCondition(FieldChanges, FieldBeforeAfter, Row)
Var FieldName, FieldValue;

	FieldName = Row.Name;
	If Row.GetParent() <> Undefined Then
		FieldName = Row.GetParent().Name + "." + FieldName;
	EndIf;
	If Row.IsValueAfterChange Or Row.IsValueBeforeChange Then
		FieldValue = New Structure;
		FieldValue.Insert("Field", FieldName);
		// after change
		If Row.IsValueAfterChange  Then
			FieldValue.Insert("ValueAfterChange", Row.ValueAfterChange);
		EndIf;
		// before change
		If Row.IsValueBeforeChange  Then
			FieldValue.Insert("ValueBeforeChange", Row.ValueBeforeChange);
		EndIf;
		FieldBeforeAfter.Add(FieldValue);	
	EndIf;
	
	If Row.IsChange Then
		FieldChanges.Add(FieldName);	
	EndIf;
	
EndProcedure

&AtClient
Procedure SetTypeRestriction(Item, SelectedType)
Var TypeArray;

	TypeArray = New Array;
	TypeArray.Add(SelectedType);
	Item.TypeRestriction = New TypeDescription(TypeArray);
	
EndProcedure

&AtClient
Procedure SelectPeriod(Command)
Var Dialog, Callback, ExtraParameters;
	
	Dialog = New StandardPeriodEditDialog;
	Dialog.Period.StartDate = StartDate;
	Dialog.Period.EndDate = EndDate;
	ExtraParameters = New Structure;
	ExtraParameters.Insert("Dialog", Dialog);
	Callback = New NotifyDescription("SelectPeriodCallback", ThisForm, ExtraParameters);
	Dialog.Show(Callback);
	
EndProcedure

&AtClient
Procedure SelectPeriodCallback(Result, ExtraParameters) Export
Var Dialog;
	
	Dialog = ExtraParameters.Dialog;
	If Result <> Undefined Then
		StartDate = Dialog.Period.StartDate;
		EndDate = Dialog.Period.EndDate;
	EndIf;
	
EndProcedure

&AtClient
Procedure FieldsOnChange(Item)

	If Item.CurrentData = Undefined Then
		Return;
	EndIf;
	If Item.CurrentItem.Name = "FieldsValueAfterChange" Then
		Item.CurrentData.IsValueAfterChange = True;
	ElsIf Item.CurrentItem.Name = "FieldsValueBeforeChange" Then
		Item.CurrentData.IsValueBeforeChange = True;
	EndIf;
	
EndProcedure

&AtClient
Procedure MissedFiledsOnChange(Item)

	If Item.CurrentData = Undefined Then
		Return;
	EndIf;
	If Item.CurrentItem.Name = "MissedFieldsValueAfterChange" Then
		Item.CurrentData.IsValueAfterChange = True;
	ElsIf Item.CurrentItem.Name = "MissedFieldsValueBeforeChange" Then
		Item.CurrentData.IsValueBeforeChange = True;
	EndIf;
	
EndProcedure

&AtClient
Procedure FieldsCheckBoxOnChange(Item)
Var FieldName, curId, curRow;

	FieldName = Item.Name;
	If Items.Fields.SelectedRows.Count() > 1 Then
		For Each curId In Items.Fields.SelectedRows Do
			curRow = Fields.FindByID(curId);
			If curRow <> Undefined Then
				If FieldName = "FieldsIsChange" Then
					curRow.IsChange = Items.Fields.CurrentData.IsChange;
				ElsIf FieldName = "FieldsIsValueAfterChange" Then
					curRow.IsValueAfterChange = Items.Fields.CurrentData.IsValueAfterChange;
				ElsIf FieldName = "FieldsIsValueBeforeChange" Then
					curRow.IsValueBeforeChange = Items.Fields.CurrentData.IsValueBeforeChange;
				EndIf;
			EndIf;
		EndDo;
		RefreshDataRepresentation(Items.Fields);
	EndIf;
	
EndProcedure
