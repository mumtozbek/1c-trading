﻿
Процедура ПередЗаписью(Отказ)
	Если (НЕ ЭтоГруппа) Тогда
		Если ПустаяСтрока(ПолноеНаименование) Тогда
			ПолноеНаименование = Наименование;
		КонецЕсли;
		
		ПолноеНаименование = ВРег(ПолноеНаименование);
	КонецЕсли;
КонецПроцедуры
