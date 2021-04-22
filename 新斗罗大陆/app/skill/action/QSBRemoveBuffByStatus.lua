local QSBAction = import(".QSBAction")
local QSBRemoveBuffByStatus = class("QSBRemoveBuffByStatus", QSBAction)

function QSBRemoveBuffByStatus:ctor(director, attacker, target, skill, options)
    QSBRemoveBuffByStatus.super.ctor(self, director, attacker, target, skill, options)
end

function QSBRemoveBuffByStatus:_execute(dt)
	local status = self._options.status
	local target = self._attacker
	target:removeBuffByStatus(status)
    self:finished()
end

return QSBRemoveBuffByStatus
