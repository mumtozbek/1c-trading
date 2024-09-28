
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
Var ItemsList;
	
	MetaPath = FormAttributeToValue("Object").Metadata().FullName();
	Items.FormClearFilter.Picture = PictureLib.ClearFilter;

	ItemsList = Items.VisibleHistoryItemsNumber.ChoiceList;
	ItemsList.Clear();
	ItemsList.Add(  100, NStr("ru='100 записей'; SYS='SDCH.Main.100Records'", "ru"));
	ItemsList.Add(  200, NStr("ru='200 записей'; SYS='SDCH.Main.200Records'", "ru"));
	ItemsList.Add(  500, NStr("ru='500 записей'; SYS='SDCH.Main.500Records'", "ru"));
	ItemsList.Add( 1000, NStr("ru='1000 записей'; SYS='SDCH.Main.1000Records'", "ru"));
	ItemsList.Add(10000, NStr("ru='10000 записей'; SYS='SDCH.Main.10000Records'", "ru"));
	ItemsList.Add(    0, NStr("ru='Все записи'; SYS='SDCH.Main.AllRecords'", "ru"));
	VisibleHistoryItemsNumber = 200;
	FillMetadataTypes(AvailableMetadata);
	
	BuildMetadataTree();

EndProcedure

&AtServer
Function GetRussian(English)
	If English = "Data" Then
		Return "Данные";
	ElsIf English = "Key" Then
		Return "Ключ";
	ElsIf English = "VersionNumberSwitchToDataHistoryVersion" Then
		Return "НомерВерсииПереходаНаВерсиюИсторииДанных";
	ElsIf English = "VersionNumber" Then
		Return "НомерВерсии";
	ElsIf English = "VersionNumberBeforeChange" Then
		Return "НомерВерсииДоИзменения";
	ElsIf English = "VersionNumberAfterChange" Then
		Return "НомерВерсииПослеИзменения";		
	EndIf;		
	Return Undefined;
EndFunction

&AtServer
Function GetCurrentName(English)	
	If  IsEnglish() Then
		Return English;
	Else
		Return GetRussian(English);
	EndIf;
EndFunction

&AtServer
Function GetProperty(Source, English, Result)
	Return Source.Property(English, Result)
		Or Source.Property(GetRussian(English), Result); 
EndFunction

&AtServer
Function GetCurrentProperty(Source, English, Result)
	Return Source.Property(GetCurrentName(English), Result); 
EndFunction

&AtServer
Function IsEnglish()
	Return Metadata.ScriptVariant = Metadata.ObjectProperties.ScriptVariant.English;
EndFunction

&AtServer
Procedure UpdateHistoryAtServer(WithoutFilter, ExecuteAfterWriteVersion = Undefined, AutoDeleteFromPostProcessing = Undefined)
	
	If WithoutFilter Then
		DataHistory.UpdateHistory(ExecuteAfterWriteVersion, AutoDeleteFromPostProcessing);
	Else
		HistoryFilter = New Structure(New FixedStructure(FilterValue));
		If HistoryFilter.Count() = 0 Then
			// ...... пустой отбор запрещен
			Return;
		EndIf;
		If HistoryFilter.Property("Data") Then
			// обновляем историю по объекту данных
			DataHistory.UpdateHistory(HistoryFilter.Data, ExecuteAfterWriteVersion, AutoDeleteFromPostProcessing);
		ElsIf HistoryFilter.Property("Metadata") And Is8314OrHigherCompatible() Then
			// обновляем историю по объекту метаданных (8.3.15 и старше)
			mdIncludeArray = New Array;
			mdIncludeArray.Add(Metadata.FindByType(HistoryFilter.Metadata));
			DataHistory.UpdateHistory(mdIncludeArray, , ExecuteAfterWriteVersion, AutoDeleteFromPostProcessing);
		Else
			// тут все подряд обновляем
			// это может быть в очень древних режимах совместимости
			DataHistory.UpdateHistory(ExecuteAfterWriteVersion, AutoDeleteFromPostProcessing);
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure FillDataListAtServer()
	Var HistoryFilter, HistoryTable, ProcessingObject, Row;
	
	ProcessingObject = FormAttributeToValue("Object");
	If FilterValue = Undefined Then
		// нет отбора, так нельзя
		Return;
	EndIf;
	HistoryFilter = New Structure(New FixedStructure(FilterValue));
	If HistoryFilter.Count() = 0 Then
		// нет отбора, так нельзя
		Return;
	EndIf;
	// преобразуем тип к объекту метаданных
	If HistoryFilter.Property("Metadata") Then
		HistoryFilter.Metadata = Metadata.FindByType(HistoryFilter.Metadata);
	EndIf;
	// по виду отбора проверим право редактирования комментария и проставим доступность команды
	If HistoryFilter.Property("Metadata") Then
		Items.Comment.Enabled = AccessRight("EditDataHistoryVersionComment", HistoryFilter.Metadata);
	ElsIf HistoryFilter.Property("Data") Then
		Items.Comment.Enabled = AccessRight("EditDataHistoryVersionComment", HistoryFilter.Data);
	Else
		Items.Comment.Enabled = False;
	EndIf;
	// по виду отбора проверим право редактирования комментария и проставим доступность команды
	If HistoryFilter.Property("Metadata") Then
		Items.FormGoToVersion.Enabled = AccessRight("SwitchToDataHistoryVersion", HistoryFilter.Metadata);
	ElsIf HistoryFilter.Property("Data") Then
		Items.FormGoToVersion.Enabled = AccessRight("SwitchToDataHistoryVersion", HistoryFilter.Data);
	Else
		Items.FormGoToVersion.Enabled = False;
	EndIf;
	
	HistoryTable = DataHistory.SelectVersions(HistoryFilter, , , ?(VisibleHistoryItemsNumber = 0, Undefined, VisibleHistoryItemsNumber));
	HistoryTable.Columns.Add("dctPictureIndex", New TypeDescription("Number"));
	
	For Each Column In HistoryTable.Columns Do
		Column.Name = ProcessingObject.ConvertName2English(Column.Name);
	EndDo;
	For Each Row In HistoryTable Do
		If Row.DataChangeType = DataChangeType.Create Then
			Row.dctPictureIndex = 0;
		ElsIf Row.DataChangeType = DataChangeType.Update Then
			Row.dctPictureIndex = 1;
		Else
			Row.dctPictureIndex = 2;
		EndIf;
		If Row.Node = Undefined Then
			Row.Node = NStr("ru = 'Это приложение'; SYS= 'SDCH.Main.ThisApplication'", "ru");
		Else
			Row.Node = String(Row.Node.Metadata()) + "(" + String(Row.Node) + ")" ;
		EndIf;
	EndDo;
	List.Load(HistoryTable);
	
EndProcedure

