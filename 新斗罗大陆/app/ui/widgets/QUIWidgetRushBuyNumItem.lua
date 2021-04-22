--[[	
	文件名称：QUIWidgetRushBuyNumItem.lua
	创建时间：2016-10-28 14:49:02
	作者：nieming
	描述：QUIWidgetRushBuyNumItem
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetRushBuyNumItem = class("QUIWidgetRushBuyNumItem", QUIWidget)

--初始化
function QUIWidgetRushBuyNumItem:ctor(options)
	local ccbFile = "Widget_SixYuan_Buylog.ccbi"
	local callBacks = {
	}
	QUIWidgetRushBuyNumItem.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetRushBuyNumItem:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetRushBuyNumItem:onExit()
	----代码
--end

function QUIWidgetRushBuyNumItem:getSpriteFrameByNum(num)
	local frame  = QSpriteFrameByPath(QResPath("zhanbu_zl_")[num + 1])
	return frame
end

function QUIWidgetRushBuyNumItem:createNum( num)
	if num == nil then return end

	local node = CCNode:create()
	local scale = 0.7
	local numWidth = 33
	local offsetX = 0
	local createSpriteFunc = function(num)
		local frame  = self:getSpriteFrameByNum(num)
		local sprite = CCSprite:createWithSpriteFrame(frame)
		if sprite then
			sprite:setScale(scale)
			sprite:setAnchorPoint(0, 0.5)
			sprite:setPositionX(offsetX)

			self._ccbOwner.number:addChild(sprite)
			offsetX = offsetX + (numWidth * scale)
		end
	end

	local num1 = math.floor(num/1000)
	local num2 = math.floor(num%1000/100)
	local num3 = math.floor(num%100/10)
	local num4 = math.floor(num%10)

	if num1 ~= 0 then
		createSpriteFunc(num1)
	end
	if num2 ~= 0 or (num1 ~= 0) then
		createSpriteFunc(num2)
	end
	if num3 ~= 0 or (num1 ~= 0 or num2 ~= 0) then
		createSpriteFunc(num3)
	end
	if num4 ~= 0 or (num1 ~= 0 or num2 ~= 0 or num3 ~= 0) then
		createSpriteFunc(num4)
	end
	
	self._ccbOwner.number:setPositionX(-(offsetX - (numWidth * scale)/2)/2)
end
--describe：setInfo 
function QUIWidgetRushBuyNumItem:setInfo(num, isHideEffect)
	--代码
	self._ccbOwner.number:removeAllChildren()
	self:createNum(num)
	self._ccbOwner.effect:setVisible(not isHideEffect)
end

--describe：getContentSize 
function QUIWidgetRushBuyNumItem:getContentSize()
	--代码
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetRushBuyNumItem
