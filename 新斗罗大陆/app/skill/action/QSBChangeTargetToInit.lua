local QSBAction = import(".QSBAction")
local QSBChangeTargetToInit = class("QSBChangeTargetToInit", QSBAction)

function QSBChangeTargetToInit:_execute(dt)
	self._attacker:setTarget(self._director:getInitTarget())
	self:finished()
end

return QSBChangeTargetToInit