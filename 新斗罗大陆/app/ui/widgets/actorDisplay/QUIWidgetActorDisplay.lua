
local QUIWidget = import("..QUIWidget")
local QUIWidgetActorDisplay = class("QUIWidgetActorDisplay", QUIWidget)

local QUIWidgetSkeletonActor = import(".QUIWidgetSkeletonActor")
local QUIWidgetFcaActor = import(".QUIWidgetFcaActor")
local QUIWidgetFcaActor_cpp = import(".QUIWidgetFcaActor_cpp")
local QUIDBDirector = import(".QUIDBDirector")
local QUIWidgetAnimationPlayer = import("..QUIWidgetAnimationPlayer")
local QSkeletonViewController = import("....controllers.QSkeletonViewController")

function QUIWidgetActorDisplay:ctor(actorId, options)
	options = options or {}
	QUIWidgetActorDisplay.super.ctor(self, nil, nil, options)

	local character = db:getCharacterByID(actorId)
	local actorFile = character.actor_file
	local actorScale = character.actor_scale
	local skinInfo  = nil -- 先处理放报错
	if options.heroInfo and options.heroInfo.skinId and options.heroInfo.skinId ~= 0 then
		skinInfo = remote.heroSkin:getSkinConfigDictBySkinId(options.heroInfo.skinId)
        if skinInfo.skins_fca then
            actorFile = skinInfo.skins_fca
        end
        if skinInfo.skins_scale then
            actorScale = skinInfo.skins_scale
        end
		self._actorSkinId = options.heroInfo.skinId
    end
    options.actorFile = actorFile
    options.actorScale = actorScale

	if string.find(actorFile, "fca/", 1, true) then
		if QFcaSkeletonView_cpp ~= nil and ENABLE_FCA_CPP then
			self._actor = QUIWidgetFcaActor_cpp.new(actorId, options, skinInfo)
		else
			self._actor = QUIWidgetFcaActor.new(actorId, options)
		end
	else
		self._actor = QUIWidgetSkeletonActor.new(actorId, options)
	end
	self._actorId = actorId
	self:addChild(self._actor)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
    self._actor:retain()
end

function QUIWidgetActorDisplay:onCleanup()
	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
	self:stopDisplay()
	self._actor:onCleanup()
	self._actor:release()
end

function QUIWidgetActorDisplay:getActor()
	return self._actor
end

function QUIWidgetActorDisplay:getActorId()
	return self._actorId
end

function QUIWidgetActorDisplay:setAutoStand(b)
	self._isAutoStand = b
	if self._director then
		self._director:setNoReset(b == false)
	end
end

function QUIWidgetActorDisplay:isActorPlaying()
	if self._director ~= nil then
		return true
	else
		return false
	end
end

function QUIWidgetActorDisplay:pauseAnimation()
	self._actor:getSkeletonView():pauseAnimation()
end

function QUIWidgetActorDisplay:stopDisplay()
	if self._director ~= nil then
		self._director:cancel()
		self._director = nil
	end
end

function QUIWidgetActorDisplay:displayWithBehavior(behaviorName)
	if behaviorName == nil then
		return
	end

	self:stopDisplay()
	local actionStr
	if self._actorSkinId then
		local config = db:getHeroSkinConfigByID(self._actorSkinId)
		if config and config.information_action_skins then
			actionStr = config.information_action_skins
		end
	end
	if actionStr == nil then
		local config = db:getCharacterByID(self._actorId)
		actionStr = config.information_action
	end

	local words = nil
	for _, action in ipairs(string.split(actionStr, ";")) do
		words = string.split(action, ":")
		if words[3] and words[3] == behaviorName then
			behaviorName = words[1]
			break
		end
	end
	
	self._director = QUIDBDirector.new(self._actor, behaviorName)
	self._director:setNoReset(self._isAutoStand == false)
	self._director:visit(0) -- 立即执行，不要等到下一帧开始

end

function QUIWidgetActorDisplay:setDisplayBehaviorCallback(cb)
	self._displayBehaviorCallback = cb
end

function QUIWidgetActorDisplay:setRunOverCallback(cb)
	self._runOverBack = cb
end
function QUIWidgetActorDisplay:_onFrame(dt)
	if self._director ~= nil then
		if self._director:isFinished() == true then
			self._director = nil
			if self._isAutoStand ~= false then
				self._actor:playAnimation(ANIMATION.STAND)
			end
			if self._displayBehaviorCallback then
				self._displayBehaviorCallback()
			end
		else
			self._director:visit(dt)
		end
	end

	self:updateWalk(dt)
	self:_updateChestAnimation(dt)
	self:_updateEnchantSuccessAnimation(dt)

	self._actor:update(dt)
