--[[
    路径为三阶贝塞尔曲线的子弹
    基于QBezierBullet类，增加了弹射功能
--]]
local QBullet = import(".QBullet")
local QBezierBullet2 = class("QBezierBullet2", QBullet)

local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("..views.QBaseEffectView")
end

function QBezierBullet2:ctor(attacker, targets, sbDirector, options)
	self._attacker = attacker
	self._targets = targets
	self._skill = sbDirector and sbDirector:getSkill()
	self._options = options
	self._finished = false
	self._speed = self._options.speed or self._skill:getBulletSpeed()
	self._interval_time = self._options.interval_time or 0
	self._flag = self._options.flag or 1
	self._bullet_delay = self._options.bullet_delay or 0.1
	self._length_threshold = self._options.length_threshold or 500

	-- 子弹的弹跳
	self._jumpInfo = {}
    self._jump_number = 0
    if options.jump_info then
        self._jump_number = options.jump_info.jump_number --弹跳的数目
        local range = options.jump_info.jump_range or self._skill and self._skill:getAttackDistance() or -1 --负数代表无限大
        self._jump_range = range >=0 and range^2 or range --比较距离使用平方 这样可以少开N次根号
        local distance =  options.jump_info.jump_distance or -1 --负数代表无限制
        self._jump_distance = distance >= 0 and distance^2 or distance
        self._jump_outside = options.jump_info.jump_outside or false -- 是否可以弹出屏幕外的目标
        self._jump_repeat_interval = options.jump_info.jump_repeat_interval or 1 --每个目标可以重复弹跳弹回来的次数
        -- initialize jump info
        for i = 1, #self._targets do
	        local info = {}
	        self._jumpInfo[i] = info
	        info.jump_count = 0
	        info.jump_traveled_actors = {}
	        info.start_position = self._attacker and self._attacker:getPosition() or {x = 0,y = 0}
	        info.jump_actors = {}
	    end
    end
	-- 子弹拖影数量
    self._rail_number = options.rail_number or 0
    self._rail_delay = options.rail_delay or 0.1
    self._start_position = options.start_pos
	self._points = options.points
	self._actor_view_flipx = attacker:isFlipX()
	if self._points and self._points.speed then
		self._speed = self._points.speed 
	end

	self._targetsOver = {}
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

		local flyTime = self:calculateFlyTime(self._attacker, self._targets[i])
		table.insert(self._flyTime, flyTime)
		table.insert(self._dist, dist)
		table.insert(self._targetsOver, false)
		table.insert(self._isOver, false)
		table.insert(self._smogEffects, {})

		local endPosX = targetPos.x
		local endPosY = targetPos.y + target:getCoreRect().size.height * 0.5
		table.insert(self._endPos, {x = endPosX, y = endPosY})
	end

	self._timeElapsed = 0
	self._startPos = {x = self._attacker:getPosition().x, y = self._attacker:getPosition().y}

	-- if not IsServerSide then
		local position = self._startPos
    	local start_position = self._start_position
        if start_position then
            position.x = position.x + (self._actor_view_flipx and start_position.x or -start_position.x)
            position.y = position.y + start_position.y
        end
        self._startPos = position
	-- end
	self:_createEffects()
end

function QBezierBullet2:_createEffects()
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

function QBezierBullet2:finished()
	self:_cleanup()
    self._finished = true
end

function QBezierBullet2:isFinished()
    return self._finished
end

function QBezierBullet2:visit(dt)
    self:_execute(dt)
end

function QBezierBullet2:cancel()
	self:_cleanup()
end

function QBezierBullet2:_removeBullet(index, isNotOver)
	if IsServerSide or self._isOver[index] then
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
    if not isNotOver then
        self._targetsOver[index] = true
    end
end

function QBezierBullet2:_cleanup()
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

function QBezierBullet2:_execute(dt)
	self._timeElapsed = self._timeElapsed + dt
	if self:isFinished() == false then
		self:_update()
	end
end

if not IsServerSide then
function QBezierBullet2:_update()
	local elapse = self._timeElapsed
	if self._effects then
		for i = 1, #self._targets do
			if self._isOver[i] == false then
				local target = self._targets[i]
				-- if target:isDead() == true then
				-- 	self:_removeBullet(i)
				-- else
					local delay = elapse - self._bullet_delay * i
					local isOnMove = self:bezier_update(i, target, self._effects[i], self._endPos[i], delay)
					local rails = self._rails[i] or {}
					for j, subRail in ipairs(rails) do
						self:bezier_update(i, target, subRail, self._endPos[i], delay-j*self._rail_delay, true)
					end
					if isOnMove == false then
                        self:_removeBullet(i)
                    end
				-- end
			end
		end
	end
	local allHit = true
	for _, hit in ipairs(self._targetsOver) do
		if hit == false then
			allHit = false
			break
		end
	end
	if allHit then
		self:finished()
	end
end
end

