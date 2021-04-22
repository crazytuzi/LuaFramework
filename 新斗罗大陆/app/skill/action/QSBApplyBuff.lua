--[[
    Class name QSBApplyBuff
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBApplyBuff = class("QSBApplyBuff", QSBAction)

function QSBApplyBuff:_checkBuffid(buffid)
	local id, level = q.parseIDAndLevel(buffid, 1, self._skill)
	local buffInfo = db:getBuffByID(id)
    if buffInfo == nil then
        printError("buff id: %s does not exist!", buffid)
        return false
    else
    	return true
    end
end

function QSBApplyBuff:_execute(dt)
	local actor = self._attacker
	local actors = nil
	if self._options.check_selectTarget and self._options.selectTarget == nil then
		self:finished()
		return
	end
	if self._options.is_target == true then
		actor = self._target
	elseif self._options.last_attacker == true then
		local candidate = self._attacker:getLastAttacker()
		if nil == candidate or candidate:isDead() then
			self:finished()
			return
		end
		actor = candidate
	elseif self._options.lowest_hp_teammate or self._options.lowest_hp_teammate_and_self then
		local mates = app.battle:getMyTeammates(actor,
			self._options.lowest_hp_teammate_and_self,
			self._options.just_hero)
		local candidate = q.max(mates, 
			function(actor) 
				if actor:isDead() then
					return 999999
				else
					return actor:getHp() / actor:getMaxHp()
				end
			end,
			function(d1, d2)
				if d1 == nil and d2 ~= 999999 then
					return true
				end
				return (d1 == nil and d2 ~= 999999) or (d1 ~= nil and d2 < d1)
			end)
		if self._options.lowest_hp_teammate_and_self and (candidate == nil or candidate:getHp() / actor:getMaxHp() == 1.0) then
			candidate = actor
		end
		actor = candidate
    elseif self._options.lowest_hp_enemies then
		local mates = app.battle:getMyEnemies(actor)
		local candidate = q.max(mates, 
			function(actor) 
				if actor:isDead() then
					return 999999
				else
					return actor:getHp() / actor:getMaxHp()
				end
			end,
			function(d1, d2)
				if d1 == nil and d2 ~= 999999 then
					return true
				end
				return (d1 == nil and d2 ~= 999999) or (d1 ~= nil and d2 < d1)
			end)
		if candidate == nil or candidate:getHp() / actor:getMaxHp() == 1.0 then
			candidate = actor
		end
		actor = candidate
	elseif self._options.random_enemy then
		actors = app.battle:getMyEnemies(actor, false)
        actor = actors[app.random(1, #actors)]
		actors = nil
	elseif self._options.teammate_and_self then
		actors = app.battle:getMyTeammates(actor, true)
	elseif self._options.teammate then
		actors = app.battle:getMyTeammates(actor, false)
	elseif self._options.enemy then
		actors = app.battle:getMyEnemies(actor, false)
	elseif self._options.all_enemy then
		actors = app.battle:getAllMyEnemies(actor)
	elseif self._options.multiple_target_with_skill then
		if self._skill:getRangeType() == self._skill.MULTIPLE then
			actors = self._attacker:getMultipleTargetWithSkill(self._skill)
		end
	elseif self._options.selectTargets then
		actors = self._options.selectTargets
	elseif self._options.attacker_target then
		actor = self._attacker:getTarget()
	elseif self._options.highest_rage_enemy then
		local enemies = app.battle:getMyEnemies(self._attacker)
		local targets = {}
		local prior_targets = {}
		for _, enemy in ipairs(enemies) do
            if not enemy:isSupport() then
				if self._options.prior_role == enemy:getTalentFunc() then
					table.insert(prior_targets, enemy)
				else
					table.insert(targets, enemy)
				end
            end
        end
		if #prior_targets > 0 then
			targets = prior_targets
		end
		table.sort(targets, function(e1, e2) return (e1:getRage() or 0) > (e2:getRage() or 0) end)
		actor = targets[1]
	--找到攻击最高的队友,可配优先职业
	elseif self._options.highest_attack_teammate then
		local teammates = app.battle:getMyTeammates(actor, false)
		local targets = {}
		local prior_targets = {}
		for _, teammate in ipairs(teammates) do
            if not teammate:isSupport() then
				if self._options.prior_role == teammate:getTalentFunc() then
					table.insert(prior_targets, teammate)
				else
					table.insert(targets, teammate)
				end
            end
        end
		if #prior_targets > 0 then
			targets = prior_targets
		end
		table.sort(targets, function(e1, e2) return (e1:getAttack() or 0) > (e2:getAttack() or 0) end)
		actor = targets[1]
	elseif self._options.highest_attack_teammate_and_self then
		local teammates = app.battle:getMyTeammates(actor, true)
		local targets = {}
		local prior_targets = {}
		for _, teammate in ipairs(teammates) do
            if not teammate:isSupport() then
				if self._options.prior_role == teammate:getTalentFunc() then
					table.insert(prior_targets, teammate)
				else
					table.insert(targets, teammate)
				end
            end
        end
		if #prior_targets > 0 then
			targets = prior_targets
		end
		table.sort(targets, function(e1, e2) return (e1:getAttack() or 0) > (e2:getAttack() or 0) end)
		actor = targets[1]
	elseif self._options.selectTarget then
		actor = self._options.selectTarget
	end

	local probability = self._options.probability or 1

	if actors ~= nil and self._options.buff_id ~= nil then
		if type(self._options.buff_id) == "table" then
			for _, actor in pairs(actors) do
				if app.random() < probability then
					for k,buffid in pairs(self._options.buff_id) do
						if self:_checkBuffid(buffid) then
							actor:applyBuff(buffid, self._attacker, self._skill)
						end
					end
				end
			end
		else
			if self:_checkBuffid(self._options.buff_id) then
				for _, actor in pairs(actors) do
					if app.random() < probability then
						actor:applyBuff(self._options.buff_id, self._attacker, self._skill)
					end
				end
			end
		end
	elseif actor ~= nil and self._options.buff_id ~= nil then
		if type(self._options.buff_id) == "table" then
			for k,buffid in pairs(self._options.buff_id) do
				if self:_checkBuffid(buffid) then
					if app.random() < probability then
						actor:applyBuff(buffid, self._attacker, self._skill)
				    	if not self._options.no_cancel then
				    		self._director:addBuffId(buffid, actor) 
				    	end
				    end
				end
			end
		else
			if self:_checkBuffid(self._options.buff_id) then
				if app.random() < probability then
					actor:applyBuff(self._options.buff_id, self._attacker, self._skill)
			    	if not self._options.no_cancel then
			    		self._director:addBuffId(self._options.buff_id, actor) 
			    	end
			    end
			end
		end
	end
	self:finished()
end

return QSBApplyBuff