end

function QUIWidgetActorDisplay:walkto(point)
	self:displayWithBehavior(ANIMATION_EFFECT.WALK)
	self._isWalking = true
	self._walkDst = {x = point.x, y = point.y}
	self._walkSrc = {x = self:getPositionX(), y = self:getPositionY()}
	self._walkDuration = q.distOf2Points(self._walkDst, self._walkSrc) / 220
	if self._walkDuration == 0 then
		self._isWalking = false
		return
	end
	self._walkTime = 0
	if point.x < self:getPositionX() then
		self._actor:setScaleX(math.abs(self._actor:getScaleX()))
	else
		self._actor:setScaleX(-math.abs(self._actor:getScaleX()))
	end
end

function QUIWidgetActorDisplay:walktoBySpeed(point,callback)
	self:displayWithBehavior(ANIMATION_EFFECT.WALK)
	self:setRunOverCallback(callback)
	self._isWalking = true
	self._walkDst = {x = point.x, y = point.y}
	self._walkSrc = {x = self:getPositionX(), y = self:getPositionY()}
	self._walkDuration = q.distOf2Points(self._walkDst, self._walkSrc) / 770
	if self._walkDuration == 0 then
		self._isWalking = false
		return
	end
	self._actor:getSkeletonView():setAnimationScale(2)
	self._walkTime = 0
	if point.x < self:getPositionX() then
		self._actor:setScaleX(math.abs(self._actor:getScaleX()))
	else
		self._actor:setScaleX(-math.abs(self._actor:getScaleX()))
	end
end

function QUIWidgetActorDisplay:isWalking()
	return self._isWalking
end

function QUIWidgetActorDisplay:getWalkDst()
	return self._walkDst
end

function QUIWidgetActorDisplay:updateWalk(dt)
	if not self._isWalking then
		return
	end

	local duration = self._walkDuration
	local time = math.min(self._walkTime + dt, duration)
	self._walkTime = time

	local x = math.sampler(self._walkSrc.x, self._walkDst.x, time / duration)
	local y = math.sampler(self._walkSrc.y, self._walkDst.y, time / duration)
	self:setPosition(ccp(x, y))

	if duration == time then
		self._isWalking = false
		if self._runOverBack then
			self._runOverBack()
			self._actor:getSkeletonView():setAnimationScale(1)
		end
		self._actor:resetActor()
	end
end

function QUIWidgetActorDisplay:stopWalking()
	if self._isWalking then
		self._isWalking = false
		self._actor:resetActor()
	end
end

function QUIWidgetActorDisplay:setWalkRange(range)
	self._range = range
end

function QUIWidgetActorDisplay:getWalkRange()
	return self._range
end

function QUIWidgetActorDisplay:setOpacity( ... )
	self._actor:setOpacity( ... )
end

function QUIWidgetActorDisplay:playChestAnimation(callback)
	self._chestAnimationTime = 0
	self._chestAnimationCallback = callback

	local skeletonActor = self._actor:getSkeletonView()
    local maskRect = CCRect(-384, -256, 768, 768)
    skeletonActor:setScissorEnabled(true)
    skeletonActor:setScissorRects(
        maskRect,
        CCRect(0, 0, 0, 0),
        CCRect(0, 0, 0, 0),
        CCRect(0, 0, 0, 0)
    )
    local func = ccBlendFunc()
    func.src = GL_DST_ALPHA
    func.dst = GL_DST_ALPHA
    skeletonActor:setScissorBlendFunc(func)
    skeletonActor:setScissorColor(ccc3(255, 255, 255))
    skeletonActor:setScissorOpacity(0)
    -- func.src = GL_ONE
    -- func.dst = GL_ONE - GL_SRC_ALPHA
    -- skeletonActor:setRenderTextureBlendFunc(func)
    -- skeletonActor:getRenderTextureSprite():setOpacity(255)
    skeletonActor:getSkeletonAnimation():setOpacity(0)
    skeletonActor:setSkeletonScaleX(0.8 * 1.2)
    skeletonActor:setSkeletonScaleY(0.8 * 1.2)
end