&AtServer
Procedure MakeExecuteAfterWriteAtServer(ProcessingObject)
Var HistoryFilter, mdIncludeArray;
	
	If ProcessingObject <> Undefined Then
		// выполняем постпроцессинг для конкретного объекта
		DataHistory.ExecuteAfterWriteVersionsProcessing(ProcessingObject);
	Else
		If FilterValue = Undefined Then
			HistoryFilter = New Structure(New FixedStructure(New Structure));
		Else
			HistoryFilter = New Structure(New FixedStructure(FilterValue));
		EndIf;
		If HistoryFilter.Count() = 0 Then
			// выполняем постпроцессинг для всего, без разбора
			DataHistory.ExecuteAfterWriteVersionsProcessing();
		ElsIf HistoryFilter.Property("Data") Then
			// выполняем постпроцессинг по объекту данных
			DataHistory.ExecuteAfterWriteVersionsProcessing(HistoryFilter.Data);
		ElsIf HistoryFilter.Property("Metadata") Then
			// выполняем постпроцессинг по объекту метаданных
			mdIncludeArray = New Array;
			mdIncludeArray.Add(Metadata.FindByType(HistoryFilter.Metadata));
			DataHistory.ExecuteAfterWriteVersionsProcessing(mdIncludeArray);
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure MakeDeleteFromAfterWriteAtServer(ProcessingObject, BorderDate)
Var HistoryFilter, mdIncludeArray;
	
	If ProcessingObject <> Undefined Then
		// удаляем из очереди постпроцессинга по конкретному объекту
		DataHistory.DeleteFromAfterWriteVersionsProcessing(ProcessingObject);
	Else
		HistoryFilter = New Structure(New FixedStructure(FilterValue));
		If HistoryFilter.Count() = 0 Then
			// выполняем постпроцессинг для всего, без разбора
			DataHistory.DeleteFromAfterWriteVersionsProcessing(Undefined, Undefined, BorderDate);
		ElsIf HistoryFilter.Property("Data") Then
			// удаляем из очереди постпроцессинга по конкретному объекту
			DataHistory.DeleteFromAfterWriteVersionsProcessing(HistoryFilter.Data);
		ElsIf HistoryFilter.Property("Metadata") Then
			// обновляем историю по объекту метаданных
			mdIncludeArray = New Array;
			mdIncludeArray.Add(Metadata.FindByType(HistoryFilter.Metadata));
			DataHistory.DeleteFromAfterWriteVersionsProcessing(mdIncludeArray, , BorderDate);
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory, 
	ObjectType, RootNode, MetadataItems, IconIdx, DefaultValueOnly)
	
	SecletedItemsCount = 0;
	
	For Each CurrentMetadataItem In MetadataItems Do
		DataHistoryUsingFields = New Map;
		
		If DefaultValueOnly Then
			DataHistoryUse = (CurrentMetadataItem.DataHistory = Metadata.ObjectProperties.DataHistoryUse.Use);
			
		Else
			DataHistorySettings = DataHistory.GetSettings(CurrentMetadataItem);
			DataHistoryUse = False;
			
			If DataHistorySettings = Undefined Then
				DataHistoryUse = (CurrentMetadataItem.DataHistory = Metadata.ObjectProperties.DataHistoryUse.Use); 	
			Else
				DataHistoryUse = DataHistorySettings.Use;
				DataHistoryUsingFields = DataHistorySettings.FieldsUse;
				
			EndIf;
		EndIf;
		
		SecletedItemsCount = SecletedItemsCount + DataHistoryUse;
		
		CurrentNode = RootNode.GetItems().Add();
		CurrentNode.Item = CurrentMetadataItem.Presentation();
		CurrentNode.IconIdx = IconIdx;
		CurrentNode.FullName = StrTemplate("%1.%2", ObjectType, CurrentMetadataItem.Name);
		CurrentNode.ObjectRef = New UUID;
		CurrentNode.Use = DataHistoryUse; 
		CurrentNode.Level = 2;
		CurrentNodeId = CurrentNode.GetId();
		CurrentNode.Enabled = AccessRight("UpdateDataHistorySettings", CurrentMetadataItem);
		
		If Not CurrentNode.Enabled Then
			CurrentNode.Item = StrTemplate("%1 (%2)", CurrentNode.Item, NStr("ru = 'Недостаточно прав на изменение'; SYS= 'SDCH.Main.HasNoRights'", "ru"));	
		EndIf;
				
		If ObjectType = "InformationRegisters" Then
			For Each AttributeItem In CurrentMetadataItem.Dimensions Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory, 
					"Attribute", CurrentNode, CurrentNodeId, DataHistoryUsingFields, AttributeItem, 4, MetadataUseDataHistory);
				
			EndDo;      
			
			For Each AttributeItem In CurrentMetadataItem.Resources Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
					"Attribute", CurrentNode, CurrentNodeId, DataHistoryUsingFields, AttributeItem, 4);
				
			EndDo;
		ElsIf ObjectType = "Tasks" Then
			For Each AttributeItem In CurrentMetadataItem.AddressingAttributes Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
					"AddressingAttribute", CurrentNode, CurrentNodeId, DataHistoryUsingFields, AttributeItem, 4);
				
			EndDo;
		
		ElsIf ObjectType = "ChartsOfAccounts" Then
			For Each AttributeItem In CurrentMetadataItem.AccountingFlags Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
					"AccountingFlag", CurrentNode, CurrentNodeId, DataHistoryUsingFields, AttributeItem, 4);
				
			EndDo; 
			
			For Each AttributeItem In CurrentMetadataItem.ExtDimensionAccountingFlags Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
					"ExtDimensionAccountingFlags", CurrentNode, CurrentNodeId, DataHistoryUsingFields, AttributeItem, 4);
				
			EndDo;
		EndIf; 
		
		If ObjectType <> "Constants" And ObjectType <> "InformationRegisters" Then
			For Each TabularItem In CurrentMetadataItem.TabularSections Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory, 
						"Tabular", CurrentNode, CurrentNodeId, 
						DataHistoryUsingFields, TabularItem, 6);
				
				For Each AttributeItem In TabularItem.Attributes Do					
					AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
						"TabularAttribute", CurrentNode, CurrentNodeId, 
						DataHistoryUsingFields, AttributeItem, 10, TabularItem.Name);
					
				EndDo; 
			EndDo;		
		EndIf;
		
		If ObjectType <> "Constants" Then 			
			For Each AttributeItem In CurrentMetadataItem.StandardAttributes Do					
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
					"StandardAttribute", CurrentNode, CurrentNodeId, 
					DataHistoryUsingFields, AttributeItem, 10);
				
			EndDo;
			
			For Each AttributeItem In CurrentMetadataItem.Attributes Do				
				AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory,
					"Attribute", CurrentNode, CurrentNodeId, DataHistoryUsingFields, AttributeItem, 4);
				
			EndDo; 
		EndIf;
	EndDo;
	
	If RootNode.GetItems().Count() > 0 And SecletedItemsCount = RootNode.GetItems().Count() Then
		RootNode.Use = 1;
		
	ElsIf SecletedItemsCount > 0 Then
		RootNode.Use = 2;
		
	Else
		RootNode.Use = 0;
		
	EndIf;
	
EndProcedure

&AtServer
Procedure AddFieldToMetadataInfo(MetadataInfoTable, MetadataUseDataHistory, Type, CurrentNode, CurrentNodeId, 
	DataHistoryUsingFields, AttributeItem, IconIdx, Tabular = "")

	NewObjectField = MetadataInfoTable.Add();
	NewObjectField.Presentation = AttributeItem.Presentation();
	NewObjectField.Name = AttributeItem.Name;
	NewObjectField.IconIdx = IconIdx;
	NewObjectField.Type = Type;
	NewObjectField.Tabular = Tabular;
	NewObjectField.Ref = New UUID;
	NewObjectField.Owner = CurrentNode.FullName;
	NewObjectField.ObjectRef = CurrentNode.ObjectRef;
	NewObjectField.ObjectRowId = CurrentNodeId;
	NewObjectField.Enabled = CurrentNode.Enabled;
	
	If Type <> "Tabular" Then 
		If DataHistoryUsingFields[NewObjectField.Name] = Undefined Then
			NewObjectField.Use = (AttributeItem.DataHistory = MetadataUseDataHistory);
			
		Else                   
			NewObjectField.Use = DataHistoryUsingFields[NewObjectField.Name];
			
		EndIf;
	EndIf;
	
	NewObjectField.OldValue = NewObjectField.Use;
	
EndProcedure


