

local QUIDBAction = import(".QUIDBAction")
local QUIDBPlayAnimation = class("QUIDBPlayAnimation", QUIDBAction)

function QUIDBPlayAnimation:_execute(dt)
	if not self._widgetActor:getSkeletonView():canPlayAnimation(self:_getAttackAnimationNames() or "") then
		self:finished()
		return
	end

	if self._isAnimationPlaying == true then
		return
	end

	self._animationName = self:_getAttackAnimationNames()
	self._isLoop = self._options.is_loop
	self._widgetActor:playAnimation(self._animationName, self._isLoop)
	if self._options.instant then
		self._widgetActor:getSkeletonView():updateAnimation(10)
		self:finished()
		return
	end
	self._isAnimationPlaying = true

	if self._options.async or self._animationName == ANIMATION.STAND or self._animationName == ANIMATION.WALK then
		self:finished()
	else
		self._eventProxy = cc.EventProxy.new(self._widgetActor)
    	self._eventProxy:addEventListener(self._widgetActor.ANIMATION_FINISHED_EVENT, handler(self, self._onAnimationEnded))
	end
end

function QUIDBPlayAnimation:_getAttackAnimationNames()
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

function QUIDBPlayAnimation:_onAnimationEnded(event)
	if event.animationName == self._animationName then
		self._eventProxy:removeAllEventListeners()
		self._eventProxy = nil
		if not self._isLoop then
			self:finished()
		end
	end
end

function QUIDBPlayAnimation:_onCancel()
	if  self._eventProxy ~= nil then
        self._eventProxy:removeAllEventListeners()
        self._eventProxy = nil
    end
	if not self._widgetActor:getSkeletonView().isFca then
		local actorFile, actorScale = self._widgetActor:getActorFile()
		self._widgetActor:getSkeletonView():reloadWithFile(actorFile)
		self._widgetActor:getSkeletonView():setSkeletonScaleX(actorScale)
		self._widgetActor:getSkeletonView():setSkeletonScaleY(actorScale)
	end
end

return QUIDBPlayAnimation