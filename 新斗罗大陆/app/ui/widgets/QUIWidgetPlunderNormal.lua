local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderNormal = class("QUIWidgetPlunderNormal", QUIWidget)

function QUIWidgetPlunderNormal:ctor(options)
	local ccbFile = "ccb/Widget_plunder_Normal.ccbi"
	local callbacks = {}
	QUIWidgetPlunderNormal.super.ctor(self, ccbFile, callbacks, options)
end

return QUIWidgetPlunderNormal