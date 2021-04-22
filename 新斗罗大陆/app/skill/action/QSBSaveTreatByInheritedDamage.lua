local QSBAction = import(".QSBAction")
local QSBSaveTreatByInheritedDamage = class("QSBSaveTreatByInheritedDamage", QSBAction)

function QSBSaveTreatByInheritedDamage:_execute(dt)
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
		buff:saveTreat(inherited_damage)
	end
    self:finished()
end

return QSBSaveTreatByInheritedDamage