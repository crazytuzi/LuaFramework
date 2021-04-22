--[[
    Class name QSBAttackFinish
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBAttackFinish = class("QSBAttackFinish", QSBAction)

local QBattleManager = import("...controllers.QBattleManager")

function QSBAttackFinish:_execute(dt)
	if self._attacker ~= nil and not self._director._is_triggered then
		self._attacker:onAttackFinished(false, self._skill)
	end
	self:finished()
end

return QSBAttackFinish