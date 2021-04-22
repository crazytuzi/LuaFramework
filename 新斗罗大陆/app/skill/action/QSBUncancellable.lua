
local QSBAction = import(".QSBAction")
local QSBUncancellable = class("QSBUncancellable", QSBAction)

function QSBUncancellable:_execute(dt)
	self._director:setUncancellable(true)

	self:finished()
end

return QSBUncancellable