function QUIWidgetActorDisplay:_updateChestAnimation(dt)
	if self._chestAnimationTime then
		local skeletonActor = self._actor:getSkeletonView()
		local chestAnimationTime = self._chestAnimationTime
		-- local time1 = 1 + 10 / 30
		-- local time2 = 1 + 21 / 30
		-- local time3 = 1 + 45 / 30
		-- if chestAnimationTime <= time1 then
		-- elseif chestAnimationTime <= time2 then
		-- 	skeletonActor:getSkeletonAnimation():setOpacity(255)
		--     skeletonActor:setSkeletonScaleX(math.sampler2(1.25, 1.4, time1, time2, chestAnimationTime))
		--     skeletonActor:setSkeletonScaleY(math.sampler2(1.25, 1.4, time1, time2, chestAnimationTime))
		-- elseif chestAnimationTime <= time3 then
		-- 	skeletonActor:getSkeletonAnimation():setOpacity(255)
		--     skeletonActor:setSkeletonScaleX(1.4)
		--     skeletonActor:setSkeletonScaleY(1.4)
		-- 	local value = math.sampler2(255, 0, time2, time3, chestAnimationTime)
  --           skeletonActor:setScissorColor(ccc3(value, value, value))
		-- else
		-- 	skeletonActor:getSkeletonAnimation():setOpacity(255)
		--     skeletonActor:setSkeletonScaleX(1.4)
		--     skeletonActor:setSkeletonScaleY(1.4)
  --           skeletonActor:setScissorColor(ccc3(0, 0, 0))
  --          	self._chestAnimationTime = nil
  --          	if self._chestAnimationCallback then
  --          		self._chestAnimationCallback()
  --          		self._chestAnimationCallback = nil
  --          	end
  --          	return
		-- end

		local time1 = 1 + 10 / 30
		local time2 = 1 + 13 / 30
		local time3 = 1 + 16 / 30
		local time4 = 1 + 24 / 30
		if chestAnimationTime <= time1 then
		elseif chestAnimationTime <= time2 then
			skeletonActor:getSkeletonAnimation():setOpacity(255)
		    skeletonActor:setSkeletonScaleX(math.sampler2(0.55, 1.85, time1, time2, chestAnimationTime))
		    skeletonActor:setSkeletonScaleY(math.sampler2(0.55, 1.85, time1, time2, chestAnimationTime))
		elseif chestAnimationTime <= time3 then
			skeletonActor:getSkeletonAnimation():setOpacity(255)
		    skeletonActor:setSkeletonScaleX(math.sampler2(1.85, 1.40, time2, time3, chestAnimationTime))
		    skeletonActor:setSkeletonScaleY(math.sampler2(1.85, 1.40, time2, time3, chestAnimationTime))
		elseif chestAnimationTime <= time4 then
			skeletonActor:getSkeletonAnimation():setOpacity(255)
		    skeletonActor:setSkeletonScaleX(1.40)
		    skeletonActor:setSkeletonScaleY(1.40)
			local value = math.sampler2(255, 0, time3, time4, chestAnimationTime)
            skeletonActor:setScissorColor(ccc3(value, value, value))
		else
			skeletonActor:getSkeletonAnimation():setOpacity(255)
		    skeletonActor:setSkeletonScaleX(1.4)
		    skeletonActor:setSkeletonScaleY(1.4)
            skeletonActor:setScissorColor(ccc3(0, 0, 0))
           	self._chestAnimationTime = nil
           	if self._chestAnimationCallback then
           		self._chestAnimationCallback()
           		self._chestAnimationCallback = nil
           	end
           	return
		end

		self._chestAnimationTime = chestAnimationTime + dt
	end
end

function QUIWidgetActorDisplay:playEnchantSuccessAnimation()
    if not ENABLE_ENCHANT_EFFECT then
        return
    end
    
	self._enchantSuccessAnimationTime = 0
	for _, dummy in ipairs(self._actor:getEnchantDummies() or {}) do
		local widget = QUIWidgetAnimationPlayer.new()
		widget:playAnimation("ccb/effects/fumo_effect_k.ccbi", nil, nil, true, nil)
		self._actor:getSkeletonView():attachNodeToBone(dummy, widget, false, false)
	end
	self._actor:setEnchantEffectsOpacity(0)
end

function QUIWidgetActorDisplay:_updateEnchantSuccessAnimation(dt)
	if self._enchantSuccessAnimationTime then
		local time = self._enchantSuccessAnimationTime
		if time <= 1 then
			self._enchantSuccessAnimationTime = time + dt
		else
			self._actor:setEnchantEffectsOpacity(math.min(255, math.sampler2(0, 255, 1, 2, time)))
			if time >= 2.0 then
				self._enchantSuccessAnimationTime = nil
			else
				self._enchantSuccessAnimationTime = time + dt
			end
		end
	end
end

return QUIWidgetActorDisplay