--[[
    Class name QSBTeleportToAbsolutePosition
    Create by wanghai 
--]]
local QSBAction = import(".QSBAction")
local QSBTeleportToAbsolutePosition = class("QSBTeleportToAbsolutePosition", QSBAction)

local QActor = import("...models.QActor")

function QSBTeleportToAbsolutePosition:_execute(dt)
	local actor = self._attacker
	if actor:CanControlMove() == false then
		self:finished()
		return
	end
	local pos = self._options.pos
	if nil ~= pos then
		app.grid:setActorTo(actor, pos, true)
	end

	self:finished()
end

return QSBTeleportToAbsolutePosition