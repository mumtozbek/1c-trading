﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	// Подготовка регистров накопления
	Движения.Остатки.Записывать = Истина;
	Движения.Сальдо.Записывать = Истина;
	Движения.СальдоПоТаре.Записывать = Истина;
	Движения.Касса.Записывать = Истина;
	Движения.Доходы.Записывать = Истина;
	Движения.Зарплата.Записывать = Истина;
	
	// Подготовка регистров сведения
	Движения.ЦеныТоваров.Записывать = Истина;
	Движения.ИсторияРеквизитов.Записывать = Истина;
	
	// Массив для обхода конфликтов цен
	ОбновленныеЦены = Новый Массив;
	
	Для Каждого Строка Из Товары Цикл
		// Приход товара
		Движение = Движения.Остатки.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Склад = Строка.Склад;
		Движение.Товар = Строка.Товар;
		Движение.Количество = Строка.КоличествоОстаток;
		Движение.Сумма = Строка.СуммаОстаток;
		Движение.Порожняя = Ложь;
		
		Если ОбновленныеЦены.Найти(Строка.Товар) = Неопределено Тогда
			// Цены товары - ЦенаБазовая
			Если Строка.ЦенаБазовая > 0 Тогда
				Движение = Движения.ЦеныТоваров.Добавить();
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Тип = "ЦенаБазовая";
				Движение.Цена = Строка.ЦенаБазовая;
			КонецЕсли;
			
			// Цены товары - Цена (приходная)
			Если Строка.ЦенаПриходная > 0 Тогда
				Движение = Движения.ЦеныТоваров.Добавить();
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Тип = "ЦенаПриходная";
				Движение.Цена = Строка.ЦенаПриходная;
			КонецЕсли;
			
			// Цены товары - Цена (отпускная)
			Если Строка.ЦенаПродажная > 0 Тогда
				Движение = Движения.ЦеныТоваров.Добавить();
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Тип = "ЦенаПродажная";
				Движение.Цена = Строка.ЦенаПродажная;
			КонецЕсли;
			
			// Исторические реквизиты - Ставка НДС
			Движение = Движения.ИсторияРеквизитов.Добавить();
			Движение.Период = Дата;
			Движение.Ссылка = Строка.Товар;
			Движение.Реквизит = "СтавкаНДС";
			Движение.Значение = Строка.СтавкаНДС;
			
			ОбновленныеЦены.Добавить(Строка.Товар)
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Строка Из Тары Цикл
		// Приход пустой тары
		Движение = Движения.Остатки.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Склад = Строка.Склад;
		Движение.Товар = Строка.Товар;
		Движение.Количество = Строка.Количество;
		Движение.Сумма = Строка.СуммаБазовая;
		Движение.Порожняя = Строка.Порожняя;
	КонецЦикла;

	Для Каждого Строка Из Взаиморасчеты Цикл
		// Сальдо
		Если Строка.Сальдо > 0 Тогда
			Движение = Движения.Сальдо.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Организация = Организация;
			Движение.Контрагент = Строка.Контрагент;
			Движение.ТипВзаиморасчета = Строка.ТипВзаиморасчета;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Сумма = Строка.Сальдо;
		ИначеЕсли Строка.Сальдо < 0 Тогда
			Движение = Движения.Сальдо.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Организация = Организация;
			Движение.Контрагент = Строка.Контрагент;
			Движение.ТипВзаиморасчета = Строка.ТипВзаиморасчета;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Сумма = -Строка.Сальдо;
		КонецЕсли;
	КонецЦикла;
	
	// СальдоПоТаре
	Для Каждого Строка Из ВзаиморасчетыПоТаре Цикл
		Движение = Движения.СальдоПоТаре.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Организация = Организация;
		Движение.Товар = Строка.Товар;
		Движение.Контрагент = Строка.Контрагент;
		Движение.Примечание = глНайтиПримечания(Комментарий);
		Движение.Количество = Строка.Количество;
		Движение.Сумма = Строка.Сумма;
	КонецЦикла;

	// Касса
	Для Каждого Строка Из Кассы Цикл
		Движение = Движения.Касса.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Касса = Строка.Касса;
		Движение.Статья = Справочники.СтатьиДвиженияДенежныхСредств.ВводОстатков;
		Движение.Примечание = глНайтиПримечания(Комментарий);
		Движение.Сумма = Строка.Остаток;
	КонецЦикла;
	
	// Доходы
	Для Каждого Строка Из Доходы Цикл
		Движение = Движения.Доходы.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Статья = Строка.Статья;
		Движение.Реализация = Ложь;
		Движение.Примечание = глНайтиПримечания(Комментарий);
		Движение.Сумма = Строка.Сумма;
	КонецЦикла;

	// Авансы
	Для Каждого Строка Из Авансы Цикл
		Движение = Движения.Зарплата.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Сотрудник = Строка.Сотрудник;
		Движение.Примечание = глНайтиПримечания(Комментарий);
		Движение.Сумма = Строка.Сумма;
	КонецЦикла;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Для Каждого Строка Из Товары Цикл
		Если ЗначениеЗаполнено(Строка.ЦенаПриходная) И ЗначениеЗаполнено(Строка.ЦенаБазовая) = Ложь Тогда
			Строка.ЦенаБазовая = АрифметическиеФункции.ВычитатьНаценку(Строка.ЦенаПриходная, Строка.СтавкаНДС);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Строка.ЦенаПриходная) = Ложь И ЗначениеЗаполнено(Строка.ЦенаБазовая) Тогда
			Строка.ЦенаПриходная = АрифметическиеФункции.ДобавитьНаценку(Строка.ЦенаБазовая, Строка.СтавкаНДС);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
