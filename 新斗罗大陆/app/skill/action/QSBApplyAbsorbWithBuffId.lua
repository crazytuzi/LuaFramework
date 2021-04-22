local QSBAction = import(".QSBAction")
local QSBApplyAbsorbWithBuffId = class("QSBApplyAbsorbWithBuffId", QSBAction)

function QSBApplyAbsorbWithBuffId:_execute(dt)
	local actor = self._attacker
	local buff_id = self._options.buff_id
	local absorb_buff_id = self._options.absorb_buff_id
	local base_percent = self._options.base_percent or 0
	local coefficient = self._options.coefficient or 0
	local num = 0
	local check_targets = {actor}
	if self._options.check_enemy then
		check_targets = app.battle:getMyEnemies(self._attacker)
	end
	for _, target in ipairs(check_targets) do
		for i,buff in ipairs(target:getBuffs()) do
			if buff:getId() == buff_id and buff:isImmuned() ~= true then
				num = num + 1
			end
		end
	end
	local absorb_value = base_percent + coefficient * num
	local hp_value = actor:getMaxHp() * absorb_value
	local newbuff = actor:applyBuff(absorb_buff_id, self._attacker, self._skill)
	if newbuff then
		newbuff._isAbsorbDamage = true
		local old_value = newbuff:getAbsorbDamageValue()
		hp_value = newbuff:setAbsorbDamageValue(old_value + hp_value, true)
		actor:dispatchAbsorbChangeEvent(hp_value - old_value)
	end
	self:finished()
end

return QSBApplyAbsorbWithBuffId