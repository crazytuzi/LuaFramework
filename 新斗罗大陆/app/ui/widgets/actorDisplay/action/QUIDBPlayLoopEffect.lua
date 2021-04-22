

local QUIDBAction = import(".QUIDBAction")
local QUIDBPlayLoopEffect = class("QUIDBPlayLoopEffect", QUIDBAction)

local QUIWidgetSkeletonEffect = import("..QUIWidgetSkeletonEffect")

function QUIDBPlayLoopEffect:_execute(dt)
	if self._isAnimationPlaying == true then
		return
	end

	if self._options.effect_id == nil or string.len(self._options.effect_id) == 0 then
		self:finished()
		return
	end

	if self._options.duration == nil or self._options.duration <= 0 then
		self:finished()
		return
	end

	local frontEffect, backEffect = QUIWidgetSkeletonEffect.createEffectByID(self._options.effect_id, {time_scale = self._options.time_scale})

	if self._widgetActor:attachEffect(self._options.effect_id, frontEffect, backEffect) == false then
		self:finished()
		return
	end

	if frontEffect ~= nil then
		frontEffect:playAnimation(EFFECT_ANIMATION, true)
		if self._options.no_sound_loop then
			frontEffect:playSoundEffect(false)
		else
			frontEffect:playSoundEffect(true)
		end
	end

	if backEffect ~= nil then
		backEffect:playAnimation(EFFECT_ANIMATION, true)
		if self._options.no_sound_loop then
			backEffect:playSoundEffect(false)
		else
			backEffect:playSoundEffect(true)
		end
	end

	self._handler = scheduler.performWithDelayGlobal(function()
        self:_removeEffect()
        self:finished()
        self._handler = nil
    end, self._options.duration)

	if self._frontEffect ~= nil then
		self._frontEffect:release()
		self._frontEffect = nil
	end
	self._frontEffect = frontEffect
	if self._frontEffect ~= nil then
		self._frontEffect:retain()
	end

	if self._backEffect ~= nil then
		self._backEffect:release()
		self._backEffect = nil
	end
	self._backEffect = backEffect
	if self._backEffect ~= nil then
		self._backEffect:retain()
	end
	
	self._isAnimationPlaying = true
end

function QUIDBPlayLoopEffect:_removeEffect()
	if self._frontEffect ~= nil then
		self._frontEffect:stopAnimation()
		self._frontEffect:stopSoundEffect()
		self._widgetActor:getSkeletonView():detachNodeToBone(self._frontEffect)
		self._frontEffect:release()
		self._frontEffect = nil
    end

    if self._backEffect ~= nil then
		self._backEffect:stopAnimation()
		self._backEffect:stopSoundEffect()
		self._widgetActor:getSkeletonView():detachNodeToBone(self._backEffect)
		self._backEffect:release()
		self._backEffect = nil
    end
end

function QUIDBPlayLoopEffect:_onCancel()
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
		self:_removeEffect()
	end
end

return QUIDBPlayLoopEffect