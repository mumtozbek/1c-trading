﻿
//&НаСервере
//Процедура Обновить(Объект) Экспорт
//	УстановленныеТовары = Новый Массив;
//	
//	Запрос = Новый Запрос("
//		|ВЫБРАТЬ
//		|	СкидкиТовары.Товар КАК Товар,
//		|	СкидкиТовары.Скидка КАК Скидка,
//		|	СкидкиТовары.МаксимальнаяСкидка КАК МаксимальнаяСкидка,
//		|	СкидкиТовары.МинимальнаяСкидка КАК МинимальнаяСкидка
//		|ИЗ
//		|	Справочник.Скидки.Товары КАК СкидкиТовары
//		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Скидки.Каналы КАК СкидкиКаналы ПО (СкидкиКаналы.Ссылка = СкидкиТовары.Ссылка)
//		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Скидки.Клиенты КАК СкидкиКлиенты ПО (СкидкиКлиенты.Ссылка = СкидкиТовары.Ссылка)
//		|ГДЕ
//		|	СкидкиТовары.Ссылка.Активный
//		|	И СкидкиТовары.Ссылка.ДатаНачала <= &Дата
//		|	И СкидкиТовары.Ссылка.ДатаОкончания >= &Дата
//		|	И (СкидкиКаналы.Канал = &Канал ИЛИ СкидкиКаналы.Канал = ЗНАЧЕНИЕ(Справочник.Каналы.ПустаяСсылка))
//		|	И (СкидкиКлиенты.Клиент = &Клиент ИЛИ СкидкиКлиенты.Клиент = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка))
//		|УПОРЯДОЧИТЬ ПО
//		|	СкидкиТовары.Скидка УБЫВ
//		|"
//	);
//	
//	Запрос.УстановитьПараметр("Дата", Объект.Дата);
//	Запрос.УстановитьПараметр("Канал", Объект.Контрагент.Канал);
//	Запрос.УстановитьПараметр("Клиент", Объект.Контрагент.Ссылка);
//	
//	Выборка = Запрос.Выполнить().Выбрать();
//	Пока Выборка.Следующий() Цикл
//		Если Выборка.Товар.ЭтоГруппа Тогда
//			Запрос = Новый Запрос("ВЫБРАТЬ
//				|	Товары.Ссылка КАК Товар
//				|ИЗ
//				|	Справочник.Товары КАК Товары
//				|ГДЕ
//				|	Товары.Ссылка В ИЕРАРХИИ (&Ссылка)
//				|	И Товары.Ссылка В(&Товары)");
//			
//			Запрос.УстановитьПараметр("Ссылка", Выборка.Товар);
//			Запрос.УстановитьПараметр("Товары", Объект.Товары.Выгрузить().ВыгрузитьКолонку("Товар"));
//			
//			РезультатЗапроса = Запрос.Выполнить();
//			
//			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
//			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
//				НайденныеСтроки = Объект.Товары.НайтиСтроки(Новый Структура("Товар", ВыборкаДетальныеЗаписи.Товар));
//				Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
//					УстановитьСкидку(Выборка, НайденнаяСтрока);
//					
//					УстановленныеТовары.Добавить(НайденнаяСтрока.Товар);
//				КонецЦикла;
//			КонецЦикла;
//		Иначе
//			НайденныеСтроки = Объект.Товары.НайтиСтроки(Новый Структура("Товар", Выборка.Товар));
//			Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
//				УстановитьСкидку(Выборка, НайденнаяСтрока);
//				
//				УстановленныеТовары.Добавить(НайденнаяСтрока.Товар);
//			КонецЦикла;
//		КонецЕсли;
//	КонецЦикла;
//	
//	Для Каждого Строка Из Объект.Товары Цикл
//		Если УстановленныеТовары.Найти(Строка.Товар) = Неопределено Тогда
//			Строка.Скидка = 0;
//		КонецЕсли;
//	КонецЦикла;
//КонецПроцедуры

