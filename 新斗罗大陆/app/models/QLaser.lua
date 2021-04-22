local QLaser
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QLaser = class("QLaser", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QLaser = class("QLaser", QModelBase)
end

local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("..views.QBaseEffectView")
end

QLaser.TIME_INTERVAL = 1.0 / 30

function QLaser:ctor(attacker, targets, skill, options)
    self._attacker = attacker
    self._targets = targets
    self._skill = skill
    self._options = options
    self._finished = false
    self._fromTarget = options.from_target  
    self._target = attacker:getTarget()
    self._start_pos = options.start_pos or {x = 0, y = 0}
    self._laserInfos = {}
    self._useClip = options.use_clip
    self._followTime = options.duration or 0.5
    self._interval = options.interval
    self._hitCount = 0
    self._switchTarget = options.switch_target
    self._cancelSkill = options.cancel_skill
    self._hit_dummy = {}
    self._attack_dummy = options.attack_dummy
    for _, target in ipairs(targets) do
        self._hit_dummy[target] = self._options.hit_dummy or db:getEffectDummyByID(options.effect_id or self._skill:getBulletEffectID()) or target:getHitDummy()
    end

    self._on_hit_target = options.on_hit_target

    self:_createLasers()
end

function QLaser:finished()
    self._finished = true
end

function QLaser:isFinished()
    return self._finished
end

function QLaser:visit(dt)
    self:_execute(dt)
end

function QLaser:cancel()
    if self:isFinished() == true then
        return
    end

    for _, laserInfo in pairs(self._laserInfos) do
        if not IsServerSide then
            if laserInfo.view then
                local laserView = laserInfo.view
                self:removeLaserView(laserView)
                laserView:release()
                laserInfo.view = nil
                laserInfo.effects = nil
            end
        end
        laserInfo.over = true
    end

    self:finished()
end

function QLaser:_createLasers()
    local options = self._options
    local effect_width = options.effect_width
    local move_time = options.move_time

    effect_width = effect_width or 50
    move_time = move_time or 0.1

    local actor = self._fromTarget and self._fromTarget or self._attacker
    for _, target in ipairs(self._targets) do
        if not IsServerSide then
            local laserView = CCNode:create()
            laserView:retain()
            function laserView:pauseSoundEffect() end
            function laserView:resumeSoundEffect() end
            function laserView:getLaserTarget() return target end
            if self._options.sort_layer_with_pos then
                local actor_view = app.scene:getActorViewFromModel(target)
                if actor_view then
                    actor_view:addChild(laserView)
                end
            else
                app.scene:addEffectViews(laserView, {isFrontEffect = true})
            end
            local laserInfo = {time = 0, follow_time = 0, view = laserView, effects = {}, hit = false, over = false}
            table.insert(self._laserInfos, laserInfo)
        else
            local laserInfo = {time = 0, follow_time = 0, hit = false, over = false}
            table.insert(self._laserInfos, laserInfo)
        end
    end
end

if IsServerSide then
function QLaser:_updateLaser2(actor, target, laserInfo, dt, effect_width, move_time, effectID)
    laserInfo.time = laserInfo.time + dt 

    --[[if target:isDead() then
        laserInfo.over = true
        laserInfo.interrupted = true
    else]]if laserInfo.hit == false then
        if laserInfo.time >= move_time then
            self:_onLaserHitTarget(target)
            laserInfo.time = 0
            laserInfo.hit = true
        end
    elseif laserInfo.over == false then
        local interval, hitCount = self._interval, self._hitCount
        if interval and interval > 0 then
            local follow_time = math.min(self._followTime, laserInfo.time)
            while true do
                if math.floor(follow_time / interval) > hitCount then
                    self:_onLaserHitTarget(target)
                    hitCount = hitCount + 1
                else
                    break
                end
            end
            self._hitCount = hitCount
        end
        if laserInfo.time < self._followTime then
        else
            laserInfo.over = true
        end
    end
end
end

function QLaser:_getDistance(actor, target, effectID)
    local hit_dummy = self._hit_dummy[target]
    local actorView = app.scene:getActorViewFromModel(actor)
    local actorPos = clone(actor:getPosition())
    local dummy = (self._attack_dummy or DUMMY.WEAPON)
    local bonePosition
    if actorView and dummy then
        bonePosition = actorView:getBonePosition(dummy)
    else
        bonePosition = {x = 0, y = actor:getCoreRect().size.height / 2}
    end
    actorPos.x = actorPos.x + bonePosition.x + self._start_pos.x * (actor:isFlipX() and 1 or -1)
    actorPos.y = actorPos.y + bonePosition.y + self._start_pos.y
    local targetPos, targetHeight
    local hit_pos = {x = 0, y = 0}
    if hit_dummy then
        local view = app.scene:getActorViewFromModel(target)
        if view then
            local pos = view:getBonePosition(hit_dummy)
            targetPos = {x = target:getPosition().x + pos.x, y = target:getPosition().y}
            targetHeight = pos.y
            hit_pos = pos
        end
    end
    if targetPos == nil or targetHeight == nil then
        targetPos = target:getPosition()
        targetHeight = target:getCoreRect().size.height / 2
    end
    local deltax = targetPos.x - actorPos.x
    local deltay = targetPos.y + targetHeight - actorPos.y
    local distance = math.sqrt(math.pow(deltax, 2) + math.pow(deltay, 2))
    return actorPos, deltax, deltay, distance, hit_pos
end

if not IsServerSide then
function QLaser:_updateLaser2(actor, target, laserInfo, dt, effect_width, move_time, effectID)
    local laserView = laserInfo.view
    laserInfo.time = laserInfo.time + dt 

    local actorPos, deltax, deltay, distance, hit_pos = self:_getDistance(actor, target, effectID)
    --[[if target:isDead() then
        self:removeLaserView(laserView)
        laserView:release()
        laserInfo.view = nil
        laserInfo.effects = nil
        laserInfo.over = true
        laserInfo.interrupted = true
    else]]if laserInfo.hit == false then
        local laserLength = distance
        local effect = laserInfo.effects[1]
        if effect == nil then
            local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, nil, nil, self._options)
            local laserEffect = frontEffect or backEffect
            laserView:addChild(laserEffect)
            laserInfo.effects[1] = laserEffect
            effect = laserEffect
            laserEffect:setPosition(0, 0)
            laserEffect:playSoundEffect(false)
            laserEffect:playAnimation(laserEffect:getPlayAnimationName(), true)
        end
        if self._options.sort_layer_with_pos then
            laserView:setPosition(-deltax + hit_pos.x, -deltay + hit_pos.y)            
        else
            laserView:setPosition(actorPos.x, actorPos.y)
        end
        laserView:setRotation(180 - math.deg(math.atan2(deltay, deltax)))
        if not self._useClip then
            laserView:setScaleX(laserLength / effect_width * math.min(laserInfo.time/move_time, 1.0))
        else
            effect:setClippingRect({origin = {x = -laserLength, y = -64}, size = {width = laserLength + 16, height = 128}})
            laserView:setScaleX(math.max(laserLength / effect_width, 1.0) * math.min(laserInfo.time/move_time, 1.0))
        end

        if laserInfo.time >= move_time then
            self:_onLaserHitTarget(target)
            laserInfo.time = 0
            laserInfo.hit = true
        end
    elseif laserInfo.over == false then
        local interval, hitCount = self._interval, self._hitCount
        if interval and interval > 0 then
            local follow_time = math.min(self._followTime, laserInfo.time)
            while true do
                if math.floor(follow_time / interval) > hitCount then
                    self:_onLaserHitTarget(target)
                    hitCount = hitCount + 1
                else
                    break
                end
            end
            self._hitCount = hitCount
        end
        if laserInfo.time < self._followTime then
            local laserLength = distance
            local effect = laserInfo.effects[1]
            if self._options.sort_layer_with_pos then
                laserView:setPosition(-deltax + hit_pos.x, -deltay + hit_pos.y)   
            else
                laserView:setPosition(actorPos.x, actorPos.y)
            end
            laserView:setRotation(180 - math.deg(math.atan2(deltay, deltax)))
            if not self._useClip then
                laserView:setScaleX(laserLength / effect_width)
            else
                effect:setClippingRect({origin = {x = -laserLength, y = -64}, size = {width = laserLength + 16, height = 128}})
                laserView:setScaleX(math.max(laserLength / effect_width, 1.0))
            end
        else
            self:removeLaserView(laserView)
            laserView:release()
            laserInfo.view = nil
            laserInfo.effects = nil
            laserInfo.over = true
        end
    end
