--[[	
	文件名称：QUIWidgetSunwarRuleSeparator.lua
	创建时间：2016-03-12 21:05:00
	作者：nieming
	描述：QUIWidgetSunwarRuleSeparator
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSunwarRuleSeparator = class("QUIWidgetSunwarRuleSeparator", QUIWidget)

--初始化
function QUIWidgetSunwarRuleSeparator:ctor(options)
	local ccbFile = "Widget_SunWar_Rule_Separator.ccbi"
	local callBacks = {
	}
	QUIWidgetSunwarRuleSeparator.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetSunwarRuleSeparator:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSunwarRuleSeparator:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetSunwarRuleSeparator:setInfo(info)
	--代码
	if info.name then
		self._ccbOwner.separatorName:setString(info.name)
	end
end

--describe：getContentSize 
function QUIWidgetSunwarRuleSeparator:getContentSize()
	return self._ccbOwner.node_bg:getContentSize()
end

return QUIWidgetSunwarRuleSeparator
