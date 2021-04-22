--[[
    Class name QSBStopMove
    Create by mousecute
--]]
local QSBAction = import(".QSBAction")
local QSBStopMove = class("QSBStopMove", QSBAction)

function QSBStopMove:_execute(dt)
	app.grid:setActorTo(self._attacker, self._attacker:getPosition(), false, true)
	self._attacker:stopMoving()

	self:finished()
end

return QSBStopMove