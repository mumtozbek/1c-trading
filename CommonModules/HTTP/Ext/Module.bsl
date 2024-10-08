﻿
Функция Запрос(АдресРесурса, СтрокаЗапроса = "", МетодЗапроса = "GET", Пользователь = "", Пароль = "", Параметры = Неопределено) Экспорт
	Если ТипЗнч(Параметры) <> Тип("Структура") Тогда
		Параметры = Новый Структура;
	КонецЕсли;
	
	Если Параметры.Свойство("Заголовки") = Ложь Тогда
		Параметры.Вставить("Заголовки", Новый Массив);
	КонецЕсли;
	
	Попытка
		ПараметрыЗапроса = ПолучитьПараметрыАдреса(АдресРесурса);
		
		// Получение имена временных файлов
		ИмяФайлаОтвета = ПолучитьИмяВременногоФайла();
		
		// Создание соединения
		HTTPСоединение = Новый HTTPСоединение(ПараметрыЗапроса.Хост, ПараметрыЗапроса.Порт, Пользователь, Пароль,,, ПараметрыЗапроса.ЗащищенноеСоединение);
		
		HTTPЗапрос = Новый HTTPЗапрос(ПараметрыЗапроса.Адрес);
		HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
		
		HTTPЗапрос.Заголовки.Вставить("Accept", "*/*");
		HTTPЗапрос.Заголовки.Вставить("Accept-Encoding", "none");
		HTTPЗапрос.Заголовки.Вставить("Accept-Language", "ru");
		HTTPЗапрос.Заголовки.Вставить("Accept-Charset", "utf-8");
		
		HTTPЗапрос.Заголовки.Вставить("Connection", "keep-alive");
		HTTPЗапрос.Заголовки.Вставить("Host", ПараметрыЗапроса.Хост);
		
        Если ТипЗнч(Параметры.Заголовки) = Тип("Массив") Тогда
			Для Каждого Заголовок Из Параметры.Заголовки Цикл
				ЧастиЗаголовка = СтрРазделить(Заголовок, ":", Ложь);
				HTTPЗапрос.Заголовки.Вставить(СокрЛП(ЧастиЗаголовка[0]), СокрЛП(ЧастиЗаголовка[1]));
			КонецЦикла;
		ИначеЕсли ТипЗнч(Параметры.Заголовки) = Тип("Соответствие") Тогда
			Для Каждого Заголовок Из Параметры.Заголовки Цикл
				HTTPЗапрос.Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
			КонецЦикла;
		КонецЕсли;
		
		HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаЗапроса, КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать);
		
		Если ПустаяСтрока(СтрокаЗапроса) Тогда
			ОтветСервера = HTTPСоединение.ВызватьHTTPМетод(МетодЗапроса, HTTPЗапрос, ИмяФайлаОтвета);
		Иначе
			ОтветСервера = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос, ИмяФайлаОтвета);
		КонецЕсли;
		
		// Чтение ответа
		Параметры.Вставить("СтрокаОтвета", РаботаСФайлами.Читать(ИмяФайлаОтвета));
		Параметры.Вставить("КодОтвета", ОтветСервера.КодСостояния);
		Параметры.Вставить("ЗаголовкиОтвета", ОтветСервера.Заголовки);
		
		// Удаление временного файла ответа
		УдалитьФайлы(ИмяФайлаОтвета);
			
		Если Параметры.КодОтвета >= 200 И Параметры.КодОтвета <= 299 Тогда
			Возврат Параметры.СтрокаОтвета;
		Иначе
			ВызватьИсключение "HTTP: Ошибка при запросе (код: " + СокрЛП(Параметры.КодОтвета) + "; сообщение: " + СокрЛП(Параметры.СтрокаОтвета) + ")";
		КонецЕсли;
	Исключение
		ВызватьИсключение;
	КонецПопытки;
КонецФункции

Функция ПолучитьПараметрыАдреса(АдресРесурса) Экспорт
	Результат = Неопределено;
	
	Нахождения = СтрНайтиПоРегулярномуВыражению(АдресРесурса, "^(\w+)\:\/\/([a-z0-9.]+)\:?(\d+)?\/?(.*)?$").ПолучитьГруппы();
	Если Нахождения.Количество() > 0 Тогда
		Результат = Новый Структура;
		Результат.Вставить("ЗащищенноеСоединение", ?(Нахождения[0].Значение = "https", Новый ЗащищенноеСоединениеOpenSSL(), Неопределено));
		Результат.Вставить("Хост", Нахождения[1].Значение);
		Результат.Вставить("Порт", ?(ЗначениеЗаполнено(Нахождения[2].Значение), Число(Нахождения[2].Значение), ?(Нахождения[0].Значение = "https", 443, 80)));
		Результат.Вставить("Адрес", Нахождения[3].Значение);
	Иначе
		ВызватьИсключение "HTTP: Введен неправильный адрес";
	КонецЕсли;
	
	Возврат Результат;
КонецФункции