if IsServerSide then
function QBezierBullet2:_update()
    local elapse = self._timeElapsed
    for i = 1, #self._targets do
        if self._isOver[i] == false then
            local target = self._targets[i]
            -- if target:isDead() == true then
            --  self:_removeBullet(i)
            -- else
                local delay = elapse - self._bullet_delay * i
                local isOnMove = self:bezier_update(i, target, nil, self._endPos[i], delay)
                if isOnMove == false then
                    self:_removeBullet(i)
                end
            -- end
        end
    end
    local allHit = true
    for _, hit in ipairs(self._targetsOver) do
        if hit == false then
            allHit = false
            break
        end
    end
    if allHit then
        self:finished()
    end
end
end

function QBezierBullet2:bezier_update(index, target, effect, endPos, elapse, isNotHit)
	if self._options.follow_target_pos then
		local targetPos = target:getPosition()
		local endPosX = targetPos.x
		local endPosY = targetPos.y + target:getCoreRect().size.height * 0.5
		endPos = {x = endPosX, y = endPosY}
	end
	local isOnMove = self:get_bezier_pos(index, effect, elapse, self._flyTime[index], self._startPos, endPos, isNotHit)
	return isOnMove
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

function QBezierBullet2:get_bezier_pos(index, effect, elapse, duration, p1, p2, isNotHit)
    if effect then
    	local controlPoints = self:getControlPoints(index, p1, p2)
    	local u = elapse / duration
    	local p, atan2 = _bezier_lerp(u, unpack(controlPoints))
    	effect:setPosition(p.x, p.y)
    	if p1.x < p2.x then
    		effect:setRotation(-atan2 / math.pi * 180)
    	else
    		effect:setRotation(-atan2 / math.pi * 180 - 180)
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

    if isNotHit then return end

	local move = true
	if (self._timeElapsed - self._bullet_delay * index) >= self._flyTime[index] then
		if not self._targetsOver[index] then
			self:_onBulletHitTarget(self._targets[index])
			move = false
		end
	end
	--贝塞尔曲线子弹弹射
	if move == false then
        local info = self._jumpInfo[index]
        if info.already_jump_self then
            return false
        end
        local conditionJump2Self = self._options.jump_info and self._options.jump_info.jump_self
            and 0 < self._jump_number and info.jump_count == self._jump_number

        if info.jump_count < self._jump_number or conditionJump2Self then
            info.jump_count = info.jump_count + 1
            info.jump_actors[info.jump_count] = target

            local jumpTarget = self:getNewJumpTarget(index)
			local jump2SelfEarly = false   --本次弹射子弹是否弹回自身, 是否提前返回自身

            if self._options.jump_info.jump_self and jumpTarget == nil then
                conditionJump2Self = true
                jump2SelfEarly = true
            end

            if conditionJump2Self then
                info.already_jump_self = true
            end

            local new_target = conditionJump2Self and self._attacker or jumpTarget
            if new_target then
		        for target,v in pairs(info.jump_traveled_actors) do
		            if v > 0 then
		                info.jump_traveled_actors[target] = v - 1
		            end
		        end
		        info.jump_traveled_actors[new_target] = self._jump_repeat_interval
			    
            	--计算到新目标的运动时间
            	self._flyTime[index] = self:calculateFlyTime(self._targets[index], new_target)
            	--命中目标弹射时重新计算控制点
				self._controlPoints[index] = nil
				--当前命中目标的位置为下次弹射的起始坐标	
            	self._startPos = {x = p2.x, y = p2.y}
            	--重置累积时间	
            	self._timeElapsed = 0
            	--下次弹射终点坐标
                self._endPos[index] = {x = new_target:getPosition().x, y = new_target:getPosition().y + new_target:getCoreRect().size.height * 0.5}
                --转向
                local oldStartPosX, oldEndPosX = p1.x, p2.x
                local newStartPosX, newEndPosX = p2.x, new_target:getPosition().x
                local condition1 = oldStartPosX < oldEndPosX and newEndPosX <= newStartPosX	--左朝右转向
                local condition2 = oldEndPosX < oldStartPosX and newStartPosX <= newEndPosX	--右朝左转向
                if (condition1 or condition2) and effect then
                	effect:getSkeletonView():setScaleX(effect:getSkeletonView():getScaleX() * -1)
                end
                --提前返回触发一次伤害
                if jump2SelfEarly then
                    self:_onBulletHitTarget(self._targets[index], nil, true)
                    if self._options.jump_info.jump_self_early_buffid then
                        target:applyBuff(self._options.jump_info.jump_self_early_buffid, self._attacker, self._skill) --提前返回给目标加个buff
                    end
                end
                --保存新目标
                self._targets[index] = new_target
                move = true
            else
                move = false
            end
        end
    end
    return move
end

function QBezierBullet2:getControlPoints(index, p1, p2)
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

function QBezierBullet2:calculateFlyTime(startActor, endActor)
	local dist = q.distOf2Points(startActor:getPosition(), endActor:getPosition())		
	local fromBack = dist < self._length_threshold
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
	return flyTime
end

return QBezierBullet2
