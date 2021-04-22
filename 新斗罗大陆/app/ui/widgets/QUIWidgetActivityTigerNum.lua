--
-- Author: Your Name
-- Date: 2015-06-24 18:46:50
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityTigerNum = class("QUIWidgetActivityTigerNum", QUIWidget)

function QUIWidgetActivityTigerNum:ctor(options)
	local ccbFile = "ccb/Widget_DragonMine_Num.ccbi"
  	local callBacks = {
  	}
	QUIWidgetActivityTigerNum.super.ctor(self,ccbFile,callBacks,options)
	self._areaHeight = self._ccbOwner.tf_num1:getContentSize().height
	self._speed = 1
	self._minSpeed = 5
	self._maxSpeed = 20
	self._addSpeed = 1.5
	self._isAdd = true
	self:resetAll()
end

function QUIWidgetActivityTigerNum:onExit()
	QUIWidgetActivityTigerNum.super.onExit(self)
	self:_removeAnimation()
end

function QUIWidgetActivityTigerNum:resetAll()
	self._ccbOwner.tf_num2:setPositionY(self._ccbOwner.tf_num1:getPositionY() + self._areaHeight)
	self._ccbOwner.tf_num1:setString("0")
	self._ccbOwner.tf_num2:setString("1")
	self._num = 1
end

function QUIWidgetActivityTigerNum:addNum()
	self._num = self._num + 1
	if self._num >= 10 then
		self._num = 0
	end
end

function QUIWidgetActivityTigerNum:setNumPosition(value)
	local pos1 = self._ccbOwner.tf_num1:getPositionY() - value
	local pos2 = self._ccbOwner.tf_num2:getPositionY() - value
	if pos1 <= pos2 then
		if pos1 < -self._areaHeight then
			pos1 = pos2 + self._areaHeight
			self:addNum()
			self._num1 = self._num
			self._ccbOwner.tf_num1:setString(self._num)
		end
	else
		if pos2 < -self._areaHeight then
			pos2 = pos1 + self._areaHeight
			self:addNum()
			self._num2 = self._num
			self._ccbOwner.tf_num2:setString(self._num)
		end
	end
	self._ccbOwner.tf_num1:setPositionY(pos1)
	self._ccbOwner.tf_num2:setPositionY(pos2)
end

function QUIWidgetActivityTigerNum:runAnimation()
	if self:getParent() == nil then return end
	self:_removeAnimation()
	self._count = 0
	self._speed = self._minSpeed
	self._isAdd = true
	self._targetNum = nil
	self._animationHandler = scheduler.scheduleGlobal(handler(self, self._onEnterFrame), 0)
end

function QUIWidgetActivityTigerNum:_removeAnimation()
	if self._animationHandler ~= nil then
		scheduler.unscheduleGlobal(self._animationHandler)
		self._animationHandler = nil
	end
end

function QUIWidgetActivityTigerNum:setTargetNum(num,round)
	self._targetNum = num
	self._isAdd = false
end

function QUIWidgetActivityTigerNum:_onEnterFrame()
	self._count = self._count + 1
	if self._isAdd == true and self._speed < self._maxSpeed and self._count % 10 == 0 then
		self._speed = self._speed + self._addSpeed
	elseif self._isAdd == false and self._speed > self._minSpeed and self._count % 10 == 0 then
		self._speed = self._speed - self._addSpeed
	end
	self:setNumPosition(self._speed)
	if self._targetNum ~= nil and self._num == self._targetNum and self._speed <= self._maxSpeed/4 then
		if self._num1 == self._num then
			if self._ccbOwner.tf_num1:getPositionY() < 10 and self._ccbOwner.tf_num1:getPositionY() > -10 then
				if self._ccbOwner.tf_num2:getPositionY() < self._ccbOwner.tf_num1:getPositionY() then
					self._ccbOwner.tf_num2:runAction(CCMoveTo:create(0.4, ccp(0,-self._areaHeight)))
				else
					self._ccbOwner.tf_num2:runAction(CCMoveTo:create(0.4, ccp(0,self._areaHeight)))
				end
				self._ccbOwner.tf_num1:runAction(CCMoveTo:create(0.4, ccp(0,0)))
				self:_removeAnimation()
			end
		else
			if self._ccbOwner.tf_num2:getPositionY() < 10 and self._ccbOwner.tf_num2:getPositionY() > -10 then
				if self._ccbOwner.tf_num1:getPositionY() < self._ccbOwner.tf_num2:getPositionY() then
					self._ccbOwner.tf_num1:runAction(CCMoveTo:create(0.4, ccp(0,-self._areaHeight)))
				else
					self._ccbOwner.tf_num1:runAction(CCMoveTo:create(0.4, ccp(0,self._areaHeight)))
				end
				self._ccbOwner.tf_num2:runAction(CCMoveTo:create(0.4, ccp(0,0)))
				self:_removeAnimation()
			end
		end
	end
end

return QUIWidgetActivityTigerNum