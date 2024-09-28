﻿
Процедура Сформировать(ТабДок) Экспорт
	ТабДок.Очистить();
	
	Макет = ПолучитьМакет("Основной");

	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьОбщийИтог = Макет.ПолучитьОбласть("ОбщиеИтоги");
	ОбластьСклад = Макет.ПолучитьОбласть("Склад");
	ОбластьГруппа = Макет.ПолучитьОбласть("Группа");
	ОбластьТовар = Макет.ПолучитьОбласть("Товар");
	ОбластьРегистратор = Макет.ПолучитьОбласть("Регистратор");
	
	ОбластьЗаголовок.Параметры.НазваниеОрганизации = Организация.Наименование;
	ОбластьЗаголовок.Параметры.Период = ПредставлениеПериода(Период.ДатаНачала, КонецДня(Период.ДатаОкончания));
	ОбластьЗаголовок.Параметры.Склад = Склад.Наименование;
	ТабДок.Вывести(ОбластьЗаголовок);
	
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	Запрос = Новый Запрос("ВЫБРАТЬ");
	
	Если Объединить Тогда
		Запрос.Текст =  Запрос.Текст + " (&Склад) КАК Склад,";
	Иначе
		Запрос.Текст =  Запрос.Текст + " РегОстаткиОстаткиИОбороты.Склад КАК Склад,";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|	ВЫБОР КОГДА (РегОстаткиОстаткиИОбороты.Регистратор ССЫЛКА Документ.РеализацияТМЦ) ТОГДА
	|		РегОстаткиОстаткиИОбороты.Регистратор.Контрагент
	|	ИНАЧЕ
	|		NULL
	|	КОНЕЦ КАК Контрагент,
	|	РегОстаткиОстаткиИОбороты.Товар КАК Товар,
	|	РегОстаткиОстаткиИОбороты.Товар.Код КАК ТоварКод,
	|	РегОстаткиОстаткиИОбороты.Товар.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	РегОстаткиОстаткиИОбороты.Товар.Объем КАК Объем,
	|	ИсторияРеквизитовСтавкаНДС.Значение КАК СтавкаНДС,";
	
	Если Подробно Тогда
		Запрос.Текст = Запрос.Текст + "	РегОстаткиОстаткиИОбороты.Регистратор КАК Регистратор,";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|	(РегОстаткиОстаткиИОбороты.СуммаНачальныйОстаток) КАК СуммаНачальныйОстаток,
	|	(РегОстаткиОстаткиИОбороты.СуммаПриход) КАК СуммаПриход,
	|	(РегОстаткиОстаткиИОбороты.СуммаРасход) КАК СуммаРасход,
	|	(РегОстаткиОстаткиИОбороты.СуммаКонечныйОстаток) КАК СуммаКонечныйОстаток,
	|	(РегОстаткиОстаткиИОбороты.КоличествоНачальныйОстаток) КАК КоличествоНачальныйОстаток,
	|	(РегОстаткиОстаткиИОбороты.КоличествоПриход) КАК КоличествоПриход,
	|	(РегОстаткиОстаткиИОбороты.КоличествоРасход) КАК КоличествоРасход,
	|	(РегОстаткиОстаткиИОбороты.КоличествоКонечныйОстаток) КАК КоличествоКонечныйОстаток
	|ИЗ
	|	РегистрНакопления.Остатки.ОстаткиИОбороты(&Дата1, &Дата2, Запись, ДвиженияИГраницыПериода, Порожняя = &Порожняя И Бронь = Ложь) КАК РегОстаткиОстаткиИОбороты
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ИсторияРеквизитов.СрезПоследних(&Дата2, Реквизит = ""СтавкаНДС"") КАК ИсторияРеквизитовСтавкаНДС ПО ИсторияРеквизитовСтавкаНДС.Ссылка.Ссылка = РегОстаткиОстаткиИОбороты.Товар.Ссылка
	|ГДЕ
	|	ИСТИНА";
	
	Если ИсключитьНулевых Тогда
		Запрос.Текст = Запрос.Текст + " И (РегОстаткиОстаткиИОбороты.КоличествоНачальныйОстаток <> 0 ИЛИ РегОстаткиОстаткиИОбороты.КоличествоПриход <> 0 И РегОстаткиОстаткиИОбороты.КоличествоРасход <> 0 ИЛИ РегОстаткиОстаткиИОбороты.КоличествоКонечныйОстаток <> 0)";
	КонецЕсли;
	
	Если НЕ Склад.Пустая() Тогда
		Запрос.Текст = Запрос.Текст + " И РегОстаткиОстаткиИОбороты.Склад В ИЕРАРХИИ (&Склад)";
	КонецЕсли;
	
	Если НЕ Товар.Пустая() Тогда
		Запрос.Текст = Запрос.Текст + " И (РегОстаткиОстаткиИОбороты.Товар В ИЕРАРХИИ (&Товар))";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|УПОРЯДОЧИТЬ ПО
	|	РегОстаткиОстаткиИОбороты.Склад.Наименование,
	|	РегОстаткиОстаткиИОбороты.Товар.Наименование";
	
	Если Подробно Тогда
		Запрос.Текст = Запрос.Текст + ",	РегОстаткиОстаткиИОбороты.Регистратор.Дата";
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
	|ИТОГИ
	|	СУММА(СуммаНачальныйОстаток),
	|	СУММА(СуммаПриход),
	|	СУММА(СуммаРасход),
	|	СУММА(СуммаКонечныйОстаток),
	|	СУММА(КоличествоПриход),
	|	СУММА(КоличествоРасход),
	|	СУММА(КоличествоКонечныйОстаток)
	|ПО
	|	ОБЩИЕ,
	|	Склад,
	|	Товар" + ?(ПоГруппам, " ИЕРАРХИЯ", "");
	
	Если Подробно Тогда
		Запрос.Текст = Запрос.Текст + ",	Регистратор";
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Дата1", НачалоДня(Период.ДатаНачала));
	Запрос.УстановитьПараметр("Дата2", КонецДня(Период.ДатаОкончания));
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Товар", Товар);
	Запрос.УстановитьПараметр("Порожняя", Порожняя);

	РезультатЗапроса = Запрос.Выполнить();

	ТабДок.НачатьАвтогруппировкуСтрок();

	ВыборкаОбщийИтог = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
    Пока ВыборкаОбщийИтог.Следующий() Цикл
		ОбластьОбщийИтог.Параметры.Заполнить(ВыборкаОбщийИтог);
		ОбластьОбщийИтог.Параметры.Счет = "2910 - Товары на складах";
		ТабДок.Вывести(ОбластьОбщийИтог, ВыборкаОбщийИтог.Уровень());

		ВыборкаСклад = ВыборкаОбщийИтог.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);

		НомерСтроки = 1;
		Пока ВыборкаСклад.Следующий() Цикл
			СтруктураРасшифровки = Новый Структура;
			СтруктураРасшифровки.Вставить("Склад", ВыборкаСклад.Склад);
			
			ОбластьСклад.Параметры.Заполнить(ВыборкаСклад);
			ОбластьСклад.Параметры.Расшифровка = СтруктураРасшифровки;
			ТабДок.Вывести(ОбластьСклад, ВыборкаСклад.Уровень());

			ВыборкаТовар = ВыборкаСклад.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаТовар.Следующий() Цикл
				СтруктураРасшифровки = Новый Структура;
				СтруктураРасшифровки.Вставить("Склад", ВыборкаТовар.Склад);
				СтруктураРасшифровки.Вставить("Товар", ВыборкаТовар.Товар);
				
				Если ВыборкаТовар.Товар.ЭтоГруппа Тогда
					ОбластьГруппа.Параметры.Заполнить(ВыборкаТовар);
					ОбластьГруппа.Параметры.Расшифровка = СтруктураРасшифровки;
					ТабДок.Вывести(ОбластьГруппа, ВыборкаТовар.Уровень());
				Иначе
					ОбластьТовар.Параметры.Заполнить(ВыборкаТовар);
					ОбластьТовар.Параметры.Расшифровка = СтруктураРасшифровки;
					ОбластьТовар.Параметры.НомерСтроки = НомерСтроки;
					
					//ОбластьТовар.Параметры.СтавкаНДС = ИсторияРеквизитов.Получить(ВыборкаТовар.Товар, "СтавкаНДС", КонецДня(Период.ДатаОкончания), Справочники.СтавкиНДС.БезНДС);
					
					//ОбластьТовар.Параметры.ЦенаБазоваяНаНачало = ?(ВыборкаТовар.КоличествоНачальныйОстаток > 0, ВыборкаТовар.СуммаНачальныйОстаток / ВыборкаТовар.КоличествоНачальныйОстаток, 0);
					//ОбластьТовар.Параметры.ЦенаБазоваяНаКонец = ?(ВыборкаТовар.КоличествоКонечныйОстаток > 0, ВыборкаТовар.СуммаКонечныйОстаток / ВыборкаТовар.КоличествоКонечныйОстаток, 0);
					
					ТабДок.Вывести(ОбластьТовар, ВыборкаТовар.Уровень());
					
					НомерСтроки = НомерСтроки + 1;
				КонецЕсли;
				
				Если Подробно Тогда
					ВыборкаРегистратор = ВыборкаТовар.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
					Пока ВыборкаРегистратор.Следующий() Цикл
						Если ВыборкаРегистратор.Регистратор <> Неопределено Тогда
							ОбластьРегистратор.Параметры.Заполнить(ВыборкаРегистратор);
							ТабДок.Вывести(ОбластьРегистратор, ВыборкаРегистратор.Уровень());
						КонецЕсли;
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;

	ТабДок.ЗакончитьАвтогруппировкуСтрок();
	
	ТабДок.Вывести(ОбластьПодвал);

	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.АвтоМасштаб = Истина;
	ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
КонецПроцедуры