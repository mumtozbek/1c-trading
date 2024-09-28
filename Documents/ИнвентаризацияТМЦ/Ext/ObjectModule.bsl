﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Неопределено") ИЛИ ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда
		Склад = ПараметрыСеанса.Пользователь.Склад;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	// регистр Остатки Расход
	Движения.Остатки.Записывать = Истина;
	
	Для Каждого Строка Из Товары Цикл
		Если Строка.Записать = Ложь Тогда
			Продолжить;
		КонецЕсли;
		
		Если Строка.Разница > 0 Тогда
			Движение = Движения.Остатки.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Склад = Склад;
			Движение.Товар = Строка.Товар;
			Движение.Порожняя = Ложь;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Количество = Строка.Разница;
			Движение.Сумма = Строка.Разница * Строка.ЦенаБазовая;
		ИначеЕсли Строка.Разница < 0 Тогда
			Движение = Движения.Остатки.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Склад = Склад;
			Движение.Товар = Строка.Товар;
			Движение.Порожняя = Ложь;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Количество = -Строка.Разница;
			Движение.Сумма = -Строка.Разница * Строка.ЦенаБазовая;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
