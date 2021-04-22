local QSBAction = import(".QSBAction")
local QSBWaitSaveTreatClear = class("QSBWaitSaveTreatClear", QSBAction)

function QSBWaitSaveTreatClear:_execute(dt)
	local buff_id = self._options.buff_id
	local save_treat_buff
	for i,buff in ipairs(self._attacker:getBuffs()) do
		if buff:getId() == buff_id then
			save_treat_buff = buff
			break
		end
	end
	if save_treat_buff == nil or save_treat_buff:getSaveTreat() < 1 then
		self:finished()
	end
end

return QSBWaitSaveTreatClear