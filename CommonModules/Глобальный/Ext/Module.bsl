﻿
#Если Сервер Тогда

Функция глПолучитьСсылкуПеречисления(ЛокальноеИмяПеречисления, ЗначениеПеречисления, База = Неопределено) Экспорт
	Если ЗначениеПеречисления = Неопределено ИЛИ ЗначениеПеречисления.Пустая() Тогда
		Возврат Перечисления[ЛокальноеИмяПеречисления].ПустаяСсылка();
	Иначе
		ИмяПеречисления = ЗначениеПеречисления.Метаданные().Имя;
		Если База = Неопределено Тогда
			ИндексЗначенияПеречисления = Перечисления[ИмяПеречисления].Индекс(ЗначениеПеречисления);
			ИмяЗначенияПеречисления =  Метаданные.Перечисления[ИмяПеречисления].ЗначенияПеречисления[ИндексЗначенияПеречисления].Имя;
		Иначе
			ИндексЗначенияПеречисления = База.Перечисления[ИмяПеречисления].Индекс(ЗначениеПеречисления);
			ИмяЗначенияПеречисления = База.Метаданные().Перечисления[ИмяПеречисления].EnumValues.Get(ИндексЗначенияПеречисления).Name;
		КонецЕсли;
		Попытка
			Возврат Перечисления[ЛокальноеИмяПеречисления][ИмяЗначенияПеречисления];
		Исключение
			Возврат Неопределено;
		КонецПопытки;
	КонецЕсли;
КонецФункции

Функция глПолучитьИмениПеречисления(ЗначениеПеречисления) Экспорт
	ЛокальноеИмяПеречисления = ЗначениеПеречисления.Метаданные().Имя;
	
	Если ЗначениеПеречисления = Неопределено ИЛИ ЗначениеПеречисления.Пустая() Тогда
		Возврат Перечисления[ЛокальноеИмяПеречисления].ПустаяСсылка();
	Иначе
		ИмяПеречисления = ЗначениеПеречисления.Метаданные().Имя;
		ИндексЗначенияПеречисления = Перечисления[ИмяПеречисления].Индекс(ЗначениеПеречисления);
		ИмяЗначенияПеречисления =  Метаданные.Перечисления[ИмяПеречисления].ЗначенияПеречисления[ИндексЗначенияПеречисления].Имя;
		Возврат ИмяЗначенияПеречисления;
	КонецЕсли;
КонецФункции

Функция глПолучитьСсылкуПеречисленияV7(ЛокальноеИмяПеречисления, ЗначениеПеречисления, База = Неопределено) Экспорт
	Если ЗначениеПеречисления.Выбран() = 0 Тогда
		Возврат Перечисления[ЛокальноеИмяПеречисления].ПустаяСсылка();
	Иначе
		ИмяПеречисления = ЗначениеПеречисления.Идентификатор();
		Если База = Неопределено Тогда
			ИндексЗначенияПеречисления = Перечисления[ИмяПеречисления].Индекс(ЗначениеПеречисления);
			ИмяЗначенияПеречисления =  Метаданные.Перечисления[ИмяПеречисления].ЗначенияПеречисления[ИндексЗначенияПеречисления].Имя;
		Иначе
			ИмяЗначенияПеречисления = ИмяПеречисления;
		КонецЕсли;
		Возврат Перечисления[ЛокальноеИмяПеречисления][ИмяЗначенияПеречисления];
	КонецЕсли;
КонецФункции

Функция глПолучитьДатуСозданияСсылки(Ссылка) Экспорт
	 ГУИД = Ссылка.УникальныйИдентификатор();
	 Строка16 = Сред(ГУИД, 16, 3) + Сред(ГУИД, 10, 4) + Сред(ГУИД, 1, 8);
	 Разрядность = СтрДлина(Строка16);
	 ЧислоСек = 0;
	 Для Позиция = 1 По Разрядность Цикл
	 	ЧислоСек = ЧислоСек + Найти("123456789abcdef", Сред(Строка16, Позиция, 1)) * Pow(16, Разрядность - Позиция);
	 КонецЦикла;
	 ЧислоСек = ЧислоСек / 10000000;
	 Возврат Дата(1582, 10, 15, 04, 00, 00) + ЧислоСек;
 КонецФункции

Функция глПолучитьДокументПоКлючу(Вид, Ключ) Экспорт
	ЛокальнаяСсылка = Документы[Вид].ПолучитьСсылку(Ключ);
	
	Если ЗначениеЗаполнено(ЛокальнаяСсылка.Номер) И ЗначениеЗаполнено(ЛокальнаяСсылка.Дата) Тогда
		Возврат ЛокальнаяСсылка;
	КонецЕсли;
 КонецФункции
 
Функция глПолучитьЭлементПоКлючу(Вид, Имя, Ключ) Экспорт
	ИдентификаторЭлемента = Новый УникальныйИдентификатор(Ключ);
	Если Вид = "Справочники" Тогда
		ЛокальнаяСсылка = Справочники[Имя].ПолучитьСсылку(ИдентификаторЭлемента);
	Иначе
		ЛокальнаяСсылка = Документы[Имя].ПолучитьСсылку(ИдентификаторЭлемента);
	КонецЕсли;
	Возврат ЛокальнаяСсылка;
