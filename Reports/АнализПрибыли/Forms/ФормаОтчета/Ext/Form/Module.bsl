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
		
		ЗначенияЗаполнения = Новый Структура("Дата,Ставка", Отчет.Дата, Отчет.Ставка, Истина);
		
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
		Отчет.Дата = ХранилищеНастроекДанныхФорм.Загрузить("Отчет." + ЭтотОбъект.ИмяФормы, "Дата");
		Отчет.Ставка = ХранилищеНастроекДанныхФорм.Загрузить("Отчет." + ЭтотОбъект.ИмяФормы, "Ставка");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПередЗакрытиемНаСервере()
	ХранилищеНастроекДанныхФорм.Сохранить("Отчет." + ЭтотОбъект.ИмяФормы, "Дата", Отчет.Дата);
	ХранилищеНастроекДанныхФорм.Сохранить("Отчет." + ЭтотОбъект.ИмяФормы, "Ставка", Отчет.Ставка);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если ЗавершениеРаботы = Ложь Тогда
		ПередЗакрытиемНаСервере();
	КонецЕсли;
КонецПроцедуры