&AtServer
Function BuildMetadataTree(DefaultValueOnly = False)
	
	Var CanUseExchangePlan;
	
	DataHistoryTree.GetItems().Clear();
	
	TreeRoot = AddNewDataHistoryRootNode(
		DataHistoryTree, NStr("ru = 'Все объекты'; SYS='SDCH.Main.TreeRoot'", "ru"), 0, 0);
	TreeRoot.Enabled = True;
	
	MetadataExchangePlans = Metadata.ExchangePlans;   
	MetadataConstants = Metadata.Constants;
	MetadataChartsOfCalculationTypes = Metadata.ChartsOfCalculationTypes;
	
	CanUseExchangePlan = CanUseInDataHistory(MetadataExchangePlans);
	CanUseConstants = CanUseInDataHistory(MetadataConstants);
	CanUseChartOfCalculationTypes = CanUseInDataHistory(MetadataConstants); 
		
	If CanUseExchangePlan Then
		ExchangePlansRoot = AddNewDataHistoryRootNode(
			TreeRoot, NStr("ru = 'Планы обмена'; SYS='SDCH.Main.ExchangePlansRoot'", "ru"), 1, 8);
		
	EndIf;
	
	If CanUseConstants Then
	    ConstantsRoot = AddNewDataHistoryRootNode(
			TreeRoot, NStr("ru = 'Константы'; SYS='SDCH.Main.ConstantsRoot'", "ru"), 1, 10);  
	EndIf;
	
	CatalogRoot = AddNewDataHistoryRootNode(
		TreeRoot, NStr("ru = 'Справочники'; SYS='SDCH.Main.CatalosgNode'", "ru"), 1, 1);	
	DocumentRoot = AddNewDataHistoryRootNode(                             
		TreeRoot, NStr("ru = 'Документы'; SYS='SDCH.Main.DocumentsNode'", "ru"), 1, 2); 
	ChartsOfCharacteristicTypesRoot = AddNewDataHistoryRootNode(
		TreeRoot, NStr("ru = 'Планы видов характеристик'; SYS='SDCH.Main.ChartsOfCharacteristicTypesRoot'", "ru"), 1, 7);
	InfoRegistersRoot = AddNewDataHistoryRootNode(
		TreeRoot, NStr("ru = 'Регистры сведений'; SYS='SDCH.Main.InfoRegisterRoot'", "ru"), 1, 3);   
	ChartsOfAccountsRoot = AddNewDataHistoryRootNode(
		TreeRoot, NStr("ru = 'Планы счетов'; SYS='SDCH.Main.ChartsOfAccountsRoot'", "ru"), 1, 6);
		
	If CanUseChartOfCalculationTypes Then	
		ChartOfCalculationTypesRoot = AddNewDataHistoryRootNode(
			TreeRoot, NStr("ru = 'Планы видов расчета'; SYS='SDCH.Main.ChartOfCalculationTypesRoot'", "ru"), 1, 9); 
			
	EndIf;
	
	BusinessProcessesRoot = AddNewDataHistoryRootNode(
		TreeRoot, NStr("ru = 'Бизнес-процессы'; SYS='SDCH.Main.BusinessProcessesRoot'", "ru"), 1, 4);
	TasksRoot = AddNewDataHistoryRootNode(
		TreeRoot, NStr("ru = 'Задачи'; SYS='SDCH.Main.TasksRoot'", "ru"), 1, 5);
		
	MetadataInfoTable = FormAttributeToValue("MetadataInfo");
	MetadataUseDataHistory = Metadata.ObjectProperties.DataHistoryUse.Use;
		
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"Catalogs", CatalogRoot, Metadata.Catalogs, 1, DefaultValueOnly);  
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"Documents", DocumentRoot, Metadata.Documents, 2, DefaultValueOnly);
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"InformationRegisters", InfoRegistersRoot, Metadata.InformationRegisters, 3, DefaultValueOnly);
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"BusinessProcesses", BusinessProcessesRoot, Metadata.BusinessProcesses, 4, DefaultValueOnly);
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"Tasks", TasksRoot, Metadata.Tasks, 5, DefaultValueOnly);
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"ChartsOfAccounts", ChartsOfAccountsRoot, Metadata.ChartsOfAccounts, 6, DefaultValueOnly);
	FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
		"ChartsOfCharacteristicTypes", ChartsOfCharacteristicTypesRoot, Metadata.ChartsOfCharacteristicTypes, 7, DefaultValueOnly);
	
	If CanUseExchangePlan Then
		FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
			"ExchangePlans", ExchangePlansRoot, MetadataExchangePlans, 8, DefaultValueOnly);
		
	EndIf;
	
	If CanUseChartOfCalculationTypes Then
		FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
			"ChartsOfCalculationTypes", ChartOfCalculationTypesRoot, Metadata.ChartsOfCalculationTypes, 9, DefaultValueOnly);
		
	EndIf;
	
	If CanUseConstants Then
		FillMetadataInfoByObject(MetadataInfoTable, MetadataUseDataHistory,
			"Constants", ConstantsRoot, MetadataConstants, 10, DefaultValueOnly);
		
	EndIf;

	FirstLevelItems = TreeRoot.GetItems();
	FirstLevelItemsCount = FirstLevelItems.Count() - 1;
	
	TreeItems = DataHistoryTree.FindByID(TreeRoot.GetId());
	
	For Index = 0 To FirstLevelItemsCount Do 
		CurrentIndex = FirstLevelItemsCount - Index;
		CurrentChild = FirstLevelItems[CurrentIndex];
		
		If CurrentChild.GetItems().Count() = 0 Then
			TreeItems.GetItems().Delete(CurrentChild);
			
		EndIf;
		
	EndDo;
	
	FirstLevelItems = TreeRoot.GetItems(); 
	SecletedItemsCount = 0;
	
	For Each FirstLevelItem In FirstLevelItems Do
	    SecletedItemsCount = SecletedItemsCount + ?(FirstLevelItem.Use > 1, 1, 0);
	
	EndDo;

	If SecletedItemsCount = FirstLevelItems.Count() Then
		TreeRoot.Use = 1;
		
	ElsIf SecletedItemsCount > 0 Then
		TreeRoot.Use = 2;
		
	Else
		TreeRoot.Use = 0;
		
	EndIf;
	
	ValueToFormAttribute(MetadataInfoTable, "MetadataInfo");
	
	Return TreeRoot.GetID();
	
EndFunction

&AtServer
Function CanUseInDataHistory(MetadataManager)

	If MetadataManager.Count() > 0 Then
		AnyFirstObject = MetadataManager.Get(0);
		
		Try
			DataHistory.GetSettings(AnyFirstObject);	
		    Return True;
		Except
		EndTry;
		
		
	EndIf;
	
	Return False;
	
EndFunction // CanUseInDataHistory()

&AtServer
Function AddNewDataHistoryRootNode(NodeRoot, ItemTitle, Level, IconIdx)
		
	CurrentNode = NodeRoot.GetItems().Add();
	CurrentNode.Item = ItemTitle;
	CurrentNode.IconIdx = IconIdx;
	CurrentNode.Level = Level;
	CurrentNode.Enabled = True;
	
	Return CurrentNode;
	
EndFunction // AddNewDataHistoryRootNode()

