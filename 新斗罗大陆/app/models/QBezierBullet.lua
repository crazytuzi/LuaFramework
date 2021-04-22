--[[
    路径为三阶贝塞尔曲线的子弹
--]]
local QBullet = import(".QBullet")
local QBezierBullet = class("QBezierBullet", QBullet)

local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("..views.QBaseEffectView")
end


function QBezierBullet:ctor(attacker, targets, sbDirector, options)
	self._attacker = attacker
	self._targets = targets
	-- self._targets = app.battle:getMyEnemies(self._attacker)
	self._skill = sbDirector and sbDirector:getSkill()
	self._options = options
	self._finished = false
	self._speed = self._options.speed or self._skill:getBulletSpeed()
	self._interval_time = self._options.interval_time or 0
	self._flag = self._options.flag or 1
	self._bullet_delay = self._options.bullet_delay or 0.1
	self._length_threshold = self._options.length_threshold or 500

	-- 子弹拖影数量
    self._rail_number = options.rail_number or 0
    self._rail_delay = options.rail_delay or 0.1
    self._start_position = options.start_pos
	self._points = options.points
	self._actor_view_flipx = attacker:isFlipX()
	if self._points and self._points.speed then
		self._speed = self._points.speed 
	end

	self._isHit = {}
	self._isOver = {}
	self._dist = {}
	self._flyTime = {}
	self._fromBack = {}
	self._endPos = {}
	self._smogEffects = {}
	self._controlPoints = {}

	for i = 1, #self._targets do
		local attckerPos = self._attacker:getPosition()
		local target = self._targets[i]
		local targetPos = target:getPosition()
		local dist = q.distOf2Points(attckerPos, targetPos)
		
		local fromBack = dist < self._length_threshold
		table.insert(self._fromBack, fromBack)

		local flyTime
		if self._options.flyTime then
			flyTime = self._options.flyTime
		else
			flyTime = (dist * 1.0) / self._speed
			if fromBack then
				dist = dist + self._length_threshold * 2.0
				flyTime = dist / self._speed
			end 
		end
		table.insert(self._flyTime, flyTime)
		table.insert(self._dist, dist)
		table.insert(self._isHit, false)
		table.insert(self._isOver, false)
		table.insert(self._smogEffects, {})

		local endPosX = targetPos.x
		local endPosY = targetPos.y + target:getCoreRect().size.height * 0.5
		table.insert(self._endPos, {x = endPosX, y = endPosY})
	end

	self._timeElapsed = 0
	self._startPos = {x = self._attacker:getPosition().x, y = self._attacker:getPosition().y}

	if not IsServerSide then
		local position = self._startPos
    	local start_position = self._start_position
        if start_position then
            position.x = position.x + (self._actor_view_flipx and start_position.x or -start_position.x)
            position.y = position.y + start_position.y
        end
        self._startPos = position
	end

	self:_createEffects()
end

function QBezierBullet:_createEffects()
	if not IsServerSide then
		local effects = {}
		local rails = {}
		local effectID = self._options.effect_id or self._skill:getBulletEffectID()
		local actorView = app.scene:getActorViewFromModel(self._attacker)

		for i = 1, #self._targets do
			local effect = QBaseEffectView.createEffectByID(effectID)
			effect:playAnimation(effect:getPlayAnimationName(), true)
			local endPosX = self._endPos[i].x
			if self._startPos.x >= endPosX then
				effect:getSkeletonView():setScaleX(effect:getSkeletonView():getScaleX() * -1)
			end

			function effect:getActorView()
                return actorView
            end

	        effect:retain()
	        app.scene:addEffectViews(effect, {isFrontEffect = true})
	        table.insert(effects, effect)
		end

	    -- initialize rails
		for i, effect in ipairs(effects) do
            local rail = {}
            local opacity = 255/(self._rail_number + 1)
            for j = 1, self._rail_number do
                local subRail = QBaseEffectView.createEffectByID(effectID)
                subRail:setPosition(ccp(effect:getPosition()))
                subRail:playAnimation(subRail:getPlayAnimationName(), true)
                subRail:getSkeletonView():setScaleX(effect:getSkeletonView():getScaleX())
                subRail:getSkeletonView():setOpacity(255 - j * opacity )
              	subRail:retain()
	        	app.scene:addEffectViews(subRail, {isFrontEffect = true})
                table.insert(rail, subRail)
            end
	       	table.insert(rails, rail)
	    end

		self._effects = effects
        self._rails = rails
	end
	self:_update()
end

function QBezierBullet:finished()
	self:_cleanup()
    self._finished = true
