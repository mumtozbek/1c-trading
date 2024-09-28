﻿
Функция ПолучитьПравила(Организация, ВидРеализации) Экспорт
	Список = Новый Массив;
	
	Выборка = Справочники.ВидыЛицензии.Выбрать();
	Пока Выборка.Следующий() Цикл
		Для Каждого Правило Из Выборка.Правила Цикл
			Если Правило.Активность И Правило.Организация = Организация И Правило.ВидРеализации = ВидРеализации Тогда
				Список.Добавить(Выборка.Ссылка);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Список;
КонецФункции