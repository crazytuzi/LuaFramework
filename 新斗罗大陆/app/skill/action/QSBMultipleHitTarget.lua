-- @Author: xurui
-- @Date:   2018-05-07 20:24:46
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-05-08 15:28:51
local QSBAction = import(".QSBAction")
local QSBMultipleHitTarget = class("QSBMultipleHitTarget", QSBAction)

function QSBMultipleHitTarget:ctor(director, attacker, target, skill, options)
    QSBMultipleHitTarget.super.ctor(self, director, attacker, target, skill, options)
    self._intervalTime = self._options.interval_time or 0
    self._currentIndex = 1
	self._hitCount = self._options.hit_count or 1
end

function QSBMultipleHitTarget:_execute(dt)
    if self._startTime == nil then
        self._startTime = app.battle:getTime()
        self._currentTime = self._startTime
        self._lastTriggerTime = self._startTime
    else
        self._currentTime = self._currentTime + dt
    end

	self._skill._range_type = "single"
    if self._currentTime - self._lastTriggerTime >= self._intervalTime then
        if self._currentIndex <= self._hitCount then
			local candidates = self:getCandidates()
			local candidateNum = #candidates
			local index = app.random(1, candidateNum)
        	local targets = {candidates[index]}
			self._attacker:onHit(self._skill, candidates[index])

            table.remove(candidates, index)
            self._currentIndex = self._currentIndex + 1
		end
    	self._lastTriggerTime = self._lastTriggerTime + self._intervalTime
	end

    if self._currentIndex > self._hitCount then
        self:finished()
    end
end

function QSBMultipleHitTarget:getCandidates()
	local range_min = 0
	local range_max = 9999
	if self._options.range then
		local min = self._options.range.min
		if min then
			range_min = min
		end
		local max = self._options.range.max
		if max then
			range_max = max
		end
	end
	range_min = range_min * range_min * global.pixel_per_unit * global.pixel_per_unit
	range_max = range_max * range_max * global.pixel_per_unit * global.pixel_per_unit

    if self._candidates == nil or #self._candidates == 0 then
        self._candidates = {}
        local actor = self._attacker
        local enemies = app.battle:getMyEnemies(actor)
        for _, enemy in ipairs(enemies) do
            if not enemy:isDead() and not enemy:isSupport() then
	            local x = enemy:getPosition().x - actor:getPosition().x
	            local y = enemy:getPosition().y - actor:getPosition().y
	            local d = x * x + y * y * 4

	            if d <= range_max and d >= range_min then
            		local index = app.random(1, #self._candidates)
            		table.insert(self._candidates, index, enemy)
            	end
            end
        end
    end

    return self._candidates
end

return QSBMultipleHitTarget
