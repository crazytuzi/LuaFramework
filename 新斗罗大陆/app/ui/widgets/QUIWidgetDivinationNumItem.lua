--[[	
	文件名称：QUIWidgetDivinationNumItem.lua
	创建时间：2016-10-28 14:49:02
	作者：nieming
	描述：QUIWidgetDivinationNumItem
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetDivinationNumItem = class("QUIWidgetDivinationNumItem", QUIWidget)

--初始化
function QUIWidgetDivinationNumItem:ctor(options)
	local ccbFile = "Widget_zhanbu_xiangqing.ccbi"
	local callBacks = {
	}
	QUIWidgetDivinationNumItem.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetDivinationNumItem:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetDivinationNumItem:onExit()
	----代码
--end

function QUIWidgetDivinationNumItem:createNum( num, isActive )
	-- body
	local str 
	if not isActive then
		str = "zhanbu_zn_"
	else
		str = "zhanbu_zl_"
	end

	local node = CCNode:create()
	if num < 10 then
		local frame  = QSpriteFrameByPath(QResPath(str)[num+1])
		if frame then
			local sprite = CCSprite:createWithSpriteFrame(frame)
			if sprite then
				node:addChild(sprite)
			end
		end
	else
		local num1 = math.floor(num/10)
		local num2 = num%10
		local frame1  = QSpriteFrameByPath(QResPath(str)[num1+1])
		local frame2  = QSpriteFrameByPath(QResPath(str)[num2+1])
		if frame1 then
			local sprite1 = CCSprite:createWithSpriteFrame(frame1)
			if sprite1 then
				sprite1:setPositionX(-16)
				node:addChild(sprite1)
			end

		end
		if frame2 then
			local sprite2 = CCSprite:createWithSpriteFrame(frame2)	
			if sprite2 then
				sprite2:setPositionX(16)
				node:addChild(sprite2)
			end
		end
	end
	return node
end
--describe：setInfo 
function QUIWidgetDivinationNumItem:setInfo(num, isActive)
	--代码
	self._ccbOwner.number:removeAllChildren()
	local node = self:createNum(num, isActive)
	self._ccbOwner.number:addChild(node)
end

--describe：getContentSize 
function QUIWidgetDivinationNumItem:getContentSize()
	--代码
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetDivinationNumItem
