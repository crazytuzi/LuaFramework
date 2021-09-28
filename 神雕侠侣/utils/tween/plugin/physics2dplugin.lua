--[[
	how to use:
	TweenNano.to(TweenTarget:new(self.m_pDownView, TweenTarget.Window),
										20, {ease = {type=Linear.type},
									 	plugin = Physics2dPlugin.type, value={velocity=600, angle=260, gravity=400, friction=0}})
	
]]
local DEG2RAD = math.pi / 180
---------------------------------------------
local Physics2dProp = {}
Physics2dProp.__index = Physics2dProp

function Physics2dProp:new(start, velocity, acceleration, stepsPerTimeUnit)
	local self = {}
	setmetatable(self, Physics2dProp)
	self.__index = self

	function init()
		self.start = start
		self.value = start
		self.velocity = velocity
		self.v = self.velocity / stepsPerTimeUnit
		if acceleration then
			self.acceleration = acceleration
			self.a = self.acceleration / (stepsPerTimeUnit * stepsPerTimeUnit)
		else
			self.acceleration = 0
			self.a = 0
		end
	end

	init()
	return self
end
---------------------------------------------

Physics2dPlugin = {}
Physics2dPlugin.__index = Physics2dPlugin

Physics2dPlugin.type = "Physics2dPlugin"

function Physics2dPlugin:new()
	local self = {}
	setmetatable(self, Physics2dPlugin)
	self.__index = self
	return self
end

function Physics2dPlugin:initTween(target, value, tween)
	self.target = target
	self.value = value
	self.tween = tween
	self.step = 0
	self.stepsPerTimeUnit = 30

	local angle = value.angle or 0
	local velocity = value.velocity or 0
	local acceleration = value.acceleration or 0

	local aAngle
	if value.accelerationAngle then
		aAngle = value.accelerationAngle 
	else 
		aAngle = angle
	end

	if value.gravity then
		acceleration = value.gravity
		aAngle = 90
	end

	angle = angle * DEG2RAD
	aAngle = aAngle * DEG2RAD

	if value.friction then
		self.friction = 1 - value.friction
	end
	self.x = Physics2dProp:new(target:getX(), math.cos(angle) * velocity, math.cos(aAngle) * acceleration, self.stepsPerTimeUnit)
	self.y = Physics2dProp:new(target:getY(), math.sin(angle) * velocity, math.sin(aAngle) * acceleration, self.stepsPerTimeUnit)

	return true
end

function Physics2dPlugin:SetChangeFactor(n)
	local time = self.tween.cachedTime * 0.001
	local x = 1
	local y = 1
	if self.friction == 1 then
		local tt = time * time * 0.5
		x = self.x.start + ((self.x.velocity * time) + (self.x.acceleration * tt))
		y = self.y.start + ((self.y.velocity * time) + (self.y.acceleration * tt))

	else
		local steps = math.floor(time * self.stepsPerTimeUnit) - self.step
		local remainder = (time * self.stepsPerTimeUnit) % 1
		local j
		if steps > 0 then 
			j = steps
			while j > 0 do
				self.x.v = self.x.v + self.x.a
				self.y.v = self.y.v + self.y.a
				self.x.v = self.x.v * self.friction
				self.y.v = self.y.v * self.friction
				self.x.value = self.x.value + self.x.v
				self.y.value = self.y.value + self.y.v

				j = j - 1
			end
		else
			j = steps * (-1)
			while j > 0 do
				self.x.value = self.x.value - self.x.v
				self.y.value = self.y.value - self.y.v
				self.x.v = self.x.v / self.friction
				self.y.v = self.y.v / self.friction
				self.x.v = self.x.v - self.x.a
				self.y.v = self.y.v - self.y.a

				j = j - 1
			end
		end
		x = self.x.value + (self.x.v * remainder)
		y = self.y.value + (self.y.v * remainder)

		self.step = self.step + steps
	end
	self.target:setX(x)
	self.target:setY(y)
end