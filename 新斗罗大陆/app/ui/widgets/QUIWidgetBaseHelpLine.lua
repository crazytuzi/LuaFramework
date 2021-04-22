--[[	
	文件名称：QUIWidgetBaseHelpLine.lua
	创建时间：2016-09-28 11:28:09
	作者：nieming
	描述：QUIWidgetBaseHelpLine
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetBaseHelpLine = class("QUIWidgetBaseHelpLine", QUIWidget)

--初始化
function QUIWidgetBaseHelpLine:ctor(options)
	local ccbFile = "Widget_Base_Help_Line.ccbi"
	local callBacks = {
	}
	QUIWidgetBaseHelpLine.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetBaseHelpLine:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetBaseHelpLine:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetBaseHelpLine:setInfo(info)
	--代码
end

--describe：getContentSize 
function QUIWidgetBaseHelpLine:getContentSize()
	--代码
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetBaseHelpLine
