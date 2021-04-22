local QModelBase = import("...models.QModelBase")
local QVCRBullet = class("QVCRBullet", QModelBase)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QBaseEffectView = import("...views.QBaseEffectView")
local QBullet = import("...models.QBullet")

function QVCRBullet:ctor(attacker, targets, bullet_effect_id, bullet_speed, options)
    self._attacker = attacker
    self._targets = targets
    self._bullet_effect_id = bullet_effect_id
    self._bullet_speed = bullet_speed
    self._options = options
    self._finished = false
    self._fromTarget = options.from_target
    self._throw = options.is_throw
    self._target = attacker:getTarget()
    self._throwInfo = {}
    self._throw_height = options.height_ratio or QBullet.THROW_HEIGHT
    self._throw_speed_power = options.speed_power or QBullet.THROW_SPEED_POWER
    self._throw_hit_duration = options.hit_duration or QBullet.HIT_DURATION
    self._throw_at_position = options.at_position or {x = 0, y = 0}
    self._throw_speed = options.throw_speed

    self._targetsHit = {}
    self._targetsOver = {}
    for i = 1, #targets do
        table.insert(self._targetsHit, false)
        table.insert(self._targetsOver, false)
    end

    self:_createBulletEffect()
    
    for _, bulletView in ipairs(self._bulletViews) do
        app.scene:addEffectViews(bulletView, {isFrontEffect = true})
    end
end

function QVCRBullet:finished()
	self._finished = true
end

function QVCRBullet:isFinished()
	return self._finished
end

function QVCRBullet:visit(dt)
	self:_execute(dt)
end

function QVCRBullet:cancel()
	if self:isFinished() == true then
		return
	end

	for _, bulletView in ipairs(self._bulletViews) do
        if bulletView ~= nil then
            app.scene:removeEffectViews(bulletView)
        end
    end

    self._bulletEffects = {}
    self._bulletViews = {}

    self:finished()
end

function QVCRBullet:_execute(dt)
	if self:isFinished() == true then
		return
	end

	if self._lastInterval == nil then
		self._lastInterval = 0
	end

    if self._accumulatedTime == nil then
        self._accumulatedTime = 0
    end

    local time_gear = app.battle:getTimeGear()
    local TIME_INTERVAL = QBullet.TIME_INTERVAL * time_gear

    self._lastInterval = self._lastInterval + dt
    if self._lastInterval >= TIME_INTERVAL then
        local deltatime = math.floor(self._lastInterval / TIME_INTERVAL) * TIME_INTERVAL
        self._accumulatedTime = self._accumulatedTime + self._lastInterval
        for i = 1, #self._targets do
            if self._targetsOver[i] == false then
                local target = self._targets[i]
                if target:isDead() == true then
                    app.scene:removeEffectViews(self._bulletViews[i])
                    self._targetsOver[i] = true
                else
                    local isOnMove = self:_bulletMove(i, deltatime, self._bulletEffects[i], self._bulletViews[i], target, self._accumulatedTime)
                    if isOnMove == false then
                        app.scene:removeEffectViews(self._bulletViews[i])
                        -- self:_onBulletHitTarget(target)
                        self._targetsOver[i] = true
                    end
                end
            end
        end
        self._lastInterval = self._lastInterval - deltatime

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

function QVCRBullet:_calculateThrowInfo(bulletView, target, totalTime)
    local pos1 = {}
    pos1.x, pos1.y = bulletView:getPosition()

    local pos2 = clone(target:getPosition())
    local height = target:getCoreRect().size.height
    pos2.y = pos2.y + height * QBullet.THROW_AT

    pos2.x = pos2.x + self._throw_at_position.x
    pos2.y = pos2.y + self._throw_at_position.y

    local dy = math.abs(pos2.y - pos1.y)
    local dx = math.abs(pos2.x - pos1.x)
    if math.abs(dx) < 1 then
        dx = 1
    end
    if math.abs(dy) < 1 then
        dx = 1
    end

    local ratio1 = 1 / ((dy / dx) + 2)
    local midX = math.sampler(pos1.x, pos2.x, (pos1.y > pos2.y) and ratio1 or (1 - ratio1))

    local ratio2 = 1 / ((dy / dx) + self._throw_height)
    local peakY = math.max(pos1.y, pos2.y) + dx * ratio2

    local totalTime = totalTime
    local fhTime = totalTime * math.abs(pos1.x - midX) / dx
    local shTime = totalTime - fhTime

    local info = {pos1 = pos1, pos2 = pos2, midX = midX, peakY = peakY, totalTime = totalTime, currentTime = 0, fhTime = fhTime, shTime = shTime}
    return info
end

function QVCRBullet:_createBulletEffect()
    self._bulletViews = {}
    self._bulletEffects = {}
    for i = 1, #self._targets do
        local bulletView = CCNode:create()
        local effectID = self._bullet_effect_id
        local actor = self._fromTarget and self._target or self._attacker
        local actorView = app.scene:getActorViewFromModel(actor)
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, attackerView, nil, self._options)
        local bulletEffect = frontEffect or backEffect
        if bulletEffect ~= nil then

            -- bullet view initialize and set position
            bulletView._dummy_as_position = bulletEffect._dummy_as_position   --为了在QBattleScene:removeAllDummyAsPositionViews()中删除
            bulletView:addChild(bulletEffect)
            local position = actor:getPosition()
            bulletView:setPosition(ccp(position.x, position.y - 0.1))
            local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.WEAPON)
            local bonePosition = actorView:getSkeletonActor():getBonePosition(dummy)
            bulletEffect:setPosition(bonePosition)
            bulletEffect:playSoundEffect(false)
            bulletEffect:playAnimation(EFFECT_ANIMATION, not(self._options.is_not_loop))
            if self._options.scissor then
                local scissor = self._options.scissor
                bulletEffect:setScissorEnabled(true)
                bulletEffect:setScissorRects(
                    CCRect(scissor.x - 300, scissor.y, 300 + scissor.grad1x1, scissor.height),
                    CCRect(scissor.x + scissor.grad1x1, scissor.y, math.abs(scissor.grad1x1 - scissor.grad1x2), scissor.height),
                    CCRect(scissor.x + scissor.width + scissor.grad2x1, scissor.y, math.abs(scissor.grad2x1 - scissor.grad2x2), scissor.height),
                    CCRect(scissor.x + scissor.width + scissor.grad2x2, scissor.y, 300, scissor.height)
                )
            end

            if not self._throw then
                local bulletDeltaX, bulletDeltaY = bulletEffect:getPosition()
                local bulletPosX, bulletPosY = bulletView:getPosition()
                local target = self._targets[i]
                local targetPos = target:getPosition()
                local height = target:getCoreRect().size.height
                local targetPosX = 0
                local targetPosY = height * 0.5
                local deltaX = targetPos.x + targetPosX - (bulletPosX + bulletDeltaX)
                local deltaY = targetPos.y + targetPosY - (bulletPosY + bulletDeltaY)
                bulletEffect:getSkeletonView():setRotation(math.deg(-1.0*math.atan2(deltaY, deltaX)))

                if self._options.start_position then
                    local targetPos = target:getPosition()
                    local height = target:getCoreRect().size.height
                    local targetPosX = 0
                    local targetPosY = height * 0.5
                    local deltaX = targetPos.x + targetPosX - (bulletPosX + bulletDeltaX)
                    local deltaY = targetPos.y + targetPosY - (bulletPosY + bulletDeltaY)
                    local targetDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
                    local precent = self._options.start_position / targetDistance
                    bulletView:setPosition(ccp(bulletPosX + deltaX * precent, bulletPosY + deltaY * precent))
                    bulletEffect:getSkeletonView():setRotation(math.deg(-1.0*math.atan2(deltaY, deltaX)))
                end
            else
                local target = self._targets[i]
                local throw_time = QBullet.THROW_TIME
                if self._throw_speed then
                    throw_time = q.distOf2Points(actor:getPosition(), target:getPosition()) / self._throw_speed
                end
                local info = self:_calculateThrowInfo(bulletView, target, throw_time)
                info.throwTime = throw_time
                self._throwInfo[target] = info
            end

            bulletView.bulletEffect = bulletEffect
            function bulletView:pauseSoundEffect()
                if self.bulletEffect.pauseSoundEffect then
                    self.bulletEffect:pauseSoundEffect()
                end
            end
            function bulletView:resumeSoundEffect()
                if self.bulletEffect.resumeSoundEffect then
                    self.bulletEffect:resumeSoundEffect()
                end
            end
        end

        table.insert(self._bulletViews, bulletView)
        table.insert(self._bulletEffects, bulletEffect)
    end
end

function QVCRBullet:_bulletMoveThrow(index, interval, bulletEffect, bulletView, target, accumualtedTime)
    local info = self._throwInfo[target]

    -- 检查目标是否有移动，是则重新计算轨道
    local currentTargetPosition = clone(target:getPosition())
    local height = target:getCoreRect().size.height
    currentTargetPosition.y = currentTargetPosition.y + height * QBullet.THROW_AT

    currentTargetPosition.x = currentTargetPosition.x + self._throw_at_position.x
    currentTargetPosition.y = currentTargetPosition.y + self._throw_at_position.y

    local info = self._throwInfo[target]
    info.currentTime = info.currentTime + interval
    local adjustCurrentTime = math.pow(accumualtedTime / info.throwTime, self._throw_speed_power) * info.totalTime
    if adjustCurrentTime < info.fhTime then
        if info.pos1.x - info.midX ~= 0 then
            local a = (info.pos1.y - info.peakY) / (math.pow(info.pos1.x - info.midX, 2))
            if a > 0 then a = -a end
            local newX = math.sampler(info.pos1.x, info.midX, adjustCurrentTime / info.fhTime)
            local newY = a * math.pow(newX - info.midX, 2) + info.peakY
            local offsetX = (currentTargetPosition.x - info.pos2.x) * adjustCurrentTime / info.totalTime
            local offsetY = (currentTargetPosition.y - info.pos2.y) * adjustCurrentTime / info.totalTime
            bulletView:setPosition(ccp(newX + offsetX, newY + offsetY))
            return true
        end
    elseif adjustCurrentTime < info.totalTime then
        if info.pos2.x - info.midX ~= 0 then
            local a = (info.pos2.y - info.peakY) / (math.pow(info.pos2.x - info.midX, 2))
            if a > 0 then a = -a end
            local newX = math.sampler(info.midX, info.pos2.x, (adjustCurrentTime - info.fhTime) / info.shTime)
            local newY = a * math.pow(newX - info.midX, 2) + info.peakY
            local offsetX = (currentTargetPosition.x - info.pos2.x) * adjustCurrentTime / info.totalTime
            local offsetY = (currentTargetPosition.y - info.pos2.y) * adjustCurrentTime / info.totalTime
            bulletView:setPosition(ccp(newX + offsetX, newY + offsetY))
            return true
        end
    elseif info.currentTime < info.totalTime + self._throw_hit_duration then
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end            
        bulletView:setPosition(ccp(currentTargetPosition.x, currentTargetPosition.y))
        bulletView.bulletEffect:getSkeletonView():setAnimationScaleOriginal(1.0)
        return true
    else
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end   
        return false
    end
end

-- return false is move finished
function QVCRBullet:_bulletMove(index, interval, bulletEffect, bulletView, target, accumulatedTime)
    if bulletEffect == nil or bulletView == nil or target == nil then
        return false
    end

    if self._throw then
        return self:_bulletMoveThrow(index, interval, bulletEffect, bulletView, target, accumulatedTime)
    end

	local bulletDeltaX, bulletDeltaY = bulletEffect:getPosition()
    local bulletPosX, bulletPosY = bulletView:getPosition()

    -- calculate target position
    local targetPos = target:getPosition()
    local height = target:getCoreRect().size.height
    local targetPosX = 0
    local targetPosY = height * 0.5

    local deltaX = targetPos.x + targetPosX - (bulletPosX + bulletDeltaX)
    local deltaY = targetPos.y + targetPosY - (bulletPosY + bulletDeltaY)
    local targetDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local actor = self._fromTarget and self._target or self._attacker
    if math.xor(deltaX > 0, (targetPos.x + targetPosX - actor:getPosition().x) > 0) then
        targetDistance = 0 - targetDistance
    end
    local bulletSpeed = self._bullet_speed
    local bulletMoveDistance = interval * bulletSpeed

    if self._options.end_position then
        local adjust_targetDistance = targetDistance + self._options.end_position
        deltaX = adjust_targetDistance / targetDistance * deltaX
        deltaY = adjust_targetDistance / targetDistance * deltaY
        targetDistance = adjust_targetDistance
    end

    local move = true

    if bulletMoveDistance > targetDistance then
        bulletMoveDistance = targetDistance
        if bulletEffect:isLoopSoundEffect() == true then
            bulletEffect:stopSoundEffect()
        end
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end
        move = false
    end

    local precent = bulletMoveDistance / targetDistance
    bulletView:setPosition(ccp(bulletPosX + deltaX * precent, bulletPosY + deltaY * precent))
    bulletEffect:getSkeletonView():setRotation(math.deg(-1.0*math.atan2(deltaY, deltaX)))

    if self._options.scissor then
        local scissor = self._options.scissor
        local accumulatedDistance = accumulatedTime * bulletSpeed
        bulletEffect:setScissorEnabled(true)
        local disappear_position = 0

        if self._options.disappear_position then
            local distance = targetDistance - bulletMoveDistance
            if 0 - distance > self._options.disappear_position then
                disappear_position = self._options.disappear_position + distance
            end 
        end
        bulletEffect:setScissorRects(
            CCRect(scissor.x - 300 - accumulatedDistance, scissor.y, 300 + scissor.grad1x1, scissor.height),
            CCRect(scissor.x + scissor.grad1x1 - accumulatedDistance, scissor.y, math.abs(scissor.grad1x1 - scissor.grad1x2), scissor.height),
            CCRect(scissor.x + scissor.width + scissor.grad2x1 + disappear_position, scissor.y, math.abs(scissor.grad2x1 - scissor.grad2x2), scissor.height),
            CCRect(scissor.x + scissor.width + scissor.grad2x2 + disappear_position, scissor.y, 300, scissor.height)
        )
    end
    return move
end

function QVCRBullet:_onBulletHitTarget(target)
	return
end

return QVCRBullet