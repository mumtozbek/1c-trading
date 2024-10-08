﻿
// Справочники
Процедура СправочникПриУстановкеНовогоКода(Источник, СтандартнаяОбработка, Префикс) Экспорт
	// TODO: перенести логику в нумераторы
	Префикс = Константы.ПрефиксКодаСправочников.Получить() + Префикс;
КонецПроцедуры

Процедура СправочникОбработкаЗаполнения(Источник, ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка) Экспорт
	ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
	Если ОбщийРеквизитОрганизация <> Неопределено Тогда
		Если ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
			Источник.Организация = ПараметрыСеанса.Пользователь.Организация;
		КонецЕсли;
	КонецЕсли;
	
	ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
	Если ОбщийРеквизитФилиал <> Неопределено Тогда
		Если ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
			Источник.Филиал = ПараметрыСеанса.Пользователь.Филиал;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура СправочникПередЗаписью(Источник, Отказ) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Если ПользователиИБ.ЭтоАдминистратор() = Ложь Тогда
		ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитОрганизация <> Неопределено Тогда
			Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Организация) И ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если Источник.Организация <> ПараметрыСеанса.Пользователь.Организация Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитФилиал <> Неопределено Тогда
			Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Филиал) И ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если Источник.Филиал <> ПараметрыСеанса.Пользователь.Филиал Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура СправочникПриЗаписи(Источник, Отказ) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Если Источник.ДополнительныеСвойства.Свойство("Источник") И Источник.ДополнительныеСвойства.Свойство("Идентификатор") Тогда
		ВнешниеИдентификаторы.Установить(Источник.ДополнительныеСвойства.Источник, Источник.Ссылка, Источник.ДополнительныеСвойства.Идентификатор, Истина);
	КонецЕсли;
КонецПроцедуры

Процедура СправочникПередУдалением(Источник, Отказ) Экспорт
	Если Источник.ПометкаУдаления = Ложь Тогда
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

// Документы
Процедура ДокументПриУстановкеНовогоНомера(Источник, СтандартнаяОбработка, Префикс) Экспорт
	// TODO: перенести логику в нумераторы
	Префикс = Константы.ПрефиксНомераДокументов.Получить() + Префикс;
КонецПроцедуры

Процедура ДокументОбработкаЗаполнения(Источник, ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка) Экспорт
	Источник.Дата = ТекущаяДата();
	Источник.Автор = ПараметрыСеанса.Пользователь;
	
	ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
	Если ОбщийРеквизитОрганизация <> Неопределено Тогда
		Если ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
			Источник.Организация = ПараметрыСеанса.Пользователь.Организация;
		КонецЕсли;
	КонецЕсли;
	
	ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
	Если ОбщийРеквизитФилиал <> Неопределено Тогда
		Если ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
			Источник.Филиал = ПараметрыСеанса.Пользователь.Филиал;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ДокументПриКопировании(Источник, ОбъектКопирования) Экспорт
	Источник.Дата = ТекущаяДата();
КонецПроцедуры

Процедура ДокументПередЗаписью(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Источник.ДополнительныеСвойства.Вставить("УчетнаяПолитика", УчетныеПолитики.ПолучитьНаДату(Источник.Дата, Источник.Организация));
	
	//Если Источник.ДополнительныеСвойства.Свойство("Источник") Тогда
	//	Источник.Источник = Источник.ДополнительныеСвойства.Источник;
	//КонецЕсли;
	
	Если ЗначениеЗаполнено(Источник.Автор) = Ложь Тогда
		Источник.Автор = ПараметрыСеанса.Пользователь;
	КонецЕсли;
	
	Если ПользователиИБ.ЭтоАдминистратор() = Ложь Тогда
		Если Константы.КонтрольПравДоступа.Получить() Тогда
			Если Источник.Модифицированность() Тогда
				Если Источник.Автор <> ПараметрыСеанса.Пользователь Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитОрганизация <> Неопределено Тогда
			Если ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Организация) И Источник.Организация <> ПараметрыСеанса.Пользователь.Организация Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитФилиал <> Неопределено Тогда
			Если ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Филиал) И Источник.Филиал <> ПараметрыСеанса.Пользователь.Филиал Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ДокументПриЗаписи(Источник, Отказ) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Если Источник.ДополнительныеСвойства.Свойство("Источник") И Источник.ДополнительныеСвойства.Свойство("Идентификатор") Тогда
		ВнешниеИдентификаторы.Установить(Источник.ДополнительныеСвойства.Источник, Источник.Ссылка, Источник.ДополнительныеСвойства.Идентификатор, Истина);
	КонецЕсли;
