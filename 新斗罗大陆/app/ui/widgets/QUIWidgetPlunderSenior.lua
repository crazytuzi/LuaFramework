local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderSenior = class("QUIWidgetPlunderSenior", QUIWidget)

function QUIWidgetPlunderSenior:ctor(options)
	local ccbFile = "ccb/Widget_plunder_senior.ccbi"
	local callbacks = {}
	QUIWidgetPlunderSenior.super.ctor(self, ccbFile, callbacks, options)
end

return QUIWidgetPlunderSenior