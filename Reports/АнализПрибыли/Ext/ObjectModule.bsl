﻿
Процедура Сформировать(ТабДок) Экспорт
	ТабДок.Очистить();
	
	УчетнаяПолитика = УчетныеПолитики.ПолучитьНаДату(Дата, Организация);
	
	Данные = Новый ТаблицаЗначений;
	Данные.Колонки.Добавить("Статья");
	Данные.Колонки.Добавить("Сумма");
	
	Макет = ПолучитьМакет("Основной");

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьОбщийИтог = Макет.ПолучитьОбласть("ОбщиеИтоги");
	ОбластьСтатья = Макет.ПолучитьОбласть("Статья");

	ОбластьЗаголовок.Параметры.Период = ПредставлениеПериода(НачалоДня(Дата), КонецДня(Дата));
	ТабДок.Вывести(ОбластьЗаголовок);
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	// Доходы //
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	СУММА(Движения.СуммаОстаток) КАК Сумма
	|ИЗ
	|	РегистрНакопления.Доходы.Остатки(&Дата) КАК Движения
	|ГДЕ
	|	ИСТИНА
	|ИТОГИ
	|	СУММА(Сумма)
	|ПО
	|	ОБЩИЕ");

	Запрос.УстановитьПараметр("Дата", КонецДня(Дата) + 1);

	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДоходы = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаДоходы.Следующий() Цикл
		Строка = Данные.Добавить();
		Строка.Статья = "Нераспределенный доход";
		Строка.Сумма = ВыборкаДоходы.Сумма;
	КонецЦикла;
	// Доходы //
	
	// Остатки //
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	СУММА(Движения.СуммаОстаток) КАК Сумма
	|ИЗ
	|	РегистрНакопления.Остатки.Остатки(&Дата, Порожняя = Ложь И Бронь = Ложь) КАК Движения
	|ГДЕ
	|	Склад.Временный
	|ИМЕЮЩИЕ
	|	СУММА(Движения.СуммаОстаток) > 0
	|ИТОГИ
	|	СУММА(Сумма)
	|ПО
	|	ОБЩИЕ");

	Запрос.УстановитьПараметр("Дата", КонецДня(Дата) + 1);

	РезультатЗапроса = Запрос.Выполнить();

	ВыборкаОстатки = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаОстатки.Следующий() Цикл
		Строка = Данные.Добавить();
		Строка.Статья = "Несписанный товар";
		Строка.Сумма = -АрифметическиеФункции.ДобавитьНаценку(АрифметическиеФункции.ДобавитьНаценку(ВыборкаОстатки.Сумма, Ставка), УчетнаяПолитика.СтавкаНДС);
	КонецЦикла;
	// Остатки //
	
	ТабДок.НачатьАвтогруппировкуСтрок();
	
	Для Каждого Строка Из Данные Цикл
		ОбластьСтатья.Параметры.Заполнить(Строка);
		ТабДок.Вывести(ОбластьСтатья);
	КонецЦикла;
	
	ОбластьОбщийИтог.Параметры.Сумма = Данные.Итог("Сумма");
	ТабДок.Вывести(ОбластьОбщийИтог);
	
	ТабДок.ЗакончитьАвтогруппировкуСтрок();

	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.АвтоМасштаб = Истина;
КонецПроцедуры