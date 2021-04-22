--[[
    Class name QSBSelectTarget
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBSelectTarget = class("QSBSelectTarget", QSBAction)

function QSBSelectTarget:_execute(dt)
	if self._executed then
		return
	end
	self._executed = true

	local actor = self._attacker

	if not self._options.always and actor:getTarget() then
		self:finished()
		return
	end

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

	local target = actor:getTarget()
	local enemies = app.battle:getMyEnemies(actor)
	local candidates = {}
	local target_as_candidate = nil
	for _, enemy in ipairs(enemies) do
        if not enemy:isDead() and not enemy:isSupport() then
            local x = enemy:getPosition().x - actor:getPosition().x
            local y = enemy:getPosition().y - actor:getPosition().y
            local d = x * x + y * y * 4
            if d <= range_max and d >= range_min then
            	if enemy == target then
            		target_as_candidate = enemy
            	else
            		table.insert(candidates, enemy)
            	end
            end
        end
	end 

	if self._options.furthest then
		table.insert(candidates, target_as_candidate)
		table.sort(candidates, function(e1, e2)
			local d1 = q.distOf2PointsSquare(actor:getPosition(), e1:getPosition())
			local d2 = q.distOf2PointsSquare(actor:getPosition(), e2:getPosition())
			if d1 ~= d2 then
				return d1 > d2
			else
				return e1:getUUID() < e2:getUUID()
			end
		end)
		candidates = {candidates[1]}
	elseif self._options.lowest_hp then
		table.insert(candidates, target_as_candidate)
		table.sort(candidates, function(e1, e2)
			local d1 = e1:getHp() / e1:getMaxHp()
			local d2 = e2:getHp() / e2:getMaxHp()
			if d1 ~= d2 then
				return d1 < d2
			else
				return e1:getUUID() < e2:getUUID()
			end
		end)
		candidates = {candidates[1]}
	elseif self._options.max_haste_coefficient then
		table.insert(candidates, target_as_candidate)
		table.sort(candidates, function(e1, e2)
			local d1 = e1:getMaxHasteCoefficient()
			local d2 = e2:getMaxHasteCoefficient()
			if d1 ~= d2 then
				return d1 < d2
			else
				return e1:getUUID() < e2:getUUID()
			end
		end)
		candidates = {candidates[1]}
	elseif self._options.min_distance then
		table.insert(candidates,target_as_candidate)
		local self_pos = self._attacker:getPosition()
		table.sort(candidates,function(e1,e2)
			local d1 = q.distOf2PointsSquare(e1:getPosition(),self_pos)
			local d2 = q.distOf2PointsSquare(e2:getPosition(),self_pos)
			if d1 ~= d2 then
				return d1 < d2
			else
				return e1:getUUID() < e2:getUUID()
			end
		end)
		candidates = {candidates[1]}
	elseif self._options.max_distance then
		table.insert(candidates,target_as_candidate)
		local self_pos = self._attacker:getPosition()
		table.sort(candidates,function(e1,e2)
			local d1 = q.distOf2PointsSquare(e1:getPosition(),self_pos)
			local d2 = q.distOf2PointsSquare(e2:getPosition(),self_pos)
			if d1 ~= d2 then
				return d1 > d2
			else
				return e1:getUUID() < e2:getUUID()
			end
		end)
		candidates = {candidates[1]}
	elseif self._options.random_target then
		table.insert(candidates,target_as_candidate)
	elseif self._options.under_status then
		table.insert(candidates,target_as_candidate)
		for _, actor in ipairs(candidates) do
			if actor:isUnderStatus(self._options.under_status) then
				candidates = {actor}
				break
			end
		end
	end



	if #candidates > 0 then
		actor:setTarget(candidates[app.random(1, #candidates)])
		actor:_verifyFlip()
		self:finished()
	elseif target_as_candidate then
		self:finished()
	else
		if self._options.cancel_if_not_found then
			app.battle:performWithDelay(function()
				actor:_cancelCurrentSkill()
			end, 0)
		else
			self:finished()
		end
	end
end

return QSBSelectTarget