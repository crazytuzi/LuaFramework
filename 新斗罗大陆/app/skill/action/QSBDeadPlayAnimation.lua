--[[
	死亡播放动作专用
--]]

local QSBAction = import(".QSBAction")
local QSBDeadPlayAnimation = class("QSBDeadPlayAnimation", QSBAction)

function QSBDeadPlayAnimation:_execute(dt)
	if IsServerSide then
		self:finished()
		return
	end
	
	if nil == self._attacker or nil == app.scene:getActorViewFromModel(self._attacker) then
		self:finished()
		return
	end

	-- if self._isAnimationPlaying == true then
	-- 	return
	-- end

	self._widgetActor = app.scene:getActorViewFromModel(self._attacker):getSkeletonActor()
	if not self._widgetActor:canPlayAnimation(self:_getAttackAnimationNames() or "") then
		self:cancel() --不能播放动画就cancel掉 这样可以直接播放dead动画
		return
	end

	self._animationName = self:_getAttackAnimationNames()
	self._isLoop = self._options.is_loop
	self._widgetActor:playAnimation(self._animationName, self._isLoop)
	if self._options.instant then
		self._widgetActor:updateAnimation(10)
		self:finished()
		return
	end
	self._isAnimationPlaying = true

	if self._options.async or self._animationName == ANIMATION.STAND or self._animationName == ANIMATION.WALK then
		self:finished()
	else
		self._widgetActor:connectAnimationEventSignal(handler(self, self._onActorAnimationEvent))
	end
end

function QSBDeadPlayAnimation:_getAttackAnimationNames()
    local name = (self._options.animation or self._director:getActorNpcSkillAnimation())
    local animations = {}
    if string.len(name) ~= 0 then
    	table.insert(animations, name)
    	if self._options.is_loop ~= true and not self._options.no_stand then
    		table.insert(animations, ANIMATION.STAND)
    	end
    end

    return animations[1]
end

function QSBDeadPlayAnimation:_onActorAnimationEvent(eventType, trackIndex, animationName, loopCount)
    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
    	self:finished()
    end
end

function QSBDeadPlayAnimation:_onCancel()
    self._widgetActor:playAnimation(ANIMATION.DEAD, self._isLoop)
end

return QSBDeadPlayAnimation