end
end

function QLaser:_execute(dt)
    if self:isFinished() == true then
        return
    end

    local options = self._options
    local effectID = options.effect_id or self._skill:getBulletEffectID()
    local effect_width = options.effect_width
    local move_time = options.move_time

    effect_width = effect_width or 50
    move_time = move_time or 0.1

    local actor = self._fromTarget and self._fromTarget or self._attacker
    for i, target in ipairs(self._targets) do
        local laserInfo = self._laserInfos[i]
        if laserInfo.over ~= true then
            if self._switchTarget  then
                local next_target = self:chooseTarget(target)
                if next_target then
                    target = next_target
                    self._targets[i] = target
                end
            end
            self:_updateLaser2(actor, target, laserInfo, dt, effect_width, move_time, effectID)
        end
    end

    local allover = true
    local interrupted = false
    for i, laserInfo in ipairs(self._laserInfos) do
        if laserInfo.over == false then
            allover = false
            break
        else
            interrupted = interrupted or laserInfo.interrupted
        end
    end

    if allover then
        if interrupted and self._cancelSkill then -- 射线提前结束的话打断施法动作
            if self._attacker:getCurrentSkill() == self._skill then
                self._attacker:_cancelCurrentSkill()
            end
        end
        self:finished()
    end
end

function QLaser:chooseTarget(lastTarget)
    local actor = self._attacker
    if actor:getTarget() and not actor:getTarget():isDead() then
        return actor:getTarget()
    elseif lastTarget:isDead() then
        local range_min = 0
        local range_max = 9999
        range_min = range_min * range_min * global.pixel_per_unit * global.pixel_per_unit
        range_max = range_max * range_max * global.pixel_per_unit * global.pixel_per_unit

        local actors
        if actor:isHealth() then
            actors = app.battle:getMyTeammates(actor, true)
        else
            actors = app.battle:getMyEnemies(actor)
        end
        local candidates = {}
        local target_as_candidate = nil
        for _, enemy in ipairs(actors) do
            if not enemy:isDead() and not enemy:isSupport() then
                local x = enemy:getPosition().x - actor:getPosition().x
                local y = enemy:getPosition().y - actor:getPosition().y
                local d = x * x + y * y * 4
                if d <= range_max and d >= range_min then
                    if enemy ~= lastTarget then
                        table.insert(candidates, enemy)
                    end
                end
            end
        end
        if #candidates > 0 then
            local target = candidates[app.random(1, #candidates)]
            return target
        end
    end
end

function QLaser:_onLaserHitTarget(target)
    if target == nil then
        return
    end

    if not IsServerSide then
        -- play effect
        local options = {isRandomPosition = self._options.is_random_position, followActorPosition = true}
        local effectID = self._options.hit_effect_id
        effectID = effectID or self._skill:getHitEffectID()
        if effectID ~= nil then
            target:playSkillEffect(effectID, nil, options)
        end
    end

    if self._on_hit_target then
        self._on_hit_target(target)
    end

    -- play damage
    local split_number = self._skill:getDamageSplit() and #self._targets or 0
    self._attacker:hit(self._skill, target, split_number)
    if self._options.apply_buffIds then
        for _, buffId in ipairs(self._options.apply_buffIds) do
            target:applyBuff(buffId, self._attacker, self._skill)
        end
    end
end

function QLaser:getAttacker()
    return self._attacker
end

function QLaser:removeLaserView(laserView)
    if self._options.sort_layer_with_pos then
        laserView:removeFromParent()
    else
        app.scene:removeEffectViews(laserView)
    end
end

return QLaser
