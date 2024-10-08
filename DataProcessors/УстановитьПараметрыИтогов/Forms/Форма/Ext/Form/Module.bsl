﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.Регистр.СписокВыбора.Добавить("", "Все регистры");
	
	Для Каждого ОбъектМетаданных Из Метаданные.РегистрыНакопления Цикл
		Элементы.Регистр.СписокВыбора.Добавить(ОбъектМетаданных.Имя, ОбъектМетаданных.Синоним);
	КонецЦикла;
	
	Для Каждого ОбъектМетаданных Из Метаданные.РегистрыБухгалтерии Цикл
		Элементы.Регистр.СписокВыбора.Добавить(ОбъектМетаданных.Имя, ОбъектМетаданных.Синоним);
	КонецЦикла;
	
	РегистрПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура РегистрПриИзмененииНаСервере()
	Если ЗначениеЗаполнено(Объект.Регистр) Тогда
		Если Метаданные.РегистрыНакопления.Найти(Объект.Регистр) <> Неопределено Тогда
			Объект.ИспользованиеИтогов = РегистрыНакопления[Объект.Регистр].ПолучитьИспользованиеИтогов();
			Объект.РежимРазделенияИтогов = РегистрыНакопления[Объект.Регистр].ПолучитьРежимРазделенияИтогов();
			
			Если Метаданные.РегистрыНакопления[Объект.Регистр].ВидРегистра = Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Остатки Тогда
				Объект.ИспользованиеТекущихИтогов = РегистрыНакопления[Объект.Регистр].ПолучитьИспользованиеТекущихИтогов();
				Объект.Период.ДатаНачала = РегистрыНакопления[Объект.Регистр].ПолучитьМинимальныйПериодРассчитанныхИтогов();
				Объект.Период.ДатаОкончания = РегистрыНакопления[Объект.Регистр].ПолучитьМаксимальныйПериодРассчитанныхИтогов();
			КонецЕсли;
		ИначеЕсли Метаданные.РегистрыБухгалтерии.Найти(Объект.Регистр) <> Неопределено Тогда
			Объект.ИспользованиеИтогов = РегистрыБухгалтерии[Объект.Регистр].ПолучитьИспользованиеИтогов();
			Объект.ИспользованиеТекущихИтогов = РегистрыБухгалтерии[Объект.Регистр].ПолучитьИспользованиеТекущихИтогов();
			Объект.РежимРазделенияИтогов = РегистрыБухгалтерии[Объект.Регистр].ПолучитьРежимРазделенияИтогов();
			Объект.Период.ДатаНачала = РегистрыБухгалтерии[Объект.Регистр].ПолучитьМинимальныйПериодРассчитанныхИтогов();
			Объект.Период.ДатаОкончания = РегистрыБухгалтерии[Объект.Регистр].ПолучитьМаксимальныйПериодРассчитанныхИтогов();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура РегистрПриИзменении(Элемент)
	РегистрПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметры(Регистр)
	Если ЗначениеЗаполнено(Регистр) Тогда
		Если Метаданные.РегистрыНакопления.Найти(Регистр) <> Неопределено Тогда
			РегистрыНакопления[Регистр].УстановитьИспользованиеИтогов(Объект.ИспользованиеИтогов);
			РегистрыНакопления[Регистр].УстановитьРежимРазделенияИтогов(Объект.РежимРазделенияИтогов);
			Если Метаданные.РегистрыНакопления[Регистр].ВидРегистра = Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Остатки Тогда
				РегистрыНакопления[Регистр].УстановитьИспользованиеТекущихИтогов(Объект.ИспользованиеТекущихИтогов);
			    РегистрыНакопления[Регистр].УстановитьМинимальныйИМаксимальныйПериодыРассчитанныхИтогов(НачалоДня(Объект.Период.ДатаНачала), КонецДня(Объект.Период.ДатаОкончания));
			КонецЕсли;
		ИначеЕсли Метаданные.РегистрыБухгалтерии.Найти(Регистр) <> Неопределено Тогда
			РегистрыБухгалтерии[Регистр].УстановитьИспользованиеИтогов(Объект.ИспользованиеИтогов);
			РегистрыБухгалтерии[Регистр].УстановитьИспользованиеТекущихИтогов(Объект.ИспользованиеТекущихИтогов);
			РегистрыБухгалтерии[Регистр].УстановитьРежимРазделенияИтогов(Объект.РежимРазделенияИтогов);
			РегистрыБухгалтерии[Регистр].УстановитьМинимальныйИМаксимальныйПериодыРассчитанныхИтогов(НачалоДня(Объект.Период.ДатаНачала), КонецДня(Объект.Период.ДатаОкончания));
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура КомандаУстановитьНаСервере()
	Если ЗначениеЗаполнено(Объект.Регистр) Тогда
		УстановитьПараметры(Объект.Регистр);
	Иначе
		Для Каждого ОбъектМетаданных Из Метаданные.РегистрыНакопления Цикл
			УстановитьПараметры(ОбъектМетаданных.Имя);
		КонецЦикла;
		
		Для Каждого ОбъектМетаданных Из Метаданные.РегистрыБухгалтерии Цикл
			УстановитьПараметры(ОбъектМетаданных.Имя);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КомандаУстановить(Команда)
	КомандаУстановитьНаСервере();
КонецПроцедуры

