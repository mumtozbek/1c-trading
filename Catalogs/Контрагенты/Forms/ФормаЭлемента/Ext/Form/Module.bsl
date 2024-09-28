﻿
&НаКлиенте
Процедура Обновить(Команда)
	ИнформацияИзГНК = Неопределено;
	
	Оператор = МодульЭДО.АвторизоватьОператора();
	
	Если Объект.ТипКонтрагента = ПредопределенноеЗначение("Перечисление.ТипыКонтрагента.ЮридическоеЛицо") Тогда
		Если ЗначениеЗаполнено(Объект.ИНН) Тогда
			ИнформацияИзГНК = МодульЭДО.ПолучитьИнформациюПоКонтрагенту(Объект.ИНН);
		Иначе
			Предупреждение("ИНН не указан для юридического лица!");
		КонецЕсли;
	ИначеЕсли Объект.ТипКонтрагента = ПредопределенноеЗначение("Перечисление.ТипыКонтрагента.ФизическоеЛицо") Тогда
		Если ЗначениеЗаполнено(Объект.ПИНФЛ) Тогда
			ИнформацияИзГНК = МодульЭДО.ПолучитьИнформациюПоКонтрагенту(Объект.ПИНФЛ);
		Иначе
			Предупреждение("ПИНФЛ не указан для физического лица!");
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ИнформацияИзГНК) Тогда
		Если ПустаяСтрока(ИнформацияИзГНК.ИНН) И ПустаяСтрока(ИнформацияИзГНК.ПИНФЛ) Тогда
			Предупреждение("Контрагент не найден!");
			
			Возврат;
		КонецЕсли;
		
		Объект.ПлательщикНДС = ИнформацияИзГНК.ПлательщикНДС;
		Если Объект.ПлательщикНДС Тогда
			Объект.КодПНДС = ИнформацияИзГНК.КодПНДС;
		Иначе
			Объект.КодПНДС = "";
		КонецЕсли;
		
		Объект.ПолноеНаименование = ИнформацияИзГНК.ПолноеНаименование;
		Объект.ИНН = ИнформацияИзГНК.ИНН;
		Объект.ПИНФЛ = ИнформацияИзГНК.ПИНФЛ;
		Объект.КодПНДС = ИнформацияИзГНК.КодПНДС;
		Объект.КодОКЭД = ИнформацияИзГНК.КодОКЭД;
		Объект.Адрес = ИнформацияИзГНК.Адрес;
		Объект.Руководитель = ИнформацияИзГНК.Руководитель;
		Объект.Бухгалтер = ИнформацияИзГНК.Бухгалтер;
		
		ОбновитьНаСервере(ИнформацияИзГНК);
		
		Модифицированность = Истина;
	Иначе
		Предупреждение("Контрагент не найден или тип контрагента указан неправильно!");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ОбновитьНаСервере(ИнформацияИзГНК)
	Если ЗначениеЗаполнено(ИнформацияИзГНК.КодРайона) Тогда
		РайонСсылка = Справочники.Районы.НайтиПоКоду(ИнформацияИзГНК.КодРайона);
		Если ЗначениеЗаполнено(РайонСсылка) Тогда
			Объект.Район = РайонСсылка;
		КонецЕсли;
	КонецЕсли;
	
	Если Объект.Ссылка.Пустая() = Ложь Тогда
		Если ЗначениеЗаполнено(ИнформацияИзГНК.НомерБанковскогоСчета) И ЗначениеЗаполнено(ИнформацияИзГНК.МФОБанковскогоСчета) Тогда
			БанковскийСчетСсылка = Справочники.БанковскиеСчета.НайтиПоРеквизиту("Номер", СокрЛП(ИнформацияИзГНК.НомерБанковскогоСчета),, Объект.Ссылка);
			Если ЗначениеЗаполнено(БанковскийСчетСсылка) Тогда
				БанковскийСчетОбъект = БанковскийСчетСсылка.ПолучитьОбъект();
			Иначе
				БанковскийСчетОбъект = Справочники.БанковскиеСчета.СоздатьЭлемент();
				БанковскийСчетОбъект.Владелец = Объект.Ссылка;
			КонецЕсли;
			
			БанковскийСчетОбъект.Наименование = "Основной";
			БанковскийСчетОбъект.Номер = СокрЛП(ИнформацияИзГНК.НомерБанковскогоСчета);
			БанковскийСчетОбъект.Банк = Справочники.Банки.НайтиПоКоду(СокрЛП(ИнформацияИзГНК.МФОБанковскогоСчета));
			БанковскийСчетОбъект.Записать();
			
			Объект.ОсновнойБанковскийСчет = БанковскийСчетОбъект.Ссылка;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры
