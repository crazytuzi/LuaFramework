local QSBAction = import(".QSBAction")
local QSBRoledirection = class("QSBRoledirection", QSBAction)

local QActor = import("...models.QActor")

function QSBRoledirection:_execute(dt)
	local direction = self._options.direction
	local actor = self._attacker
	if nil == actor then
		self:finished()
		return
	end
	if direction == "left" then
		actor:setDirection(QActor.DIRECTION_LEFT)
	elseif direction == "right" then
		actor:setDirection(QActor.DIRECTION_RIGHT)
	elseif direction == "target" then
		local target = actor:getTarget()
		if target then
			self:_relativeDirectrion(target, actor)
		end
	elseif direction == "skill_target" then
		local target = self._target
		if target then
			self:_relativeDirectrion(target, actor)
		end
	end
	self:finished()
end

function QSBRoledirection:_relativeDirectrion(target, actor)
	local actorPos = actor:getPosition()
	local targetPos = target:getPosition()
	if (targetPos.x - actorPos.x) > 0 then
		actor:setDirection(self:_getBackTo(QActor.DIRECTION_RIGHT))
    else
        actor:setDirection(self:_getBackTo(QActor.DIRECTION_LEFT))
	end
end

function QSBRoledirection:_getBackTo(direction)
	if self._options.back_to then
		if direction == QActor.DIRECTION_RIGHT then
			return QActor.DIRECTION_LEFT
		else
			return QActor.DIRECTION_RIGHT
		end
	end

	return direction
end

return QSBRoledirection
