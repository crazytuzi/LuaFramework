local QModelBase = import("...models.QModelBase")
local QVCRLaser = class("QVCRLaser", QModelBase)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QBaseEffectView = import("...views.QBaseEffectView")
local QLaser = import("...models.QLaser")

function QVCRLaser:ctor(attacker, targets, bullet_effect_id, options)
    self._attacker = attacker
    self._targets = targets
    self._bullet_effect_id = bullet_effect_id
    self._options = options
    self._finished = false
    self._fromTarget = options.from_target
    self._target = attacker:getTarget()
    self._laserInfos = {}

    self:_createLasers()
end

function QVCRLaser:finished()
	self._finished = true
end

function QVCRLaser:isFinished()
	return self._finished
end

function QVCRLaser:visit(dt)
	self:_execute(dt)
end

function QVCRLaser:cancel()
	if self:isFinished() == true then
		return
	end

    for _, laserInfo in pairs(self._laserInfos) do
        if laserInfo.view then
            local laserView = laserInfo.view
            app.scene:removeEffectViews(laserView)
            laserView:release()
            laserInfo.view = nil
            laserInfo.effects = nil
            laserInfo.over = true
        end
    end

    self:finished()
end

function QVCRLaser:_createLasers()
    local options = self._options
    local effectID = options.effect_id
    local effect_width = options.effect_width
    local laser_speed = options.laser_speed

    effect_width = effect_width or 50
    laser_speed = laser_speed or 2000

    local actor = self._fromTarget and self._fromTarget or self._attacker
    for _, target in ipairs(self._targets) do
        local laserView = CCNode:create()
        laserView:retain()
        function laserView:pauseSoundEffect() end
        function laserView:resumeSoundEffect() end
        app.scene:addEffectViews(laserView, {isFrontEffect = true})
        local laserInfo = {time = 0, view = laserView, effects = {}, hit = false, over = false}
        table.insert(self._laserInfos, laserInfo)
    end
end

function QVCRLaser:_updateLaser2(actor, target, laserInfo, dt, effect_width, laser_speed, effectID)
    local laserView = laserInfo.view
    local actorView = app.scene:getActorViewFromModel(actor)
    laserInfo.time = laserInfo.time + dt 

    if laserInfo.hit == false then
        local actorPos = clone(actor:getPosition())
        local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.WEAPON)
        local bonePosition = actorView:getSkeletonActor():getBonePosition(dummy)
        actorPos.x = actorPos.x + bonePosition.x
        actorPos.y = actorPos.y + bonePosition.y
        local targetPos = target:getPosition()
        local targetHeight = target:getCoreRect().size.height / 2
        local deltax = targetPos.x - actorPos.x
        local deltay = targetPos.y + targetHeight - actorPos.y
        local distance = math.sqrt(math.pow(deltax, 2) + math.pow(deltay, 2))

        laserLength = distance
        local effect = laserInfo.effects[1]
        if effect == nil then
            local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, nil, nil, self._options)
            local laserEffect = frontEffect or backEffect
            laserView:addChild(laserEffect)
            laserView._dummy_as_position = laserEffect._dummy_as_position   --为了在QBattleScene:removeAllDummyAsPositionViews()中删除
            laserInfo.effects[1] = laserEffect
            laserEffect:setPosition(ccp(0, 0))
            laserEffect:playSoundEffect(false)
            laserEffect:playAnimation(EFFECT_ANIMATION, false)
        end

        laserView:setPosition(ccp(actorPos.x, actorPos.y))
        laserView:setRotation(180 - math.deg(math.atan2(deltay, deltax)))
        laserView:setScaleX(laserLength / effect_width)

        if laserLength == distance then
            self:_onLaserHitTarget(target)
            laserInfo.time = 0
            laserInfo.hit = true
        end
    elseif laserInfo.over == false then
        if laserInfo.time < 0.5 then
        else
            app.scene:removeEffectViews(laserView)
            laserView:release()
            laserInfo.view = nil
            laserInfo.effects = nil
            laserInfo.over = true
        end
    end
end

function QVCRLaser:_updateLaser1(actor, target, laserInfo, dt, effect_width, laser_speed, effectID)
    local laserView = laserInfo.view
    local actorView = app.scene:getActorViewFromModel(actor)
    laserInfo.time = laserInfo.time + dt 

    if laserInfo.hit == false then
        local actorPos = clone(actor:getPosition())
        local dummy = (QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID) or DUMMY.WEAPON)
        local bonePosition = actorView:getSkeletonActor():getBonePosition(dummy)
        actorPos.x = actorPos.x + bonePosition.x
        actorPos.y = actorPos.y + bonePosition.y
        local targetPos = target:getPosition()
        local deltax = targetPos.x - actorPos.x
        local deltay = targetPos.y - actorPos.y
        local distance = math.sqrt(math.pow(deltax, 2) + math.pow(deltay, 2))
        local laserLength = (laserInfo.time) * laser_speed

        laserLength = laserLength < distance and laserLength or distance
        local index = 1
        local length = laserLength
        while length > 0 do
            local effect = laserInfo.effects[index]
            if effect == nil then
                -- TODO create effect
                local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, nil, nil, self._options)
                local laserEffect = frontEffect or backEffect
                laserView:addChild(laserEffect)
                laserInfo.effects[index] = laserEffect
                laserEffect:setPosition(ccp((index - 1) * effect_width, 0))
                laserEffect:playSoundEffect(false)
                laserEffect:playAnimation(EFFECT_ANIMATION, not(self._options.is_not_loop))
            end
            -- TODO mask

            index = index + 1
            length = length - effect_width
        end
        -- TODO update position
        laserView:setPosition(ccp(actorPos.x, actorPos.y))
        -- TODO update rotation
        laserView:setRotation(0 - math.deg(math.atan2(deltay, deltax)))

        if laserLength == distance then
            self:_onLaserHitTarget(target)
            laserInfo.time = 0
            laserInfo.hit = true
        end
    elseif laserInfo.over == false then
        if laserInfo.time < 0.5 then
            laserView:setOpacity(255 * laserInfo.time / 0.5)
        else
            app.scene:removeEffectViews(laserView)
            laserView:release()
            laserInfo.view = nil
            laserInfo.effects = nil
            laserInfo.over = true
        end
    end
end

function QVCRLaser:_execute(dt)
    if self:isFinished() == true then
        return
    end

    local options = self._options
    local effectID = self._bullet_effect_id
    local effect_width = options.effect_width
    local laser_speed = options.laser_speed

    effect_width = effect_width or 50
    laser_speed = laser_speed or 2000

    local actor = self._fromTarget and self._fromTarget or self._attacker
    for i, target in ipairs(self._targets) do
        local laserInfo = self._laserInfos[i]
        self:_updateLaser2(actor, target, laserInfo, dt, effect_width, laser_speed, effectID)
    end

    local allover = true
    for i, laserInfo in ipairs(self._laserInfos) do
        if laserInfo.over == false then
            allover = false
            break
        end
    end

    if allover then
        self:finished()
    end
end

function QVCRLaser:_onLaserHitTarget(target)
    return
end

return QVCRLaser