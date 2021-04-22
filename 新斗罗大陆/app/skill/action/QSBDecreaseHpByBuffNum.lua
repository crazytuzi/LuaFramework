local QSBAction = import(".QSBAction")
local QSBDecreaseHpByBuffNum = class("QSBDecreaseHpByBuffNum", QSBAction)

function QSBDecreaseHpByBuffNum:_execute(dt)
	local actor = self._target
	local buff_id = self._options.buff_id
	local base_percent = self._options.base_percent or 0
	local coefficient = self._options.coefficient or 0
	local num = 0

	if not self:isDeflection(self._attacker, actor) then
		for i,buff in ipairs(actor:getBuffs()) do
			if buff:getId() == buff_id and buff:isImmuned() ~= true then
				num = num + 1
			end
		end
		local hp_percent = base_percent + coefficient * num
		local hp_value = actor:getMaxHp() * hp_percent
		hp_value = hp_value * self:getDragonModifier()
		actor:decreaseHp(hp_value, self._attacker, self._skill, false, false, self._options.ignore_absorb)
	end
	self:finished()
end

return QSBDecreaseHpByBuffNum