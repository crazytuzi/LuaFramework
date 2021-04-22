--
-- Author: Your Name
-- Date: 2014-09-15 17:51:24
--
local QUIWidgetInstanceHead = import(".QUIWidgetInstanceHead")
local QUIWidgetInstanceNormalMonster = class("QUIWidgetInstanceNormalMonster", QUIWidgetInstanceHead)

function QUIWidgetInstanceNormalMonster:ctor(options)
	local ccbFile = "ccb/Widget_Instance_NormalMonster.ccbi"
	QUIWidgetInstanceNormalMonster.super.ctor(self,ccbFile,options)
end

function QUIWidgetInstanceNormalMonster:getName()
	return "QUIWidgetInstanceNormalMonster"
end

return QUIWidgetInstanceNormalMonster