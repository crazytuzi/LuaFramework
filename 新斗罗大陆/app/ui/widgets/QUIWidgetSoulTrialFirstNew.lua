--
-- Author: Kumo.Wang
-- Date: Fri Mar 11 13:03:07 2016
-- 魂力试炼序章——新的动画特效
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTrialFirstNew = class("QUIWidgetSoulTrialFirstNew", QUIWidget)

local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetSoulTrialFirstNew.SOULTRIAL_CLICK = "SOULTRIAL_CLICK"
QUIWidgetSoulTrialFirstNew.RADIUS = 185
QUIWidgetSoulTrialFirstNew.FCA_START_Y = -400
QUIWidgetSoulTrialFirstNew.FCA_END_Y = 20
QUIWidgetSoulTrialFirstNew.FCA_OFFSET_Y = 20
QUIWidgetSoulTrialFirstNew.FCA_SPEED_Y = 10

function QUIWidgetSoulTrialFirstNew:ctor(options)
	local ccbFile = "ccb/Widget_SoulTrial_First.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)}
	}
	QUIWidgetSoulTrialFirstNew.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	self._isOver = false

	self:_init()
end

function QUIWidgetSoulTrialFirstNew:onEnter()
end

function QUIWidgetSoulTrialFirstNew:onExit()
	if self._schedulerUp then
		scheduler.unscheduleGlobal(self._schedulerUp)
		self._schedulerUp = nil
	end
	if self._schedulerDown then
		scheduler.unscheduleGlobal(self._schedulerDown)
		self._schedulerDown = nil
	end
end

function QUIWidgetSoulTrialFirstNew:_init()
	self._ccbOwner.node_effect:removeAllChildren()

	-- 球的遮罩初始化
	local ccclippingNode = CCClippingNode:create()
	local maskDrawNode = CCDrawNode:create()
	maskDrawNode:drawCircle(self.RADIUS)
	ccclippingNode:setStencil(maskDrawNode)
	maskDrawNode:setPosition(0, 0)

	if not self._fcaAnimation1 then
		self._fcaAnimation1 = QUIWidgetFcaAnimation.new("fca/lansedizi_1_2", "res")
	end
	ccclippingNode:addChild(self._fcaAnimation1)
	self._fcaAnimation1:setPositionY(self.FCA_START_Y)
	self._fcaAnimation1:setScale(1.1)
	if not self._fcaAnimation2 then
		self._fcaAnimation2 = QUIWidgetFcaAnimation.new("fca/lansedizi_1_2", "res")
	end
	ccclippingNode:addChild(self._fcaAnimation2)
	self._fcaAnimation2:setScaleX(-1.1)
	self._fcaAnimation2:setScaleY(1.1)
	self._fcaAnimation2:setPositionY(self.FCA_START_Y - self.FCA_OFFSET_Y)

	self._ccbOwner.node_effect:addChild(ccclippingNode)
	local glassPath = remote.soulTrial:getGlassImgPath()
	local glassImg = CCSprite:create(glassPath)
	self._ccbOwner.node_effect:addChild(glassImg)
end

-- enum
-- {
--     CCControlEventTouchDown           = 1 << 0,    // A touch-down event in the control.
--     CCControlEventTouchDragInside     = 1 << 1,    // An event where a finger is dragged inside the bounds of the control.
--     CCControlEventTouchDragOutside    = 1 << 2,    // An event where a finger is dragged just outside the bounds of the control.
--     CCControlEventTouchDragEnter      = 1 << 3,    // An event where a finger is dragged into the bounds of the control.
--     CCControlEventTouchDragExit       = 1 << 4,    // An event where a finger is dragged from within a control to outside its bounds.
--     CCControlEventTouchUpInside       = 1 << 5,    // A touch-up event in the control where the finger is inside the bounds of the control.
--     CCControlEventTouchUpOutside      = 1 << 6,    // A touch-up event in the control where the finger is outside the bounds of the control.
--     CCControlEventTouchCancel         = 1 << 7,    // A system event canceling the current touches for the control.
--     CCControlEventValueChanged        = 1 << 8      // A touch dragging or otherwise manipulating a control, causing it to emit a series of different values.
-- };
function QUIWidgetSoulTrialFirstNew:_onTriggerClick(event)
	if self._isOver then return end
	-- print(event)
	local e = tonumber(event)
	if e == CCControlEventTouchDown then

		if self._schedulerUp then
			scheduler.unscheduleGlobal(self._schedulerUp)
			self._schedulerUp = nil
		end
		if self._schedulerDown then
			scheduler.unscheduleGlobal(self._schedulerDown)
			self._schedulerDown = nil
		end

		self:handInEffect(function()
				self._schedulerUp = scheduler.scheduleGlobal(function ()
					self:_animationUp()
				end, 0.04)
			end)
	elseif e == CCControlEventTouchUpInside or e == CCControlEventTouchUpOutside or e == CCControlEventTouchCancel then
		if self._schedulerUp then
			scheduler.unscheduleGlobal(self._schedulerUp)
			self._schedulerUp = nil
		end
		if self._schedulerDown then
			scheduler.unscheduleGlobal(self._schedulerDown)
			self._schedulerDown = nil
		end

		self:handOutEffect()
		self._schedulerDown = scheduler.scheduleGlobal(function ()
			self:_animationDown()
		end, 0.04)
	end
	
