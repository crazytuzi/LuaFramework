--[[
    Class name QSBPlayAnimation
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBPlayAnimation = class("QSBPlayAnimation", QSBAction)

local QActor = import("...models.QActor")

function QSBPlayAnimation:_execute(dt)
	if self._isAnimationPlaying == true then
		return
	end

	local animations = self:_getAttackAnimationNames()
	if table.nums(animations) == 0 then
		self:_onAnimationAttack({atk_x = 0, atk_y = 0})
		self:finished()
		return
	end

	self._attacker:playSkillAnimation(animations, self._options.is_loop)
	if not IsServerSide then
		local actorView = app.scene:getActorViewFromModel(self._attacker)
		if actorView ~= nil then
			actorView:setIsKeepAnimation(self._options.is_keep_animation)
			self._director:setActorKeepAnimation(self._options.is_keep_animation)
		end
	end
	
	if self._options.is_loop ~= true then
		local count = table.nums(animations)
		self._endAnimationName = animations[1]
		self._isAnimationPlaying = true

		self._eventListener = cc.EventProxy.new(self._attacker)
		self._eventListener:addEventListener(QActor.ANIMATION_ENDED, handler(self, self._onAnimationEnded))
		self._eventListener:addEventListener(QActor.ANIMATION_ATTACK, handler(self, self._onAnimationAttack))

		local coefficient = self._attacker:getMaxHasteCoefficient()
	    if self:isAffectedByHaste() == false then
	        coefficient = 1
	    end

		if self._attacker ~= nil then
			self._attacker:setAnimationScale(coefficient, self)
		end
	else
		self:finished()
	end
end

function QSBPlayAnimation:_getAttackAnimationNames()
    local name = (self._options.animation or self._skill:getActorAttackAnimation())
    local animations = {}
    if string.len(name) ~= 0 then
    	table.insert(animations, name)
    	if self._options.is_loop ~= true and not self._options.no_stand then
    		table.insert(animations, ANIMATION.STAND)
    	end
    end

    return animations
end

function QSBPlayAnimation:_onAnimationEnded(event)
	if event.animationName == self._endAnimationName then
		self:finished()
		self._eventListener:removeAllEventListeners()

		if self._attacker == nil then
			return
		end
		self._attacker:setAnimationScale(1.0, self)
	end
end

local _mathabs = math.abs

function QSBPlayAnimation:_onAnimationAttack(event)
	-- nzhang: fca attack event, QSBHitTarget, QSBBullet, QSBLaser, QSBUFO
    if self._animAtkIdx == nil then
        self._animAtkIdx = 1
    end
    local chdIdx = math.min(self._animAtkIdx, self:getChildrenCount())

    local child = self:getChildAtIndex(chdIdx)
    if child then
	    if not IsServerSide then
	    	local actorView = app.scene:getActorViewFromModel(self._attacker)
	    	if actorView then
	    		local skeletonActor = actorView:getSkeletonActor()
	    		if skeletonActor and skeletonActor.isFca then
	    			local options = child:getOptions()
	    			local is_effect_by_animation
	    			if nil ~= options.start_pos then
	    				is_effect_by_animation = options.start_pos.is_animation
					end
	    			if is_effect_by_animation == nil or is_effect_by_animation == true then
					    local scale = skeletonActor:getRootScale()
					    local start_pos = {x = event.atk_x * _mathabs(scale), y = event.atk_y * _mathabs(scale), effect_by_animation = true}
					    options.start_pos = start_pos
				   	end
				end
			end
		end
		child:getOptions().ani_atk_idx = self._animAtkIdx
		child:reset()
	    child:start()
	    child:visit(0)
	end
	self._animAtkIdx = self._animAtkIdx + 1
end

function QSBPlayAnimation:_onCancel()
    if self._eventListener ~= nil then
		self._eventListener:removeAllEventListeners()
	end

	if self._attacker == nil then
		return
	end
	if not IsServerSide then
		if self._options.reload_on_cancel then
			if not self._attacker:isDead() then
				local actorView = app.scene:getActorViewFromModel(self._attacker)
				if not actorView:getSkeletonActor().isFca then
					actorView:reloadSkeleton()
					actorView:getSkeletonActor():resetActorWithAnimation(ANIMATION.STAND, true)
					local scale, _ = actorView:getModel():getActorScale()
					actorView:getSkeletonActor():setSkeletonScaleX(scale)
					actorView:getSkeletonActor():setSkeletonScaleY(scale)
				end
			end
		end
	end
	self._attacker:setAnimationScale(1.0, self)
end

function QSBPlayAnimation:_onRevert()
	if self._attacker == nil then
		return
	end
	if not IsServerSide then
		if self._options.reload_on_cancel then
			if not self._attacker:isDead() then
				local actorView = app.scene:getActorViewFromModel(self._attacker)
				if not actorView:getSkeletonActor().isFca then
					actorView:reloadSkeleton()
					actorView:getSkeletonActor():resetActorWithAnimation(ANIMATION.STAND, true)
					local scale, _ = actorView:getModel():getActorScale()
					actorView:getSkeletonActor():setSkeletonScaleX(scale)
					actorView:getSkeletonActor():setSkeletonScaleY(scale)
				end
			end
		end
	end
	self._attacker:setAnimationScale(1.0, self)
end

return QSBPlayAnimation