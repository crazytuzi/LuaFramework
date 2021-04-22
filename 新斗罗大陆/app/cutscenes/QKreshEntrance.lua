
local QEntranceBase = import(".QEntranceBase")
local QKreshEntrance = class("QKreshEntrance", QEntranceBase)
local QNotificationCenter = import("..controllers.QNotificationCenter")

local ccbLine1 = "ccb/Widget_NewPlayer3.ccbi"
local ccbLine2 = "ccb/Widget_NewPlayer3_3.ccbi"
local ccbLine3 = "ccb/Widget_NewPlayer3_2.ccbi"

function QKreshEntrance:ctor(name, options)
	QKreshEntrance.super.ctor(self, name, options)

	-- charactor display id
	local guardianId = 40112
	local kreshId = 40118

	self._guardian1 = self:_createActorView(guardianId)
	self._guardian2 = self:_createActorView(guardianId)
	self._kresh = self:_createActorView(kreshId)

	self:_addSkeletonView(self._guardian1)
	self:_addSkeletonView(self._guardian2)
	self:_addSkeletonView(self._kresh)
end

function QKreshEntrance:exit()
	self:_removeActorView(self._guardian1)
	self:_removeActorView(self._guardian2)
	self:_removeActorView(self._kresh)

	app.scene:togglePlaySpeedAndSkipVisibility()

   	QKreshEntrance.super.exit(self)
end

function QKreshEntrance:getKreshPosition()
	if self._kresh == nil then
		return 0, 0
	end

	return self._kresh:getPosition()
end

function QKreshEntrance:getKreshSkeletonView()
	return self._kresh
end

function QKreshEntrance:startAnimation()
	self._guardian1:setPosition(570, 400)
	self._guardian2:setPosition(820, 400)
	self._kresh:setPosition(1600, 350)

	self:_setupAnimations()

	app.scene:togglePlaySpeedAndSkipVisibility()
end

function QKreshEntrance:_createDialogue(ccb, word, target, deltaX, deltaY, isFlip)
	if word == nil or target == nil then
		return
	end

	if deltaX == nil then
		deltaX = 0
	end

	if deltaY == nil then
		deltaY = 0
	end

	local ccbOwner = {}
	local ccbView = CCBuilderReaderLoad(ccb, CCBProxy:create(), ccbOwner)
	self._uiRoot:addChild(ccbView)
	local x, y = target:getPosition()
	ccbView:setPosition(x + deltaX, y + deltaY)
	ccbOwner.label:setString(word)
	if isFlip then
		local anchorPoint = ccbOwner.sprite:getAnchorPoint()
		ccbOwner.sprite:setAnchorPoint(ccp(1.0 - anchorPoint.x, anchorPoint.y))
		ccbOwner.sprite:setScaleX(-1.0)
	end
	return ccbView
end

