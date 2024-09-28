﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("ВидРеализации", Объект.ВидРеализации));
	УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("Склад", Объект.Склад));
	
	Обновить();
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	Если ЗначениеЗаполнено(ПолучитьНакладную()) Тогда
		ЭтаФорма.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	Обновить();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	НастроитьФорму();
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	Обновить();
КонецПроцедуры


&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	НастроитьФорму();
КонецПроцедуры

&НаКлиенте
Процедура ВидРеализацииПриИзменении(Элемент)
	УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("ВидРеализации", Объект.ВидРеализации));
	
	НастроитьФорму();
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	НастроитьФорму(Истина);
КонецПроцедуры

&НаКлиенте
Процедура СкладПриИзменении(Элемент)
	УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("Склад", Объект.Склад));
КонецПроцедуры

&НаСервере
Процедура СкидкаПриИзмененииНаСервере()
	Для Каждого Строка Из Объект.Товары Цикл
		Строка.Скидка = Объект.Скидка;
		
		ТоварыПересчитатьСтроку(Строка.ПолучитьИдентификатор(), "ТоварыСкидка");
	КонецЦикла;
	
	Обновить();
КонецПроцедуры

&НаКлиенте
Процедура СкидкаПриИзменении(Элемент)
	Если Объект.Товары.Количество() > 0 И Вопрос("Хотите установить новую скидку для всех товаров?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
		ЭтаФорма.ТекущийЭлемент = ЭтаФорма.Элементы.ТоварыСкидка;
		
		СкидкаПриИзмененииНаСервере();
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОкруглениеПриИзменении(Элемент)
	Обновить();
КонецПроцедуры

&НаКлиенте
Процедура ОкруглениеНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ОкругленитьИтоговуюСумму();
	
	Обновить();
КонецПроцедуры


&НаКлиенте
Процедура КомандаПодтвердить(Команда)
	Записать(Новый Структура("РежимЗаписи", РежимЗаписиДокумента.Проведение));
	
	// Создаём структуру для передачи в виде параметра при открытии формы.
	ПараметрыФормы = Новый Структура("Основание", Объект.Ссылка);
	
	// Получить связанную накладную
	// TODO: убрать
	//Если ЗначениеЗаполнено(Объект.Накладная) Тогда
	//	Накладная = Объект.Накладная;
	//Иначе
		Накладная = ПолучитьНакладную();
	//КонецЕсли;
	
	// Открываем форму документа с передачей данных для заполнения
	Если ЗначениеЗаполнено(Накладная) Тогда
		ОткрытьФормуМодально("Документ.РеализацияТМЦ.ФормаОбъекта", Новый Структура("Ключ", Накладная));
	Иначе
		ОткрытьФормуМодально("Документ.РеализацияТМЦ.ФормаОбъекта", ПараметрыФормы);
	КонецЕсли;
	
	Закрыть();
КонецПроцедуры

&НаСервере
Процедура КомандаТоварыЗаполнитьНаСервере()
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ЗаполнитьТовары(Объект.Товары, Ложь);
	
	Для Каждого Строка Из Объект.Товары Цикл
		ТоварыПересчитатьСтроку(Строка.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура КомандаТоварыЗаполнить(Команда)
	КомандаТоварыЗаполнитьНаСервере();
	
	ЭтаФорма.Модифицированность = Истина;
	
	Обновить();
КонецПроцедуры

&НаСервере
Процедура КомандаТоварыОбновитьНаСервере()
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ЗаполнитьТовары(Объект.Товары, Истина);
	
	Для Каждого Строка Из Объект.Товары Цикл
		ТоварыПересчитатьСтроку(Строка.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура КомандаТоварыОбновить(Команда)
	КомандаТоварыОбновитьНаСервере();
	
	ЭтаФорма.Модифицированность = Истина;
	
	Обновить();
КонецПроцедуры

&НаКлиенте
Процедура КомандаТоварыУдалитьПС(Команда)
	ПустыеСтроки = Объект.Товары.НайтиСтроки(Новый Структура("Количество", 0)); 
	Для Каждого Строка Из ПустыеСтроки Цикл 
		Объект.Товары.Удалить(Строка); 
	КонецЦикла;
КонецПроцедуры


&НаКлиенте
Процедура ТоварыТоварПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыБонусКоличествоПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПродажнаяПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПродажнаяПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСкидкаПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаОтпускнаяПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаОтпускнаяПриИзменении(Элемент)
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
	
	ПараметрыФормы = Новый Структура("РежимВыбора,Дата,Склад,Организация,Контрагент", Истина, Момент, Объект.Склад, Объект.Организация, Объект.Контрагент);
	
	ОбработкаВыбора = Новый ОписаниеОповещения("ПриЗакрытииФормыВыбора", ЭтаФорма,"ПодборРеализации");
	
	ОткрытьФорму("Справочник.Товары.Форма.ФормаПодбора", ПараметрыФормы, ЭтаФорма, Новый УникальныйИдентификатор,,, ОбработкаВыбора);;
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	ТоварыПересчитатьНагрузки(Элементы.Товары.ТекущаяСтрока, Элементы.Товары.ТекущийЭлемент.Имя);
	
	// TODO
	//ОкругленитьИтоговуюСумму();
	
	Обновить();
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПослеУдаления(Элемент)
	ТоварыПересчитатьБонусы(Неопределено);
	
	ТоварыПересчитатьНагрузки();
	
	Обновить();
КонецПроцедуры

&НаСервере
Процедура ТоварыПересчитатьСтроку(ИдентификаторСтроки, Колонка = Неопределено)
	Если ИдентификаторСтроки <> Неопределено Тогда
		Строка = Объект.Товары.НайтиПоИдентификатору(ИдентификаторСтроки);
		Строка.Количество = Макс(Строка.Количество, Строка.БонусКоличество);
		
		Если Колонка = "ТоварыТовар" Тогда
			Момент = ОбщийМодульСервер.ПолучитьМоментВремениДокумента(Объект);
			Строка.Остаток = РаботаСТоварами.Остаток(Объект.Склад, Строка.Товар, Момент);
			
			Строка.ЦенаПродажная = РаботаСТоварами.Цена(Строка.Товар, "ЦенаПродажная", Момент);
			
			Строка.Скидка = РаботаСТоварами.Скидка(Строка.Товар, Момент, Строка.Скидка);
			
			Строка.ЦенаОтпускная = Окр(Строка.ЦенаПродажная * (100 - Строка.Скидка) / 100, 2);
			
			Строка = РаботаСТоварами.ПересчитатьЗаказа(Строка, "ТоварыКоличество");
		Иначе
			Строка = РаботаСТоварами.ПересчитатьЗаказа(Строка, Колонка);
		КонецЕсли;
	КонецЕсли;
	
	ТоварыПересчитатьБонусы(ИдентификаторСтроки);
КонецПроцедуры

&НаСервере
Процедура ТоварыПересчитатьБонусы(ИдентификаторСтроки)
	Бонусы.Пересчитать(Объект, ИдентификаторСтроки);
	
	Если ИдентификаторСтроки <> Неопределено Тогда
		Строка = Объект.Товары.НайтиПоИдентификатору(ИдентификаторСтроки);
		
		Если Строка.БонусКоличество > Строка.Количество Тогда
			Строка.Количество = Строка.БонусКоличество;
			
			Строка = РаботаСТоварами.ПересчитатьЗаказа(Строка, "ТоварыКоличество");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ТоварыПересчитатьНагрузки(ИдентификаторСтроки = Неопределено, Колонка = Неопределено)
	Нагрузки.Обновить(Объект, ИдентификаторСтроки, Колонка);
	
	Для Каждого Строка Из Объект.Товары Цикл
		ТоварыПересчитатьСтроку(Строка.ПолучитьИдентификатор(), "ТоварыКоличество");
	КонецЦикла;
КонецПроцедуры

//
&НаКлиенте
Процедура ПриЗакрытииФормыВыбора(Значение, ДопПараметры) Экспорт
	Если Значение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.Товары.ТекущиеДанные.Товар = Значение;
	
	Элементы.Товары.ТекущийЭлемент = Элементы.ТоварыКоличество;
	
	ТоварыПересчитатьСтроку(Элементы.Товары.ТекущаяСтрока, "ТоварыТовар");
КонецПроцедуры

&НаСервере
Процедура НастроитьФорму(Обновить = Ложь)
	Если Обновить Тогда
		Объект.Агент = Объект.Контрагент.Агент;
	КонецЕсли;
	
	ЭтаФорма.Сальдо = РаботаСКонтрагентами.Сальдо(Объект.Контрагент, Объект.ВидРеализации.ТипВзаиморасчета, Объект.Дата);
КонецПроцедуры

&НаКлиенте
Процедура ОкругленитьИтоговуюСумму()
	РезультатВопроса = Вопрос("Округлить в большую сторону?", РежимДиалогаВопрос.ДаНетОтмена, 0, КодВозвратаДиалога.Да, "Округление");
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		РассчитанноеОкругление = АрифметическиеФункции.Округлить(Объект.Товары.Итог("СуммаОтпускная") - Объект.Товары.Итог("БонусСумма"), Ложь);
	ИначеЕсли РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		РассчитанноеОкругление = АрифметическиеФункции.Округлить(Объект.Товары.Итог("СуммаОтпускная") - Объект.Товары.Итог("БонусСумма"), Истина);
	КонецЕсли;
	
	Если Объект.Округление <> РассчитанноеОкругление Тогда
		Объект.Округление = РассчитанноеОкругление;
		
		ЭтаФорма.Модифицированность = Истина;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура Обновить()
	ЭтаФорма.Сумма = Объект.Товары.Итог("СуммаОтпускная") - Объект.Товары.Итог("БонусСумма") + Объект.Округление;
КонецПроцедуры

&НаСервере
Функция ПолучитьНакладную()
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Возврат Документы.РеализацияТМЦ.НайтиПоРеквизиту("Заказ", Объект.Ссылка);
	КонецЕсли;
КонецФункции
