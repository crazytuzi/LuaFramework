--
-- Author: Kumo.Wang
-- 宗門活躍詳細Cell
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionActivityInfoCell = class("QUIWidgetSocietyUnionActivityInfoCell", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("..QUIViewController")

function QUIWidgetSocietyUnionActivityInfoCell:ctor(options)
	local ccbFile = "Widget_Society_Activity_Info_Sheet.ccbi"
	local callBacks = {}
	QUIWidgetSocietyUnionActivityInfoCell.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSocietyUnionActivityInfoCell:setInfo(info, index)
	self._ccbOwner.tf_name:setString(info.name or "")
	self._ccbOwner.tf_value:setString(info.activeDegree or 0)
end

function QUIWidgetSocietyUnionActivityInfoCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSocietyUnionActivityInfoCell
