﻿
&НаСервере
Процедура КомандаСформироватьНаСервере()
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	ОтчетОбъект.Сформировать(ТабДок);
КонецПроцедуры

&НаКлиенте
Процедура КомандаСформировать(Команда)
	КомандаСформироватьНаСервере();
КонецПроцедуры
