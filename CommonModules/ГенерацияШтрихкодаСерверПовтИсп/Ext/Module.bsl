﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Функция выполняет подключение внешней компоненты и ее первоначальную настройку.
// Выполняет подключение внешней компоненты.
// Функция возвращает Неопределено, если компоненту не удалось загрузить.
//
// Параметры:
//   ТипПлатформыКомпоненты - Строка - тип платформы
//
// Возвращаемое значение:
//   ОбъектВнешнейКомпоненты:
//    * ECL - Число
//    * GS1DatabarКоличествоСтрок - Число
//    * АвтоТип - Булево
//    * Версия - Строка
//    * ВертикальноеВыравниваниеКода - Число
//    * ВертСмещение - Число
//    * ВидимостьКС - Булево
//    * ВыравниваниеКода - Число
//    * Высота - Число
//    * ГорСмещение - Число
//    * ГрафикаУстановлена - Булево
//    * ЗначениеКода - Строка
//    * ИмяФайла - Строка
//    * КоличествоСтолбцов - Число
//    * КоличествоСтрок - Число
//    * КоличествоШрифтов - Число
//    * КонтрольныйСимвол - Строка
//    * ЛоготипКартинка - Картинка 
//    * ЛоготипРазмерПроцентОтШК - Число
//    * МаксимальныйРазмерШрифтаДляПринтеровНизкогоРазрешения - Число
//    * МинимальнаяВысотаКода - Число
//    * МинимальнаяШиринаКода - Число
//    * ОриентацияТекста - Число
//    * ОтображатьТекст - Булево
//    * ПоложениеТекста - Число
//    * ПрозрачныйФон - Булево
//    * Пропорции - Строка
//    * РазделителиКода - Число
//    * РазмерКрая - Число
//    * РазмерШрифта - Число
//    * Результат - Число
//    * СодержитКС - Булево
//    * ТекстКода - Строка
//    * ТипВходныхДанных - Число
//    * ТипКода - Число
//    * УбратьЛишнийФон - Булево
//    * УголПоворота - Число
//    * УровеньКоррекцииQR - Число
//    * ЦветПолос - Число
//    * ЦветТекста - Число
//    * ЦветФона - Число
//    * Ширина - Число
//    * Шрифт - Строка
//   Неопределено
//
Функция ПодключитьКомпонентуГенерацииИзображенияШтрихкода(ТипПлатформыКомпоненты) Экспорт
	
	Возврат ГенерацияШтрихкода.ПолучитьКомпонентуШтрихКодирования();
	
КонецФункции

#КонецОбласти