&AtServerNoContext
Procedure FillMetadataTypes(Tree)
	
	If Is8313OrHigherCompatible() Then
		FillMetadataType(Tree, Metadata.Constants, "ConstantValueKey", NStr("ru='Константы';SYS='SDCH.Main.Constants'", "ru"), False);
		FillMetadataType(Tree, Metadata.ExchangePlans, "ExchangePlanRef", NStr("ru='Планы обмена';SYS='SDCH.Main.ExchangePlans'", "ru"), True);
	EndIf;
	FillMetadataType(Tree, Metadata.Catalogs, "CatalogRef", NStr("ru='Справочники';SYS='SDCH.Main.Catalogs'", "ru"), True);
	FillMetadataType(Tree, Metadata.Documents, "DocumentRef", NStr("ru='Документы';SYS='SDCH.Main.Documens'", "ru"), True);
	If Is8313OrHigherCompatible() Then
		FillMetadataType(Tree, Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypesRef", NStr("ru='Планы видов характеристик';SYS='SDCH.Main.ChartOfCharacteristicTypes'", "ru"), True);
		FillMetadataType(Tree, Metadata.ChartsOfAccounts, "ChartOfAccountsRef", NStr("ru='Планы счетов';SYS='SDCH.Main.ChartOfAccounts'", "ru"), True);
		FillMetadataType(Tree, Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypesRef", NStr("ru='Планы видов расчета';SYS='SDCH.Main.ChartOfCalculationTypes'", "ru"), True);
	EndIf;
	FillMetadataType(Tree, Metadata.BusinessProcesses, "BusinessProcessRef", NStr("ru='Бизнес-процессы';SYS='SDCH.Main.BusinessProcess'", "ru"), True);
	FillMetadataType(Tree, Metadata.Tasks, "TaskRef", NStr("ru='Задачи';SYS='SDCH.Main.Tasks'", "ru"), True);
	FillMetadataType(Tree, Metadata.InformationRegisters, "InformationRegisterRecordKey", NStr("ru='Регистры сведений';SYS='SDCH.Main.InformationRegisters'", "ru"), False);
	
EndProcedure

&AtServerNoContext
Function FillMetadataType(Tree, mdClass, TypeDomainName, NodePresentation, UseTypeRestriction)
Var mdItem, Node, ObjectHistorySettings, HistoryOn, Item;

	Node = Undefined;
	For Each mdItem In mdClass Do
		If Not AccessRight("ViewDataHistory", mdItem) Then
			Continue;
		EndIf;
		If Node = Undefined Then
			Node = Tree.GetItems().Add();
			Node.Presentation = NodePresentation;
		EndIf;
		If Is8311OrHigherCompatible() Then
			ObjectHistorySettings = DataHistory.GetSettings(mdItem);
		Else
			ObjectHistorySettings = Undefined;
		EndIf;
		If mdItem.DataHistory = Metadata.ObjectProperties.DataHistoryUse.Use And ObjectHistorySettings = Undefined Then
			HistoryOn = True;
		ElsIf ObjectHistorySettings <> Undefined Then
			HistoryOn = ObjectHistorySettings.Use;
		Else
			HistoryOn = False;
		EndIf;
		Item = Node.GetItems().Add();
		Item.Value = Type(TypeDomainName + "." + mdItem.Name);
		Item.Presentation = "" + mdItem.Presentation() + ?(HistoryOn, " (" + NStr("ru = 'история включена';SYS='SDCH.Main.HistoryOn'", "ru") + ")", "");
		Item.UseTypeRestriction = UseTypeRestriction;
	EndDo;
	
EndFunction

&AtServerNoContext
Function GetFormNameByData(Data, FormName)
	
	Return Data.Metadata().FullName() + "." + FormName;
	
EndFunction

&AtServerNoContext
Function GetFormNameToSwitch(Data)
Var DataMetadata;
	
	DataMetadata = Data.Metadata();
	If Metadata.InformationRegisters.Contains(DataMetadata) Then
		Return DataMetadata.FullName() + ".RecordForm";
	ElsIf Metadata.Constants.Contains(DataMetadata) Then
		Return DataMetadata.FullName() + ".ConstantsForm";
	Else
		Return DataMetadata.FullName() + ".ObjectForm";
	EndIf;
	
EndFunction

&AtServerNoContext
Procedure WriteComment(Data, VersionNumber, Comment)
	
	DataHistory.WriteComment(Data, VersionNumber, Comment);
	
EndProcedure

&AtServerNoContext
Function GetPreviousVersionNumber(dataObject, baseVersionNumber)
Var PreviousVersionNumber, CheckVersionNumber, ExcludeDeleted, Result, Filter;
	
	ExcludeDeleted = New Array();
	ExcludeDeleted.Add(DataChangeType.Create);
	ExcludeDeleted.Add(DataChangeType.Update);
	Filter = New Structure;
	Filter.Insert("Data", dataObject);
	Filter.Insert("DataChangeType", ExcludeDeleted);
	Result = DataHistory.SelectVersions(Filter, "VersionNumber", "VersionNumber Asc");
	For Each CheckVersionNumber In Result Do
		If CheckVersionNumber[0] = baseVersionNumber Then
			Return PreviousVersionNumber;
		EndIf;
		PreviousVersionNumber = CheckVersionNumber[0];
	EndDo;
	Return PreviousVersionNumber;
EndFunction

&AtServerNoContext
Function GetLastVersionNumber(dataObject)
Var Filter, ExcludeDeleted, Result, CheckVersionNumber;

	ExcludeDeleted = New Array();
	ExcludeDeleted.Add(DataChangeType.Create);
	ExcludeDeleted.Add(DataChangeType.Update);
	Filter = New Structure;
	Filter.Insert("Data", dataObject);
	Filter.Insert("DataChangeType", ExcludeDeleted);
	Result = DataHistory.SelectVersions(Filter, "VersionNumber", "VersionNumber Desc", 1);
	For Each CheckVersionNumber In Result Do
		Return CheckVersionNumber[0];
	EndDo;
	Return Undefined;
	
EndFunction

&AtServerNoContext
Function GetMDPresentationByType(Val Type)
	
	Return Metadata.FindByType(Type).Presentation();
	
EndFunction

&AtServerNoContext
Function Is8311OrHigherCompatible() Export
  Return 
    Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_10
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_9
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_8
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_7
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_6
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_5
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_4
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_3
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_2
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_1
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_2_16
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_2_13
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_1;
	
EndFunction	

&AtServerNoContext
Function Is8313OrHigherCompatible() Export
  Return 
	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_12
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_11
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_9
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_8
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_7
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_6
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_5
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_4
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_3
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_2
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_1
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_2_16
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_2_13
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_1;
	
EndFunction	

&AtServerNoContext
Function Is8314OrHigherCompatible() Export
  Return 
	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_14
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_13
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_12
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_11
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_9
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_8
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_7
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_6
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_5
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_4
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_3
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_2
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_3_1
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_2_16
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_2_13
		 And	Metadata.CompatibilityMode <> Metadata.ObjectProperties.CompatibilityMode.Version8_1;
	
EndFunction	

&AtClient
Функция GetFormName(FormName) Export
Var ForReturn;

	ForReturn = MetaPath + ".Form";
	If Not IsBlankString(FormName) Then
		ForReturn = ForReturn + "." + FormName;
	EndIf;
	Return ForReturn;
	
КонецФункции

&AtClient
Procedure OnOpen(Cancel)
	
	MakeFilterPresentation(FilterValue);
	AttachIdleHandler("OnOpenDelayed", 0.1, True);
	
EndProcedure

&AtClient
Procedure OnOpenDelayed() Export
	
	SetFilter(Items.FormSetFilter);
	
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	
	If EventName = "StandardDataChangeHistory.Update" Then
		Status(NStr("ru='Выполняется обновление истории...';SYS='SDCH.Main.UpdateInProgress'", "ru"));
		UpdateHistoryAtServer(False, Parameter.ExecuteAfterWriteVersion, Parameter.AutoDeleteFromPostProcessing);
		Status(NStr("ru='Завершено обновление истории';SYS='SDCH.Main.UpdateComplete'", "ru"));
	ElsIf EventName = "StandardDataChangeHistory.ExecuteAfterWrite" Then
		Status(NStr("ru='Выполняется обработка после записи версий...';SYS='SDCH.Main.ExecureAfterWriteProcessing'", "ru"));
		MakeExecuteAfterWriteAtServer(Undefined);
		Status(NStr("ru='Завершена обработка после записи версий';SYS='SDCH.Main.ExecureAfterWriteProcessingCompete'", "ru"));
	ElsIf EventName = "StandardDataChangeHistory.DeleteFromAfterWrite" Then
		Status(NStr("ru='Выполняется удаление из очереди обработки после записи версий...';SYS='SDCH.Main.DeleteFromAfterWriteProcessing'", "ru"));
		MakeDeleteFromAfterWriteAtServer(Undefined, Parameter.BorderDate);
		Status(NStr("ru='Завершено удаление из очереди обработки после записи версий';SYS='SDCH.Main.DeleteFromAfterWriteProcessingCompete'", "ru"));
	EndIf;
	
EndProcedure

&AtClient
Procedure MakeFilterPresentation(Filter)
Var Presentation;

	Presentation = "";
	If Filter <> Undefined Then
		Items.FormClearFilter.Enabled = True;
		If Filter.Property("StartDate") OR Filter.Property("EndDate") Then
			Presentation = PeriodPresentation(?(Filter.Property("StartDate"), Filter.StartDate, '00010101'), ?(Filter.Property("EndDate"), Filter.EndDate, '00010101')) + ",";
		EndIf;
		If Filter.Property("Metadata") Then
			Presentation = Presentation + NStr("ru='метаданные';SYS='SDCH.Main.FPmetada'", "ru") + ": " + GetMDPresentationByType(Filter.Metadata) + ",";
		EndIf;
		If Filter.Property("Data") Then
			Presentation = Presentation + NStr("ru='данные';SYS='SDCH.Main.FPdata'", "ru") + ": " + String(Filter.Data) + ",";
		EndIf;
		If Filter.Property("User") Or Filter.Property("UserFullName") Or Filter.Property("UserName") Then
			Presentation = Presentation + NStr("ru='пользователи';SYS='SDCH.Main.FPusers'", "ru") + ",";
		EndIf;
		If Filter.Property("DataChangeType") Then
			If TypeOf(Filter.DataChangeType) = Type("DataChangeType") Or (TypeOf(Filter.DataChangeType) = Type("Array") And Filter.DataChangeType.Count() <> 3) Then
				Presentation = Presentation + NStr("ru='действия';SYS='SDCH.Main.FPaction'", "ru") + ",";
			EndIf;
		EndIf;
		If Filter.Property("FieldValuesChange") Then
			Presentation = Presentation + NStr("ru='изменение значений';SYS='SDCH.Main.FPvalueChanges'", "ru") + ",";
		EndIf;
		If Filter.Property("FieldValues") Then
			Presentation = Presentation + NStr("ru='значения до/после';SYS='SDCH.Main.FPvalue'", "ru") + ",";
		EndIf;
		If Filter.Property("Comment") Or Filter.Property("Node") Or Filter.Property("DataPresentation") Then
			Presentation = Presentation + NStr("ru='прочие значения';SYS='SDCH.Main.FPother'", "ru") + ",";
		EndIf;
		Items.FilterPresentation.Title = New FormattedString(
				New FormattedString(NStr("ru='Отбор:';SYS='SDCH.Main.FPprefix'", "ru"), New Font( , , True)),
				" " + StrConcat(StrSplit(Presentation, ",", False), ", "));
	Else
		Presentation = NStr("ru='Для просмотра истории необходимо в отборе указать вид метаданных';SYS='SDCH.Main.NoFilterSpecified'", "ru");
		Items.FilterPresentation.Title = New FormattedString(Presentation, New Font( , , True));
		Items.FormClearFilter.Enabled = False;
	EndIf;
	
EndProcedure

#Region Basic_Commands_Client

&AtClient
Procedure SetFilter(Command)
Var DialogName, FormParameter, Callback;
	
	DialogName = GetFormName("DataHistoryFilter");
	If DialogName = Undefined Then
		Return;
	EndIf;
	Callback = New NotifyDescription("SetFilterCallback", ThisForm);
	FormParameter = New Structure;
	FormParameter.Insert("Filter", FilterValue);
	FormParameter.Insert("AvailableMetadata", AvailableMetadata);
	OpenForm(DialogName, FormParameter, , , , , Callback);
	
EndProcedure

&AtClient
Procedure SetFilterCallback(Result, ExtraParameters) Export
	
	If TypeOf(Result) = Type("Structure") Then
		FilterValue = Result;
		Refresh(Items.FormRefresh);
	EndIf;
	MakeFilterPresentation(FilterValue);
	
EndProcedure

&AtClient
Procedure Refresh(Command)
	
	If FilterValue = Undefined Or FilterValue.Count() = 0 Then
		SetFilter(Items.FormSetFilter);
		Return;
	EndIf;
	FinishText = NStr("ru='Обновление завершено';SYS='SDCH.Main.RefreshComplete'", "ru");
	If UpdateAtRefresh Then
		StartText = NStr("ru='Выполняется обновление истории данных и списка истории...';SYS='SDCH.Main.RefreshInProgress'", "ru");
	Else
		StartText = NStr("ru='Выполняется обновление списка истории...';SYS='SDCH.Main.RefreshInProgress'", "ru");
	EndIf;
	Status(StartText);
	// если надо - обновим историю по виду метаданных, который в отборе установлен
	If UpdateAtRefresh Then
		UpdateHistoryAtServer(False);
	EndIf;
	FillDataListAtServer();
	Status(FinishText);
	
EndProcedure

&AtClient
Procedure VisibleHistoryItemsNumberOnChange(Item)
	
	Refresh(Items.FormRefresh);
	
EndProcedure

&AtClient
Procedure ClearFilter(Command)

	List.Clear();
	FilterValue = Undefined;
	MakeFilterPresentation(FilterValue);
	SetFilter(Items.FormSetFilter);
	
EndProcedure

&AtClient
Procedure OpenVersion(Command)
Var curData, FormParams, VersionNumber;
	
	If Not CheckCurrentData(Items.List.CurrentData) Then
		Return;
	EndIf;
	If Items.List.CurrentItem = Items.Comment Then
		Return;
	EndIf;
	curData = Items.List.CurrentData.Data;
	VersionNumber = Items.List.CurrentData.VersionNumber;
	If VersionNumber = Undefined Then
		Return;
	EndIf;
	FormParams = New Structure;
	FormParams.Insert(GetCurrentName("Data"), curData);
	FormParams.Insert(GetCurrentName("VersionNumber"), VersionNumber);
	OpenForm(GetFormNameByData(curData, "DataHistoryVersionDataForm"), FormParams);
		
EndProcedure

&AtClient
Procedure ListCommentOnChange(Item)
Var curData;
	
	If Not CheckCurrentData(Items.List.CurrentData) Then
		Return;
	EndIf;
	curData = Items.List.CurrentData;
	WriteComment(curData.Data, curData.VersionNumber, curData.Comment);
	
EndProcedure

&AtClient
Procedure ComparePrev(Command)
Var curData, FormParams, AfterVersionNumber, BeforeVersionNumber;
	
	If Not CheckCurrentData(Items.List.CurrentData) Then
		Return;
	EndIf;
	curData = Items.List.CurrentData.Data;
	AfterVersionNumber = Items.List.CurrentData.VersionNumber;
	If AfterVersionNumber = Undefined Then
		Return;
	EndIf;
	BeforeVersionNumber = GetPreviousVersionNumber(curData, AfterVersionNumber);
	If BeforeVersionNumber = Undefined Then
		ShowMessageBox(,NStr("ru='Предыдущая версия отсутствует';SYS='SDCH.Main.PreviousVersionNotExists'", "ru"));
		Return;
	EndIf;
	
	FormParams = New Structure;
	FormParams.Insert(GetCurrentName("Data"), curData);
	FormParams.Insert(GetCurrentName("VersionNumberBeforeChange"), BeforeVersionNumber);
	FormParams.Insert(GetCurrentName("VersionNumberAfterChange"), AfterVersionNumber);
	OpenForm(GetFormNameByData(curData, "DataHistoryVersionDifferencesForm"), FormParams);

EndProcedure

&AtClient
Procedure CompareCur(Command)
Var curData, FormParams, LastVersionNumber, BeforeVersionNumber;
	
	If Not CheckCurrentData(Items.List.CurrentData) Then
		Return;
	EndIf;
	curData = Items.List.CurrentData.Data;
	BeforeVersionNumber = Items.List.CurrentData.VersionNumber;
	If BeforeVersionNumber = Undefined Then
		Return;
	EndIf;
	LastVersionNumber = GetLastVersionNumber(curData);
	If LastVersionNumber = BeforeVersionNumber Then
		ShowMessageBox(,NStr("ru='Версия является текущей';SYS='SDCH.Main.VersionIsLast'", "ru"));
		Return;
	EndIf;
	
	FormParams = New Structure;
	FormParams.Insert(GetCurrentName("Data"), curData);
	FormParams.Insert(GetCurrentName("VersionNumberBeforeChange"), BeforeVersionNumber);
	FormParams.Insert(GetCurrentName("VersionNumberAfterChange"), LastVersionNumber);
	OpenForm(GetFormNameByData(curData, "DataHistoryVersionDifferencesForm"), FormParams);

EndProcedure

&AtClient
Procedure CompareVersion(Command)
Var curData, itemVersion1, itemVersion2, itemList, VersionNumberBeforeChange, VersionNumberAfterChange, FormParam;

	itemList = Items.List;
	If itemList.CurrentData = Undefined Then
		Return;
	EndIf;
	If itemList.SelectedRows.Count() <> 2 Then
		ShowMessageBox(, NStr("ru='Выберите две версии для сравнения';SYS='SDCH.Main.Select2Version'", "ru"));
		Return;
	EndIf;
	itemVersion1 = itemList.RowData(itemList.SelectedRows[0]);
	itemVersion2 = itemList.RowData(itemList.SelectedRows[1]);
	If itemVersion1.Data <> itemVersion2.Data Then
		ShowMessageBox(, NStr("ru='Нельзя сравнивать версии разных объектов информационной базы';SYS='SDCH.Main.ObjectNotIdentical'", "ru"));
		Return;
	EndIf;
	If itemVersion1.DataChangeType = PredefinedValue("DataChangeType.Delete") Or itemVersion2.DataChangeType = PredefinedValue("DataChangeType.Delete") Then
		ShowMessageBox(, NStr("ru='Нельзя сравнивать с удалением данных';SYS='SDCH.Main.IncorrectChangeType'", "ru"));
		Return;
	EndIf;
	If itemVersion1.VersionNumber = itemVersion2.VersionNumber Then
		ShowMessageBox(, NStr("ru='Номера версий не должны быть равными';SYS='SDCH.Main.EqualVersionNumber'", "ru"));
		Return;
	EndIf;
	If itemVersion1.VersionNumber > itemVersion2.VersionNumber Then
		VersionNumberBeforeChange = itemVersion2.VersionNumber;
		VersionNumberAfterChange = itemVersion1.VersionNumber;
	Else
		VersionNumberBeforeChange = itemVersion1.VersionNumber;
		VersionNumberAfterChange = itemVersion2.VersionNumber;
	EndIf;
	curData = itemVersion1.Data;
	FormParams = New Structure;
	FormParams.Insert(GetCurrentName("Data"), curData);
	FormParams.Insert(GetCurrentName("VersionNumberBeforeChange"), VersionNumberBeforeChange);
	FormParams.Insert(GetCurrentName("VersionNumberAfterChange"), VersionNumberAfterChange);
	OpenForm(GetFormNameByData(curData, "DataHistoryVersionDifferencesForm"), FormParams);
			
EndProcedure

&AtClient
Procedure ListSelection(Item, SelectedRow, Field, StandardProcessing)
	
	If Not CheckCurrentData(Items.List.CurrentData) Then
		Return;
	EndIf;
	OpenVersion(ThisForm.Commands.Find("OpenVersion"));
	
EndProcedure

&AtClient
Procedure GoToVersion(Command)
Var curData, FormParams, VersionNumber;
	
	If Not CheckCurrentData(Items.List.CurrentData) Then
		Return;
	EndIf;
	curData = Items.List.CurrentData.Data;
	VersionNumber = Items.List.CurrentData.VersionNumber;
	If VersionNumber = Undefined Then
		Return;
	EndIf;
	FormParams = New Structure;
	FormParams.Insert(GetCurrentName("Key"), curData);
	FormParams.Insert(GetCurrentName("VersionNumberSwitchToDataHistoryVersion"), VersionNumber);
	OpenForm(GetFormNameToSwitch(curData), FormParams);

EndProcedure

&AtClient
Function CheckCurrentData(itemCurrendData)
	
	If itemCurrendData = Undefined Then
		Return False;
	EndIf;
	If itemCurrendData.DataChangeType = PredefinedValue("DataChangeType.Delete") Then
		ShowMessageBox(, NStr("ru='Не поддерживается выполнение операции с версией удаления данных';SYS='SDHC.Main.UnsupportOperation'", "ru"));
		Return False;
	EndIf;
	Return True;
	
EndFunction

&AtClient
Procedure UpdateHistory(Command)
	
	Status(NStr("ru='Выполняется обновление истории...';SYS='SDCH.Main.UpdateInProgress'", "ru"));
	// история будет обновлена по всем объектам метаданных
	UpdateHistoryAtServer(True);
	FillDataListAtServer();
	Status(NStr("ru='Завершено обновление истории';SYS='SDCH.Main.UpdateComplete'", "ru"));
	
EndProcedure

&AtClient
Procedure ExtendedDataHistoryControl(Command)
Var DialogName, FormParameter, Presentation, FilterSet;
	
	FilterSet = False;
	Presentation = "";
	If FilterValue <> Undefined Then
		If FilterValue.Property("Data") Then
			Presentation = NStr("ru='история по';SYS='SDCH.Main.FPdata4Service'", "ru") + " " + String(FilterValue.Data) + " (" + GetMDPresentationByType(FilterValue.Metadata) + ")";
			FilterSet = True;
		ElsIf FilterValue.Property("Metadata") Then
			Presentation = NStr("ru='история по всем данным объекта конфигурации';SYS='SDCH.Main.FPmetada4Service'", "ru") + " " + GetMDPresentationByType(FilterValue.Metadata);
			FilterSet = True;
		EndIf;
	Else
		Presentation = NStr("ru='история по всем объектам с включенной историей';SYS='SDCH.Main.NoFilterSpecified4Service'", "ru");
	EndIf;
	FormParameter = New Structure;
	FormParameter.Insert("FilterPresentation", Presentation);
	FormParameter.Insert("FilterSet", FilterSet);
	DialogName = GetFormName("DataHistoryManagement");
	If DialogName = Undefined Then
		Return;
	EndIf;
	OpenForm(DialogName, FormParameter);
	
EndProcedure

&AtClient
Procedure DataHistoryTreeOnActivateRow(Item)
	
	DataHistoryDetailsTree.GetItems().Clear();
	
	CurrentData = Items.DataHistoryTree.CurrentData;
	
	If CurrentData = Undefined Then
		Return;
		
	EndIf;
	
	MetadataRows = MetadataInfo.FindRows(New Structure("Owner", CurrentData.FullName));
	MetadataMap = New Structure;

	MetadataMap.Insert("Attributes", New Array);
	MetadataMap.Insert("Tabular", New Structure);	
                                   
	For Each MetadataRow In MetadataRows Do
		If MetadataRow.Type = "Attribute" Then
			MetadataMap.Attributes.Add(MetadataRow);
			
		ElsIf MetadataRow.Type = "Tabular" Then
			If Not MetadataMap.Tabular.Property(MetadataRow.Name) Then
				TabularStructure = New Structure;
				TabularStructure.Insert("Presentation", MetadataRow.Presentation);
				TabularStructure.Insert("Items",  New Array);
				
				MetadataMap.Tabular.Insert(MetadataRow.Name, TabularStructure);	
			EndIf;
			
		ElsIf MetadataRow.Type = "TabularAttribute" Then			
			MetadataMap.Tabular[MetadataRow.Tabular].Items.Add(MetadataRow);
			
		EndIf;
		
	EndDo;
	
	CurrentDataRowId = CurrentData.GetID();
	HasDisabled = False;
	
	If MetadataMap.Attributes.Count() > 0 Then
		RootAttributesTree = DataHistoryDetailsTree.GetItems().Add();
		RootAttributesTree.Item = NStr("ru = 'Поля'; SYS='SDCH.Main.RootAttributesTree'", "ru");
		RootAttributesTree.IconIdx = 10;
        RootAttributesTree.Type = "AttributesRoot";
		RootAttributesTree.ObjectRef = CurrentData.ObjectRef;
		RootAttributesTree.ObjectRowId = CurrentDataRowId;
		UsingAttributesCount = 0;
        HasDisabled = False;
		
		For Each AttributeInfo In MetadataMap.Attributes Do
			AttributeNode = RootAttributesTree.GetItems().Add();
			AttributeNode.Item = AttributeInfo.Presentation;
			AttributeNode.Name = AttributeInfo.Name;
			AttributeNode.IconIdx = 10;	
			AttributeNode.Use = AttributeInfo.Use;
			AttributeNode.Ref = AttributeInfo.Ref;
            AttributeNode.Type = AttributeInfo.Type;
			AttributeNode.ObjectRowId = CurrentDataRowId;
			AttributeNode.ObjectRef = CurrentData.ObjectRef;
			AttributeNode.Enabled = AttributeInfo.Enabled;
			
			If Not HasDisabled And Not AttributeNode.Enabled Then
				HasDisabled = True;
				
			EndIf;
			
			UsingAttributesCount = UsingAttributesCount + ?(AttributeNode.Use, 1, 0); 
		EndDo;
	   
		If UsingAttributesCount = MetadataMap.Attributes.Count() Then
			RootAttributesTree.Use = 1;
			
		ElsIf UsingAttributesCount > 0 Then
			RootAttributesTree.Use = 2;
			
		EndIf; 
		
		RootAttributesTree.Enabled = Not HasDisabled;
		
		Items.DataHistoryDetailsTree.Expand(RootAttributesTree.GetID());
	EndIf;
	
	If MetadataMap.Tabular.Count() > 0 Then
		RootTabularTree = DataHistoryDetailsTree.GetItems().Add();
		RootTabularTree.Item = NStr("ru = 'Табличные части'; SYS='SDCH.Main.RootTabularTree'", "ru");
		RootTabularTree.IconIdx = 6;
        RootTabularTree.Type = "TabularRoot";
		RootTabularTree.ObjectRowId = CurrentDataRowId;
		RootTabularTree.ObjectRef = CurrentData.ObjectRef;
		
		UsingTabularCount = 0;
		
		For Each TabularInfo In MetadataMap.Tabular Do
			TabularInfoData = TabularInfo.Value;
			
			TabularNode = RootTabularTree.GetItems().Add();
			TabularNode.Item = TabularInfoData.Presentation;
			TabularNode.IconIdx = 6;
            TabularNode.Type = "Tabular";
			TabularNode.ObjectRowId = CurrentDataRowId;
			TabularNode.Name = TabularInfo.Key;
			TabularNode.ObjectRef = CurrentData.ObjectRef;
			
			UsingAttributesCount = 0;

			For Each AttributeInfo In TabularInfoData.Items Do
				AttributeNode = TabularNode.GetItems().Add();
				AttributeNode.Item = AttributeInfo.Presentation;
				AttributeNode.IconIdx = 10;	
				AttributeNode.Use = AttributeInfo.Use;
				AttributeNode.Ref = AttributeInfo.Ref;
	            AttributeNode.Type = AttributeInfo.Type;
				AttributeNode.ObjectRowId = CurrentDataRowId;
				AttributeNode.Name = AttributeInfo.Name;
				AttributeNode.ObjectRef = CurrentData.ObjectRef;
				AttributeNode.Enabled = AttributeInfo.Enabled;
				
				If Not HasDisabled And Not AttributeNode.Enabled Then
					HasDisabled = True;
					
				EndIf;
				
				UsingAttributesCount = UsingAttributesCount + ?(AttributeNode.Use = 1, 1, 0); 
			EndDo;
		   
			If UsingAttributesCount = TabularInfoData.Items.Count() Then
				TabularNode.Use = 1;
				
			ElsIf UsingAttributesCount > 0 Then
				TabularNode.Use = 2;
				
			EndIf;
			TabularNode.Enabled = Not HasDisabled;
			UsingTabularCount = UsingTabularCount + ?(TabularNode.Use = 1, 1, 0);
			
		EndDo;
		
		RootTabularTree.Enabled = Not HasDisabled;
		
		If UsingTabularCount = MetadataMap.Tabular.Count() Then
			RootTabularTree.Use = 1;
			
		ElsIf UsingTabularCount > 0 Then
			RootTabularTree.Use = 2;
			
		EndIf;
		
		Items.DataHistoryDetailsTree.Expand(RootTabularTree.GetID(), True);
	EndIf;
	
EndProcedure

&AtClient
Procedure DataHistoryDetailsTreeUseOnChange(Item)
	
	CurrentRowId = Items.DataHistoryDetailsTree.CurrentRow;
	
	If CurrentRowId = Undefined Then
		Return;
		
	EndIf;

	CurrentRow = DataHistoryDetailsTree.FindByID(CurrentRowId);
	
	If CurrentRow.Type = "Attribute" Then
		If CurrentRow.Use = 2 Then
			CurrentRow.Use = 0;
		
		EndIf;
		
		ParentRow = CurrentRow.GetParent();
		
		AttributesChildren = ParentRow.GetItems();
		
		UsingAttributesCount = 0;
		
		For Each AttributeInfo In AttributesChildren Do			
			UsingAttributesCount = UsingAttributesCount + ?(AttributeInfo.Use = 1, 1, 0);
			
		EndDo;
		
				
		If UsingAttributesCount = AttributesChildren.Count() Then
			ParentRow.Use = 1;
			
		ElsIf UsingAttributesCount > 0 Then
			ParentRow.Use = 2;
			
		ElsIf UsingAttributesCount = 0 Then	
			ParentRow.Use = 0;
			
		EndIf; 
		
		AtributeRow = MetadataInfo.FindRows(New Structure("Ref", CurrentRow.Ref)); 
		
		If AtributeRow.Count() > 0 Then
			AtributeRow[0].Use = CurrentRow.Use;
			
		EndIf;
	ElsIf CurrentRow.Type = "AttributesRoot" 
		Or CurrentRow.Type = "Tabular" Then
		
		If CurrentRow.Use = 2 Then
			CurrentRow.Use = 0;
		
		EndIf;
		
		AttributesChildren = CurrentRow.GetItems();
		
		For Each AttributeInfo In AttributesChildren Do			
			AttributeInfo.Use = CurrentRow.Use;
			
		EndDo; 
		
		If CurrentRow.Type = "AttributesRoot" Then	
			AtributeRows = MetadataInfo.FindRows(
				New Structure("ObjectRef,Type", CurrentRow.ObjectRef, "Attribute")); 
			
		Else
			AtributeRows = MetadataInfo.FindRows(
				New Structure("ObjectRef,Type,Tabular", CurrentRow.ObjectRef, "TabularAttribute", CurrentRow.Name)); 	
		EndIf; 
		
		For Each AtributeRow In AtributeRows Do
			AtributeRow.Use = CurrentRow.Use;
			
		EndDo;
	ElsIf CurrentRow.Type = "TabularRoot" Then
		If CurrentRow.Use = 2 Then
			CurrentRow.Use = 0;
		
		EndIf;
		
		TabularChildren = CurrentRow.GetItems();
		
		For Each TabularInfo In TabularChildren Do			
			TabularInfo.Use = CurrentRow.Use;
			AttributesChildren = TabularInfo.GetItems();
			
			For Each AttributeInfo In AttributesChildren Do			
				AttributeInfo.Use = CurrentRow.Use;
				
			EndDo;
		EndDo; 
		
		AtributeRows = MetadataInfo.FindRows(
			New Structure("ObjectRef,Type", CurrentRow.ObjectRef, "TabularAttribute")); 
		
		For Each AtributeRow In AtributeRows Do
			AtributeRow.Use = CurrentRow.Use;
			
		EndDo; 
		
		AtributeRows = MetadataInfo.FindRows(
			New Structure("ObjectRef,Type", CurrentRow.ObjectRef, "Tabular")); 
		
		For Each AtributeRow In AtributeRows Do
			AtributeRow.Use = CurrentRow.Use;
			
		EndDo;

	ElsIf CurrentRow.Type = "TabularAttribute" Then
		If CurrentRow.Use = 2 Then
			CurrentRow.Use = 0;
		
		EndIf;
		
		ParentRow = CurrentRow.GetParent();
		
		AttributesChildren = ParentRow.GetItems();
		
		UsingAttributesCount = 0;
		
		For Each AttributeInfo In AttributesChildren Do			
			UsingAttributesCount = UsingAttributesCount + ?(AttributeInfo.Use = 1, 1, 0);
			
		EndDo;
		
				
		If UsingAttributesCount = AttributesChildren.Count() Then
			ParentRow.Use = 1;
			
		ElsIf UsingAttributesCount > 0 Then
			ParentRow.Use = 2;
			
		ElsIf UsingAttributesCount = 0 Then	
			ParentRow.Use = 0;
			
		EndIf;
		
		RootTabularRow = ParentRow.GetParent(); 
		TabularList = RootTabularRow.GetItems();
		
		UsingTabularCount = 0; 
		HasNotCompleted = False;
		
		For Each TabularNode In TabularList Do
		    UsingTabularCount = UsingTabularCount + ?(TabularNode.Use = 1, 1, 0);
			
			If Not HasNotCompleted And TabularNode.Use Then
				HasNotCompleted = True;
				
			EndIf;
		EndDo;
		
		If UsingTabularCount = TabularList.Count() Then
			RootTabularRow.Use = 1;
			
		ElsIf UsingTabularCount > 0 Or HasNotCompleted Then
			RootTabularRow.Use = 2;
			
		Else
			RootTabularRow.Use = 0;
			
		EndIf;
		
		AtributeRows = MetadataInfo.FindRows(
			New Structure("Ref,Type", CurrentRow.Ref, "TabularAttribute")); 
		
		For Each AtributeRow In AtributeRows Do
			AtributeRow.Use = CurrentRow.Use;
			
		EndDo;
	EndIf;
	
EndProcedure

&AtClient
Procedure UpdateMetadataUsingTree(ObjectRowId)
	
	ObjectRow = DataHistoryTree.FindByID(ObjectRowId);
	
	If ObjectRow = Undefined Then            
		Return;
		
	EndIf;
	
	ObjectRows = MetadataInfo.FindRows(New Structure("ObjectRef", ObjectRow.ObjectRef));
	ObjectHasNotCompleted = False;
	ObjectHasNotUsingCount = 0;
	ObjectHasUsingCount = 0;
	
	For Each ChildRow In ObjectRows Do
		If ChildRow.Use = 2 Then
			ObjectHasNotCompleted = True;
			Break;
		EndIf;
		
		If ChildRow.Use = 0 Then
			ObjectHasNotUsingCount = ObjectHasNotUsingCount + 1;
		EndIf;
		
		If ChildRow.Use = 1 Then
			ObjectHasUsingCount = ObjectHasUsingCount + 1;
		EndIf;
		
	EndDo;
	
	If ObjectHasNotCompleted Then
		ObjectRow.Use = 2;
			
	ElsIf ObjectHasNotUsingCount = ObjectRows.Count() Then
		ObjectRow.Use = 0;
		
	Else
		ObjectRow.Use = ?(ObjectHasUsingCount = ObjectRows.Count(), 1, 2);
		
	EndIf;

	ParentRow = ObjectRow.GetParent();
	CurrentParentRows = ParentRow.GetItems();
	
	UsingAttributesCount = 0;
	HasNotCompleted = False;
	
	For Each AttributeInfo In CurrentParentRows Do			
		UsingAttributesCount = UsingAttributesCount + ?(AttributeInfo.Use = 1, 1, 0);
		
		If Not HasNotCompleted And AttributeInfo.Use = 2 Then
			HasNotCompleted = True;
			Break;
		EndIf;
	EndDo;
	
	If UsingAttributesCount = CurrentParentRows.Count() Then
		ParentRow.Use = 1;
		
	ElsIf HasNotCompleted Then
		ParentRow.Use = 2;
		
	ElsIf UsingAttributesCount = 0 Then	
		ParentRow.Use = 0;
		
	EndIf;
	
	UpdateMetadaRootTree();
	
EndProcedure

&AtClient
Procedure DataHistoryTreeUseOnChange(Item)
	
	ObjectRowId = Items.DataHistoryTree.CurrentRow;
	
	If ObjectRowId = Undefined Then            
		Return;
		
	EndIf;
	
	CurrentRow = DataHistoryTree.FindByID(ObjectRowId);
	
	If CurrentRow.Use = 2 Then
		CurrentRow.Use = 0;
	
	EndIf;
	
	If CurrentRow.Level = 0 Then
		CategoryChildren = CurrentRow.GetItems();
		SelectedCategories = 0;
		
		For Each CurrentCategory In CategoryChildren Do
			CurrentCategory.Use = CurrentRow.Use;
			
			MetadataItems = CurrentCategory.GetItems();
			SelectedChildItems = 0;
			
			For Each MetadataItem In MetadataItems Do
				If MetadataItem.Enabled Then
			    	MetadataItem.Use = CurrentRow.Use;
				EndIf;
				
				SelectedChildItems = SelectedChildItems + MetadataItem.Use;
			EndDo;   
			
			If SelectedChildItems > 0 And SelectedChildItems < MetadataItems.Count() Then
				CurrentCategory.Use = 2;
				
			EndIf;
			
			SelectedCategories = ?(CurrentCategory.Use = 1, 1, 0);
		EndDo;    
		
		If SelectedCategories > 0 And SelectedCategories < CategoryChildren.Count() Then
			CurrentRow.Use = 2;
			
		EndIf;
	ElsIf CurrentRow.Level = 1 Then
		MetadataItems = CurrentRow.GetItems();	
		SelectedChildItems = 0;
		
		For Each MetadataItem In MetadataItems Do
			If MetadataItem.Enabled Then
		    	MetadataItem.Use = CurrentRow.Use;
			EndIf;
			
			SelectedChildItems = SelectedChildItems + MetadataItem.Use;
		EndDo;
		
		If SelectedChildItems > 0 And SelectedChildItems < MetadataItems.Count() Then
			CurrentRow.Use = 2;
			
		EndIf;
		
		ParentRow = CurrentRow.GetParent();
		CategoryChildren = ParentRow.GetItems();
		
		UsingAttributesCount = 0;
		HasNotCompleted = False;
		
		For Each CategoryInfo In CategoryChildren Do			
			UsingAttributesCount = UsingAttributesCount + ?(CategoryInfo.Use = 1, 1, 0);
			
			If Not HasNotCompleted And CategoryInfo.Use = 2 Then
				HasNotCompleted = True;
				Break;
			EndIf;
		EndDo;
		
		If UsingAttributesCount = CategoryChildren.Count() Then
			ParentRow.Use = 1;
			
		ElsIf HasNotCompleted Or UsingAttributesCount > 0 Then
			ParentRow.Use = 2;
			
		ElsIf UsingAttributesCount = 0 Then	
			ParentRow.Use = 0;
			
		EndIf;
	ElsIf CurrentRow.Level = 2 Then
		ParentRow = CurrentRow.GetParent();
		MetadataChildren = ParentRow.GetItems();
		
		UsingAttributesCount = 0;
		
		For Each MetadataInfoItem In MetadataChildren Do			
			UsingAttributesCount = UsingAttributesCount + ?(MetadataInfoItem.Use = 1, 1, 0);
			
		EndDo;
		
		If UsingAttributesCount = MetadataChildren.Count() Then
			ParentRow.Use = 1;
			
		ElsIf UsingAttributesCount > 0 Then
			ParentRow.Use = 2;
			
		ElsIf UsingAttributesCount = 0 Then	
			ParentRow.Use = 0;
			
		EndIf;
		
		UsingAttributesCount = 0;
		RootNode = ParentRow.GetParent();
		CategoryChildren = RootNode.GetItems();
		
		HasNotCompleted = false;
		
		For Each CategoryInfo In CategoryChildren Do			
			UsingAttributesCount = UsingAttributesCount + ?(CategoryInfo.Use = 1, 1, 0);
			
			If HasNotCompleted = False And CategoryInfo.Use = 2 Then
				HasNotCompleted = True;
				
			EndIf;
			
		EndDo;
		
		If UsingAttributesCount = CategoryChildren.Count() Then
			RootNode.Use = 1;
			
		ElsIf HasNotCompleted Or UsingAttributesCount > 0 Then
			RootNode.Use = 2;
			
		ElsIf UsingAttributesCount = 0 Then	
			RootNode.Use = 0;
			
		EndIf;
	EndIf;
	
EndProcedure

&AtClient
Procedure UpdateMetadaRootTree()
	
	RootItems = DataHistoryTree.GetItems();
	
	If RootItems.Count() = 0 Then
		Return;
		
	EndIf;
	
	RootTree = RootItems.Get(0);
	RootChildren = RootTree.GetItems();
	
	UsingAttributesCount = 0;
	HasNotCompleted = False;
	
	For Each AttributeInfo In RootChildren Do			
		UsingAttributesCount = UsingAttributesCount + ?(AttributeInfo.Use = 1, 1, 0);
		
		If Not HasNotCompleted And AttributeInfo.Use = 2 Then
			HasNotCompleted = True;
			Break;
		EndIf;
	EndDo;
	
	If UsingAttributesCount = RootChildren.Count() Then
		RootTree.Use = 1;
		
	ElsIf HasNotCompleted Then
		RootTree.Use = 2;
		
	ElsIf UsingAttributesCount = 0 Then	
		RootTree.Use = 0;
		
	EndIf;

EndProcedure

&AtClient
Procedure CancelChanges(Command)

	MetadataInfo.Clear();
	
	RootId = BuildMetadataTree();
	Items.DataHistoryTree.Expand(RootId);
	
EndProcedure

&AtClient
Procedure CommitSettings(Command)
	
	CommitSettingsAtServer();
	
EndProcedure

&AtServer
Procedure CommitSettingsAtServer()

	RootNode = DataHistoryTree.GetItems().Get(0);
	
	MetadataInfoTable = FormAttributeToValue("MetadataInfo");	
	MetadataInfoTable.Indexes.Add("ObjectRef");
	MetadataInfoTable.Indexes.Add("ObjectRef,Type");
	
	For Each CategoryItem In RootNode.GetItems() Do
	    MetadataInfoList = CategoryItem.GetItems();
		
		For Each MetadataInfoItem In MetadataInfoList Do
		    CurrentMetadataInfo = Eval(StrTemplate("Metadata.%1", MetadataInfoItem.FullName));
			
			If Not AccessRight("UpdateDataHistorySettings", CurrentMetadataInfo) Then
				Continue;
				
			EndIf;
			
			DataHistorySettings = DataHistory.GetSettings(CurrentMetadataInfo);
			DataHistoryUse = False;
			DataHistoryUsingFields = New Map;
			
			If DataHistorySettings = Undefined Then
				DataHistoryUse = (CurrentMetadataInfo.DataHistory = Metadata.ObjectProperties.DataHistoryUse.Use);
				
			Else
				DataHistoryUse = DataHistorySettings.Use;
				DataHistoryUsingFields = DataHistorySettings.FieldsUse;
				
			EndIf;
			
			NewDataHistoryUseValue = MetadataInfoItem.Use;
					
			NeedSaveHistorySettings = (DataHistoryUse <> NewDataHistoryUseValue);
			
			OutputFieldsToWrite = New Map;
			
			WriteDataHistoryField(MetadataInfoTable, OutputFieldsToWrite,
				CurrentMetadataInfo, MetadataInfoItem.ObjectRef, DataHistoryUsingFields, "Attribute");
			WriteDataHistoryField(MetadataInfoTable, OutputFieldsToWrite,
				CurrentMetadataInfo, MetadataInfoItem.ObjectRef, DataHistoryUsingFields, "TabularAttribute");
			WriteDataHistoryField(MetadataInfoTable, OutputFieldsToWrite,
				CurrentMetadataInfo, MetadataInfoItem.ObjectRef, DataHistoryUsingFields, "Dimension");
			WriteDataHistoryField(MetadataInfoTable, OutputFieldsToWrite,
				CurrentMetadataInfo, MetadataInfoItem.ObjectRef, DataHistoryUsingFields, "Resource");
				
			If NeedSaveHistorySettings Or OutputFieldsToWrite.Count() > 0 Or DataHistorySettings <> Undefined Then
				NeedToSave = False;
				
				If NeedSaveHistorySettings Then
					NeedToSave = True;
					
				EndIf;
				
				If OutputFieldsToWrite.Count() > 0 Then
					FieldsToWrite = MetadataInfoTable.FindRows(New Structure("ObjectRef", MetadataInfoItem.ObjectRef));
					
					For Each FieldToWrite In FieldsToWrite Do
						FieldToWriteUsing = (FieldToWrite.Use > 0);
						
						If FieldToWrite.Type = "TabularAttribute" Then
							FieldName = StrTemplate("%1.%2", FieldToWrite.Tabular, FieldToWrite.Name);
							
						Else
							FieldName = FieldToWrite.Name;
							
						EndIf;
						
						If OutputFieldsToWrite[FieldName] = Undefined Then
							Continue;
							
						EndIf;
						
						If OutputFieldsToWrite[FieldName] <> FieldToWrite.OldValue Then
							NeedToSave = True;
							Break;
							
						EndIf;
						
					EndDo;
				EndIf;
				
				If NeedToSave Then
					NewDataHistorySettings = New DataHistorySettings;
					NewDataHistorySettings.Use = Boolean(MetadataInfoItem.Use);
					NewDataHistorySettings.FieldsUse = OutputFieldsToWrite;
					
				EndIf;
				
				If NeedToSave Then
					DataHistory.SetSettings(CurrentMetadataInfo, NewDataHistorySettings);
					
				EndIf;
				
			EndIf;
		EndDo;
		
	
	EndDo;

EndProcedure

&AtServer
Procedure WriteDataHistoryField(MetadataInfoTable, OutputFieldsToWrite, MetadataObject, ObjectRef, DataHistoryUsingFields, Type)

	FieldsToWrite = MetadataInfoTable.FindRows(New Structure("ObjectRef,Type", ObjectRef, Type));
	UsingAnyFieldToWrite = False;
	
	For Each FieldToWrite In FieldsToWrite Do
		FieldToWriteUsing = (FieldToWrite.Use > 0);
		
		If FieldToWriteUsing <> FieldToWrite.OldValue Then
			UsingAnyFieldToWrite = True;
			Break;
		EndIf;
	EndDo;
	
	If Not UsingAnyFieldToWrite Then
		Return;
		
	EndIf;
	
	For Each FieldToWrite In FieldsToWrite Do
		UsingInConfiguration = UsingInConfiguration(MetadataObject, 
			DataHistoryUsingFields, FieldToWrite.Name, Type, FieldToWrite.Tabular);
		
		FieldToWriteUsing = (FieldToWrite.Use > 0); 
		
		If Type = "TabularAttribute" Then
			FieldName = StrTemplate("%1.%2", FieldToWrite.Tabular, FieldToWrite.Name);
			
		Else
			FieldName = FieldToWrite.Name;
			
		EndIf;     
	
		OutputFieldsToWrite.Insert(FieldName, FieldToWriteUsing);
	
	EndDo;
	
EndProcedure

&AtServer
Function UsingInConfiguration(MetadataObject, DataHistoryUsingFields, Name, Type, Tabular)
	
	Var MetadataObjectItem;
	
	If DataHistoryUsingFields[Name] <> Undefined Then
		Return DataHistoryUsingFields[Name];
		
	EndIf;
	
	DataHistoryUse = Metadata.ObjectProperties.DataHistoryUse.DontUse;
	
	If Type = "Attribute" Then
		MetadataObjectItem = MetadataObject.Attributes.Find(Name);
		
	ElsIf Type = "TabularAttribute" Then
		MetadataObjectTabularItem = MetadataObject.TabularSections.Find(Tabular);
		
		If MetadataObjectTabularItem <> Undefined Then
			MetadataObjectItem = MetadataObjectTabularItem.Attributes.Find(Name);
			
		EndIf;
	ElsIf Type = "Dimension" Then
		MetadataObjectItem = MetadataObject.Dimensions.Find(Name);
		
	ElsIf Type = "Resource" Then
		MetadataObjectItem = MetadataObject.Resources.Find(Name);
		
	EndIf;
	
	If MetadataObjectItem <> Undefined Then
		DataHistoryUse = MetadataObjectItem.DataHistory;
		
	EndIf;
	
	Return (DataHistoryUse = Metadata.ObjectProperties.DataHistoryUse.Use);	
	
EndFunction // UsingInConfiguration()

&НаКлиенте
Процедура DefaultSettings(Команда)
	
	MetadataInfo.Clear();
	
	RootId = BuildMetadataTree(True);
	Items.DataHistoryTree.Expand(RootId);
	
КонецПроцедуры

#EndRegion 