end

function QBezierBullet:isFinished()
    return self._finished
end

function QBezierBullet:visit(dt)
    self:_execute(dt)
end

function QBezierBullet:cancel()
	self:_cleanup()
end

function QBezierBullet:_removeBullet(index)
	if IsServerSide then
		return
	end

    if self._isOver[index] then
        return
    end

    if self._effects then
        app.scene:removeEffectViews(self._effects[index])
    end
    if self._smogEffects[index] then
    	for _, effect in ipairs(self._smogEffects[index]) do
    		app.scene:removeEffectViews(effect)
    	end
    end
    if self._rails[index] then
    	for _, effect in ipairs(self._rails[index]) do
    		app.scene:removeEffectViews(effect)
    	end
    end
    self._isOver[index] = true
end

function QBezierBullet:_cleanup()
	if self._effects then
		for _, effect in ipairs(self._effects) do
			app.scene:removeEffectViews(effect)
			effect:release()
		end
		for i = 1, #self._smogEffects do
			for _, effect in ipairs(self._smogEffects[i]) do
				app.scene:removeEffectViews(effect)
				effect:release()
			end
			self._smogEffects[i] = nil
		end
		for i = 1, #self._rails do
			for _, effect in ipairs(self._rails[i]) do
				app.scene:removeEffectViews(effect)
				effect:release()
			end
			self._rails[i] = nil
		end
		self._effects = nil
		self._smogEffects = nil
		self._rails = nil
	end
	self._finished = true
end

function QBezierBullet:_execute(dt)
	self._timeElapsed = self._timeElapsed + dt
	if self:isFinished() == false then
		self:_update()
	end
end

function QBezierBullet:_update()
	local elapse = self._timeElapsed
	if not IsServerSide then
		if self._effects then
			for i = 1, #self._targets do
				if self._isOver[i] == false then
					local target = self._targets[i]
					if target:isDead() == false then
						local delay = elapse - self._bullet_delay * i
						self:bezier_update(i, target, self._effects[i], self._endPos[i], delay)
						local rails = self._rails[i] or {}
						for j, subRail in ipairs(rails) do
							self:bezier_update(i, target, subRail, self._endPos[i], delay-j*self._rail_delay)
						end
					else
						self:_removeBullet(i)
					end
				end
			end
		end
	end

	for index, target in ipairs(self._targets) do
		if (elapse - self._bullet_delay * index) >= self._flyTime[index] then
			if not self._isHit[index] then
				self:_onBulletHitTarget(target)
				self._isHit[index] = true
				self:_removeBullet(index)
			end
		end
	end
	local allHit = true
	for _, hit in ipairs(self._isHit) do
		if hit == false then
			allHit = false
			break
		end
	end
	if allHit then
		self:finished()
	end
end

function QBezierBullet:bezier_update(index, target, effect, endPos, elapse)
	if self._options.follow_target_pos then
		local targetPos = target:getPosition()
		local endPosX = targetPos.x
		local endPosY = targetPos.y + target:getCoreRect().size.height * 0.5
		endPos = {x = endPosX, y = endPosY}
	end
	self:get_bezier_pos(index, effect, elapse, self._flyTime[index], self._startPos, endPos)
end

local function lerp(u, p1, p2)
	return {x = p1.x * (1 - u) + p2.x * u, y = p1.y * (1 - u) + p2.y * u}
end

