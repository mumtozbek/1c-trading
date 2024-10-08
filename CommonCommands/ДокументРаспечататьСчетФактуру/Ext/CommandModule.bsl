﻿
&НаКлиенте
Процедура ОбработкаКоманды(Данные, ПараметрыВыполненияКоманды)
	ТабДок = Новый ТабличныйДокумент;
	
	КоличествоКопий = ОбщийМодульСервер.ПолучитьЗначениеКонстанты("Реализация_КоличествоЭкземпляровВсего");
	
	Напечатать = ВвестиЧисло(КоличествоКопий, "Сколько копий напечатать?", 1, 0);
	
	ОбработкаКомандыНаСервере(Данные, ТабДок);
	
	ТабДок.КоличествоЭкземпляров = КоличествоКопий;
	
	Если Напечатать Тогда
		ТабДок.Напечатать(РежимИспользованияДиалогаПечати.НеИспользовать);
	Иначе
		ТабДок.Показать();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ОбработкаКомандыНаСервере(Знач Данные, ТабДок)
	Для Каждого Документ Из Данные Цикл
		Если Документ.ВидРеализации.ТипВзаиморасчета = Перечисления.ТипыВзаиморасчета.Нал Тогда
			ФактурыСервер.СформироватьСчетФактуруДляАгента(Документ, ТабДок);
		Иначе
			ФактурыСервер.СформироватьСчетФактуру(Документ, ТабДок);
		КонецЕсли;
		
		ТабДок.ОтображатьСетку = Ложь;
		ТабДок.Защита = Ложь;
		ТабДок.ТолькоПросмотр = Ложь;
		ТабДок.ОтображатьЗаголовки = Ложь;
		ТабДок.АвтоМасштаб = Истина;
		ТабДок.ПолеСверху = 2;
		ТабДок.ПолеСправа = 2;
		ТабДок.ПолеСнизу = 2;
		ТабДок.ПолеСлева = 2;
	КонецЦикла;
КонецПроцедуры

