﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Дата = ТекущаяДата();
	
	Если ДанныеЗаполнения = Неопределено ИЛИ ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда
		ВидРеализации = Справочники.ВидыРеализации.Перечисление;
		Склад = ПараметрыСеанса.Пользователь.Склад;
		АвтоОкругление = Константы.Реализация_АвтоматическоеОкруглениеИтоговойСуммыПеремещений.Получить();
		Наценка = Константы.Реализация_НаценкаПоУмолчанию.Получить();
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Подготовка регистров накопления
	Движения.Продажи.Записывать = Истина;
	Движения.Остатки.Записывать = Истина;
	Движения.СальдоПоМагазинам.Записывать = Истина;
	Движения.Доходы.Записывать = Истина;
	
	// Подготовка регистров сведения
	Движения.ЦеныТоваров.Записывать = Истина;
	Движения.ИсторияРеквизитов.Записывать = Истина;
	
	Для Каждого Строка Из Товары Цикл
		Если Строка.Количество = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Строка.Товар) = Ложь Тогда
			Продолжить;
		КонецЕсли;
		
		// Контроль текущих остатков товара
		Если Склад.КонтрольОстатков И ПривилегированныйРежим() = Ложь Тогда
			Если (Строка.ОстатокДо - Строка.Количество) < 0 Тогда
				Сообщить("Недостаточно товаров на складе: " + Строка.НомерСтроки + ". " + Строка.Товар.Наименование + " (" + Строка.Товар.Код + ")", СтатусСообщения.ОченьВажное);
				
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
		
		// Расход товара с остатков
		Если Склад.НеВестиУчет = Ложь Тогда
			Движение = Движения.Остатки.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Склад = Склад;
			Движение.Товар = Строка.Товар;
			Движение.Порожняя = (Строка.Товар.ВидТовара.ТипТовара <> Перечисления.ТипыТовара.Товар);
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Количество = Строка.Количество;
			Движение.Сумма = Строка.Количество * Строка.ЦенаБазовая;
			
			// Расход тары с остатков
			Если Склад.Временный = Ложь И ЗначениеЗаполнено(Строка.Товар.Тара) Тогда
				Движение = Движения.Остатки.Добавить();
				Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
				Движение.Период = Дата;
				Движение.Склад = Склад;
				Движение.Товар = Строка.Товар.Тара;
				Движение.Порожняя = Ложь;
				Движение.Примечание = глНайтиПримечания(Комментарий);
				Движение.Количество = Строка.Количество;
				Движение.Сумма = 0;
			КонецЕсли;
		КонецЕсли;
		
		// Приход товаров и тары, если получатель не розница
		Если СкладПолучатель.ТипСклада = Перечисления.ТипыСклада.ОптовыйСклад Тогда
			Движение = Движения.Остатки.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Склад = СкладПолучатель;
			Движение.Товар = Строка.Товар;
			Движение.Порожняя = (Строка.Товар.ВидТовара.ТипТовара <> Перечисления.ТипыТовара.Товар);
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Количество = Строка.Количество;
			Движение.Сумма = Строка.Количество * Строка.ЦенаБазовая;
			
			// Приход тары на склад получатель
			Если СкладПолучатель.Временный = Ложь И ЗначениеЗаполнено(Строка.Товар.Тара) Тогда
				Движение = Движения.Остатки.Добавить();
				Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
				Движение.Период = Дата;
				Движение.Склад = СкладПолучатель;
				Движение.Товар = Строка.Товар.Тара;
				Движение.Порожняя = Ложь;
				Движение.Примечание = глНайтиПримечания(Комментарий);
				Движение.Количество = Строка.Количество;
				Движение.Сумма = 0;
			КонецЕсли;
		КонецЕсли;
		
		// Учет продажи
		Если СкладПолучатель.ТипСклада = Перечисления.ТипыСклада.РозницаНТТ Тогда
			Движение = Движения.Продажи.Добавить();
			Движение.Период = Дата;
			Движение.Склад = Склад;
			Движение.ВидРеализации = ВидРеализации;
			Движение.Агент = Неопределено;
			Движение.Товар = Строка.Товар;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Количество = Строка.Количество;
			Движение.Объем = Строка.Объем;
			Движение.СуммаБазовая = Строка.СуммаБазовая;
			Движение.СуммаСНаценкой = Строка.СуммаСНаценкой;
			Движение.СуммаПродажная = Строка.СуммаПродажная;
			Движение.СуммаОтпускная = Строка.СуммаОтпускная;
		КонецЕсли;
		
		Если Склад.НеВестиУчет И СкладПолучатель.НеВестиУчет = Ложь Тогда
			// Запись цены товара (базовая)
			Если Строка.ЦенаБазовая > 0 Тогда
				Движение = Движения.ЦеныТоваров.Добавить();
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Тип = "ЦенаБазовая";
				Движение.Цена = Строка.ЦенаБазовая;
			КонецЕсли;
			
			// Запись цены товара (отпускная)
			Если Строка.ЦенаОтпускная > 0 Тогда
				Движение = Движения.ЦеныТоваров.Добавить();
				Движение.Период = Дата;
				Движение.Товар = Строка.Товар;
				Движение.Тип = "ЦенаПродажная";
				Движение.Цена = Строка.ЦенаОтпускная;
			КонецЕсли;
			
			Движение = Движения.ИсторияРеквизитов.Добавить();
			Движение.Период = Дата;
			Движение.Ссылка = Строка.Товар;
			Движение.Реквизит = "СтавкаНДС";
			Движение.Значение = Строка.СтавкаНДС;
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(Сумма) И Склад.Временный И СкладПолучатель.ТипСклада = Перечисления.ТипыСклада.РозницаНТТ Тогда
		// Сальдо
		Движение = Движения.СальдоПоМагазинам.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Магазин = СкладПолучатель;
		Движение.Примечание = глНайтиПримечания(Комментарий);
		Движение.Сумма = Сумма;
		
		// Доход - сумма товаров
		Если Товары.Итог("СуммаПродажная") <> 0 Тогда
			Движение = Движения.Доходы.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Статья = Справочники.СтатьиДоходовИРасходов.РозничнаяТорговля;
			Движение.Реализация = Истина;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Сумма = Товары.Итог("СуммаПродажная");
		КонецЕсли;
		
		// Доход - Округление
		Если Округление <> 0 Тогда
			Движение = Движения.Доходы.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Статья = Справочники.СтатьиДоходовИРасходов.Округление;
			Движение.Реализация = Истина;
			Движение.Примечание = глНайтиПримечания(Комментарий);
			Движение.Сумма = Округление;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Если Константы.Реализация_ПересчетОстатковПриПроведенииДокумента.Получить() Тогда
			РаботаСТоварами.Заполнить(ЭтотОбъект, "Товары", Истина);
		КонецЕсли;
	КонецЕсли;
	
	// Пересчет
	Для Каждого Строка Из Товары Цикл
		Если Строка.Количество = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Строка.Объем = Строка.Количество * Строка.Товар.Объем;
		Строка.Вес = Строка.Количество * Строка.Товар.Вес;
	КонецЦикла;
	
	Сумма = Товары.Итог("СуммаОтпускная") + Округление;
КонецПроцедуры
