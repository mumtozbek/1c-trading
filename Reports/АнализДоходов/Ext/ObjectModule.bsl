﻿
Процедура Сформировать(ТабДок) Экспорт
	ТабДок.Очистить();
	
	Макет = ПолучитьМакет("Основной");

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьОбщийИтог = Макет.ПолучитьОбласть("ОбщиеИтоги");
	ОбластьСтатья = Макет.ПолучитьОбласть("Статья");
	ОбластьРегистратор = Макет.ПолучитьОбласть("Регистратор");
	ОбластьКомментарий = Макет.ПолучитьОбласть("Комментарий");

	ОбластьЗаголовок.Параметры.Период = ПредставлениеПериода(НачалоДня(Период.ДатаНачала), КонецДня(Период.ДатаОкончания));
	ТабДок.Вывести(ОбластьЗаголовок);
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	Движения.Статья КАК Статья,
	|	Движения.Регистратор КАК Регистратор,
	|	Движения.Примечание КАК Примечание,
	|	СУММА(Движения.СуммаНачальныйОстаток) КАК СуммаНачальныйОстаток,
	|	СУММА(Движения.СуммаПриход) КАК СуммаПриход,
	|	СУММА(Движения.СуммаРасход) КАК СуммаРасход,
	|	СУММА(Движения.СуммаКонечныйОстаток) КАК СуммаКонечныйОстаток
	|ИЗ
	|	РегистрНакопления.Доходы.ОстаткиИОбороты(&Дата1, &Дата2, Регистратор, ДвиженияИГраницыПериода) КАК Движения
	|ГДЕ
	|	ИСТИНА");
	
	Если ЗначениеЗаполнено(Статья) Тогда
		Запрос.Текст = Запрос.Текст + " И Движения.Статья = &Статья";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|СГРУППИРОВАТЬ ПО
	|	Статья,
	|	Регистратор,
	|	Примечание
	|УПОРЯДОЧИТЬ ПО
	|	Статья.Наименование,
	|	Регистратор.Дата
	|ИТОГИ
	|	СУММА(СуммаНачальныйОстаток),
	|	СУММА(СуммаПриход),
	|	СУММА(СуммаРасход),
	|	СУММА(СуммаКонечныйОстаток)
	|ПО
	|	ОБЩИЕ,
	|	Статья,
	|	Регистратор,
	|	Примечание";

	Запрос.УстановитьПараметр("Дата1", НачалоДня(Период.ДатаНачала));
	Запрос.УстановитьПараметр("Дата2", КонецДня(Период.ДатаОкончания));
	Запрос.УстановитьПараметр("Статья", Статья);

	РезультатЗапроса = Запрос.Выполнить();
	
	ТабДок.НачатьАвтогруппировкуСтрок();
	
	ВыборкаОбщийИтог = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
    Пока ВыборкаОбщийИтог.Следующий() Цикл
		ОбластьОбщийИтог.Параметры.Заполнить(ВыборкаОбщийИтог);
		ОбластьОбщийИтог.Параметры.СуммаДоход = ВыборкаОбщийИтог.СуммаПриход - ВыборкаОбщийИтог.СуммаРасход;
		ТабДок.Вывести(ОбластьОбщийИтог, ВыборкаОбщийИтог.Уровень());

		ВыборкаСтатья = ВыборкаОбщийИтог.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаСтатья.Следующий() Цикл
			СтруктураРасшифровки = Новый Структура;
			СтруктураРасшифровки.Вставить("Статья", ВыборкаСтатья.Статья);
			
			ОбластьСтатья.Параметры.Заполнить(ВыборкаСтатья);
			ОбластьСтатья.Параметры.Расшифровка = СтруктураРасшифровки;
			ТабДок.Вывести(ОбластьСтатья, ВыборкаСтатья.Уровень());

			Если Подробно Тогда
				ВыборкаРегистратор = ВыборкаСтатья.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаРегистратор.Следующий() Цикл
					Если ВыборкаРегистратор.Регистратор <> Неопределено И ВыборкаРегистратор.Регистратор.Дата >= НачалоДня(Период.ДатаНачала) И ВыборкаРегистратор.Регистратор.Дата <= КонецДня(Период.ДатаОкончания) Тогда
						ОбластьРегистратор.Параметры.Заполнить(ВыборкаРегистратор);
						ТабДок.Вывести(ОбластьРегистратор, ВыборкаРегистратор.Уровень());
						
						ВыборкаКомментарий = ВыборкаРегистратор.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
						Пока ВыборкаКомментарий.Следующий() Цикл
							Если ЗначениеЗаполнено(ВыборкаКомментарий.Примечание) И (ЗначениеЗаполнено(ВыборкаКомментарий.СуммаПриход) ИЛИ ЗначениеЗаполнено(ВыборкаКомментарий.СуммаРасход)) Тогда
								ОбластьКомментарий.Параметры.Заполнить(ВыборкаКомментарий);
								ТабДок.Вывести(ОбластьКомментарий, ВыборкаКомментарий.Уровень());
							КонецЕсли;
						КонецЦикла;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	ТабДок.ЗакончитьАвтогруппировкуСтрок();

	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.АвтоМасштаб = Истина;
КонецПроцедуры