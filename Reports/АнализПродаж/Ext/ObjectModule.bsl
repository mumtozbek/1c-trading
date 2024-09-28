﻿
Процедура Сформировать(ТабДок) Экспорт
	ТабДок.Очистить();
	
	Макет = ПолучитьМакет("Основной");

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьОбщийИтог = Макет.ПолучитьОбласть("ОбщиеИтоги");
	ОбластьВидРеализации = Макет.ПолучитьОбласть("ВидРеализации");
	ОбластьСклад = Макет.ПолучитьОбласть("Склад");
	ОбластьАгент = Макет.ПолучитьОбласть("Агент");
	ОбластьГруппа = Макет.ПолучитьОбласть("Группа");
	ОбластьТовар = Макет.ПолучитьОбласть("Товар");
	ОбластьРегистратор = Макет.ПолучитьОбласть("Регистратор");
	
	ОбластьЗаголовок.Параметры.Период = ПредставлениеПериода(НачалоДня(Период.ДатаНачала), КонецДня(Период.ДатаОкончания));
	ТабДок.Вывести(ОбластьЗаголовок);
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	Продажи.Склад КАК Склад,
	|	Продажи.ВидРеализации КАК ВидРеализации,
	|	Продажи.Агент КАК Агент,
	|	Продажи.Товар КАК Товар,
	|	Продажи.Регистратор КАК Регистратор,
	|	СУММА(Продажи.КоличествоОборот) КАК Количество,
	|	СУММА(Продажи.ОбъемОборот) КАК Объем,
	|	СУММА(Продажи.СуммаБазоваяОборот) КАК СуммаБазовая,
	|	СУММА(Продажи.СуммаСНаценкойОборот) КАК СуммаСНаценкой,
	|	СУММА(Продажи.СуммаПродажнаяОборот) КАК СуммаПродажная,
	|	СУММА(Продажи.СуммаОтпускнаяОборот) КАК СуммаОтпускная
	|ИЗ
	|	РегистрНакопления.Продажи.Обороты(&Дата1, &Дата2, Регистратор) КАК Продажи
	|ГДЕ
	|	ИСТИНА");
	
	Если НЕ Склад.Пустая() Тогда
		Запрос.Текст = Запрос.Текст + " И Склад = &Склад";
	КонецЕсли;
	
	Если НЕ ВидРеализации.Пустая() Тогда
		Запрос.Текст = Запрос.Текст + " И ВидРеализации = &ВидРеализации";
	КонецЕсли;
	
	Если НЕ Агент.Пустая() Тогда
		Запрос.Текст = Запрос.Текст + " И Агент = &Агент";
	КонецЕсли;
	
	Если НЕ Товар.Пустая() Тогда
		Запрос.Текст = Запрос.Текст + " И (Товар = &Товар ИЛИ Товар В ИЕРАРХИИ (&Товар))";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|СГРУППИРОВАТЬ ПО
	|	Склад,
	|	ВидРеализации,
	|	Агент,
	|	Товар,
	|	Регистратор
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВидРеализации,
	|	Склад.Наименование,
	|	Агент.Наименование,
	|	Товар.Наименование,
	|	Регистратор.Дата
	|ИТОГИ
	|	СУММА(Количество),
	|	СУММА(Объем),
	|	СУММА(СуммаБазовая),
	|	СУММА(СуммаСНаценкой),
	|	СУММА(СуммаПродажная),
	|	СУММА(СуммаОтпускная)
	|ПО
	|	ОБЩИЕ,";
	
	Если ПоСкладам Тогда
		Запрос.Текст = Запрос.Текст + " Склад,";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|	ВидРеализации,
	|	Агент,
	|	Товар" + ?(ПоГруппам, " ИЕРАРХИЯ", "") + ",
	|	Регистратор";

	Запрос.УстановитьПараметр("Дата1", НачалоДня(Период.ДатаНачала));
	Запрос.УстановитьПараметр("Дата2", КонецДня(Период.ДатаОкончания));
	Запрос.УстановитьПараметр("ВидРеализации", ВидРеализации);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Товар", Товар);
	Запрос.УстановитьПараметр("Агент", Агент);

	РезультатЗапроса = Запрос.Выполнить();

	ТабДок.НачатьАвтогруппировкуСтрок();

	ВыборкаОбщийИтог = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
    Пока ВыборкаОбщийИтог.Следующий() Цикл
		ОбластьОбщийИтог.Параметры.Заполнить(ВыборкаОбщийИтог);
		ТабДок.Вывести(ОбластьОбщийИтог, ВыборкаОбщийИтог.Уровень());

		Если ПоСкладам Тогда
			ВыборкаСклад = ВыборкаОбщийИтог.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаСклад.Следующий() Цикл
				СтруктураРасшифровки = Новый Структура;
				СтруктураРасшифровки.Вставить("Склад", ВыборкаСклад.Склад);
				
				ОбластьСклад.Параметры.Заполнить(ВыборкаСклад);
				ОбластьСклад.Параметры.Расшифровка = СтруктураРасшифровки;
				ТабДок.Вывести(ОбластьСклад, ВыборкаСклад.Уровень());
				
				ВыборкаВидРеализации = ВыборкаСклад.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаВидРеализации.Следующий() Цикл
					СтруктураРасшифровки = Новый Структура;
					СтруктураРасшифровки.Вставить("Склад", ВыборкаВидРеализации.Склад);
					СтруктураРасшифровки.Вставить("ВидРеализации", ВыборкаВидРеализации.ВидРеализации);
					
					ОбластьВидРеализации.Параметры.Заполнить(ВыборкаВидРеализации);
					ОбластьВидРеализации.Параметры.Расшифровка = СтруктураРасшифровки;
					ТабДок.Вывести(ОбластьВидРеализации, ВыборкаВидРеализации.Уровень());

					ВыборкаАгент = ВыборкаВидРеализации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
					Пока ВыборкаАгент.Следующий() Цикл
						СтруктураРасшифровки = Новый Структура;
						СтруктураРасшифровки.Вставить("Склад", ВыборкаАгент.Склад);
						СтруктураРасшифровки.Вставить("ВидРеализации", ВыборкаАгент.ВидРеализации);
						СтруктураРасшифровки.Вставить("Агент", ВыборкаАгент.Агент);
						
						ОбластьАгент.Параметры.Заполнить(ВыборкаАгент);
						ОбластьАгент.Параметры.Расшифровка = СтруктураРасшифровки;
						ТабДок.Вывести(ОбластьАгент, ВыборкаАгент.Уровень());

						Если ПоТоварам Тогда
							ВыборкаТовар = ВыборкаАгент.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
							Пока ВыборкаТовар.Следующий() Цикл
								Если ВыборкаТовар.Товар.ЭтоГруппа Тогда
									ОбластьГруппа.Параметры.Заполнить(ВыборкаТовар);
									ТабДок.Вывести(ОбластьГруппа, ВыборкаТовар.Уровень());
								Иначе
									ОбластьТовар.Параметры.Заполнить(ВыборкаТовар);
									ТабДок.Вывести(ОбластьТовар, ВыборкаТовар.Уровень());
								КонецЕсли;
								
								Если Подробно Тогда
									ВыборкаРегистратор = ВыборкаТовар.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
									Пока ВыборкаРегистратор.Следующий() Цикл
										Если ВыборкаРегистратор.Регистратор <> Неопределено И ВыборкаРегистратор.Регистратор.Дата >= НачалоДня(Период.ДатаНачала) И ВыборкаРегистратор.Регистратор.Дата <= КонецДня(Период.ДатаОкончания) Тогда
											ОбластьРегистратор.Параметры.Заполнить(ВыборкаРегистратор);
											ТабДок.Вывести(ОбластьРегистратор, ВыборкаРегистратор.Уровень());
										КонецЕсли;
									КонецЦикла;
								КонецЕсли;
							КонецЦикла;
						КонецЕсли;
					КонецЦикла;
				КонецЦикла;
			КонецЦикла;
		Иначе
			ВыборкаВидРеализации = ВыборкаОбщийИтог.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаВидРеализации.Следующий() Цикл
				СтруктураРасшифровки = Новый Структура;
				СтруктураРасшифровки.Вставить("Склад", ВыборкаВидРеализации.Склад);
				СтруктураРасшифровки.Вставить("ВидРеализации", ВыборкаВидРеализации.ВидРеализации);
				
				ОбластьВидРеализации.Параметры.Заполнить(ВыборкаВидРеализации);
				ОбластьВидРеализации.Параметры.Расшифровка = СтруктураРасшифровки;
				ТабДок.Вывести(ОбластьВидРеализации, ВыборкаВидРеализации.Уровень());

				ВыборкаАгент = ВыборкаВидРеализации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаАгент.Следующий() Цикл
					СтруктураРасшифровки = Новый Структура;
					СтруктураРасшифровки.Вставить("Склад", ВыборкаАгент.Склад);
					СтруктураРасшифровки.Вставить("ВидРеализации", ВыборкаАгент.ВидРеализации);
					СтруктураРасшифровки.Вставить("Агент", ВыборкаАгент.Агент);
					
					ОбластьАгент.Параметры.Заполнить(ВыборкаАгент);
					ОбластьАгент.Параметры.Расшифровка = СтруктураРасшифровки;
					ТабДок.Вывести(ОбластьАгент, ВыборкаАгент.Уровень());

					Если ПоТоварам Тогда
						ВыборкаТовар = ВыборкаАгент.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
						Пока ВыборкаТовар.Следующий() Цикл
							Если ВыборкаТовар.Товар.ЭтоГруппа Тогда
								ОбластьГруппа.Параметры.Заполнить(ВыборкаТовар);
								ТабДок.Вывести(ОбластьГруппа, ВыборкаТовар.Уровень());
							Иначе
								ОбластьТовар.Параметры.Заполнить(ВыборкаТовар);
								ТабДок.Вывести(ОбластьТовар, ВыборкаТовар.Уровень());
							КонецЕсли;
							
							Если Подробно Тогда
								ВыборкаРегистратор = ВыборкаТовар.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
								Пока ВыборкаРегистратор.Следующий() Цикл
									Если ВыборкаРегистратор.Регистратор <> Неопределено И ВыборкаРегистратор.Регистратор.Дата >= НачалоДня(Период.ДатаНачала) И ВыборкаРегистратор.Регистратор.Дата <= КонецДня(Период.ДатаОкончания) Тогда
										ОбластьРегистратор.Параметры.Заполнить(ВыборкаРегистратор);
										ТабДок.Вывести(ОбластьРегистратор, ВыборкаРегистратор.Уровень());
									КонецЕсли;
								КонецЦикла;
							КонецЕсли;
						КонецЦикла;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;

	ТабДок.ЗакончитьАвтогруппировкуСтрок();

	// Показать
	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.АвтоМасштаб = Истина;
КонецПроцедуры