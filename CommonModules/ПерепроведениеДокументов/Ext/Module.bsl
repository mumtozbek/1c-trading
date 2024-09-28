﻿
Процедура Запустить(ЗНАЧ Период, ЗНАЧ ВидыДокументов = Неопределено, Транзакция = Ложь, ЗНАЧ Адрес) Экспорт
	Попытка
		ДокументыЗаПериод = ПолучитьДокументыЗаПериод(Период, ВидыДокументов);
		Если ДокументыЗаПериод.Количество() > 0 Тогда
            ПерепроведениеДокументов(Адрес, ДокументыЗаПериод, ДокументыЗаПериод.Количество(), Транзакция);
		Иначе
			ПоместитьВоВременноеХранилище(Новый Структура("Прогресс,Документ,Количество", 100, "", ДокументыЗаПериод.Количество()), Адрес);
		КонецЕсли;
	Исключение
		ПоместитьВоВременноеХранилище(Новый Структура("Ошибка", ОписаниеОшибки()), Адрес);
	КонецПопытки;
КонецПроцедуры

Процедура ПерепроведениеДокументов(Адрес, ДокументыЗаПериод, КоличествоДокументов, Транзакция)
	Если Транзакция Тогда
		НачатьТранзакцию();
	КонецЕсли;
	
	Счетчик = 0;
	Для Каждого ДокументЗаПериод Из ДокументыЗаПериод Цикл
		Если ДокументЗаПериод.Уровень = 1 Тогда
			Попытка
				ДокументОбъект = ДокументЗаПериод.Документ.ПолучитьОбъект();
				ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
			Исключение
				ВызватьИсключение;
			КонецПопытки;
			
			Счетчик = Счетчик + 1;
			
			Прогресс = Окр(Счетчик * 100 / КоличествоДокументов, 2);
			
			ПоместитьВоВременноеХранилище(Новый Структура("Прогресс,Документ,Количество", Прогресс, ДокументЗаПериод.Документ, КоличествоДокументов), Адрес);
		КонецЕсли;
	КонецЦикла;
	
	Если Транзакция Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьДокументыЗаПериод(ЗНАЧ Период, ЗНАЧ ВидыДокументов = Неопределено, ГруппироватьПоМесяцам = Ложь) Экспорт
	ДокументыЗаПериод = Новый Массив;
	
	ТекстЗапроса = "";
	
	Если ВидыДокументов = Неопределено Тогда
		ВидыДокументов = Метаданные.Документы;
	КонецЕсли;
	
	Для Каждого ОбъектМетаданных Из ВидыДокументов Цикл
		Если ЗначениеЗаполнено(ТекстЗапроса) Тогда
			ТекстЗапроса = ТекстЗапроса + "
				|ОБЪЕДИНИТЬ ВСЕ";
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса + "
			|ВЫБРАТЬ
			|	НАЧАЛОПЕРИОДА(Дата, МЕСЯЦ) КАК Месяц,
			|	Ссылка КАК Документ,
			|	МоментВремени КАК МоментВремени
			|ИЗ
			|	Документ." + ОбъектМетаданных.Имя + "
			|ГДЕ
			|	Проведен И (Дата МЕЖДУ &НачалоПериода И &КонецПериода)";
	КонецЦикла;
	
	ТекстЗапроса = ТекстЗапроса + "
		|УПОРЯДОЧИТЬ ПО
		|	МоментВремени
		|
		|ИТОГИ ПО
		|	НАЧАЛОПЕРИОДА(Дата, МЕСЯЦ),
		|	Документ";
	
	Запрос = Новый Запрос(ТекстЗапроса);

	Запрос.УстановитьПараметр("НачалоПериода", НачалоДня(Период.ДатаНачала));
	Запрос.УстановитьПараметр("КонецПериода", КонецДня(Период.ДатаОкончания));

	Результат = Запрос.Выполнить();
	
	ВыборкаМесяц = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаМесяц.Следующий() Цикл
		Если ГруппироватьПоМесяцам Тогда
			ДокументыЗаПериод.Добавить(Новый Структура("Уровень,Месяц,Документ,МоментВремени", ВыборкаМесяц.Уровень(), ВыборкаМесяц.Месяц, ВыборкаМесяц.Документ, ВыборкаМесяц.МоментВремени));
		КонецЕсли;
		
		ВыборкаСсылка = ВыборкаМесяц.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаСсылка.Следующий() Цикл
			ДокументыЗаПериод.Добавить(Новый Структура("Уровень,Месяц,Документ,МоментВремени", ВыборкаСсылка.Уровень(), ВыборкаСсылка.Месяц, ВыборкаСсылка.Документ, ВыборкаСсылка.МоментВремени));
		КонецЦикла;
	КонецЦикла;
	
	Возврат ДокументыЗаПериод;
КонецФункции
