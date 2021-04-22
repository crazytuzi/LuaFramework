--[[
    Class name QSBTeleportToPosition
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBTeleportToPosition = class("QSBTeleportToPosition", QSBAction)

local QActor = import("...models.QActor")

function QSBTeleportToPosition:ctor(director, attacker, target, skill, options )
    QSBTeleportToPosition.super.ctor(self, director, attacker, target, skill, options)
    
    if options and options.is_random_pos == true then
    	local x = app.random(BATTLE_AREA.left, BATTLE_AREA.right)
    	local y = app.random(BATTLE_AREA.bottom, BATTLE_AREA.top)
    	self._dragPosition = {x = x, y = y}
    else
	    self._dragPosition = attacker:getDragPosition()
	end
end

function QSBTeleportToPosition:_execute(dt)
	if self._attacker ~= nil and not self._attacker:isCopyHero() then
		if self._attacker:CanControlMove() == false then
			self:finished()
			return
		end
		local targetPosition = self._dragPosition
		if targetPosition.x < BATTLE_AREA.left then targetPosition.x = BATTLE_AREA.left end
	    if targetPosition.x > BATTLE_AREA.right then targetPosition.x = BATTLE_AREA.right end
	    if targetPosition.y < BATTLE_AREA.bottom then targetPosition.y = BATTLE_AREA.bottom end
	    if targetPosition.y > BATTLE_AREA.top then targetPosition.y = BATTLE_AREA.top end
		app.grid:setActorTo(self._attacker, targetPosition, true)
	end
	self:finished()
end

return QSBTeleportToPosition
