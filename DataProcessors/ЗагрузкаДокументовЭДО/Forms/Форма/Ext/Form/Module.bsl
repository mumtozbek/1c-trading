﻿
&НаКлиенте
Процедура КомандаВыполнить(Команда)
	МодульОператора = МодульЭДО.АвторизоватьОператора(Объект.Оператор);
	
	ПомеченныеСтроки = Объект.Документы.НайтиСтроки(Новый Структура("Загрузить", Истина));
	Для Каждого Строка Из ПомеченныеСтроки Цикл
		ДокументЭлемент = МодульОператора.ПолучитьТелоДокумента(Строка.Идентификатор);
		
		Строка.Документ = ЗагрузитьДокумент(Строка.Вид, ДокументЭлемент);
		
		ЭлектронныеДокументы.Установить(Объект.Оператор, Строка.Документ, Строка.Идентификатор, "", Строка.Статус);
		
		Сообщить(Строка.Документ);
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура КомандаДокументыЗаполнитьНаСервере(Данные)
	МодульОбъекта = РеквизитФормыВЗначение("Объект");
	
	Объект.Документы.Очистить();
	Для Каждого Строка Из Данные Цикл
		НоваяСтрока = Объект.Документы.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
		НоваяСтрока.Дата = МодульОбъекта.ПолучитьДату(Строка.Дата);
		НоваяСтрока.ДатаДоговора = МодульОбъекта.ПолучитьДату(Строка.ДатаДоговора);
		
		ДокументыОбновитьСтроку(НоваяСтрока.ПолучитьИдентификатор());
	КонецЦикла;
	
	Объект.Документы.Сортировать("Дата,Номер");
КонецПроцедуры

&НаКлиенте
Процедура КомандаДокументыЗаполнить(Команда)
	Если ЗначениеЗаполнено(Объект.Оператор) = Ложь Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Организация) = Ложь Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Тип) = Ложь Тогда
		Возврат;
	КонецЕсли;
	
	Настройки = Новый Структура("Организация,НачалоПериода,КонецПериода,Тип,Номер,Идентификатор");
	
	Настройки.Организация = Объект.Организация;
	Настройки.Тип = Объект.Тип;
	
	Если ЗначениеЗаполнено(Объект.Период.ДатаНачала) Тогда
		Настройки.НачалоПериода = Объект.Период.ДатаНачала;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Период.ДатаОкончания) Тогда
		Настройки.КонецПериода = Объект.Период.ДатаОкончания;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Номер) Тогда
		Настройки.Номер = Объект.Номер;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Идентификатор) Тогда
		Настройки.Идентификатор = Объект.Идентификатор;
	КонецЕсли;
	
	МодульОператора = МодульЭДО.АвторизоватьОператора(Объект.Оператор);
	
	Данные = МодульОператора.ПолучитьСписокДокументов(Настройки);
	
	КомандаДокументыЗаполнитьНаСервере(Данные);
КонецПроцедуры

&НаСервере
Процедура КомандаДокументыОбновитьНаСервере()
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаДокументыОбновить(Кнопка)
	КомандаДокументыОбновитьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ДокументыПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ДокументыПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаСервере
Процедура ДокументыОбновитьСтроку(ИдентификаторСтроки)
	Строка = Объект.Документы.НайтиПоИдентификатору(ИдентификаторСтроки);
	
	ДокументПоИдентификатору = ЭлектронныеДокументы.ПолучитьПоИдентификатору(Строка.Идентификатор);
	Если ЗначениеЗаполнено(ДокументПоИдентификатору) Тогда
		Строка.Документ = ДокументПоИдентификатору["Документ"];
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Строка.Документ) Тогда
		Строка.Вид = Строка.Документ.Метаданные().Имя;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Строка.Вид) = Ложь Тогда
		Строка.Загрузить = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДокументыВидНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	Элемент.СписокВыбора.Очистить();
	Элемент.СписокВыбора.Добавить("ПоступлениеТМЦ", "Поступление ТМЦ");
	Элемент.СписокВыбора.Добавить("РеализацияТМЦ", "Реализация ТМЦ");
КонецПроцедуры

