local QSBAction = import(".QSBAction")
local QSBPauseCooldown = class("QSBPauseCooldown", QSBAction)

function QSBPauseCooldown:_execute(dt)
	if self._options.resume then
		self._skill:resumeCoolDown(true)
	else
		self._skill:pauseCoolDown(true)
	end
	self:finished()
end

function QSBPauseCooldown:_onCancel()
	self:_onRevert()
end

function QSBPauseCooldown:_onRevert()
	self._skill:resumeCoolDown(true)
end

return QSBPauseCooldown