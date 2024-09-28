﻿
&НаСервере
Функция ПолучитьЗаписьНепериодическогоРегистрыСведений(ИмяРегистра, Отбор) Экспорт
	Возврат РегистрыСведений[ИмяРегистра].Получить(Отбор);
КонецФункции

&НаСервере
Функция ПолучитьВремяНовогоДокумента(Документ) Экспорт
    ТекстЗапроса = "
    |ВЫБРАТЬ
    |    Дата
    |ИЗ
    |    [ИмяТаблицы]
    |ГДЕ
    |    Дата МЕЖДУ &Дата1 И &Дата2
	|УПОРЯДОЧИТЬ ПО
	|	Дата УБЫВ
    |";
    
    ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "[ИмяТаблицы]", Метаданные.НайтиПоТипу(ТипЗнч(Документ.Ссылка)).ПолноеИмя());
    
    Запрос = Новый Запрос;
    Запрос.Текст = ТекстЗапроса;
    Запрос.УстановитьПараметр("Ссылка", Документ.Ссылка);
	Запрос.УстановитьПараметр("Дата1", НачалоДня(Документ.Дата));
	Запрос.УстановитьПараметр("Дата2", КонецДня(Документ.Дата));
	
	РезультатЗапроса = Запрос.Выполнить();
    
    Выборка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Дата + 1;
	Иначе
		Возврат НачалоДня(Документ.Дата);
	КонецЕсли;
КонецФункции