&НаКлиенте
Процедура ДокументыВидПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Элементы.Документы.ТекущиеДанные.Вид) Тогда
		Элементы.ДокументыДокумент.ОграничениеТипа = Новый ОписаниеТипов("ДокументСсылка." + Элементы.Документы.ТекущиеДанные.Вид);
	Иначе
		Элементы.Документы.ТекущиеДанные.Документ = Неопределено;
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ДокументыДокументПриИзменении(Элемент)
	Строка = Элементы.Документы.ТекущиеДанные;
	
	СтрокиПоДокументу = Объект.Документы.НайтиСтроки(Новый Структура("Документ", Строка.Документ));
	Для Каждого ТекСтрока Из СтрокиПоДокументу Цикл
		Если ТекСтрока.ПолучитьИдентификатор() <> Строка.ПолучитьИдентификатор() Тогда
			Строка.Документ = Неопределено;
			
			Сообщить("Данный документ уже существует в списке.");
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(Строка.Документ) Тогда
		ЭлектронныеДокументы.Установить(Объект.Оператор, Строка.Документ, Строка.Идентификатор, "", Строка.Статус);
	Иначе
		ЭлектронныеДокументы.УдалитьИдентификатор(Строка.Идентификатор);
	КонецЕсли;
	
	ДокументыОбновитьСтроку(Элементы.Документы.ТекущаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ДокументыЗагрузитьПриИзменении(Элемент)
	ДокументыОбновитьСтроку(Элементы.Документы.ТекущаяСтрока);
КонецПроцедуры

&НаСервере
Функция ЗагрузитьДокумент(Вид, ДокументЭлемент)
	МодульОбъекта = РеквизитФормыВЗначение("Объект");
	
	ЭлектронныйДокумент = ЭлектронныеДокументы.ПолучитьПоИдентификатору(ДокументЭлемент.FacturaId);
	
	Если ЗначениеЗаполнено(ЭлектронныйДокумент) Тогда
		ДокументОбъект = ЭлектронныйДокумент.Документ.ПолучитьОбъект();
	Иначе
		ДокументОбъект = Документы[Вид].СоздатьДокумент();
		ДокументОбъект.Дата = МодульОбъекта.ПолучитьДату(ДокументЭлемент.FacturaDoc.FacturaDate);
	КонецЕсли;
	
	ДокументОбъект.Организация = Объект.Организация;
	
	Если Вид = "ПоступлениеТМЦ" ИЛИ Вид = "РеализацияТМЦ" Тогда
		ДокументОбъект.Склад = ПараметрыСеанса.Пользователь.Склад;
	КонецЕсли;
	
	Если Объект.Тип = "Входящие" Тогда
		ДокументОбъект.НомерВходящегоДокумента = ДокументЭлемент.FacturaDoc.FacturaNo;
		ДокументОбъект.ДатаВходящегоДокумента = МодульОбъекта.ПолучитьДату(ДокументЭлемент.FacturaDoc.FacturaDate);
		ДокументОбъект.Контрагент = МодульОбъекта.НайтиКонтрагента(ДокументЭлемент.SellerTin, "", ДокументЭлемент.Seller);
		ДокументОбъект.Договор = МодульОбъекта.НайтиДоговора(ДокументОбъект.Контрагент, ДокументЭлемент.ContractDoc.ContractNo, МодульОбъекта.ПолучитьДату(ДокументЭлемент.ContractDoc.ContractDate), Перечисления.ВидыДоговора.СПоставщиком);
		
		Если Вид = "ПоступлениеТМЦ" Тогда
			МодульОбъекта.ЗаполнитьДокументПоступлениеТМЦ(ДокументОбъект, ДокументЭлемент);
		КонецЕсли;
	Иначе
		ДокументОбъект.Номер = ДокументЭлемент.FacturaDoc.FacturaNo;
		ДокументОбъект.Дата = МодульОбъекта.ПолучитьДату(ДокументЭлемент.FacturaDoc.FacturaDate);
		ДокументОбъект.Контрагент = МодульОбъекта.НайтиКонтрагента(ДокументЭлемент.BuyerTin, "", ДокументЭлемент.Buyer);
		ДокументОбъект.Договор = МодульОбъекта.НайтиДоговора(ДокументОбъект.Контрагент, ДокументЭлемент.ContractDoc.ContractNo, МодульОбъекта.ПолучитьДату(ДокументЭлемент.ContractDoc.ContractDate), Перечисления.ВидыДоговора.СПокупателем);
		
		Если Вид = "РеализацияТМЦ" Тогда
			МодульОбъекта.ЗаполнитьДокументРеализацияТМЦ(ДокументОбъект, ДокументЭлемент);
		КонецЕсли;
	КонецЕсли;
	
	ДокументОбъект.Записать();
	
	Возврат ДокументОбъект.Ссылка;
КонецФункции
