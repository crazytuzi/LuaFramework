--[[
    Class name QSBTeleportToCastPosition
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBTeleportToCastPosition = class("QSBTeleportToCastPosition", QSBAction)

local QActor = import("...models.QActor")

function QSBTeleportToCastPosition:_execute(dt)
	local actor = self._attacker
	local pos = self._director:getCastPosition()
	if actor:CanControlMove() == false then
		self:finished()
		return
	end
	app.grid:setActorTo(actor, pos, true)

	self:finished()
end

return QSBTeleportToCastPosition