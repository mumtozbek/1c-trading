﻿
// Предопределенные
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
КонецПроцедуры

// Товары
&НаСервере
Процедура ТоварыЗаполнитьНаСервере()
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	РегОстатки.Склад КАК Склад,
	|	РегОстатки.Товар КАК Товар,
	|	РегОстатки.КоличествоОстаток КАК Остаток,
	|	ИсторияРеквизитовСтавкаНДС.Значение КАК СтавкаНДС,
	|	ВЫБОР КОГДА (РегОстатки.КоличествоОстаток <> 0 И РегОстатки.СуммаОстаток <> 0) ТОГДА (РегОстатки.СуммаОстаток / РегОстатки.КоличествоОстаток) ИНАЧЕ РегЦенаБазовая.Цена КОНЕЦ КАК ЦенаБазовая
	|ИЗ
	|	РегистрНакопления.Остатки.Остатки(&Дата, Порожняя = Ложь И Бронь = Ложь) КАК РегОстатки
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныТоваров.СрезПоследних(&Дата, Тип = ""ЦенаБазовая"") КАК РегЦенаБазовая ПО РегЦенаБазовая.Товар.Ссылка = РегОстатки.Товар.Ссылка
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ИсторияРеквизитов.СрезПоследних(&Дата, Реквизит = ""СтавкаНДС"") КАК ИсторияРеквизитовСтавкаНДС ПО ИсторияРеквизитовСтавкаНДС.Ссылка.Ссылка = РегОстатки.Товар.Ссылка
	|ГДЕ
	|	(РегОстатки.Товар.ВидТовара.ТипТовара = Значение(Перечисление.ТипыТовара.Продукция) или РегОстатки.Товар.ВидТовара.ТипТовара = Значение(Перечисление.ТипыТовара.Товар))
	|УПОРЯДОЧИТЬ ПО
	|	РегОстатки.Склад.Наименование,
	|	РегОстатки.Товар.Наименование");

	Запрос.УстановитьПараметр("Дата", Объект.Дата);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаТовар = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.Прямой);
	Пока ВыборкаТовар.Следующий() Цикл
		СтарыеСтроки = Объект.Товары.НайтиСтроки(Новый Структура("Склад,Товар", ВыборкаТовар.Склад, ВыборкаТовар.Товар));
		Если СтарыеСтроки.Количество() > 0 Тогда
			ТекСтрока = СтарыеСтроки[0];
		Иначе
			ТекСтрока = Объект.Товары.Добавить();
		КонецЕсли;
		
		ТекСтрока.Склад = ВыборкаТовар.Склад;
		ТекСтрока.Товар = ВыборкаТовар.Товар;
		ТекСтрока.Количество = ВыборкаТовар.Остаток;
		ТекСтрока.ЦенаБазовая = ВыборкаТовар.ЦенаБазовая;
		ТекСтрока.СтавкаНДССтарая = ВыборкаТовар.СтавкаНДС;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЗаполнить(Кнопка)
	ТоварыЗаполнитьНаСервере();
	
	Для Каждого ТекСтрока Из Объект.Товары Цикл
		ТоварыПересчитатьСтроку(ТекСтрока.ПолучитьИдентификатор());
	КонецЦикла;
	
	Объект.Товары.Сортировать("Товар");
КонецПроцедуры