end

function QUIWidgetSoulTrialFirstNew:_animationUp()
	local yNum
	if self._isOver then
		if self._schedulerUp then
			scheduler.unscheduleGlobal(self._schedulerUp)
			self._schedulerUp = nil
		end
		if self._schedulerDown then
			scheduler.unscheduleGlobal(self._schedulerDown)
			self._schedulerDown = nil
		end
		yNum = self.FCA_END_Y
	else
		yNum = self._fcaAnimation1:getPositionY() + self.FCA_SPEED_Y
		if yNum > self.FCA_END_Y then
			if self._schedulerUp then
				scheduler.unscheduleGlobal(self._schedulerUp)
				self._schedulerUp = nil
			end
			if self._schedulerDown then
				scheduler.unscheduleGlobal(self._schedulerDown)
				self._schedulerDown = nil
			end
			yNum = self.FCA_END_Y
			self._isOver = true
			self:_animationBoom()
			return
		end
	end

	if self._fcaAnimation1 then
		self._fcaAnimation1:setPositionY(yNum)
	end
	if self._fcaAnimation2 then
		self._fcaAnimation2:setPositionY(yNum - self.FCA_OFFSET_Y)
	end
end

function QUIWidgetSoulTrialFirstNew:handInEffect(callback)
	if self._handAction then
		self._ccbOwner.sp_hand:stopAction(self._handAction)
		self._ccbOwner.sp_hand:setScale(1)
	end

	local effectArray = CCArray:create()
	effectArray:addObject(CCMoveTo:create(0.3, ccp(20, -20)))
	effectArray:addObject(CCScaleTo:create(0.05, 0.9))
	effectArray:addObject(CCCallFunc:create(function()
			if callback then
				callback()
			end
		end))
	self._handAction = self._ccbOwner.sp_hand:runAction(CCSequence:create(effectArray))
end

function QUIWidgetSoulTrialFirstNew:handOutEffect(callback)
	if self._handAction then
		self._ccbOwner.sp_hand:stopAction(self._handAction)
	end

	local effectArray = CCArray:create()
	effectArray:addObject(CCMoveTo:create(0.3, ccp(188, -655)))
	effectArray:addObject(CCCallFunc:create(function()
			if callback then
				callback()
			end
		end))
	self._handAction = self._ccbOwner.sp_hand:runAction(CCSequence:create(effectArray))
end

function QUIWidgetSoulTrialFirstNew:_animationDown()
	local yNum
	if self._isOver then
		if self._schedulerUp then
			scheduler.unscheduleGlobal(self._schedulerUp)
			self._schedulerUp = nil
		end
		if self._schedulerDown then
			scheduler.unscheduleGlobal(self._schedulerDown)
			self._schedulerDown = nil
		end
		yNum = self.FCA_END_Y
	else
		yNum = self._fcaAnimation1:getPositionY() - self.FCA_SPEED_Y
		if yNum < self.FCA_START_Y then
			if self._schedulerUp then
				scheduler.unscheduleGlobal(self._schedulerUp)
				self._schedulerUp = nil
			end
			if self._schedulerDown then
				scheduler.unscheduleGlobal(self._schedulerDown)
				self._schedulerDown = nil
			end
			yNum = self.FCA_START_Y
		end
	end

	if self._fcaAnimation1 then
		self._fcaAnimation1:setPositionY(yNum) 
	end
	if self._fcaAnimation2 then
		self._fcaAnimation2:setPositionY(yNum - self.FCA_OFFSET_Y)
	end
end

function QUIWidgetSoulTrialFirstNew:_animationBoom()
	print("QUIWidgetSoulTrialFirstNew:_animationBoom()")
	if self._isOver then
		if self._schedulerUp then
			scheduler.unscheduleGlobal(self._schedulerUp)
			self._schedulerUp = nil
		end
		if self._schedulerDown then
			scheduler.unscheduleGlobal(self._schedulerDown)
			self._schedulerDown = nil
		end

		if not self._fcaAnimation3 then
			self._fcaAnimation3 = QUIWidgetFcaAnimation.new("fca/baozha_1_2", "res")
			self._ccbOwner.node_effect:addChild(self._fcaAnimation3)
			self._fcaAnimation3:playAnimation("animation", false)
		end
		self._ccbOwner.sp_hand:setVisible(false)
		
		self._fcaAnimation3:setEndCallback(handler(self, self._animationBoomEndHandler))
	end
end

function QUIWidgetSoulTrialFirstNew:_animationBoomEndHandler()
	print("{name = QUIWidgetSoulTrialFirstNew.SOULTRIAL_CLICK}")
	self:dispatchEvent({name = QUIWidgetSoulTrialFirstNew.SOULTRIAL_CLICK})
end

return QUIWidgetSoulTrialFirstNew
