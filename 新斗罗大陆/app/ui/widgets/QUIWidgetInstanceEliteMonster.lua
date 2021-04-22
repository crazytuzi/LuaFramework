--
-- Author: Your Name
-- Date: 2014-09-15 17:52:09
--

local QUIWidgetInstanceHead = import(".QUIWidgetInstanceHead")
local QUIWidgetInstanceEliteMonster = class("QUIWidgetInstanceEliteMonster", QUIWidgetInstanceHead)

function QUIWidgetInstanceEliteMonster:ctor(options)
	local ccbFile = "ccb/Widget_Instance_EliteMonster.ccbi"
	QUIWidgetInstanceEliteMonster.super.ctor(self,ccbFile,options)
end

function QUIWidgetInstanceEliteMonster:getName()
	return "QUIWidgetInstanceEliteMonster"
end

return QUIWidgetInstanceEliteMonster