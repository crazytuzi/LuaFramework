--
-- Author: Your Name
-- Date: 2014-09-15 17:50:31
--

local QUIWidgetInstanceHead = import(".QUIWidgetInstanceHead")
local QUIWidgetInstanceEliteBoss = class("QUIWidgetInstanceEliteBoss", QUIWidgetInstanceHead)

function QUIWidgetInstanceEliteBoss:ctor(options)
	local ccbFile = "ccb/Widget_Instance_EliteBoss.ccbi"
	QUIWidgetInstanceEliteBoss.super.ctor(self,ccbFile,options)
end

function QUIWidgetInstanceEliteBoss:getName()
	return "QUIWidgetInstanceEliteBoss"
end

return QUIWidgetInstanceEliteBoss