КонецФункции

Функция глПолучитьКаталогИБ() Экспорт
    ТекущаяСтрока = СокрЛП(ВРег(СтрокаСоединенияИнформационнойБазы()));
    Возврат СокрЛП(Сред(ТекущаяСтрока, 7, СтрНайти(ТекущаяСтрока,""";") - 7));
КонецФункции

Функция глНайтиПримечания(Комментарий) Экспорт
	Если ПустаяСтрока(Комментарий) Тогда
		Возврат Справочники.Примечания.ПустаяСсылка();
	КонецЕсли;
	
	Элемент = Справочники.Примечания.НайтиПоНаименованию(СокрЛП(Комментарий), Истина);
	
	Если Элемент.Пустая() Тогда
		ЭлементОбъект = Справочники.Примечания.СоздатьЭлемент();
		ЭлементОбъект.Наименование = СокрЛП(Комментарий);
		ЭлементОбъект.Записать();
		
		Элемент = ЭлементОбъект.Ссылка;
	КонецЕсли;
	
	Возврат Элемент;
КонецФункции

Функция глСсылкаСуществует(Ссылка) Экспорт
	Если ЗначениеЗаполнено(Ссылка) = Ложь Тогда
		Возврат Ложь;
	КонецЕсли;
	
    ТекстЗапроса = "
    |ВЫБРАТЬ
    |    Ссылка
    |ИЗ
    |    [ИмяТаблицы]
    |ГДЕ
    |    Ссылка = &Ссылка
    |";
    
    ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "[ИмяТаблицы]", Метаданные.НайтиПоТипу(ТипЗнч(Ссылка)).ПолноеИмя());
    
    Запрос = Новый Запрос;
    Запрос.Текст = ТекстЗапроса;
    Запрос.УстановитьПараметр("Ссылка", Ссылка);
    
    Возврат НЕ Запрос.Выполнить().Пустой();
КонецФункции

Функция глКомандаСистемы(СтрокаКоманды, ЖдатьОтвета = Ложь) Экспорт
   Shell = Новый COMОбъект("Wscript.Shell");
   Если ЖдатьОтвета Тогда
       Возврат Shell.run(СтрокаКоманды, 1, -1);
   Иначе
       Возврат Shell.run(СтрокаКоманды, 1, 0);
   КонецЕсли;
КонецФункции

#Иначе

Функция глПолучитьКаталогИБ() Экспорт
    ТекущаяСтрока = СокрЛП(ВРег(СтрокаСоединенияИнформационнойБазы()));
    Возврат СокрЛП(Сред(ТекущаяСтрока, 7, СтрНайти(ТекущаяСтрока,""";") - 7));
КонецФункции

#КонецЕсли

Функция глСтрокаВЧисло(ЗНАЧ СтрокаСЧислом) Экспорт
    МассивСтрок = СтрРазделить(СтрокаСЧислом, "0123456789", Ложь);
	
	Для Каждого ТекСтрока из МассивСтрок Цикл 
        СтрокаСЧислом = СтрЗаменить(СтрокаСЧислом, ТекСтрока, "");
	КонецЦикла;
	
	Попытка
		Возврат Число(СтрокаСЧислом);
	Исключение
		Возврат СтрокаСЧислом;
	КонецПопытки;
КонецФункции

Функция глПолучитьЧисло(ЗНАЧ Значение) Экспорт
	Возврат ?(ЗначениеЗаполнено(Значение), Значение, 0);
КонецФункции

Функция глВыполнитьПауза(Секунд) Экспорт	
	//имя файла, куда сохраним скрипт
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("vbs");

	Попытка
		Скрипт = Новый ТекстовыйДокумент;
		Скрипт.УстановитьТекст("WScript.sleep " + XMLСтрока(Цел(Секунд * 1000)));
		Скрипт.Вывод = ИспользованиеВывода.Разрешить;
		Скрипт.Записать(ИмяВременногоФайла, КодировкаТекста.Системная);

		WshShell=Новый COMОбъект("WScript.Shell");
		WshShell.Run("wscript.exe """ + ИмяВременногоФайла + """", 0, -1);

		//удаляем временный файл
		УдалитьФайлы(ИмяВременногоФайла);
    Исключение
		
	КонецПопытки;
	
	Возврат Секунд;
КонецФункции

Функция глПолучитьДату(ЗНАЧ Строка) Экспорт
	Если ПустаяСтрока(Строка) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Строка = СтрЗаменить(Строка, ".", "");
	Строка = СтрЗаменить(Строка, " ", "");
	Строка = СтрЗаменить(Строка, ":", "");

	Попытка
		Возврат Дата(Строка);
	Исключение
		ВызватьИсключение;
	КонецПопытки;
КонецФункции

&НаСервере
Функция глПолучитьКорректныйНомерДокумента(ЗНАЧ ОригинальныйНомер, Длина, Префикс = Неопределено) Экспорт
	Номер = СокрЛП(ОригинальныйНомер);
	
	Если СтрНайти(Номер, "/") > 0 Тогда
		ОригинальныйРазделитель = "/";
		ЧастиНомера = СтрРазделить(Номер, ОригинальныйРазделитель, Ложь);
		ОригинальныйПрефикс = ЧастиНомера[0];
	ИначеЕсли СтрНайти(Номер, "-") > 0 Тогда
		ОригинальныйРазделитель = "-";
		ЧастиНомера = СтрРазделить(Номер, ОригинальныйРазделитель, Ложь);
		ОригинальныйПрефикс = ЧастиНомера[0];
	Иначе
		ОригинальныйРазделитель = "";
		ЧастиНомера = Новый Массив;
		ЧастиНомера.Добавить("");
		ЧастиНомера.Добавить(Номер);
		ОригинальныйПрефикс = ЧастиНомера[0];
	КонецЕсли;
	
	Если ТипЗнч(Префикс) = Тип("Неопределено") Тогда
		Префикс = ЧастиНомера[0];
	КонецЕсли;
	
	Если СтрНайти(Префикс, "/") > 0 Тогда
		Разделитель = "/";
	ИначеЕсли СтрНайти(Префикс, "-") > 0 Тогда
		Разделитель = "-";
	Иначе
		Разделитель = ОригинальныйРазделитель;
	КонецЕсли;
	
	Если СтрЧислоВхождений(Префикс, Разделитель) > 0 ИЛИ Префикс = "" Тогда
		Разделитель = "";
	КонецЕсли;
	
	Номер = СокрЛП(ЧастиНомера[ЧастиНомера.Количество() - 1]);
	Номер = СтрЗаменитьПоРегулярномуВыражению(Номер, "[^\d]", "", Истина);
	Номер = Прав(Номер, (Длина - СтрДлина(ОригинальныйПрефикс + ОригинальныйРазделитель)));
	
	Попытка
		Номер = Формат(Число(Номер), "ЧЦ=" + (Длина - СтрДлина(Префикс + Разделитель)) + "; ЧВН=; ЧГ=0");
	Исключение
		Номер = Формат(Номер, "ЧЦ=" + (Длина - СтрДлина(Префикс + Разделитель)) + "; ЧВН=; ЧГ=0");
	КонецПопытки;
	
	Возврат Префикс + Разделитель + Номер;
КонецФункции

&НаСервере
Функция глПолучитьКорректныйКодСправочника(ЗНАЧ ОригинальныйКод, Длина, Префикс = Неопределено) Экспорт
	Код = СокрЛП(ОригинальныйКод);
	
	Если СтрНайти(Код, "/") > 0 Тогда
		ОригинальныйРазделитель = "/";
		ЧастиКода = СтрРазделить(Код, ОригинальныйРазделитель, Ложь);
		ОригинальныйПрефикс = ЧастиКода[0];
	ИначеЕсли СтрНайти(Код, "-") > 0 Тогда
		ОригинальныйРазделитель = "-";
		ЧастиКода = СтрРазделить(Код, ОригинальныйРазделитель, Ложь);
		ОригинальныйПрефикс = ЧастиКода[0];
	Иначе
		ОригинальныйРазделитель = "";
		ЧастиКода = Новый Массив;
		ЧастиКода.Добавить("");
		ЧастиКода.Добавить(Код);
		ОригинальныйПрефикс = ЧастиКода[0];
	КонецЕсли;
	
	Если ТипЗнч(Префикс) = Тип("Неопределено") Тогда
		Префикс = ЧастиКода[0];
	КонецЕсли;
	
	Если СтрНайти(Префикс, "/") > 0 Тогда
		Разделитель = "/";
	ИначеЕсли СтрНайти(Префикс, "-") > 0 Тогда
		Разделитель = "-";
	Иначе
		Разделитель = ОригинальныйРазделитель;
	КонецЕсли;
	
	Если СтрЧислоВхождений(Префикс, Разделитель) > 0 ИЛИ Префикс = "" Тогда
		Разделитель = "";
	КонецЕсли;
	
	Код = СокрЛП(ЧастиКода[ЧастиКода.Количество() - 1]);
	Код = СтрЗаменитьПоРегулярномуВыражению(Код, "[^\d]", "", Истина);
	Код = Прав(Код, (Длина - СтрДлина(ОригинальныйПрефикс + ОригинальныйРазделитель)));
	
	Попытка
		Код = Формат(Число(Код), "ЧЦ=" + (Длина - СтрДлина(Префикс + Разделитель)) + "; ЧВН=; ЧГ=0");
	Исключение
		Код = Формат(Код, "ЧЦ=" + (Длина - СтрДлина(Префикс + Разделитель)) + "; ЧВН=; ЧГ=0");
	КонецПопытки;
	
	Возврат Префикс + Разделитель + Код;
КонецФункции
