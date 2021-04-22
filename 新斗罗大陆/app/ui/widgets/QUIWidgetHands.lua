--
-- Author: xurui
-- Date: 2015-09-26 11:43:02
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHands = class("QUIWidgetHands", QUIWidget)

function QUIWidgetHands:ctor(options)
	local ccbFile = "ccb/Widget_Hands.ccbi"
	local callBacks = {}
	QUIWidgetHands.super.ctor(self, ccbFile, callBacks, options)
end

return QUIWidgetHands