function QKreshEntrance:_setupAnimations()
	self._guardian1:flipActor()

	local arr = CCArray:create()

	arr:addObject(CCCallFunc:create(function()
		self._guardian1:playAnimation("attack01", false)
		self._guardian1:appendAnimation(ANIMATION.STAND, true)
	end))
	arr:addObject(CCCallFunc:create(function()
		self._guardian2:playAnimation(ANIMATION.STAND, true)
	end))

	arr:addObject(CCDelayTime:create(0.25))
	arr:addObject(CCCallFunc:create(function()
		self._widgetDialogue1 = self:_createDialogue(device.platform == "android" and ccbLine3 or ccbLine2, "前面几关的守卫都被打败了...", self._guardian1, 90, 150)
	end))

	arr:addObject(CCDelayTime:create(1.5))
	arr:addObject(CCCallFunc:create(function()
		self._kresh:playAnimation("attack06", false)
		self._kresh:appendAnimation("attack04", true)
	end))

	arr:addObject(CCDelayTime:create(0.25))
	arr:addObject(CCCallFunc:create(function()
		self._widgetDialogue1:removeFromParent()
		self._widgetDialogue1 = nil

		self._guardian2:playAnimation("attack02", false)
		self._guardian2:appendAnimation(ANIMATION.STAND, true)
	end))

	arr:addObject(CCDelayTime:create(0.25))
	arr:addObject(CCCallFunc:create(function()
		self._widgetDialogue2 = self:_createDialogue(device.platform == "android" and ccbLine3 or ccbLine2, "是啊，燃烧军团越来越靠不住了！", self._guardian2, -150, 150, true)
	end))

	arr:addObject(CCDelayTime:create(1.2))
	arr:addObject(CCCallFunc:create(function()
		local effect = self:_createEffectAndAttachToActor("revolve_1", self._kresh)
		if effect.front then
			effect.front.view:playAnimation(effect.front.view:getPlayAnimationName(), true)
		end
		if effect.back then
			effect.back.view:playAnimation(effect.back.view:getPlayAnimationName(), true)
		end
		self._kresh.revolveEffect = effect

		local _, gridPos = app.grid:_toGridPos(850, 350)
		local screenPos = app.grid:_toScreenPos(gridPos)
		local currentPos = ccp(self._kresh:getPosition())
		local bezierConfig = ccBezierConfig:new()
	    bezierConfig.endPosition = ccp(screenPos.x, screenPos.y)
	    bezierConfig.controlPoint_1 = ccp(currentPos.x + (screenPos.x - currentPos.x) * 0.333, screenPos.y + 200)
	    bezierConfig.controlPoint_2 = ccp(currentPos.x + (screenPos.x - currentPos.x) * 0.667, screenPos.y + 250)
	    local bezierTo = CCBezierTo:create(2.0, bezierConfig)
		self._kresh:runAction(CCEaseIn:create(bezierTo, 4))
		bezierConfig:delete()
	end))

	arr:addObject(CCDelayTime:create(0.8))

	-- 向后跳
	arr:addObject(CCCallFunc:create(function()
		self._widgetDialogue2:removeFromParent()
		self._widgetDialogue2 = nil
		self._guardian2:flipActor()
	end))
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCCallFunc:create(function()
		self._guardian2:playAnimation("attack23", false)
		self._guardian2:appendAnimation(ANIMATION.STAND, true)
	end))
	arr:addObject(CCDelayTime:create(0.3))
	arr:addObject(CCCallFunc:create(function()
		self._guardian2:runAction(CCMoveTo:create(0.4, ccp(590, 300)))
	end))

	arr:addObject(CCDelayTime:create(0.5))

	arr:addObject(CCCallFunc:create(function()
		local effect = self:_createEffectAndAttachToActor("trample_skum_1", self._kresh)
		if effect.front then
			effect.front.view:setScale(0.5)
			effect.front.view:playAnimation(effect.front.view:getPlayAnimationName(), true)
		end
		if effect.back then
			effect.back.view:setScale(0.5)
			effect.back.view:playAnimation(effect.back.view:getPlayAnimationName(), true)
		end
		self._kresh.trampleEffect = effect

		effect = self._kresh.revolveEffect
		if effect.front then
			self._kresh:detachNodeToBone(effect.front)
		end
		if effect.back then
			self._kresh:detachNodeToBone(effect.back)
		end
		self._kresh:playAnimation(ANIMATION.STAND, false)
		self._kresh:playAnimation("attack02", false)
		self._kresh:appendAnimation(ANIMATION.STAND, true)

		local x, y = self._kresh:getPosition()
		self._widgetDialogue3 = self:_createDialogue(device.platform == "android" and ccbLine3 or ccbLine2, "滚！两个废物！燃烧军团永不灭！", self._kresh, -150, 190, true)
	end))

	arr:addObject(CCDelayTime:create(2.5))

	-- 受惊吓
	arr:addObject(CCCallFunc:create(function()

		-- self._guardian1:stopAnimation()
		local effect = self:_createEffectAndAttachToActor("psychic_scream_4", self._guardian1)
		if effect.front then
			effect.front.view:playAnimation(effect.front.view:getPlayAnimationName(), true)
		end
		if effect.back then
			effect.back.view:playAnimation(effect.back.view:getPlayAnimationName(), true)
		end
		self._guardian1.exclemationEffect = effect

		-- self._guardian2:stopAnimation()
		local effect = self:_createEffectAndAttachToActor("psychic_scream_4", self._guardian2)
		if effect.front then
			effect.front.view:playAnimation(effect.front.view:getPlayAnimationName(), true)
		end
		if effect.back then
			effect.back.view:playAnimation(effect.back.view:getPlayAnimationName(), true)
		end
		self._guardian2.exclemationEffect = effect

		self._widgetDialogue3:removeFromParent()
		self._widgetDialogue3 = nil

		self._widgetDialogue1 = self:_createDialogue(ccbLine1, "别杀我们，远古巨龟...", self._guardian1, 90, 145)
	end))

	arr:addObject(CCDelayTime:create(1.0))
	arr:addObject(CCCallFunc:create(function()
		self._widgetDialogue1:removeFromParent()
		self._widgetDialogue1 = nil
		self._widgetDialogue2 = self:_createDialogue(ccbLine1, "我们现在就滚...", self._guardian2, 90, 145)
	end))

	arr:addObject(CCDelayTime:create(1.0))
	arr:addObject(CCCallFunc:create(function()
		self._widgetDialogue2:removeFromParent()
		self._widgetDialogue2 = nil
	end))

	-- 逃跑
	arr:addObject(CCCallFunc:create(function()
		self._guardian1:flipActor()
		self._guardian1:playAnimation("attack24", true)
		self._guardian1:runAction(CCMoveTo:create(3, ccp(-100, 550)))

		self._guardian2:flipActor()
		self._guardian2:playAnimation("attack24", true)
		self._guardian2:runAction(CCMoveTo:create(3, ccp(-100, 150)))
	end))

	arr:addObject(CCDelayTime:create(0.2))
	arr:addObject(CCCallFunc:create(function()
		local effect = self._kresh.trampleEffect
		if effect.front then
			self._kresh:detachNodeToBone(effect.front)
		end
		if effect.back then
			self._kresh:detachNodeToBone(effect.back)
		end
	end))

	arr:addObject(CCDelayTime:create(3.5))

	arr:addObject(CCCallFunc:create(function()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QEntranceBase.ANIMATION_FINISHED})
	end))
	
	self._skeletonRoot:runAction(CCSequence:create(arr))
end

return QKreshEntrance
