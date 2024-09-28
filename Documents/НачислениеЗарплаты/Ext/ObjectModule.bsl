﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Неопределено") ИЛИ ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда
		Касса = Справочники.Кассы.Наличка;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	// регистр Зарплата
	Движения.Зарплата.Записывать = Истина;
	
	Для Каждого Строка Из Начисления Цикл
		Если Строка.Сумма > 0 Тогда
			// регистр Зарплата Приход
			Движение = Движения.Зарплата.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Сотрудник = Строка.Сотрудник;
			Движение.ТипВзаиморасчета = Перечисления.ТипыВзаиморасчета.Нал;
			Движение.Примечание = глНайтиПримечания(Строка.Комментарий);
			Движение.Сумма = Строка.Сумма;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
