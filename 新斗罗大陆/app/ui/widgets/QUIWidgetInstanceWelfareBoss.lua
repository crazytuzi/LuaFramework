--
-- Author: Your Name
-- Date: 2014-09-15 17:50:31
--

local QUIWidgetInstanceHead = import(".QUIWidgetInstanceHead")
local QUIWidgetInstanceWelfareBoss = class("QUIWidgetInstanceWelfareBoss", QUIWidgetInstanceHead)

function QUIWidgetInstanceWelfareBoss:ctor(options)
	local ccbFile = "ccb/Widget_Instance_WelfareBoss.ccbi"
	QUIWidgetInstanceWelfareBoss.super.ctor(self,ccbFile,options)
end

function QUIWidgetInstanceWelfareBoss:getName()
	return "QUIWidgetInstanceWelfareBoss"
end

return QUIWidgetInstanceWelfareBoss