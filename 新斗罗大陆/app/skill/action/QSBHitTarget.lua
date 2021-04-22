--[[
    Class name QSBHitTarget
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBHitTarget = class("QSBHitTarget", QSBAction)

local QActor = import("...models.QActor")

function QSBHitTarget:_execute(dt)
	local is_choose_target = self._options.is_auto_choose_target == nil and true or false
	if self._attacker:isRanged() and is_choose_target then
    	self._director:chooseTarget()
	end

	local skill = self._skill
	local target = self._options.selectTarget or self._target
    local ignoreAbsorbPercent = self._options.ignore_absorb_percent or 0

	if self._options.is_current_target then
		target = self._attacker:getTarget()
    elseif self._options.is_self then
        target = self._attacker
	elseif self._options.target_teammate_lowest_hp_percent then
        local actors = app.battle:getMyTeammates(self._attacker, true)
        if #actors > 0 then
            table.sort(actors, function(actor1, actor2)
                local hppercent1 = actor1:getHp() / actor1:getMaxHp()
                local hppercent2 = actor2:getHp() / actor2:getMaxHp()
                if hppercent1 > hppercent2 then
                    return false
                elseif hppercent1 < hppercent2 then
                    return true
                else
                    return tonumber(actor1:getActorID()) > tonumber(actor2:getActorID())
                end
            end)
            target = actors[1]
        else
            self:finished()
            return
        end
    elseif self._options.target_enemy_lowest_hp_percent then
    	local actors = app.battle:getMyEnemies(self._attacker)
    	if #actors > 0 then
    		table.sort(actors, function(actor1, actor2)
                local hppercent1 = actor1:getHp() / actor1:getMaxHp()
                local hppercent2 = actor2:getHp() / actor2:getMaxHp()
                if hppercent1 > hppercent2 then
                    return false
                elseif hppercent1 < hppercent2 then
                    return true
                else
                    return tonumber(actor1:getActorID()) > tonumber(actor2:getActorID())
                end
            end)
            target = actors[1]
    	else
    		self:finished()
            return
    	end
    end

    if self._options.check_target_by_skill then
        local skill_type = skill:getAttackType()
        local hero = self._attacker
        if skill_type == skill.TREAT then
            local need_change = false
            if target == nil then
                need_change = true
            else
                if hero:getType() == ACTOR_TYPES.NPC then
                    need_change = target:getType() ~= ACTOR_TYPES.NPC
                else
                    need_change = target:getType() == ACTOR_TYPES.NPC
                end
            end
            if need_change then
                local actors = app.battle:getMyTeammates(hero, true)
                local len = #actors
                if len > 0 then
                    target = actors[app.random(1, len)]
                end
            end
        else
            local need_change = false
            if target == nil then
                need_change = true
            else
                if hero:getType() == ACTOR_TYPES.NPC then
                    need_change = target:getType() == ACTOR_TYPES.NPC
                else
                    need_change = target:getType() ~= ACTOR_TYPES.NPC
                end
            end
            if need_change then
                local actors = app.battle:getMyEnemies(hero)
                local len = #actors
                if len > 0 then
                    target = actors[app.random(1, len)]
                end
            end
        end
    end

    if self._options.property_promotion then
        for k,v in pairs(self._options.property_promotion) do
            self._skill:addPropertyPromotion(k,v)
        end
    end

    local ret, sameStatusBuffCount = 0, 0
    if self._options.multiple_hit_by_status then
        if nil ~= target then
            ret, sameStatusBuffCount = target:isUnderStatus(self._options.multiple_hit_by_status, true)
        end
    end
    if sameStatusBuffCount == 0 then sameStatusBuffCount = 1 end

    local multiple_scale = self._options.multiple_area_scale
    local damage_scale = self._options.damage_scale or 1.0
    damage_scale = damage_scale * self:getDragonModifier()

	if skill:getRangeType() == skill.MULTIPLE and skill:getZoneSpeed() > 0 then
		if not self._spreadPercent then
			self._spreadPercent = 0
			self._spreadActors = {}
		end
		local speed = skill:getZoneSpeed()
		local percent = self._spreadPercent
		local actors = self._spreadActors

        local real_scale = percent * (multiple_scale or 1)

		percent = math.min(1.0, speed * dt + percent)
		if percent > 0 then
			if self._options.is_range_hit == true then
				local is_zone_follow = self._skill:isZoneFollow()
				if is_zone_follow and target then
					self._attacker:onHit(self._skill, target, target:getPosition(), self._options.delay_per_hit, real_scale, actors, self._options.delay_all, damage_scale, ignoreAbsorbPercent)
				else
					self._attacker:onHit(self._skill, target, self._director:getTargetPosition(), self._options.delay_per_hit, real_scale, actors, self._options.delay_all, damage_scale, ignoreAbsorbPercent)
				end
			else
				self._attacker:onHit(self._skill, target, nil, self._options.delay_per_hit, real_scale, actors, self._options.delay_all, damage_scale, ignoreAbsorbPercent)
			end
		end

		if percent == 1.0 then
			self:finished()
		else
			self._spreadPercent = percent
		end
	else
		if self._options.is_range_hit == true then
			local is_zone_follow = self._skill:isZoneFollow()
			if is_zone_follow and target then
				self._attacker:onHit(self._skill, target, target:getPosition(), self._options.delay_per_hit, multiple_scale, nil, self._options.delay_all, damage_scale, ignoreAbsorbPercent)
			else
				self._attacker:onHit(self._skill, target, self._director:getTargetPosition(), self._options.delay_per_hit, multiple_scale, nil, self._options.delay_all, damage_scale, ignoreAbsorbPercent)
			end
		else
            for i = 1, sameStatusBuffCount do
    			self._attacker:onHit(self._skill, target, nil, self._options.delay_per_hit, multiple_scale, nil, self._options.delay_all, damage_scale, ignoreAbsorbPercent)
            end
		end
		self:finished()
	end

    if self._options.property_promotion then
        self._skill:removePropertyPromotion()
    end
end

return QSBHitTarget