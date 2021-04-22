--
-- Author: wkwang
-- Date: 2014-05-08 16:07:32
--

local QUIWidgetInstanceHead = import(".QUIWidgetInstanceHead")
local QUIWidgetInstanceNormalBoss = class("QUIWidgetInstanceNormalBoss", QUIWidgetInstanceHead)

function QUIWidgetInstanceNormalBoss:ctor(options)
	local ccbFile = "ccb/Widget_Instance_NormalBoss.ccbi"
	QUIWidgetInstanceNormalBoss.super.ctor(self,ccbFile,options)
end

function QUIWidgetInstanceNormalBoss:setInfo(info, isBattle)
	QUIWidgetInstanceNormalBoss.super.setInfo(self, info, isBattle)
end

function QUIWidgetInstanceNormalBoss:getName()
	return "QUIWidgetInstanceNormalBoss"
end

return QUIWidgetInstanceNormalBoss