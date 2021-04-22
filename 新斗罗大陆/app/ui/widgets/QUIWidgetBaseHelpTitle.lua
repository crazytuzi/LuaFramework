--[[	
	文件名称：QUIWidgetBaseHelpTitle.lua
	创建时间：2016-08-27 17:16:34
	作者：nieming
	描述：QUIWidgetBaseHelpTitle
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetBaseHelpTitle = class("QUIWidgetBaseHelpTitle", QUIWidget)

--初始化
function QUIWidgetBaseHelpTitle:ctor(options)
	local ccbFile = "Widget_Base_Help_Title.ccbi"
	local callBacks = {
	}
	QUIWidgetBaseHelpTitle.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetBaseHelpTitle:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetBaseHelpTitle:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetBaseHelpTitle:setInfo(info)
	--代码
	if info then
		self._ccbOwner.title:setString(info.name or "")
		self._ccbOwner.titleName2:setString(info.name2 or "")
		if info.pos then
			self._ccbOwner.title:setPosition(info.pos)
		end
		if info.size then
			self._ccbOwner.cellSize:setContentSize(info.size)
		end
	end
end


function QUIWidgetBaseHelpTitle:adjustPosition( pos, size )
	-- body
	self._ccbOwner.title:setPosition(pos)
	self._ccbOwner.cellSize:setContentSize(size)

end
--describe：getContentSize 
function QUIWidgetBaseHelpTitle:getContentSize()
	--代码
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetBaseHelpTitle
