﻿
Процедура Запустить(Параметры = Неопределено) Экспорт
	
КонецПроцедуры

Функция ЗаданиеВыполняется(Ключ) Экспорт
    АктивныеФоновыеЗадания = ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("Ключ,Состояние", Ключ, СостояниеФоновогоЗадания.Активно));
	
	Если АктивныеФоновыеЗадания.Количество() = 1 Тогда
		Задание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(АктивныеФоновыеЗадания[0].УникальныйИдентификатор);
		
		Если Задание <> Неопределено Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ложь;
КонецФункции