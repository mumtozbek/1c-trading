﻿
Процедура ПередЗаписью(Отказ)
	Условия.Сортировать("УсловноеКоличество УБЫВ, БонусноеКоличество УБЫВ");
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Если ДатаНачала > ДатаОкончания Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Неправильная дата начала.";
		Сообщение.Поле = "ДатаНачала";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Неправильная дата окончания.";
		Сообщение.Поле = "ДатаОкончания";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;
	КонецЕсли;
	
	Если Активный Тогда
		Запрос = Новый Запрос("
			|ВЫБРАТЬ
			|	Акции.Ссылка КАК Акция
			|ИЗ
			|	Справочник.Акции КАК Акции
			|ГДЕ
			|	Акции.Ссылка <> &Ссылка
			|	И Акции.Активный
			|	И (&ДатаНачала МЕЖДУ Акции.ДатаНачала И Акции.ДатаОкончания ИЛИ &ДатаОкончания МЕЖДУ Акции.ДатаНачала И Акции.ДатаОкончания)
			|	И Акции.Каналы.Канал В (&Каналы)
			|	И Акции.Триггеры.Товар В (&Товары)
			|"
		);
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
		Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
		Запрос.УстановитьПараметр("Каналы", Каналы.ВыгрузитьКолонку("Канал"));
		Запрос.УстановитьПараметр("Товары", Триггеры.ВыгрузитьКолонку("Товар"));
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Неуникальная акция: существуют схожие акции в заданном интервале.";
			Сообщение.Поле = "";
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если Каналы.Количество() = 0 Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Не заданы каналы.";
		Сообщение.Поле = "Каналы";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;;
	КонецЕсли;
	
	Если Триггеры.Количество() = 0 Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Не заданы триггеры.";
		Сообщение.Поле = "Триггеры";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;;
	КонецЕсли;
	
	Если Бонусы.Количество() = 0 Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Не заданы бонусы.";
		Сообщение.Поле = "Бонусы";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;;
	КонецЕсли;
	
	Если Условия.Количество() = 0 Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Не указаны условия.";
		Сообщение.Поле = "Условия";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;;
	КонецЕсли;
КонецПроцедуры
