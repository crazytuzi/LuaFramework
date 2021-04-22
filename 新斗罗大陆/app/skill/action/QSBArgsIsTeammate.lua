local QSBNode = import("..QSBNode")
local QActor = import("..models.QActor")
local QSBArgsIsTeammate = class("QSBArgsIsTeammate", QSBNode)

function QSBArgsIsTeammate:_execute(dt)    
    local target = self._target
	local reverse_result = self:getOptions().reverse_result or false
	if target == nil then
		self:finished({select = reverse_result})
		return
	end
    for k,v in pairs(app.battle:getMyTeammates(self._attacker,true)) do
		if v == target then
			self:finished({select = not reverse_result})
			return
		end
	end
    self:finished({select = reverse_result})
end

return QSBArgsIsTeammate