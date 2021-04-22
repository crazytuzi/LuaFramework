local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineNormal = class("QUIWidgetSilverMineNormal", QUIWidget)

function QUIWidgetSilverMineNormal:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Normal.ccbi"
	local callbacks = {}
	QUIWidgetSilverMineNormal.super.ctor(self, ccbFile, callbacks, options)
end

return QUIWidgetSilverMineNormal