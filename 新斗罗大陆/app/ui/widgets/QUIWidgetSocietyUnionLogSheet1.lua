--[[	
	文件名称：QUIWidgetSocietyUnionLogSheet1.lua
	创建时间：2016-03-25 18:40:13
	作者：nieming
	描述：QUIWidgetSocietyUnionLogSheet1
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionLogSheet1 = class("QUIWidgetSocietyUnionLogSheet1", QUIWidget)

--初始化
function QUIWidgetSocietyUnionLogSheet1:ctor(options)
	local ccbFile = "Widget_society_union_log_sheet1.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyUnionLogSheet1.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetSocietyUnionLogSheet1:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSocietyUnionLogSheet1:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetSocietyUnionLogSheet1:setInfo(info, index)
	--代码
	self._info = info
	self._ccbOwner.date:setString(info.value)
end

--describe：getContentSize 
function QUIWidgetSocietyUnionLogSheet1:getContentSize()
	--代码
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSocietyUnionLogSheet1