&НаКлиенте
Процедура ТоварыОбновить(Кнопка)
	Для Каждого ТекСтрока Из Объект.Товары Цикл
		ТекСтрока.ЦенаБазовая = РаботаСТоварами.Цена(ТекСтрока.Товар, "ЦенаБазовая", Объект.Дата, ТекСтрока.ЦенаБазовая);
		ТекСтрока.Количество = РаботаСТоварами.Остаток(ТекСтрока.Склад, ТекСтрока.Товар, Объект.Дата, "Количество");
		ТекСтрока.СуммаСтарая = РаботаСТоварами.Остаток(ТекСтрока.Склад, ТекСтрока.Товар, Объект.Дата, "Сумма");
		ТекСтрока.СуммаПереоценки = ТекСтрока.СуммаНовая - ТекСтрока.СуммаСтарая;
		ТоварыПересчитатьСтроку(ТекСтрока.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ТоварыУдалитьПС(Кнопка)
	ПустыеСтроки = Объект.Товары.НайтиСтроки(Новый Структура("Записать", Ложь)); 
	Для Каждого Строка Из ПустыеСтроки Цикл 
		Объект.Товары.Удалить(Строка); 
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ТоварыТоварПриИзменении(Элемент)
	ТоварыОбновитьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаБазоваяПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаБазоваяНоваяПриИзменении(Элемент)
	ТекСтрока = Элементы.Товары.ТекущиеДанные;
	
	ТекСтрока.Коэффициент = (ТекСтрока.ЦенаБазоваяНовая * 100) / ТекСтрока.ЦенаБазовая - 100;
	
	ТоварыПересчитатьСтроку(ТекСтрока.ПолучитьИдентификатор());
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоэффициентПриИзменении(Элемент)
	ТекСтрока = Элементы.Товары.ТекущиеДанные;
	
	ТекСтрока.ЦенаБазоваяНовая = ТекСтрока.ЦенаБазовая * (100 + ТекСтрока.Коэффициент) / 100;
	
	ТоварыПересчитатьСтроку(ТекСтрока.ПолучитьИдентификатор())
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПослеУдаления(Элемент)
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	Если Элементы.Товары.ТекущийЭлемент.Имя <> "ТоварыЗаписать" Тогда
		ТекСтрока = Элементы.Товары.ТекущиеДанные;
		ТекСтрока.Записать = Истина;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ТоварыОбновитьСтроку(ИдентификаторСтроки, ОбновитьОстатки = Истина)
	Строка = Объект.Товары.НайтиПоИдентификатору(ИдентификаторСтроки);
	
	Строка.Количество = РаботаСТоварами.Остаток(Строка.Склад, Строка.Товар, Объект.Дата);
	
	ТоварыПересчитатьСтроку(ИдентификаторСтроки);
КонецПроцедуры

&НаСервере
Процедура ТоварыПересчитатьСтроку(ИдентификаторСтроки)
	Строка = Объект.Товары.НайтиПоИдентификатору(ИдентификаторСтроки);
	
	Строка.СуммаСтарая = Строка.Количество * Строка.ЦенаБазовая;
	Строка.СуммаНовая = Строка.Количество * Строка.ЦенаБазоваяНовая;
	
	Если ЗначениеЗаполнено(Строка.СуммаНовая) Тогда
		Строка.СуммаПереоценки = Строка.СуммаНовая - Строка.СуммаСтарая;
	Иначе
		Строка.СуммаПереоценки = 0;
	КонецЕсли;
КонецПроцедуры

// Цены
&НаСервере
Процедура ЦеныЗаполнитьНаСервере()
	Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
	
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	Товары.Ссылка КАК Товар,
		|	РегЦенаПродажная.Цена КАК ЦенаПродажная
		|ИЗ
		|	Справочник.Товары КАК Товары
		|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныТоваров.СрезПоследних(&Дата, Тип = ""ЦенаПродажная"") КАК РегЦенаПродажная ПО (РегЦенаПродажная.Товар = Товары.Ссылка)
		|ГДЕ
		|	(Товары.ВидТовара.ТипТовара = Значение(Перечисление.ТипыТовара.Продукция) ИЛИ Товары.ВидТовара.ТипТовара = Значение(Перечисление.ТипыТовара.Товар))
		|"
	);

	Запрос.УстановитьПараметр("Дата", Момент);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаТовар = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаТовар.Следующий() Цикл
		СтарыеСтроки = Объект.Цены.НайтиСтроки(Новый Структура("Товар", ВыборкаТовар.Товар));
		Если СтарыеСтроки.Количество() > 0 Тогда
			ТекСтрока = СтарыеСтроки[0];
		Иначе
			ТекСтрока = Объект.Цены.Добавить();
		КонецЕсли;
		
		ТекСтрока.Товар = ВыборкаТовар.Товар;
		ТекСтрока.ЦенаПродажнаяСтарая = ВыборкаТовар.ЦенаПродажная;
	КонецЦикла;
	
	Объект.Цены.Сортировать("Товар");
