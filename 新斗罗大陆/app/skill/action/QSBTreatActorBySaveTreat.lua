local QSBAction = import(".QSBAction")
local QSBTreatActorBySaveTreat = class("QSBTreatActorBySaveTreat", QSBAction)
local QActor = import("...models.QActor")

function QSBTreatActorBySaveTreat:_execute(dt)
	local target_type = self._options.target_type or "skill_target"
	local percent = self._options.percent or 0
	local treat_lowest = self._options.treat_lowest or 0
	local target = nil
	if target_type == "hp_lowest" then
		local teammates = app.battle:getMyTeammates(self._attacker, true)
		table.insert(teammates, target_as_candidate)
		table.sort(teammates, function(e1, e2)
			local d1 = e1:getHp() / e1:getMaxHp()
			local d2 = e2:getHp() / e2:getMaxHp()
			if d1 ~= d2 then
				return d1 < d2
			else
				return e1:getUUID() < e2:getUUID()
			end
		end)
		target = teammates[1]
	elseif target_type == "skill_target" then
		target = self._target
	end

	if target then
		local treat_value = 0
		for k,buff in ipairs(self._attacker:getBuffs()) do
			if buff:isSaveTreat() then
				local save_value = buff:getSaveTreat()
				local _treat_value = math.clamp(save_value * percent, treat_lowest, save_value)
				buff:reduceSaveTreat(_treat_value)
				treat_value = treat_value + _treat_value
			end
		end

		if treat_value > 0 then
			local _, dHp = target:increaseHp(treat_value, self._attacker, self._skill)
			if dHp > 0 then
		        target:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, 
	                isCritical = false, tip = "", rawTip = {
	                    isHero = target:getType() == ACTOR_TYPES.HERO, 
	                    isCritical = false, 
	                    isTreat = true,
	                    number = dHp,
	                }})
		    end
		end
	end

end

return QSBTreatActorBySaveTreat