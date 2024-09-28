﻿
// Предопределенные
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Объект.Проведен Тогда
		Элементы.Дата.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	ОбновитьИтоги();
КонецПроцедуры

// Команды
&НаСервере
Процедура КомандаТоварыЗаполнитьНаСервере()
	Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ЗаполнитьТовары(Объект.Товары, Объект.Склад, Перечисления.ТипыТовара.Товар, Момент);
КонецПроцедуры

&НаКлиенте
Процедура КомандаТоварыЗаполнить(Команда)
	КомандаТоварыЗаполнитьНаСервере();
	
	ОбновитьИтоги();
КонецПроцедуры

&НаСервере
Процедура КомандаТоварыОбновитьНаСервере()
	Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ЗаполнитьТовары(Объект.Товары, Объект.Склад, Перечисления.ТипыТовара.Товар, Момент, Истина);
КонецПроцедуры

&НаКлиенте
Процедура КомандаТоварыОбновить(Команда)
	КомандаТоварыОбновитьНаСервере();
	
	ОбновитьИтоги();
КонецПроцедуры

&НаКлиенте
Процедура КомандаТоварыУдалитьПС(Команда)
	ПустыеСтроки = Объект.Товары.НайтиСтроки(Новый Структура("Количество", 0)); 
	Для Каждого Строка Из ПустыеСтроки Цикл 
		Объект.Товары.Удалить(Строка); 
	КонецЦикла;
КонецПроцедуры

// Товары
&НаКлиенте
Процедура ТоварыТоварПриИзменении(Элемент)
	Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
	
	ТекСтрока = Элементы.Товары.ТекущиеДанные;
	ТекСтрока.ЦенаБазовая = РаботаСТоварами.Цена(ТекСтрока.Товар, "ЦенаБазовая", Момент);
	ТекСтрока.ОстатокДо = РаботаСТоварами.Остаток(Объект.Склад, ТекСтрока.Товар, Момент);
	ТекСтрока.СтавкаНДС = ИсторияРеквизитов.Получить(ТекСтрока.Товар, "СтавкаНДС", Момент, ПредопределенноеЗначение("Справочник.СтавкиНДС.БезНДС"));
	
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаБазоваяПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСтавкаНДСПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаСНДСПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПослеУдаления(Элемент)
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПересчитатьСтроку(ИдентификаторСтроки)
	Строка = Объект.Товары.НайтиПоИдентификатору(ИдентификаторСтроки);
	
	Если Элементы.Товары.ТекущийЭлемент <> Неопределено Тогда
		СтавкаНДС = ОбщийМодульСервер.ПолучитьЗначениеРеквизита(Строка.СтавкаНДС, "Ставка");
		
		Если Элементы.Товары.ТекущийЭлемент.Имя = "ТоварыСНДС" Тогда
			Строка.ЦенаБазовая = АрифметическиеФункции.ВычитатьНаценку(Строка.ЦенаСНДС, СтавкаНДС);
		Иначе
			Строка.ЦенаСНДС = АрифметическиеФункции.ДобавитьНаценку(Строка.ЦенаБазовая, СтавкаНДС);
		КонецЕсли;
		
		Строка.СуммаБазовая = Строка.ЦенаБазовая * Строка.Количество;
		Строка.СуммаНДС = АрифметическиеФункции.РассчитатьНаценку(Строка.СуммаБазовая, СтавкаНДС);
		Строка.СуммаСНДС = Строка.ЦенаСНДС * Строка.Количество;
		
		Строка.Объем = Строка.Количество * ОбщийМодульСервер.ПолучитьЗначениеРеквизита(Строка.Товар, "Объем", 0);
		Строка.Вес = Строка.Количество * ОбщийМодульСервер.ПолучитьЗначениеРеквизита(Строка.Товар, "Вес", 0);
	КонецЕсли;
КонецПроцедуры

// Вспомагательные
Процедура ОбновитьИтоги()
	Количество = Объект.Товары.Итог("Количество");
	Объем = Объект.Товары.Итог("Объем");
	Вес = Объект.Товары.Итог("Вес");
	Сумма = Объект.Товары.Итог("СуммаБазовая");
	СуммаВсего = Объект.Товары.Итог("СуммаБазовая");
КонецПроцедуры