КонецПроцедуры

&НаКлиенте
Процедура ЦеныЗаполнить(Кнопка)
	ЦеныЗаполнитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЦеныОбновитьНаСервере()
	Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
	
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	Товары.Ссылка КАК Товар,
		|	РегЦенаПродажная.Цена КАК ЦенаПродажная
		|ИЗ
		|	Справочник.Товары КАК Товары
		|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныТоваров.СрезПоследних(&Дата, Тип = ""ЦенаПродажная"") КАК РегЦенаПродажная ПО (РегЦенаПродажная.Товар = Товары.Ссылка)
		|ГДЕ
		|	(Товары.ВидТовара.ТипТовара = Значение(Перечисление.ТипыТовара.Продукция) ИЛИ Товары.ВидТовара.ТипТовара = Значение(Перечисление.ТипыТовара.Товар))
		|	И Товары.Ссылка В (&МассивТоваров)
		|"
	);

	Запрос.УстановитьПараметр("Дата", Момент);
	Запрос.УстановитьПараметр("МассивТоваров", Объект.Цены.Выгрузить().ВыгрузитьКолонку("Товар"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаТовар = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаТовар.Следующий() Цикл
		СтарыеСтроки = Объект.Цены.НайтиСтроки(Новый Структура("Товар", ВыборкаТовар.Товар));
		Если СтарыеСтроки.Количество() > 0 Тогда
			ТекСтрока = СтарыеСтроки[0];
		Иначе
			ТекСтрока = Объект.Цены.Добавить();
		КонецЕсли;
		
		ТекСтрока.Товар = ВыборкаТовар.Товар;
		ТекСтрока.ЦенаПродажнаяСтарая = ВыборкаТовар.ЦенаПродажная;
		
		ЦеныОбновитьСтроку(ТекСтрока.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ЦеныОбновить(Кнопка)
	ЦеныОбновитьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ЦеныУдалитьПС(Кнопка)
	ПустыеСтроки = Объект.Цены.НайтиСтроки(Новый Структура("Записать", Ложь)); 
	Для Каждого ТекСтрока Из ПустыеСтроки Цикл 
		Объект.Цены.Удалить(ТекСтрока); 
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ЦеныТоварПриИзменении(Элемент)
	ТекСтрока = Элементы.Цены.ТекущиеДанные;
	ТекСтрока.ЦенаПродажнаяСтарая = РаботаСТоварами.Цена(ТекСтрока.Товар, "ЦенаПродажная", Объект.Дата);
КонецПроцедуры

&НаКлиенте
Процедура ЦеныКоличествоПриИзменении(Элемент)
	ЦеныПересчитатьСтроку(Элементы.Цены.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ЦеныЦенаПродажнаяСтараяПриИзменении(Элемент)
	ЦеныПересчитатьСтроку(Элементы.Цены.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ЦеныЦенаПродажнаяНоваяПриИзменении(Элемент)
	Элементы.Цены.ТекущиеДанные.Записать = Истина;
	
	ЦеныПересчитатьСтроку(Элементы.Цены.ТекущаяСтрока);
КонецПроцедуры

&НаСервере
Процедура ЦеныОбновитьСтроку(ИдентификаторСтроки)
	Строка = Объект.Цены.НайтиПоИдентификатору(ИдентификаторСтроки);
	
	Если Строка.ЦенаПродажнаяНовая = 0 Тогда
		Строка.ЦенаПродажнаяНовая = Строка.ЦенаПродажнаяСтарая;
	КонецЕсли;
	
	ЦеныПересчитатьСтроку(ИдентификаторСтроки);
КонецПроцедуры

&НаСервере
Процедура ЦеныПересчитатьСтроку(ИдентификаторСтроки)
	Строка = Объект.Цены.НайтиПоИдентификатору(ИдентификаторСтроки);
КонецПроцедуры

// Вспомагательные
&НаКлиенте
Процедура Обновить()
	
КонецПроцедуры
