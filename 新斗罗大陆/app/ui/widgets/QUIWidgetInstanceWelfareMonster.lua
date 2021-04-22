--
-- Author: Your Name
-- Date: 2014-09-15 17:52:09
--

local QUIWidgetInstanceHead = import(".QUIWidgetInstanceHead")
local QUIWidgetInstanceWelfareMonster = class("QUIWidgetInstanceWelfareMonster", QUIWidgetInstanceHead)

function QUIWidgetInstanceWelfareMonster:ctor(options)
	local ccbFile = "ccb/Widget_Instance_WelfareMonster.ccbi"
	QUIWidgetInstanceWelfareMonster.super.ctor(self,ccbFile,options)
end

function QUIWidgetInstanceWelfareMonster:getName()
	return "QUIWidgetInstanceWelfareMonster"
end

return QUIWidgetInstanceWelfareMonster