--[[
    Class name QSBPlayEffect
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBPlayEffect = class("QSBPlayEffect", QSBAction)

local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

function QSBPlayEffect:_execute(dt)
	if IsServerSide then
		self:finished()
		return
	end

	local actors = {}
	local effectID = self._options.effect_id
	local coefficient = self._attacker:getMaxHasteCoefficient()
    if self:isAffectedByHaste() == false then
        coefficient = 1
    end
    local is_flip_x = self._options.is_flip_x
    if self._options.flip_with_attacker then
    	is_flip_x = self._attacker:isFlipX()
    end
	local options = {isFlipX = is_flip_x or false, isFlipY = self._options.is_flip_y or false, isRandomPosition = self._options.is_random_position, 
					time_scale = 1 / coefficient, 
					rotation = self._options.rotation, front_layer = self._options.front_layer, ground_layer = self._options.ground_layer, 
					scale_actor_face = self._options.scale_actor_face, followActorAnimation = self._options.follow_actor_animation,
					ignore_animation_scale = self._options.ignore_animation_scale, haste = self._options.haste, followActorPosition = self._options.follow_actor_position, targetPosition = self._options.targetPosition }
	if self._options.is_hit_effect == true or self._options.is_second_hit_effect == true then

		if self._options.is_hit_effect == true then
			effectID = effectID or self._skill:getHitEffectID()
		elseif self._options.is_second_hit_effect == true then
			effectID = effectID or self._skill:getSecondHitEffectID()
		end

		if self._options.selectTarget ~= nil then
			table.insert(actors, self._options.selectTarget)
		elseif self._options.is_range_effect ~= true and self._skill:getRangeType() == QSkill.MULTIPLE then
			if self._options.teammate_in_range then
				actors = {}
				local targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition(), nil, nil, nil, true)
				local attacker_is_npc = self._attacker and self._attacker:getType() == ACTOR_TYPES.NPC
				for i, actor in ipairs(targets) do
					local actor_is_npc = actor:getType() == ACTOR_TYPES.NPC
					if attacker_is_npc == actor_is_npc then
						table.insert(actors, actor)
					end 
				end

			elseif self._options.enemy_in_range then
				actors = {}
				local targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition(), nil, nil, nil, true)
				local attacker_is_npc = self._attacker and self._attacker:getType() == ACTOR_TYPES.NPC
				for i, actor in ipairs(targets) do
					local actor_is_npc = actor:getType() == ACTOR_TYPES.NPC
					if attacker_is_npc ~= actor_is_npc then
						table.insert(actors, actor)
					end 
				end
			elseif self._options.selectTargets then
				actors = self._options.selectTargets
			else
				actors = self._attacker:getMultipleTargetWithSkill(self._skill, self._target)
			end
		else
			if self._skill:getTargetType() == QSkill.SELF then
				table.insert(actors, self._attacker)
			else
				local actor = self._attacker
				local target = actor:getTarget()
				if self._options.is_current_target and target and not target:isDead() then
					table.insert(actors, target)
				else
					table.insert(actors, self._target)
				end
			end
		end
	elseif self._options.is_target_effect == true then
		table.insert(actors, self._target)
	else
		table.insert(actors, self._attacker)
		effectID = effectID or self._skill:getAttackEffectID()
		if not self._options.not_cancel_with_skill then
			options.isAttackEffect = true
		end
		options.skillId = self._skill:getId()
	end

	if effectID == nil then
		self:finished()
		return 
	end

	if self._options.is_range_effect == true then
		local is_zone_follow = self._skill:isZoneFollow()
		if is_zone_follow and self._target then
			options.targetPosition = self._target:getPosition()
		else
			options.targetPosition = self._director:getTargetPosition()
		end
	end

	if self._options.is_rotate_to_target == true then
		if self._target ~= nil then
			local targetPos = self._target:getPosition()
	        local height = self._target:getCoreRect().size.height
			options.rotateToPosition = ccp(targetPos.x, targetPos.y + height * 0.5)
		end
	end

	if self._options.except_attacker then
		table.removebyvalue(actors, self._attacker, true)
	end

	options.attacker = self._attacker
	options.attackee = self._attackee

	local delay = self._options.delay_per_hit or 0
	local delayTime = 0
	local delay_all = self._options.delay_all
    if delay > 0 and #actors > 1 then
		q.shuffleArray(actors)
		if delay_all then
        	delay = math.min(delay, delay_all / #actors)
        end
    end
	for _, actor in ipairs(actors) do
		if delay > 0 then
			app.battle:performWithDelay(function()
                if actor:isDead() == false then
                    actor:playSkillEffect(effectID, nil, options)
                end
            end, delayTime, self._attacker)
            delayTime = delayTime + delay
		else
			actor:playSkillEffect(effectID, nil, options)
		end
	end

	self:finished()
end

return QSBPlayEffect