local QSBAction = import(".QSBAction")
local QSBSetHpPercent = class("QSBSetHpPercent", QSBAction)

function QSBSetHpPercent:_execute(dt)
	local hp_percent = self._options.hp_percent
	self._attacker:setHp(self._attacker:getMaxHp() * hp_percent)
	self:finished()
end

return QSBSetHpPercent