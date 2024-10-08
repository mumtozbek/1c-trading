﻿
&НаСервере
Процедура СформироватьНаСервере()
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	ОтчетОбъект.Сформировать(ТабДок);
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
	СформироватьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ТабДокОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка, ДополнительныеПараметры)
	Если ТипЗнч(Расшифровка) = Тип("Структура") Тогда
	    СтандартнаяОбработка = Ложь;
		
		ЗначенияЗаполнения = Новый Структура("Период,Статья,Подробно", Отчет.Период, Отчет.Статья, Истина);
		
		Для Каждого ПараметрРасшифровки Из Расшифровка Цикл
			ЗначенияЗаполнения.Вставить(ПараметрРасшифровки.Ключ, ПараметрРасшифровки.Значение);
		КонецЦикла;
		
		ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения);
		ОткрытьФорму(ЭтотОбъект.ИмяФормы, ПараметрыФормы,, Новый УникальныйИдентификатор);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("ЗначенияЗаполнения") Тогда
		СтандартнаяОбработка = Истина;
		
		Для Каждого ПараметрЗаполнения Из Параметры.ЗначенияЗаполнения Цикл
			Отчет[ПараметрЗаполнения.Ключ] = ПараметрЗаполнения.Значение;
		КонецЦикла;
		
		СформироватьНаСервере();
	Иначе
		Отчет.Период = ХранилищеНастроекДанныхФорм.Загрузить("Отчет." + ЭтотОбъект.ИмяФормы, "Период");
		Отчет.Статья = ХранилищеНастроекДанныхФорм.Загрузить("Отчет." + ЭтотОбъект.ИмяФормы, "Статья");
		Отчет.Подробно = ХранилищеНастроекДанныхФорм.Загрузить("Отчет." + ЭтотОбъект.ИмяФормы, "Подробно");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПередЗакрытиемНаСервере()
	ХранилищеНастроекДанныхФорм.Сохранить("Отчет." + ЭтотОбъект.ИмяФормы, "Период", Отчет.Период);
	ХранилищеНастроекДанныхФорм.Сохранить("Отчет." + ЭтотОбъект.ИмяФормы, "Статья", Отчет.Статья);
	ХранилищеНастроекДанныхФорм.Сохранить("Отчет." + ЭтотОбъект.ИмяФормы, "Подробно", Отчет.Подробно);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если ЗавершениеРаботы = Ложь Тогда
		ПередЗакрытиемНаСервере();
	КонецЕсли;
КонецПроцедуры