//&НаСервере
//Процедура Пересчитать(Объект, ИдентификаторТекущейСтроки) Экспорт
//	УстановленныеТовары = Новый Массив;
//	
//	Строка = Объект.Товары.НайтиПоИдентификатору(ИдентификаторТекущейСтроки);
//	
//	Запрос = Новый Запрос("
//		|ВЫБРАТЬ
//		|	СкидкиТовары.Товар КАК Товар,
//		|	СкидкиТовары.Скидка КАК Скидка,
//		|	СкидкиТовары.МаксимальнаяСкидка КАК МаксимальнаяСкидка,
//		|	СкидкиТовары.МинимальнаяСкидка КАК МинимальнаяСкидка
//		|ИЗ
//		|	Справочник.Скидки.Товары КАК СкидкиТовары
//		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Скидки.Каналы КАК СкидкиКаналы ПО (СкидкиКаналы.Ссылка = СкидкиТовары.Ссылка)
//		|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Скидки.Клиенты КАК СкидкиКлиенты ПО (СкидкиКлиенты.Ссылка = СкидкиТовары.Ссылка)
//		|ГДЕ
//		|	СкидкиТовары.Ссылка.Активный
//		|	И СкидкиТовары.Ссылка.ДатаНачала <= &Дата
//		|	И СкидкиТовары.Ссылка.ДатаОкончания >= &Дата
//		|	И (СкидкиКаналы.Канал = &Канал ИЛИ СкидкиКаналы.Канал = ЗНАЧЕНИЕ(Справочник.Каналы.ПустаяСсылка))
//		|	И (СкидкиКлиенты.Клиент = &Клиент ИЛИ СкидкиКлиенты.Клиент = ЗНАЧЕНИЕ(Справочник.Контрагенты.ПустаяСсылка))
//		|УПОРЯДОЧИТЬ ПО
//		|	СкидкиТовары.Скидка УБЫВ
//		|"
//	);
//	
//	Запрос.УстановитьПараметр("Дата", Объект.Дата);
//	Запрос.УстановитьПараметр("Канал", Объект.Контрагент.Канал);
//	Запрос.УстановитьПараметр("Клиент", Объект.Контрагент.Ссылка);
//	
//	Выборка = Запрос.Выполнить().Выбрать();
//	Пока Выборка.Следующий() Цикл
//		Если Выборка.Товар.ЭтоГруппа Тогда
//			Запрос = Новый Запрос("ВЫБРАТЬ
//				|	Товары.Ссылка КАК Товар
//				|ИЗ
//				|	Справочник.Товары КАК Товары
//				|ГДЕ
//				|	Товары.Ссылка В ИЕРАРХИИ (&Ссылка)
//				|	И Товары.Ссылка В(&Товары)");
//			
//			Запрос.УстановитьПараметр("Ссылка", Выборка.Товар);
//			Запрос.УстановитьПараметр("Товары", Строка.Товар);
//			
//			РезультатЗапроса = Запрос.Выполнить();
//			
//			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
//			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
//				УстановитьСкидку(Выборка, Строка);
//				
//				УстановленныеТовары.Добавить(Строка.Товар);
//			КонецЦикла;
//		ИначеЕсли Выборка.Товар = Строка.Товар Тогда
//			УстановитьСкидку(Выборка, Строка);
//			
//			УстановленныеТовары.Добавить(Строка.Товар);
//		КонецЕсли;
//	КонецЦикла;
//	
//	Если УстановленныеТовары.Количество() = 0 Тогда
//		Строка.Скидка = 0;
//	КонецЕсли;
//КонецПроцедуры

//&НаСервере
//Процедура УстановитьСкидку(Знач Выборка, Знач НайденнаяСтрока)
//	Если НайденнаяСтрока.Скидка = 0 И Выборка.МинимальнаяСкидка > НайденнаяСтрока.Скидка Тогда
//		НайденнаяСтрока.Скидка = Выборка.Скидка;
//	ИначеЕсли НайденнаяСтрока.Скидка > Выборка.МаксимальнаяСкидка Тогда
//		НайденнаяСтрока.Скидка = Выборка.МаксимальнаяСкидка;
//	ИначеЕсли НайденнаяСтрока.Скидка < Выборка.МинимальнаяСкидка Тогда
//		НайденнаяСтрока.Скидка = Выборка.МинимальнаяСкидка;
//	КонецЕсли;
//КонецПроцедуры
