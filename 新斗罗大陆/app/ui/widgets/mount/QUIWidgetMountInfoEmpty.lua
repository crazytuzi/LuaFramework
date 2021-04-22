local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountInfoEmpty = class("QUIWidgetMountInfoEmpty", QUIWidget)
local QUIViewController = import("...QUIViewController")

function QUIWidgetMountInfoEmpty:ctor(options)
	local ccbFile = "ccb/Widget_Mount_Empty.ccbi"
	local callBacks = {}
	QUIWidgetMountInfoEmpty.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetMountInfoEmpty:setInfo(actorId)
	self._actorId = actorId
end

return QUIWidgetMountInfoEmpty