local function _bezier_lerp(u, ...)
	local arr = {...}
	if #arr == 2 then
		return lerp(u, arr[1], arr[2]), math.atan2(arr[2].y - arr[1].y, arr[2].x - arr[1].x)
	else
		for i = 1, #arr - 1 do
			arr[i] = lerp(u, arr[i], arr[i + 1])
		end
		arr[#arr] = nil
		return _bezier_lerp(u, unpack(arr))
	end
end

function QBezierBullet:get_bezier_pos(index, effect, elapse, duration, p1, p2)
	if elapse < 0 or elapse > duration then
		effect:setVisible(false)
	else
		effect:setVisible(true)
		local controlPoints = self:getControlPoints(index, p1, p2)
		local u = elapse / duration

		local p, atan2 = _bezier_lerp(u, unpack(controlPoints))

		effect:setPosition(p.x, p.y)
		if p1.x < p2.x then
			effect:setRotation(-atan2 / math.pi * 180)
		else
			effect:setRotation(-atan2 / math.pi * 180 - 180)
		end
	end

	if self._options.smog_effect_id then
		local smog_effect = QBaseEffectView.createEffectByID(self._options.smog_effect_id)
		smog_effect:playAnimation(smog_effect:getPlayAnimationName(), false)
		smog_effect:getSkeletonView():setScaleX(effect:getSkeletonView():getScaleX())
        smog_effect:retain()
        smog_effect:setRotation(effect:getRotation())
        smog_effect:setPosition(effect:getPosition())
        app.scene:addEffectViews(smog_effect, {isFrontEffect = true})
        table.insert(self._smogEffects[index], smog_effect)
	end
end

function QBezierBullet:getControlPoints(index, p1, p2)
	if nil ~= self._controlPoints[index] then
		return self._controlPoints[index]

	elseif self._points then
		local calculate = function(x, y)
			return {x = p1.x + x, y = p1.y + y}
		end
		local controlPoints = {}
		table.insert(controlPoints, p1)
		for i, point in pairs(self._points) do
			if type(point) == "table" then
				local controlPoint = calculate(point.x, point.y)
				table.insert(controlPoints, controlPoint)
			end
		end
		table.insert(controlPoints, p2)
		self._controlPoints[index] = controlPoints

		return self._controlPoints[index]

	else
		local cp1, cp2, cp3
		if not self._fromBack[index] then
			cp1 = {x = p1.x * 0.5 + p2.x * 0.5, y = p1.y * 0.5 + p2.y * 0.5}
			cp2 = {x = p1.x * 0.5 + p2.x * 0.5, y = p1.y * 0.5 + p2.y * 0.5}
			local angle = math.atan2(p2.y - p1.y, p2.x - p1.x) + math.pi / 2
			local sin = math.sin(angle)
			local cos = math.cos(angle)
			local len = q.distOf2Points(p1, p2) * 0.5
			if self._flag == 1 or self._flag == 3 then
				cp1.x = cp1.x - cos * len
				cp1.y = cp1.y - sin * len
				cp2.x = cp2.x + cos * len
				cp2.y = cp2.y + sin * len
			else
				cp1.x = cp1.x + cos * len
				cp1.y = cp1.y + sin * len
				cp2.x = cp2.x - cos * len
				cp2.y = cp2.y - sin * len
			end
		else
			local adddist = self._length_threshold
			local angle = math.atan2(p2.y - p1.y, p2.x - p1.x)
			local p = {x = (p2.x + math.cos(angle) * adddist), y = (p2.y + math.sin(angle) * adddist)}
			angle = angle + math.pi / 2
			if self._flag == 1 then
				cp1 = {x = p.x - math.cos(angle) * adddist * 1.0, y = p.y - math.sin(angle) * adddist * 1.0}
				cp2 = {x = p.x + math.cos(angle) * adddist * 0.0, y = p.y + math.sin(angle) * adddist * 0.0}
			elseif self._flag == 3 then
				angle = math.atan2(p1.y - p2.y, p1.x - p2.x)
				p = {x = (p1.x + math.cos(angle) * adddist), y = (p1.y + math.sin(angle) * adddist)}
				angle = angle + math.pi / 2
				cp1 = {x = p.x + math.cos(angle) * adddist * 0.0, y = p.y + math.sin(angle) * adddist * 0.0}
				cp2 = {x = p.x - math.cos(angle) * adddist * 1.0, y = p.y - math.sin(angle) * adddist * 1.0}
			elseif self._flag == 4 then
				angle = math.atan2(p1.y - p2.y, p1.x - p2.x)
				p = {x = (p1.x + math.cos(angle) * adddist), y = (p1.y + math.sin(angle) * adddist)}
				angle = angle + math.pi / 2
				cp1 = {x = p.x - math.cos(angle) * adddist * 0.0, y = p.y - math.sin(angle) * adddist * 0.0}
				cp2 = {x = p.x + math.cos(angle) * adddist * 1.0, y = p.y + math.sin(angle) * adddist * 1.0}
			else
				cp1 = {x = p.x + math.cos(angle) * adddist * 1.0, y = p.y + math.sin(angle) * adddist * 1.0}
				cp2 = {x = p.x - math.cos(angle) * adddist * 0.0, y = p.y - math.sin(angle) * adddist * 0.0}
			end
			cp3 = lerp(0.5, cp2, p2)
		end

		local controlPoints = {}
		table.insert(controlPoints, p1)
		table.insert(controlPoints, cp1)
		table.insert(controlPoints, cp2)
		if cp3 then
			table.insert(controlPoints, cp3)
		end
		table.insert(controlPoints, p2)
		self._controlPoints[index] = controlPoints

		return self._controlPoints[index]
	end
end

return QBezierBullet