КонецПроцедуры

Процедура ДокументПередУдалением(Источник, Отказ) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Если Источник.ПометкаУдаления = Ложь Тогда
		Отказ = Истина;
	КонецЕсли;
	
	Если ПользователиИБ.ЭтоАдминистратор() = Ложь Тогда
		Если Константы.КонтрольПравДоступа.Получить() Тогда
			Если Источник.Модифицированность() Тогда
				Если Источник.Автор <> ПараметрыСеанса.Пользователь Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитОрганизация <> Неопределено Тогда
			Если ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Организация) И Источник.Организация <> ПараметрыСеанса.Пользователь.Организация Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитФилиал <> Неопределено Тогда
			Если ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Филиал) И Источник.Филиал <> ПараметрыСеанса.Пользователь.Филиал Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ДокументОбработкаПроведения(Источник, Отказ, РежимПроведения) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Если ПользователиИБ.ЭтоАдминистратор() = Ложь Тогда
		Если Константы.КонтрольПравДоступа.Получить() Тогда
			Если Источник.Модифицированность() Тогда
				Если Источник.Автор <> ПараметрыСеанса.Пользователь Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитОрганизация <> Неопределено Тогда
			Если ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Организация) И Источник.Организация <> ПараметрыСеанса.Пользователь.Организация Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитФилиал <> Неопределено Тогда
			Если ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Филиал) И Источник.Филиал <> ПараметрыСеанса.Пользователь.Филиал Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ДокументОбработкаУдаленияПроведения(Источник, Отказ) Экспорт
	Если Источник.ДополнительныеСвойства.Свойство("Игнорировать") Тогда
		Возврат;
	КонецЕсли;
	
	Если ПользователиИБ.ЭтоАдминистратор() = Ложь Тогда
		Если Константы.КонтрольПравДоступа.Получить() Тогда
			Если Источник.Модифицированность() Тогда
				Если Источник.Автор <> ПараметрыСеанса.Пользователь Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитОрганизация = Метаданные.ОбщиеРеквизиты.Организация.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитОрганизация <> Неопределено Тогда
			Если ОбщийРеквизитОрганизация.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Организация) И Источник.Организация <> ПараметрыСеанса.Пользователь.Организация Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ОбщийРеквизитФилиал = Метаданные.ОбщиеРеквизиты.Филиал.Состав.Найти(Источник.Метаданные());
		Если ОбщийРеквизитФилиал <> Неопределено Тогда
			Если ОбщийРеквизитФилиал.Использование = Метаданные.СвойстваОбъектов.ИспользованиеОбщегоРеквизита.Использовать Тогда
				Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Филиал) И Источник.Филиал <> ПараметрыСеанса.Пользователь.Филиал Тогда
					Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

// Общие
Процедура ОбработкаПолученияДанныхВыбора(Источник, ДанныеВыбора, Параметры, СтандартнаяОбработка) Экспорт
	//Если ПользователиИБ.ЭтоАдминистратор() = Ложь Тогда
	//    Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Организация) Тогда
	//		Параметры.Отбор.Вставить("Организация", ПараметрыСеанса.Пользователь.Организация);
	//	КонецЕсли;
	//	
	//	Если ЗначениеЗаполнено(ПараметрыСеанса.Пользователь.Филиал) Тогда
	//		Параметры.Отбор.Вставить("Филиал", ПараметрыСеанса.Пользователь.Филиал);
	//	КонецЕсли;
	//КонецЕсли;
КонецПроцедуры
