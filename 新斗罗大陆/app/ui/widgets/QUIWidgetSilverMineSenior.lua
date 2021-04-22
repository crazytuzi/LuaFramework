local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineSenior = class("QUIWidgetSilverMineSenior", QUIWidget)

function QUIWidgetSilverMineSenior:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Senior.ccbi"
	local callbacks = {}
	QUIWidgetSilverMineSenior.super.ctor(self, ccbFile, callbacks, options)
end

return QUIWidgetSilverMineSenior