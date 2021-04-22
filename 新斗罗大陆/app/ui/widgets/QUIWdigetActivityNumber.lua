-- @Author: xurui
-- @Date:   2019-03-21 15:22:03
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-05 15:24:17
local QUIWidget = import("..widgets.QUIWidget")
local QUIWdigetActivityNumber = class("QUIWdigetActivityNumber", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWdigetActivityNumber:ctor(options)
	local ccbFile = "ccb/Widget_Monday_slot.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWdigetActivityNumber.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._numSpNode = {}    -- 1是百位，2是十位，3是个位

	self:initNumberArea()
end

function QUIWdigetActivityNumber:onEnter()
end

function QUIWdigetActivityNumber:onExit()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIWdigetActivityNumber:initNumberArea()
	local clippingFunc = function(node)
		local drawNode = CCDrawNode:create()
	    drawNode:drawCircle(125)
	    drawNode:setPositionY(-7)
	    local ccclippingNode = CCClippingNode:create()
	    ccclippingNode:setAlphaThreshold(1)
	    ccclippingNode:setStencil(drawNode)
	    self:getView():addChild(ccclippingNode)

	    return drawNode
	end
	self._rootNode = clippingFunc()

	local addToRootNode = function(node)
		node:retain()
		node:removeFromParent()
		self._rootNode:addChild(node)
		node:release()
		return node
	end

	self._numSpNode[1] = addToRootNode(self._ccbOwner.node_hundred)
	self._numSpNode[2] = addToRootNode(self._ccbOwner.node_ten)
	self._numSpNode[3] = addToRootNode(self._ccbOwner.node_one)
end

function QUIWdigetActivityNumber:setInfo(number)
	self._curNumber = number or 0

	self:setNumber()
end

function QUIWdigetActivityNumber:setNumber(isAnimation)
	local hundredNum = math.floor(self._curNumber / 100)
	local tenNum = math.floor(self._curNumber % 100 / 10)
	local oneNum = math.floor(self._curNumber % 100 % 10)

	local height = -180
	local offsetX = -38
	local offsetY = -60
	local numberFunc = function(updateIndex)

		local createSpFunc = function(spNode, number)
			spNode:removeAllChildren()
			for i = 1, 2 do
				local sprite = self:getNumSprite(number + (i - 1))
				sprite:setPositionY(height * (i - 1) + offsetY)
				sprite:setPositionX(offsetX)
		    	spNode:addChild(sprite)
    			spNode:setPositionY(0)
			end
		end

		if updateIndex == 1 or updateIndex == 0 then
			createSpFunc(self._numSpNode[1], hundredNum)
		end
		if updateIndex == 2 or updateIndex == 0 then
			createSpFunc(self._numSpNode[2], tenNum)
		end
		if updateIndex == 3 or updateIndex == 0 then
			createSpFunc(self._numSpNode[3], oneNum)
		end
	end

	local updateHundred = hundredNum ~= self._hundredNum
	local updateTen = tenNum ~= self._tenNum
	local updateOne = oneNum ~= self._oneNum
	if isAnimation then
		local effectFunc = function(spNode, moveTime, updateIndex)
			local ccArray = CCArray:create()
			local positionX = spNode:getPositionX()
			ccArray:addObject(CCEaseInOut:create(CCMoveTo:create(moveTime, ccp(positionX, math.abs(height))), moveTime))
			ccArray:addObject(CCCallFunc:create(function()
					numberFunc(updateIndex)
				end))
			spNode:runAction(CCSequence:create(ccArray))
		end
		if updateHundred then
			effectFunc(self._numSpNode[1], 0.1, 1)
		end
		if updateTen then
			effectFunc(self._numSpNode[2], 0.06125, 2)
		end
		if updateOne then
			effectFunc(self._numSpNode[3], 0.025, 3)
		end
	else
		numberFunc(0)
	end

	self._hundredNum = hundredNum
	self._tenNum = tenNum
	self._oneNum = oneNum
end

function QUIWdigetActivityNumber:addNumber(number, callback)
	local newNumber = self._curNumber + (number or 0)
	self:updateNumber(newNumber, callback)
end

function QUIWdigetActivityNumber:updateNumber(number, callback)
	if number == self._curNumber then return end

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	local oldNumber = self._curNumber
	local newNumber = number

	local changeNumberFunc
	changeNumberFunc = function()
		self._curNumber = self._curNumber + 4
		if self._curNumber > newNumber then
			self._curNumber = newNumber
			self:setNumber(true)
			if self._scheduler then
				scheduler.unscheduleGlobal(self._scheduler)
				self._scheduler = nil
			end
			if callback then
				callback()
			end
		else
			self:setNumber(true)
		end
	end

	self._scheduler =  scheduler.scheduleGlobal(changeNumberFunc, 0.025)
end

function QUIWdigetActivityNumber:getNumSprite(num)
	if num == nil or num == 10 then num = 0 end

	local sprite = CCSprite:create()
	local index = num + 1
	QSetDisplaySpriteByPath(sprite, QResPath("activity_slot_num")[index])
	sprite:setAnchorPoint(ccp(0, 0))

	return sprite
end

return QUIWdigetActivityNumber
