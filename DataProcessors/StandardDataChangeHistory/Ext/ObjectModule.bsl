
Function ConvertName2English(Term) Export
	Var Terms, NewTerm;
	
	Terms = New Structure;
	Terms.Insert("Data", "Data");
	Terms.Insert("DataPresentation", "DataPresentation");
	Terms.Insert("VersionNumber", "VersionNumber");
	Terms.Insert("Date", "Date");
	Terms.Insert("User", "User");
	Terms.Insert("UserName", "UserName");
	Terms.Insert("UserFullName", "UserFullName");
	Terms.Insert("DataChangeType", "DataChangeType");
	Terms.Insert("Comment", "Comment");
	Terms.Insert("Transaction", "Transaction");
	Terms.Insert("Node", "Node");
	Terms.Insert("Данные", "Data");
	Terms.Insert("ПредставлениеДанных", "DataPresentation");
	Terms.Insert("НомерВерсии", "VersionNumber");
	Terms.Insert("Дата", "Date");
	Terms.Insert("Пользователь", "User");
	Terms.Insert("ИмяПользователя", "UserName");
	Terms.Insert("ПолноеИмяПользователя", "UserFullName");
	Terms.Insert("ВидИзмененияДанных", "DataChangeType");
	Terms.Insert("Комментарий", "Comment");
	Terms.Insert("Транзакция", "Transaction");
	Terms.Insert("Узел", "Node");
	
	If Terms.Property(Term) Then
		NewTerm = Terms[Term];
	Else
		NewTerm = Term;
	EndIf;
	return NewTerm;
EndFunction

Function ConvertStructureKeyToEn(DataStructure) Export
Var Terms, NewStructure, Item, NewKey, NewValue;
	
	If DataStructure = Undefined Then
		Return DataStructure;
	EndIf;
	Terms = New Structure;
	Terms.Insert("Метаданные", "Metadata");
	Terms.Insert("Данные", "Data");
	Terms.Insert("ПредставлениеДанных", "DataPresentation");
	Terms.Insert("НомерВерсии", "VersionNumber");
	Terms.Insert("ДатаНачала", "StartDate");
	Terms.Insert("ДатаОкончания", "EndDate");
	Terms.Insert("Пользователь", "User");
	Terms.Insert("ИмяПользователя", "UserName");
	Terms.Insert("ПолноеИмяПользователя", "UserFullName");
	Terms.Insert("ВидИзмененияДанных", "DataChangeType");
	Terms.Insert("Комментарий", "Comment");
	Terms.Insert("Транзакция", "Transaction");
	Terms.Insert("Узел", "Node");
	Terms.Insert("ЗначенияПолей", "FieldValues");
	
	Terms.Insert("Представление", "Presentation");
	Terms.Insert("Поля", "Fields");
	Terms.Insert("ТабличныеЧасти", "TabularSections");
	NewStructure = New Structure;
	For Each Item In DataStructure Do
		NewKey = Item.Key;
		If Terms.Property(Item.Key) Then
			NewKey = Terms[Item.Key];
		EndIf;
		If TypeOf(Item.Value) = Type("Structure") Then
			NewValue = ConvertStructureKeyToEn(Item.Value);
		ElsIf TypeOf(Item.Value) = Type("FixedStructure") Then
			NewValue = New FixedStructure(ConvertStructureKeyToEn(Item.Value));
		Else
			NewValue = Item.Value;
		EndIf;
		NewStructure.Insert(NewKey, NewValue);			
	EndDo;
	Return NewStructure;
	
EndFunction
