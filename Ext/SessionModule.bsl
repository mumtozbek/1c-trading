﻿
Процедура ЗаписатьПользователей()
	УстановитьПривилегированныйРежим(Истина);
	
	Пользователи = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого Пользователь Из Пользователи Цикл
		Если Пользователь.Роли.Содержит(Метаданные.Роли.Сервер) Тогда
			Продолжить;
		КонецЕсли;
		
		ЭлементСсылка = Справочники.Пользователи.ПолучитьСсылку(Пользователь.УникальныйИдентификатор);
		Если (ЗначениеЗаполнено(ЭлементСсылка.Код)) ИЛИ (ЗначениеЗаполнено(ЭлементСсылка.Наименование)) Тогда
			ЭлементОбъект = ЭлементСсылка.ПолучитьОбъект();
		Иначе
			ЭлементОбъект = Справочники.Пользователи.СоздатьЭлемент();
			ЭлементОбъект.УстановитьСсылкуНового(ЭлементСсылка);
			ЭлементОбъект.Активность = Истина;
		КонецЕсли;
		
		ЭлементОбъект.Наименование = Пользователь.ПолноеИмя;
		ЭлементОбъект.Видимость = Пользователь.ПоказыватьВСпискеВыбора;
		
		Если ЭлементОбъект.Модифицированность() Тогда
			ЭлементОбъект.ДополнительныеСвойства.Вставить("Игнорировать");
			ЭлементОбъект.Записать();
		КонецЕсли;
	КонецЦикла;
	
	ВыборкаСправочника = Справочники.Пользователи.Выбрать();
	Пока ВыборкаСправочника.Следующий() Цикл
		ПользовательСистемы = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ВыборкаСправочника.Ссылка.УникальныйИдентификатор());
		
		Если ПользовательСистемы = Неопределено Тогда
			ОбъектСправочника = ВыборкаСправочника.ПолучитьОбъект();
			ОбъектСправочника.ПометкаУдаления = Истина;
			ОбъектСправочника.ДополнительныеСвойства.Вставить("Игнорировать");
			ОбъектСправочника.Записать();
		Иначе
			Если ПользовательСистемы.Роли.Содержит(Метаданные.Роли.Сервер) Тогда
				ЭлементСсылка = Справочники.Пользователи.ПолучитьСсылку(ПользовательСистемы.УникальныйИдентификатор);
				ЭлементОбъект = ЭлементСсылка.ПолучитьОбъект();
				ЭлементОбъект.ДополнительныеСвойства.Вставить("Игнорировать");
				ЭлементОбъект.Удалить();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	ТребуемыеПараметры = Новый Массив;
	ТребуемыеПараметры.Добавить("Пользователь");
	
    #Если НЕ ВнешнееСоединение Тогда
	// Заполнить список пользователей
	ЗаписатьПользователей();
	#КонецЕсли
	
	// Пользователь системы
	ПользовательСистемы = ПользователиИнформационнойБазы.ТекущийПользователь();
	
	// Настроить пользователя
	ПараметрыСеанса.Пользователь = Справочники.Пользователи.ПолучитьСсылку(ПользовательСистемы.УникальныйИдентификатор);
КонецПроцедуры
