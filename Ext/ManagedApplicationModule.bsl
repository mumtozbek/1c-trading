﻿
Процедура ВыводКаталогаИБВЗаголовке()
    ЗаголовокСистемы = ПолучитьЗаголовокПриложения();
	
	ТекущаяСтрока = СокрЛП(ВРег(СтрокаСоединенияИнформационнойБазы()));
    Если Лев(ТекущаяСтрока, 5) = "SRVR=" Тогда
        ПозицияБД = Найти(ТекущаяСтрока, ";REF=");
        
        _ИмяСервера = Сред(ТекущаяСтрока, 7, ПозицияБД-8);
        _ИмяБД = Сред(ТекущаяСтрока, ПозицияБД+6, СтрДлина(ТекущаяСтрока)-1-(ПозицияБД+6));
        
        СтрокаБД = " (Сервер: "+_ИмяСервера+" БД: "+_ИмяБД+")";
    Иначе
        _ИмяСервера = глПолучитьКаталогИБ();
        
        СтрокаБД = " (Файл: "+_ИмяСервера+")";
    КонецЕсли;
    
    УстановитьЗаголовокПриложения(ЗаголовокСистемы + СтрокаБД);
КонецПроцедуры

Процедура ПередНачаломРаботыСистемы(Отказ)
	Если ИмяПользователя() = "Сервер" Тогда
		Возврат;
	КонецЕсли;
	
	// Проверка прав на запуск
	Если ПользователиИБ.АктивныйПользователь() = Ложь Тогда
		Предупреждение("Данный пользователь не имеет доступа к системе.");
		
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

Процедура ПриНачалеРаботыСистемы()
	ВыводКаталогаИБВЗаголовке();
	
	_Обновления.Проверить();
КонецПроцедуры
