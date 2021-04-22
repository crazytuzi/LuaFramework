local QUFO = class("QUFO", {})

local QActor = import(".QActor")

function QUFO:ctor(params)
	-- init with params
	--[[
		params = {
			required attacker,
			required attackee,
			optional speed,
		}
	]]
	self:_initWithParams(params)
end

function QUFO:_initWithParams(params)
	self._attacker = params.attacker
	self._attackee = params.attackee
	self._speed = params.speed or 350
	self._effectId = params.effectId
	self._hitEffectId = params.hitEffectId
	self._pos = clone(self._attacker:getCenterPosition())
	self._adjPos = clone(self._attacker:getCenterPosition())
	self._direction = 1
	self._phase = 0
	self._ended = false
	self._finished = false
	self._time = 0
end

function QUFO:_updatePositionAndDirection(dt)
	if self._finished then
		self._ended = true
		return
	end
	local target = self._phase == 0 and self._attackee or self._attacker
	local pos = self._pos
	local targetPos = target:getCenterPosition()
	local dx = targetPos.x - pos.x
	local dy = targetPos.y - pos.y
	local dist = math.sqrt(dx * dx + dy * dy)
	local leap = dt * self._speed
	if leap >= dist then
		self._pos = {x = targetPos.x, y = targetPos.y}
		if self._phase == 0 then
            if self._hitEffectId then
            	target:playSkillEffect(self._hitEffectId, nil, {})
            end
			self._phase = 1
		elseif self._phase == 1 then
			self._finished = true
		end
	else
		self._pos = {x = pos.x + dx * (leap / dist), y = pos.y + dy * (leap / dist)}
	end
	if dx ~= 0 then
		self._direction = dx / math.abs(dx)
	end

	-- 正弦扰动
	self._time = self._time + dt
	local amp = math.sin(self._time / 1.0 * (math.pi * 2)) * 75
	local rad = math.atan2(dy, dx) + (math.pi / 2)
	self._adjPos.x = self._pos.x + math.cos(rad) * amp
	self._adjPos.y = self._pos.y + math.sin(rad) * amp
end

function QUFO:getEffectId()
	return self._effectId
end

function QUFO:getHitEffectId()
	return self._hitEffectId
end

function QUFO:visit(dt)
	if self._ended then
		return
	end
	self:_updatePositionAndDirection(dt)
	self:_callDelegate("setPosition", self._adjPos.x, self._adjPos.y)
	self:_callDelegate("setDirection", self._direction)
end

function QUFO:isEnded()
	return self._ended
end

function QUFO:forceEnd()
	self:_callDelegate("release")
	self._viewDelegate = nil
	self._ended = true
end

function QUFO:release()
	if self._ended then
		self:_callDelegate("release")
		self._viewDelegate = nil
	end
end

function QUFO:playAnimation()
	self:_callDelegate("playAnimation")
end




--[[
	ViewDelegate must implemente
	setPosition(x, y)
	setDirection(direction)
	release()
]]

function QUFO:setViewDelegate(viewDelegate)
	self._viewDelegate = viewDelegate
end

function QUFO:_callDelegate(funcName, ...)
	if self._viewDelegate then
		local viewDelegate = self._viewDelegate
		local func = viewDelegate[funcName]
		if func then
			func(viewDelegate, ...)
		end
	end
end

return QUFO