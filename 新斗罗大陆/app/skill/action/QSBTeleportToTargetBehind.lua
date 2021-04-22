--[[
    Class name QSBTeleportToTargetBehind
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBTeleportToTargetBehind = class("QSBTeleportToTargetBehind", QSBAction)

--[[
	delta_pos 						位移后的偏移量
--]]

function QSBTeleportToTargetBehind:_execute(dt)
	local target = self._attacker:getTarget()
	if self._attacker ~= nil and target ~= nil and self._attacker:isDead() == false and target:isDead() == false then
		if self._attacker:CanControlMove() == false then
			self:finished()
			return
		end
		local pos = clone(target:getPosition())
	    local distance = (self._attacker:getRect().size.width + target:getRect().size.width) / 2
		if target:getDirection() == target.DIRECTION_RIGHT then
			pos.x = pos.x - distance
			if self._options.delta_pos then
				pos.x = pos.x - self._options.delta_pos.x
				pos.y = poa.y - self._options.delta_pos.y
			end
		else
			pos.x = pos.x + distance
			if self._options.delta_pos then
				pos.x = pos.x + self._options.delta_pos.x
				pos.y = poa.y + self._options.delta_pos.y
			end
		end

		app.grid:setActorTo(self._attacker, pos, true)

		if self._options.verify_flip then
			self._attacker:_verifyFlip()
		end
	end
	self:finished()
end

return QSBTeleportToTargetBehind
