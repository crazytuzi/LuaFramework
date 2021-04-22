--[[
    Class name QSBTeleportToTargetPos
    Create by wanghai
--]]
local QSBAction = import(".QSBAction")
local QSBTeleportToTargetPos = class("QSBTeleportToTargetPos", QSBAction)

function QSBTeleportToTargetPos:_execute(dt)
	local target = nil
	if self._options.is_attackee == true then
		target = self._target
	else
		target = self._attacker:getTarget()
	end
	if nil == target or target:isDead() then
		self:finished()
		return
	end

	if self._attacker:CanControlMove() == false then
		self:finished()
		return
	end
	
	if self._attacker ~= nil and target ~= nil and self._attacker:isDead() == false and target:isDead() == false then
		self._options.pos = self._attacker:getPosition()
		local pos = clone(target:getPosition())
		app.grid:setActorTo(self._attacker, pos, true, true)
	end

	self:finished()
end

function QSBTeleportToTargetPos:_onRevert()
	if self._options.pos then
		app.grid:setActorTo(self._attacker, self._options.pos, true)
	end
end

return QSBTeleportToTargetPos
