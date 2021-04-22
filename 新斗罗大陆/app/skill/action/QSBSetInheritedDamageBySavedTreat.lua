local QSBAction = import(".QSBAction")
local QSBSetInheritedDamageBySavedTreat = class("QSBSetInheritedDamageBySavedTreat", QSBAction)

function QSBSetInheritedDamageBySavedTreat:_execute(dt)
	local save_treat_buff = self._options.buff_id
	local inherited_damage = self._skill:getInHeritedDamage()
	local limite_attack_percent = self._options.limite_attack_percent
	local treat_left = 0
	local buff 
	for i,v in ipairs(self._attacker:getBuffs()) do
		if v:getId() == save_treat_buff then
			treat_left = v:getSaveTreat()
			buff = v
			break
		end
	end
	if buff then
		if limite_attack_percent then
			inherited_damage = math.min(limite_attack_percent * self._attacker:getAttack(), inherited_damage)
		end
		if self._skill:getRangeType() == self._skill.MULTIPLE and self._options.reduce_truely_damage then
			local target_num = #(self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition()))
			inherited_damage = math.min(inherited_damage * target_num, treat_left)/target_num
			buff:reduceSaveTreat(inherited_damage * target_num)
		else
			inherited_damage = math.min(inherited_damage, treat_left)
			buff:reduceSaveTreat(inherited_damage)
		end
		self._skill:setInheritedDamage(inherited_damage)
	else
		self._skill:setInheritedDamage(0)
	end
	self._skill._ignore_save_treat = true
    self:finished()
end

return QSBSetInheritedDamageBySavedTreat