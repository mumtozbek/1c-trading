﻿
Процедура Сформировать(ТабДок) Экспорт
	ТабДок.Очистить();
	
	Макет = ПолучитьМакет("Основной");

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьОбщийИтог = Макет.ПолучитьОбласть("ОбщиеИтоги");
	ОбластьТовар = Макет.ПолучитьОбласть("Товар");
	ОбластьРегистратор = Макет.ПолучитьОбласть("Регистратор");
	
	ОбластьЗаголовок.Параметры.Период = ПредставлениеПериода(НачалоДня(Период.ДатаНачала), КонецДня(Период.ДатаОкончания));
	ТабДок.Вывести(ОбластьЗаголовок);
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	РеализацияТМЦТовары.Ссылка КАК Регистратор,
		|	РеализацияТМЦТовары.Товар КАК Товар,
		|	(РеализацияТМЦТовары.СуммаПродажная - РеализацияТМЦТовары.СуммаОтпускная) КАК Сумма
		|ИЗ
		|	Документ.РеализацияТМЦ.Товары КАК РеализацияТМЦТовары
		|ГДЕ
		|	РеализацияТМЦТовары.Ссылка.Проведен
		|	И РеализацияТМЦТовары.Ссылка.Дата МЕЖДУ &НачалоПериода И &КонецПериода
		|	И (РеализацияТМЦТовары.СуммаПродажная - РеализацияТМЦТовары.СуммаОтпускная) <> 0
		|УПОРЯДОЧИТЬ ПО
		|	РеализацияТМЦТовары.Товар.ПорядокСортировки,
		|	РеализацияТМЦТовары.Ссылка.Дата
		|ИТОГИ
		|	СУММА(Сумма)
		|ПО
		|	ОБЩИЕ,
		|	Товар,
		|	Регистратор
		|"
	);
	
	Запрос.УстановитьПараметр("НачалоПериода", НачалоДня(Период.ДатаНачала));
	Запрос.УстановитьПараметр("КонецПериода", КонецДня(Период.ДатаОкончания));

	РезультатЗапроса = Запрос.Выполнить();

	ТабДок.НачатьАвтогруппировкуСтрок();

	ВыборкаОбщийИтог = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Если ВыборкаОбщийИтог.Следующий() Тогда
		ОбластьОбщийИтог.Параметры.Заполнить(ВыборкаОбщийИтог);
		ТабДок.Вывести(ОбластьОбщийИтог, ВыборкаОбщийИтог.Уровень());
	
		ВыборкаТовар = ВыборкаОбщийИтог.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	    Пока ВыборкаТовар.Следующий() Цикл
			ОбластьТовар.Параметры.Заполнить(ВыборкаТовар);
			ТабДок.Вывести(ОбластьТовар, ВыборкаТовар.Уровень());
			
			Если Подробно Тогда
				ВыборкаРегистратор = ВыборкаТовар.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			    Пока ВыборкаРегистратор.Следующий() Цикл
					ОбластьРегистратор.Параметры.Заполнить(ВыборкаРегистратор);
					ТабДок.Вывести(ОбластьРегистратор, ВыборкаРегистратор.Уровень());
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ТабДок.ЗакончитьАвтогруппировкуСтрок();

	// Показать
	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.АвтоМасштаб = Истина;
КонецПроцедуры