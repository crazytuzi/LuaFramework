--[[
该子弹类为跟踪实时变向变速(若目标移动)子弹，子弹终点位置为目标贴图中心点所在坐标，一开始刚发射时子弹飞行总时间根据公式：时间=距离/速度固定下来，在子弹每帧移动时，计算本帧移动的距离，本帧移动的终点位置等信息
]]
local QBullet
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QBullet = class("QBullet", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QBullet = class("QBullet", QModelBase)
end

local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("..views.QBaseEffectView")
end
local QTrapDirector = import("..trap.QTrapDirector")

QBullet.TIME_INTERVAL = 1.0 / 30
QBullet.THROW_TIME = 1.0
QBullet.THROW_SPEED_POWER = 1.5
QBullet.THROW_HEIGHT = 4
QBullet.THROW_AT = 0.3
QBullet.HIT_DURATION = 0.05

function QBullet:ctor(attacker, targets, sbDirector, options)
    self._attacker = attacker
    self._targets = targets
    self._sbDirector = sbDirector
    self._skill = sbDirector and sbDirector:getSkill()
    self._options = options
    self._finished = false
    self._fromTarget = options.from_target -- 技能的出发点，从技能的目标者触发
    self._throw = options.is_throw
    self._tornado = options.is_tornado
    self._tornadoSize = options.tornado_size
    self._tornado_hit_disappear = options.tornado_hit_disappear or false
    self._tornadoHitTargets = {}
    self._target = sbDirector and sbDirector:getTarget() or attacker:getTarget()
    self._start_position = options.start_pos
    self._rand_position = options.rand_pos
    self._end_position = options.end_pos
    self._actor_view_flipx = attacker:isFlipX()
    self._throwInfo = {}
    self._jumpInfo = {}
    self._rails = {}
    self._throw_height = options.height_ratio or QBullet.THROW_HEIGHT
    self._throw_speed_power = options.speed_power or QBullet.THROW_SPEED_POWER
    self._throw_hit_duration = options.hit_duration or QBullet.HIT_DURATION
    self._throw_at_position = options.at_position or {x = 0, y = 0}
    self._throw_speed = options.throw_speed
    self._throw_angel = options.throw_angel
    self._shakeOptions = options.shake
    self._uprise = options.uprise
    self._uprise_height = options.uprise_height
    self._uprise_duration = options.uprise_duration
    self._hit_dummy = {}
    self._flip_follow_y = options.flip_follow_y or false
    self._sort_layer_with_actor = options.sort_layer_with_actor
    for i, target in ipairs(targets) do
        self._hit_dummy[i] = target:getHitDummy() or self._options.hit_dummy
    end
    self._thorn = self._options.is_thorn
    self._bulletTime = {}

    -- 直线子弹飞行时间预先固定
    if not self._throw and not self._tornado then
        --[[nzhang: targets[1].getPosition could be nil? i'm dubious about it...]]
        if self._options.is_fixed_speed then
            for i = 1, #targets do
                local dist = (targets[i] ~= nil and targets[i].getPosition ~= nil) and q.distOf2Points(attacker:getPosition(), targets[i]:getPosition()) or 0
                self:_calculateBulletTime(options, dist, i)
            end
        else
            for i = 1, #targets do
                local dist = (targets[1] ~= nil and targets[1].getPosition ~= nil) and q.distOf2Points(attacker:getPosition(), targets[1]:getPosition()) or 0
                self:_calculateBulletTime(options, dist, i)
            end
        end
    end

    -- 子弹的弹跳
    self._jump_number = 0
    if options.jump_info then
        self._jump_number = options.jump_info.jump_number --弹跳的数目
        self._is_jump_teammate = options.jump_info.is_teammate
        local range = options.jump_info.jump_range or self._skill and self._skill:getAttackDistance() or -1 --负数代表无限大
        self._jump_range = range >=0 and range^2 or range --比较距离使用平方 这样可以少开N次根号
        local distance =  options.jump_info.jump_distance or -1 --负数代表无限制
        self._jump_distance = distance >= 0 and distance^2 or distance
        self._jump_outside = options.jump_info.jump_outside or false -- 是否可以弹出屏幕外的目标
        self._jump_repeat_interval = options.jump_info.jump_repeat_interval or 1 --每个目标可以重复弹跳弹回来的次数
    end
    -- 子弹拖影数量
    self._rail_number = options.rail_number or 0
    self._rail_inter_frame = options.rail_inter_frame or 1

    self._targetsHit = {}
    self._targetsOver = {}
    if self._tornado then
        self._targetsHit[1] = false
        self._targetsOver[1] = false
    else
        for i = 1, #targets do
            table.insert(self._targetsHit, false)
            table.insert(self._targetsOver, false)
        end
    end

    if self._tornado then
        self._tornadoDirection = attacker:isFlipX() and 1 or -1
    end

    self:_createBulletEffect()

    if not IsServerSide then
        local actorView = app.scene:getActorViewFromModel(attacker)
        local is_front_effect = true
        if self._sort_layer_with_actor then
            is_front_effect = false
        end
        for _, bulletView in ipairs(self._bulletViews) do
            function bulletView:getActorView()
                return actorView
            end
            app.scene:addEffectViews(bulletView, {isFrontEffect = is_front_effect})
        end
    end
end

function QBullet:_calculateBulletTime(options, dist, index)
    -- 直线子弹飞行时间预先固定
    if options.time then
        self._bulletTime[index] = options.time
    else
        local bulletSpeed = self._options.speed or self._skill:getBulletSpeed()
        if dist == 0 then
            self._bulletTime[index] = 0.01
        else
            self._bulletTime[index] = dist / bulletSpeed
        end
    end
end

function QBullet:finished()
    self._finished = true
end

function QBullet:isFinished()
    return self._finished
end

function QBullet:visit(dt)
    self:_execute(dt)
end

function QBullet:_removeBullet(index, isNotOver)
    if self._targetsOver[index] then
        return
    end

    if not IsServerSide then
        app.scene:removeEffectViews(self._bulletViews[index])
        if self._rails[index] then
            for _, sub_rail in ipairs(self._rails[index].sub_rails) do
                app.scene:removeEffectViews(sub_rail.bulletView)
            end
        end
    end

    if not isNotOver then
        self._targetsOver[index] = true
    end
end

function QBullet:cancel()
    if self:isFinished() == true then
        return
    end

    for index, _ in ipairs(self._targetsOver) do
        self:_removeBullet(index)
    end

    self._bulletEffects = {}
    self._bulletViews = {}

    self:finished()
end

function QBullet:_execute(dt)
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

    self._lastInterval = self._lastInterval + dt    --self._lastInterval可以理解为经过加工的，差值dt
    if self._lastInterval >= TIME_INTERVAL then
        local deltatime = math.floor(self._lastInterval / TIME_INTERVAL) * TIME_INTERVAL    --为了让子弹变化位置所经过的时间是TIME_INTERVAL的整数倍,取值在1或2*TIME_INTERVAL
        self._accumulatedTime = self._accumulatedTime + self._lastInterval  --子弹累积运动时间
        if self._tornado then
            if self:_tornadoMove(dt, self._bulletEffects[1], self._bulletViews[1]) == false then
                self:_removeBullet(1)
                self:finished()
            end
        elseif self._thorn then
            if self:_thornMove(dt) == false then
                self:finished()
            end
        else
            for i = 1, #self._targets do
                if self._targetsOver[i] == false then
                    local target = self._targets[i]
                    if target:isDead() == true and not self._options.dead_ok then
                        self:_removeBullet(i)
                    else
                        local isOnMove = self:_bulletMove(i, deltatime, self._bulletEffects[i], self._bulletViews[i], target, self._accumulatedTime)
                        if isOnMove == false then
                            self:_removeBullet(i)
                        end
                    end
                end
            end
            self._lastInterval = self._lastInterval - deltatime     --计算dt差值
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

end

function QBullet:_calculateThrowInfo(bulletView, target, totalTime)
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
        dy = 1
    end

    local ratio1 = 1 / ((dy / dx) + 2)
    local midX = math.sampler(pos1.x, pos2.x, (pos1.y > pos2.y) and ratio1 or (1 - ratio1))

    -- local ratio2 = 1 / ((dy / dx) + self._throw_height)
    -- local peakY = math.max(pos1.y, pos2.y) + dx * ratio2
    local angel = self._throw_angel or 100

    local radian = angel/360 * math.pi
    local r = dx / ((math.sin(radian))*2)

    local peakY = math.max(pos1.y, pos2.y)
    if angel>0 and angel < 180 then
        peakY = peakY + r - (dx/((math.tan(radian))*2))
    end

    local totalTime = totalTime
    local fhTime = totalTime * math.abs(pos1.x - midX) / dx --飞到中点所需要的世间
    local shTime = totalTime - fhTime --剩余时间

    local info = {pos1 = pos1, pos2 = pos2, midX = midX, peakY = peakY, totalTime = totalTime, currentTime = 0, fhTime = fhTime, shTime = shTime}
    return info
end

if IsServerSide then
local function createNode()
    local x, y = 0, 0
    local obj = {}
    function obj:setPositionX(value)
        x = value
    end
    function obj:setPositionY(value)
        y = value
    end
    function obj:setPosition(value)
        x = value.x
        y = value.y
    end
    function obj:getPosition()
        return x, y
    end
    function obj:getPositionX()
        return x
    end
    function obj:getPositionY()
        return y
    end
    return obj
end

function QBullet:_createBulletEffect()
    self._bulletViews = {}
    self._bulletEffects = {}
    if self._tornado then
        local node = createNode()
        local actor = self._fromTarget and self._target or self._attacker
        local position = clone(actor:getPosition())
        local start_position = self._start_position
        if start_position and not start_position.effect_by_animation then
            start_position.x = self._rand_position and self._rand_position[app.random(1, #self._rand_position)].x or start_position.x
            start_position.y = self._rand_position and self._rand_position[app.random(1, #self._rand_position)].y or start_position.y
            if start_position.global then
                position.x = start_position.x
                position.y = start_position.y
            else
                position.x = position.x + (self._actor_view_flipx and start_position.x or -start_position.x)
                position.y = position.y + start_position.y
            end
        end
        node:setPosition({x = math.round(position.x), y = math.round(position.y - 1)})
        self._tornadoNode = node
    elseif not self._thorn then
        for i = 1, #self._targets do
            if self._throw then
                local actor = self._fromTarget and self._target or self._attacker
                local target = self._targets[i]
                local throw_time = QBullet.THROW_TIME
                if self._throw_speed then
                    throw_time = q.distOf2Points(actor:getPosition(), target:getPosition()) / self._throw_speed
                end
                local info = {currentTime = 0, totalTime = throw_time}
                info.throwTime = throw_time
                self._throwInfo[target] = info
            end

            -- initialize jump info
            local info = {}
            self._jumpInfo[i] = info
            info.jump_count = 0
            info.jump_traveled_actors = {}
            info.start_position = self._attacker and self._attacker:getPosition() or {x = 0,y = 0}
            info.jump_actors = {}
        end
    end
end
end

if not IsServerSide then
function QBullet:_createBulletEffect()
    self._bulletViews = {}
    self._bulletEffects = {}
    if self._tornado then
        local bulletView = CCNode:create()
        local effectID = self._options.effect_id or self._skill:getBulletEffectID()
        local actor = self._fromTarget and self._target or self._attacker
        local actorView = app.scene:getActorViewFromModel(actor)
        local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, attackerView, nil, self._options)
        local bulletEffect = frontEffect or backEffect
        if bulletEffect ~= nil then
            bulletView:addChild(bulletEffect)
            local position = clone(actor:getPosition())
            local start_position = self._start_position
            if start_position and not start_position.effect_by_animation then
                start_position.x = self._rand_position and self._rand_position[app.random(1, #self._rand_position)].x or start_position.x
                start_position.y = self._rand_position and self._rand_position[app.random(1, #self._rand_position)].y or start_position.y
                if start_position.global then
                    position.x = start_position.x
                    position.y = start_position.y
                else
                    position.x = position.x + (self._actor_view_flipx and start_position.x or -start_position.x)
                    position.y = position.y + start_position.y
                end
            end
            bulletView:setPosition(ccp(math.round(position.x), math.round(position.y - 1)))
            bulletEffect:getSkeletonView():setScaleX(self._actor_view_flipx and 1 or -1)
            if not start_position then
                local dummy = (db:getEffectDummyByID(effectID) or DUMMY.CENTER)
                local bonePosition = actorView:getBonePosition(dummy)
                bulletEffect:setPosition(bonePosition)
            end
            bulletEffect:playSoundEffect(false)
            bulletEffect:playAnimation(bulletEffect:getPlayAnimationName(), not(self._options.is_not_loop))

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

            if self._flip_follow_y and not self._actor_view_flipx then
                bulletEffect:getSkeletonView():setScaleY(-bulletEffect:getSkeletonView():getScaleY())
            end

            if DISPLAY_TORNADO_BULLET_RANGE then
                local hw = self._tornadoSize.width * 0.5
                local hh = self._tornadoSize.height * 0.5
                local bottomLeftPos = {x = -hw, y = -hh}
                local topRightPos = {x = hw, y = hh}
                local vertices = {}
                table.insert(vertices, {bottomLeftPos.x, bottomLeftPos.y})
                table.insert(vertices, {bottomLeftPos.x, topRightPos.y})
                table.insert(vertices, {topRightPos.x, topRightPos.y})
                table.insert(vertices, {topRightPos.x, bottomLeftPos.y})
                local param = {
                    fillColor = ccc4f(0.0, 0.0, 0.0, 0.0),
                    borderWidth = 2,
                    borderColor = display.COLOR_BLUE_C4F
                }
                local drawNode = CCDrawNode:create()
                drawNode:clear()
                drawNode:drawPolygon(vertices, param) -- red color
                bulletView:addChild(drawNode)
            end
        end

        table.insert(self._bulletViews, bulletView)
        table.insert(self._bulletEffects, bulletEffect)
    elseif not self._thorn then 
        for i = 1, #self._targets do
            local bulletView = CCNode:create()
            local effectID = self._options.effect_id or self._skill:getBulletEffectID()
            local actor = self._fromTarget and self._target or self._attacker
            local actorView = app.scene:getActorViewFromModel(actor)
            local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, attackerView, nil, self._options)
            local bulletEffect = frontEffect or backEffect
            if bulletEffect ~= nil then

                -- bullet view initialize and set position
                bulletView:addChild(bulletEffect)
                local position = clone(actor:getPosition())
                local start_position = self._start_position
                if start_position then
                    start_position.x = self._rand_position and self._rand_position[app.random(1, #self._rand_position)].x or start_position.x
                    start_position.y = self._rand_position and self._rand_position[app.random(1, #self._rand_position)].y or start_position.y
                    if start_position.global then
                        position.x = start_position.x
                        position.y = start_position.y
                    else
                        position.x = position.x + (self._actor_view_flipx and start_position.x or -start_position.x)
                        position.y = position.y + start_position.y
                    end
                end
                bulletView:setPosition(ccp(position.x, position.y - 0.1))
                local dummy = (db:getEffectDummyByID(effectID) or DUMMY.CENTER)
                if (not start_position) and actorView and (actorView:getSkeletonActor():isBoneExist(dummy) or actorView:getSkeletonActor().isFca) then
                    local bonePosition = actorView:getBonePosition(dummy)
                    bulletEffect:setPosition(bonePosition)
                end
                bulletEffect:playSoundEffect(false)
                bulletEffect:playAnimation(bulletEffect:getPlayAnimationName(), not(self._options.is_not_loop))
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

                if self._flip_follow_y and not self._actor_view_flipx then
                    bulletEffect:getSkeletonView():setScaleY(-bulletEffect:getSkeletonView():getScaleY())
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
                    bulletView:setScaleX( (target:getPosition().x > bulletView:getPositionX()) and 1 or -1)

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

                -- initialize jump info
                local info = {}
                self._jumpInfo[i] = info
                info.jump_count = 0
                info.jump_traveled_actors = {}
                info.start_position = self._attacker and self._attacker:getPosition() or {x = 0,y = 0}
                info.jump_actors = {}
                if self._options.jump_effect_id then
                    local jumpBulletView = CCNode:create()
                    local jumpBulletEffectId = self._options.jump_effect_id or effectID
                    local frontEffect, backEffect = QBaseEffectView.createEffectByID(jumpBulletEffectId, attackerView, nil, self._options)
                    local jumpBulletEffect = frontEffect or backEffect
                    jumpBulletView:addChild(jumpBulletEffect)
                    jumpBulletView:setPosition(ccp(bulletView:getPosition()))
                    jumpBulletEffect:setPosition(ccp(bulletEffect:getPosition()))
                    jumpBulletEffect:playAnimation(jumpBulletEffect:getPlayAnimationName(), not(self._options.is_not_loop))
                    self._jumpBulletView = jumpBulletView
                    self._jumpBulletEffect = jumpBulletEffect
                    jumpBulletView._dummy_as_position = jumpBulletEffect._dummy_as_position   --为了在QBattleScene:removeAllDummyAsPositionViews()中删除
                    jumpBulletView:setVisible(false)
                    app.scene:addEffectViews(jumpBulletView, {isFrontEffect = true})
                end

                -- initialize rails
                local rail = {}
                rail.sub_rails = {}
                rail.positions = {}
                rail.rotations = {}
                for i = 1, self._rail_number do
                    local sub_rail = {}
                    table.insert(rail.sub_rails, sub_rail)
                    local railBulletView = CCNode:create()
                    local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectID, attackerView, nil, self._options)
                    local railBulletEffect = frontEffect or backEffect
                    railBulletView:addChild(railBulletEffect)
                    railBulletView:setPosition(ccp(bulletView:getPosition()))
                    railBulletEffect:setPosition(ccp(bulletEffect:getPosition()))
                    railBulletEffect:playAnimation(railBulletEffect:getPlayAnimationName(), not(self._options.is_not_loop))
                    sub_rail.bulletView = railBulletView
                    sub_rail.bulletEffect = railBulletEffect

                    sub_rail.bulletEffect:getSkeletonView():setOpacity(255 - i / (self._rail_number + 1) * 255)
                    railBulletView._dummy_as_position = railBulletEffect._dummy_as_position   --为了在QBattleScene:removeAllDummyAsPositionViews()中删除
                    railBulletView:setVisible(false)
                    app.scene:addEffectViews(railBulletView, {isFrontEffect = true})
                end
                table.insert(self._rails, rail)
            end

            table.insert(self._bulletViews, bulletView)
            table.insert(self._bulletEffects, bulletEffect)
        end
    end
end
end

function QBullet:_tornadoMove(dt, bulletEffect, bulletView)
    local width, height = self._tornadoSize.width, self._tornadoSize.height
    if IsServerSide then
        bulletView = self._tornadoNode
    end
    local posx, posy = bulletView:getPosition()
    local bulletSpeed = self._options.speed or self._skill:getBulletSpeed()
    local newx = math.round(posx + dt * bulletSpeed * self._tornadoDirection + QVERY_SMALL_NUMBER)
    local newy = math.round(posy + QVERY_SMALL_NUMBER)
    bulletView:setPositionX(newx)
    bulletView:setPositionY(newy)

    if DEBUG_ENABLE_REPLAY_LOG then
        local line1 = string.format("frameCount:%d, posx:%f, posy:%f", app.battleFrame, newx, newy)
        print(line1)
        table.insert(app.battle.actorHitAndAttackLogs, line1)
    end

    -- 检查是否碰撞了目标
    local actor = self._attacker
    local skill = self._skill
    local targets = {}
    local target_type = skill:getTargetType()
    if target_type == skill.ENEMY then
        targets = app.battle:getMyEnemies(actor)
    elseif target_type == skill.TEAMMATE then
        targets = app.battle:getMyTeammates(actor, false)
    elseif target_type == skill.TEAMMATE_AND_SELF then
        targets = app.battle:getMyTeammates(actor, true)
    else
        targets = app.battle:getMyEnemies(actor)
    end
    for _, target in ipairs(targets) do
        if self._tornadoHitTargets[target] == nil then
            local pos = target:getPosition()
            if pos.x >= (newx) - width / 2 and pos.x <= (newx) + width / 2
                and pos.y >= (newy) - height / 2 and pos.y <= (newy) + height / 2 then
                self:_onBulletHitTarget(target)
                self._tornadoHitTargets[target] = target
                if self._tornado_hit_disappear then
                    return false
                end
            end
        end
    end

    -- 检查是否出了屏幕边缘
    return not (
        (self._tornadoDirection == 1 and newx > BATTLE_SCREEN_WIDTH + width)
        or (self._tornadoDirection == -1 and newx < 0 - width)
        )
end

function QBullet:_thornMove(dt)
    local totalTime = self._bulletTime[1]
    local curTime = (self._thornCurTime or 0) + dt
    local target = self._targets[1]
    if not IsServerSide then
        local effect_id = self._options.effect_id
        local effect_interval = self._options.effect_interval or 125
        local speed = self._options.speed or self._skill:getBulletSpeed()
        local interval_time = effect_interval / speed
        local attacker = self._attacker
        local start = {attacker:getPosition().x, attacker:getPosition().y}
        local stop = {target:getPosition().x, target:getPosition().y}
        local lastTime = self._thornLastTime or 0
        if curTime - lastTime >= interval_time --[[and curTime + interval_time / 2 <= totalTime]] then
            local options = {}
            options.attacker = attacker
            options.attackee = target
            options.targetPosition = {x = math.sampler2(start[1], stop[1], 0, totalTime, curTime), y = math.sampler2(start[2], stop[2], 0, totalTime, curTime)}
            options.scale_actor_face = self._options.scale_actor_face
            options.ground_layer = true
            attacker:playSkillEffect(effect_id, nil, options)
            local options = {}
            options.attacker = attacker
            options.attackee = target
            options.targetPosition = {x = math.sampler2(start[1], stop[1], 0, totalTime, curTime) - 20, y = math.sampler2(start[2], stop[2], 0, totalTime, curTime) + 25}
            options.scale_actor_face = self._options.scale_actor_face
            options.ground_layer = true
            attacker:playSkillEffect(effect_id, nil, options)
            local options = {}
            options.attacker = attacker
            options.attackee = target
            options.targetPosition = {x = math.sampler2(start[1], stop[1], 0, totalTime, curTime) - 25, y = math.sampler2(start[2], stop[2], 0, totalTime, curTime) - 23}
            options.scale_actor_face = self._options.scale_actor_face
            options.ground_layer = true
            attacker:playSkillEffect(effect_id, nil, options)
            lastTime = lastTime + interval_time
        end
        self._thornLastTime = lastTime
    end
    self._thornCurTime = curTime
    if curTime >= totalTime then
        self:_onBulletHitTarget(target)
        return false
    else
        return true
    end
end

if IsServerSide then
function QBullet:_bulletMoveThrow(index, interval, bulletEffect, bulletView, target, accumualtedTime)
    local move
    local info = self._throwInfo[target]
    info.currentTime = info.currentTime + interval
    local adjustCurrentTime = math.pow(accumualtedTime / info.throwTime, self._throw_speed_power) * info.totalTime
    if adjustCurrentTime < info.totalTime then
        move = true
    elseif info.currentTime < info.totalTime + self._throw_hit_duration then
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end            
        move = true
    else
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end   
        move = false
    end

    return move
end
end

if not IsServerSide then
function QBullet:_bulletMoveThrow(index, interval, bulletEffect, bulletView, target, accumualtedTime)
    -- 检查目标是否有移动，是则重新计算轨道
    local currentTargetPosition = clone(target:getPosition())
    local height = target:getCoreRect().size.height
    currentTargetPosition.y = currentTargetPosition.y + height * QBullet.THROW_AT

    currentTargetPosition.x = currentTargetPosition.x + self._throw_at_position.x
    currentTargetPosition.y = currentTargetPosition.y + self._throw_at_position.y

    local move, newPos

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
            newPos = ccp(newX + offsetX, newY + offsetY)
            move = true
        end
    elseif adjustCurrentTime < info.totalTime then
        if info.pos2.x - info.midX ~= 0 then
            local a = (info.pos2.y - info.peakY) / (math.pow(info.pos2.x - info.midX, 2))
            if a > 0 then a = -a end
            local newX = math.sampler(info.midX, info.pos2.x, (adjustCurrentTime - info.fhTime) / info.shTime)
            local newY = a * math.pow(newX - info.midX, 2) + info.peakY
            local offsetX = (currentTargetPosition.x - info.pos2.x) * adjustCurrentTime / info.totalTime
            local offsetY = (currentTargetPosition.y - info.pos2.y) * adjustCurrentTime / info.totalTime
            newPos = ccp(newX + offsetX, newY + offsetY)
            move = true
        end
    elseif info.currentTime < info.totalTime + self._throw_hit_duration then
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end            
        newPos = ccp(currentTargetPosition.x, currentTargetPosition.y)
        bulletView.bulletEffect:getSkeletonView():setAnimationScaleOriginal(1.0)
        move = true
    else
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
            self._targetsHit[index] = true
        end   
        move = false
    end

    table.insert(self._rails[index].positions, 1, {x = bulletView:getPositionX(), y = bulletView:getPositionY()})
    table.insert(self._rails[index].rotations, 1, bulletEffect:getSkeletonView():getRotationX())
    if newPos then
        local _vector = {x = newPos.x - bulletView:getPositionX(),y = newPos.y - bulletView:getPositionY()}
        local _vectorX = {x = 1,y = 0}
        local model_1 = math.sqrt(_vector.x * _vector.x + _vector.y * _vector.y)
        local model_2 = math.sqrt(_vectorX.x * _vectorX.x + _vectorX.y * _vectorX.y)
        local cos = (_vector.x * _vectorX.x + _vector.y * _vectorX.y) / (model_1 * model_2)
        if cos >= -1 and cos <= 1 then
            local radian = math.acos(cos)
            radian = radian > (math.pi / 2) and (math.pi - radian) or radian
            local angel = radian / math.pi * 180
            if (_vector.y * _vector.x) < 0 then
                bulletView:setRotation(angel)
            else
                bulletView:setRotation(-angel)
            end
        end

        bulletView:setScaleX( (newPos.x > bulletView:getPositionX()) and 1 or -1)
        bulletView:setPosition(newPos)
    end

    -- update rails
    if self._rail_number > 0 then
        local rail = self._rails[index]
        local positions = rail.positions
        local rotations = rail.rotations
        if self._targetsHit[index] then
            local length = math.min(#positions, self._rail_inter_frame * self._rail_number)
            for i, sub_rail in ipairs(rail.sub_rails) do
                local pos = positions[length - self._rail_inter_frame * (self._rail_number - i)]
                local rot = rotations[length - self._rail_inter_frame * (self._rail_number - i)]
                if pos then
                    sub_rail.bulletView:setVisible(true)
                    sub_rail.bulletView:setPosition(ccp(pos.x, pos.y))
                    sub_rail.bulletEffect:getSkeletonView():setRotation(rot)
                    -- move = true
                else
                    sub_rail.bulletView:setVisible(false)
                end
            end
            positions[#positions] = nil
        else
            for i, sub_rail in ipairs(rail.sub_rails) do
                local pos = positions[self._rail_inter_frame * i]
                local rot = rotations[self._rail_inter_frame * i]
                if pos then
                    sub_rail.bulletView:setVisible(true)
                    sub_rail.bulletView:setPosition(ccp(pos.x, pos.y))
                    sub_rail.bulletEffect:getSkeletonView():setRotation(rot)
                else
                    break
                end
            end
            positions[self._rail_inter_frame * self._rail_number + 1] = nil
            rotations[self._rail_inter_frame * self._rail_number + 1] = nil
        end

        -- for i, sub_rail in ipairs(rail.sub_rails) do
        --     sub_rail.bulletView:setPosition(ccp(bulletView:getPositionX() - 50, bulletView:getPositionY()))
        --     sub_rail.bulletView:setVisible(true)
        -- end
    end

    return move
end
end

if IsServerSide then
-- return false is move finished
function QBullet:_bulletMove(index, interval, bulletEffect, bulletView, target, accumulatedTime)
    if target == nil then
        return false
    end

    if self._throw then
        return self:_bulletMoveThrow(index, interval, bulletEffect, bulletView, target, accumulatedTime)
    end

    if self._uprise then
        if accumulatedTime <= self._uprise_duration then
            bulletView:setPositionY(bulletView:getPositionY() + interval * self._uprise_height / self._uprise_duration)
            return
        else
            accumulatedTime = accumulatedTime - self._uprise_duration
        end
    end

    local bulletTime = self._bulletTime[index]
    local move = true
    if accumulatedTime >= bulletTime then
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target)
        end
        move = false
    end

    -- test bullet jump
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
            local jump2SelfEarly = false
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

                self._targets[index] = new_target
                local bulletx = target:getPosition().x
                local bullety = target:getPosition().y
                local dist = math.sqrt((self._targets[index]:getPosition().x - bulletx)^2 + (self._targets[index]:getPosition().y - bullety)^2);
                self:_calculateBulletTime(self._options, dist, index)
                self._accumulatedTime = 0
                if jump2SelfEarly then
                    self:_onBulletHitTarget(target, nil, true)  --提前返回触发一次伤害
                    if self._options.jump_info.jump_self_early_buffid then
                        target:applyBuff(self._options.jump_info.jump_self_early_buffid, self._attacker, self._skill) --提前返回给目标加个buff
                    end
                end
                move = true
            else
                move = false
            end
        end
    end

    return move
end
end

if not IsServerSide then
-- return false is move finished
function QBullet:_bulletMove(index, interval, bulletEffect, bulletView, target, accumulatedTime)
    if bulletEffect == nil or bulletView == nil or target == nil then
        return false
    end

    if self._throw then
        return self:_bulletMoveThrow(index, interval, bulletEffect, bulletView, target, accumulatedTime)
    end

    if self._uprise then
        if accumulatedTime <= self._uprise_duration then
            bulletView:setPositionY(bulletView:getPositionY() + interval * self._uprise_height / self._uprise_duration)
            return
        else
            accumulatedTime = accumulatedTime - self._uprise_duration
        end
    end

    local bulletDeltaX, bulletDeltaY = bulletEffect:getPosition()
    local bulletPosX, bulletPosY = bulletView:getPosition()

    -- calculate target position
    local targetPos = clone(target:getPosition())
    local end_position = self._end_position
    if end_position then
        targetPos.x = targetPos.x + (self._actor_view_flipx and end_position.x or -end_position.x)
        targetPos.y = targetPos.y + end_position.y
    end

    local targetPosX, targetPosY = 0, 0, 0
    local hit_dummy = self._hit_dummy[index] or DUMMY.CENTER
    local hit_dummy_found = false
    if hit_dummy then
        local view = app.scene:getActorViewFromModel(target)
        if view and view.getBonePosition and (view:getSkeletonActor():isBoneExist(hit_dummy) or view:getSkeletonActor().isFca) then
            local pos = view:getBonePosition(hit_dummy)
            targetPosX = pos.x
            targetPosY = pos.y
            hit_dummy_found = true
        end
    end
    if hit_dummy_found == false then
        local height = target:getCoreRect().size.height
        targetPosX = 0
        targetPosY = height * 0.5
    end

    local deltaX = targetPos.x + targetPosX - (bulletPosX + bulletDeltaX)   --X方向上子弹位置到目标位置的差值
    local deltaY = targetPos.y + targetPosY - (bulletPosY + bulletDeltaY)   --Y方向上子弹位置到目标位置的差值
    local targetDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)     --子弹位置到目标位置的直线差值
    local actor = self._fromTarget and self._target or self._attacker
    local info = self._jumpInfo[index]
    if info.jump_count > 0 then
        actor = info.jump_actors[info.jump_count]
    end
    if math.xor(deltaX > 0, (targetPos.x + targetPosX - actor:getPosition().x) > 0) then
        targetDistance = 0 - targetDistance
    end
    local bulletSpeed = self._options.speed or self._skill:getBulletSpeed()
    local bulletMoveDistance = interval * bulletSpeed * (targetDistance / math.abs(targetDistance)) --子弹在interval时间内直线移动的距离的初始值
    local bulletTime = self._bulletTime[index]
    if bulletTime then
        -- 控制子弹的飞行时间，而不是控制子弹的速度的方法
        if accumulatedTime >= bulletTime then
            bulletMoveDistance = targetDistance
        else
            local bulletSpeedByTime = targetDistance / (bulletTime - accumulatedTime)
            if targetDistance > 0 then
                bulletMoveDistance = math.min(interval * bulletSpeedByTime, targetDistance)
            else
                bulletMoveDistance = math.max(interval * bulletSpeedByTime, targetDistance)
            end
        end
    end

    local move = true

    if accumulatedTime >= bulletTime then
        bulletMoveDistance = targetDistance
        if self._targetsHit[index] == false then
            self:_onBulletHitTarget(target, {x = bulletPosX, y = bulletPosY})
        end
        move = false
    end

    if not self._targetsHit[index] then
        if targetDistance == 0 then targetDistance = 1 end
        local precent = bulletMoveDistance / targetDistance
        table.insert(self._rails[index].positions, 1, {x = bulletView:getPositionX(), y = bulletView:getPositionY()})
        table.insert(self._rails[index].rotations, 1, bulletEffect:getSkeletonView():getRotationX())
        bulletView:setPosition(ccp(bulletPosX + deltaX * precent, bulletPosY + deltaY * precent))
        bulletEffect:getSkeletonView():setRotation(math.deg(-1.0*math.atan2(deltaY, deltaX)))
    end

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

    -- test bullet jump 
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
            -- 替换弹射子弹特效
            if info.jump_count == 1 and self._options.jump_effect_id then
                bulletView = self._jumpBulletView
                bulletView:setVisible(true)
                bulletEffect = self._jumpBulletEffect
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
                self:_removeBullet(index, true)
                self._bulletViews[index] = bulletView
                self._bulletEffects[index] = bulletEffect
            end
            -- find a new target
            local jumpTarget = self:getNewJumpTarget(index)
            local jump2SelfEarly = false
            
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

                self._targets[index] = new_target
                local bulletx = target:getPosition().x
                local bullety = target:getPosition().y
                local dist = math.sqrt((self._targets[index]:getPosition().x - bulletx)^2 + (self._targets[index]:getPosition().y - bullety)^2);
                self:_calculateBulletTime(self._options, dist, index)
                self._accumulatedTime = 0
                if jump2SelfEarly then
                    self:_onBulletHitTarget(target, nil, true)  --提前返回触发一次伤害
                    if self._options.jump_info.jump_self_early_buffid then
                        target:applyBuff(self._options.jump_info.jump_self_early_buffid, self._attacker, self._skill) --提前返回给目标加个buff
                    end
                end
                move = true
            else
                move = false
            end
        end
    end

    if move == false then
        self._targetsHit[index] = true
        if bulletEffect:isLoopSoundEffect() == true then
            bulletEffect:stopSoundEffect()
        end
        bulletView:setVisible(false)
    end

    -- update rails
    if self._rail_number > 0 then
        local rail = self._rails[index]
        local positions = rail.positions
        local rotations = rail.rotations
        if self._targetsHit[index] then
            local length = math.min(#positions, self._rail_inter_frame * self._rail_number)
            for i, sub_rail in ipairs(rail.sub_rails) do
                local pos = positions[length - self._rail_inter_frame * (self._rail_number - i)]
                local rot = rotations[length - self._rail_inter_frame * (self._rail_number - i)]
                if pos then
                    sub_rail.bulletView:setVisible(true)
                    sub_rail.bulletView:setPosition(ccp(pos.x, pos.y))
                    sub_rail.bulletEffect:getSkeletonView():setRotation(rot)
                    -- move = true
                else
                    sub_rail.bulletView:setVisible(false)
                end
            end
            positions[#positions] = nil
        else
            for i, sub_rail in ipairs(rail.sub_rails) do
                local pos = positions[self._rail_inter_frame * i]
                local rot = rotations[self._rail_inter_frame * i]
                if pos then
                    sub_rail.bulletView:setVisible(true)
                    sub_rail.bulletView:setPosition(ccp(pos.x, pos.y))
                    sub_rail.bulletEffect:getSkeletonView():setRotation(rot)
                else
                    break
                end
            end
            positions[self._rail_inter_frame * self._rail_number + 1] = nil
            rotations[self._rail_inter_frame * self._rail_number + 1] = nil
        end
    end

    return move
end
end

function QBullet:_onBulletHitTarget(target, position, jump2SelfEarly)
    if target == nil or self._options.ignore_hit then
        return
    end

    if not IsServerSide then
        -- play effect
        local options = {isRandomPosition = self._options.is_random_position}
        local effectID = self._options.hit_effect_id
        effectID = effectID or (self._skill and self._skill:getHitEffectID())
        if effectID == "darkness_meteor_fletch_3_2_xinshou" and app.battle:isInTutorial() then
            target:playSkillEffect(effectID, nil, {targetPosition = position})
        else
            if effectID ~= nil then
                if not target:isDead() then
                    target:playSkillEffect(effectID, nil, options)
                else
                    options.dummy_as_position = true
                    target:playSkillEffect(effectID, nil, options)
                end
            end
        end
    end

    -- play damage
    if not target:isDead() then
        if self._skill then
            local skill = self._skill
            local split_number = skill:getDamageSplit() and #self._targets or 0
            local isAOE = skill:getRangeType() == skill.MULTIPLE
            local total_damage = 0
            local damageScale = jump2SelfEarly and self._options.damage_scale_back_self or self._options.damage_scale -- 伤害放大倍数

            -- 本次hit临时改变的actor属性
            if self._options.property_promotion then
                for k,v in pairs(self._options.property_promotion) do
                    self._skill:addPropertyPromotion(k,v)
                end
            end

            if self._options.single and isAOE and (target ~= self._attacker or self._is_jump_teammate) then
                -- AOE技能的单发子弹造成AOE伤害
                local attacker = self._attacker
                local targets = attacker:getMultipleTargetWithSkill(skill, target)
                for _, each_target in ipairs(targets) do
                    local _, damage = attacker:hit(skill, each_target, split_number, nil, nil, true, true, damageScale)
                    total_damage = total_damage + (damage or 0)
                end
                self:applyBuff(targets)
            elseif target ~= self._attacker or self._is_jump_teammate then
                -- 单体技能，或者AOE技能的多发子弹造成单体伤害
                local _, damage = self._attacker:hit(self._skill, target, split_number, nil, nil, isAOE, true, damageScale)
                local targets = {target}
                self:applyBuff(targets)
                total_damage = damage or 0
            end

            if self._options.jump_info and self._options.jump_info.jump_self_buffid and target == self._attacker then
                self._attacker:applyBuff(self._options.jump_info.jump_self_buffid, self._attacker, self._skill)
            end

            if self._options.property_promotion then
                self._skill:removePropertyPromotion()
            end
    
            if total_damage > 0 and skill:getDrainBloodPercent() > 0 then
                local percent = skill:getDrainBloodPercent()
                local for_teammate = skill:getDrainBloodForTeammate()
                local split = skill:getDrainBloodSplit()
                local total_drain_ammount = total_damage * percent
                local attacker = self._attacker
                if for_teammate then
                    local teammates = app.battle:getMyTeammates(attacker, true)
                    local each_drain_ammount = split and (total_drain_ammount / math.max(#teammates, 1)) or total_drain_ammount
                    for _, teammate in ipairs(teammates) do
                        local _, dHp = teammate:increaseHp(each_drain_ammount, attacker, skill)
                        if dHp > 0 then
                            teammate:dispatchEvent({name = attacker.UNDER_ATTACK_EVENT, isTreat = true, 
                                isCritical = false, tip = "", rawTip = {
                                    isHero = teammate:getType() == ACTOR_TYPES.HERO, 
                                    isCritical = false, 
                                    isTreat = true,
                                    number = dHp,
                                }})
                        end
                    end
                else
                    local _, dHp = attacker:increaseHp(total_drain_ammount, attacker, skill)
                    if dHp > 0 then
                        attacker:dispatchEvent({name = attacker.UNDER_ATTACK_EVENT, isTreat = true, 
                            isCritical = false, tip = "", rawTip = {
                                isHero = attacker:getType() == ACTOR_TYPES.HERO, 
                                isCritical = false, 
                                isTreat = true,
                                number = dHp,
                            }})
                    end
                end
            end
        elseif self._options.hp then
            local hp = math.ceil(self._options.hp)
            if not target:isDead() then
                if hp > 0 then
                    local _, dHp = target:increaseHp(hp, self._attacker, self._skill)
                    if dHp > 0 then
                        target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = true, isCritical = false, tip = "+" .. tostring(hp),
                            rawTip = {
                                isHero = target:getType() ~= ACTOR_TYPES.NPC, 
                                isDodge = false, 
                                isBlock = false, 
                                isCritical = false, 
                                isTreat = true, 
                                number = dHp
                            }})
                    end
                elseif hp < 0 then
                    local _, damage = target:decreaseHp(-hp, self._attacker, self._skill, nil, nil, nil, nil, nil, true)
                    target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = true, isCritical = false, tip = tostring(-hp),
                        rawTip = {
                            isHero = target:getType() ~= ACTOR_TYPES.NPC, 
                            isDodge = false, 
                            isBlock = false, 
                            isCritical = false, 
                            isTreat = false, 
                            number = damage
                        }})
                end
            end
        end
    end

    -- play trap
    if self._skill then
        local trapId = self._skill:getTrapId()
        if trapId ~= nil then
            local trapId, level = q.parseIDAndLevel(trapId)
            local trapDirector = QTrapDirector.new(trapId, target:getPosition(), self._attacker:getType(), self._attacker, level, self._skill)
            app.battle:addTrapDirector(trapDirector)
        end
    end

    -- play trigger skill
    if self._skill then
        local attacker = self._attacker
        local target = target
        local skill = self._skill
        local skillId, level = skill:getTriggerSkillId()
        if skillId then
            if level == "y" then level = skill:getSkillLevel() end
            local triggerSkill = attacker._skills[skillId]
            if triggerSkill == nil then
                local QSkill = skill
                triggerSkill = QSkill.new(skillId, db:getSkillByID(skillId), attacker, level)
                triggerSkill:setIsTriggeredSkill(true)
                attacker._skills[skillId] = triggerSkill
            end
            local sbDirector = attacker:triggerAttack(triggerSkill, target)
        end
    end

    -- time gear
    if self._options.hit_time_gear and not app.battle:isInBulletTime() then
        local hit_time_gear = self._options.hit_time_gear
        assert(type(hit_time_gear.time_gear) == "number" and type(hit_time_gear.duration) == "number", "")
        app.battle:setTimeGear(hit_time_gear.time_gear)
        app.battle:performWithDelay(function()
            app.battle:setTimeGear(1)
        end, hit_time_gear.duration, nil, true, false, true)
    end

    if not IsServerSide then
        -- shake screen
        if self._shakeOptions then
            local shake = self._shakeOptions
            app.scene:shakeScreen(shake.amplitude, shake.duration, shake.count)
        end
    end
end

function QBullet:getNewJumpTarget(index)
    local info = self._jumpInfo[index]
    local old_target = self._targets[index]
    if not info or not old_target then return nil end
    local function jump_filter_func(target)
        if target == old_target then
            return false
        end

        local target_pos = target:getPosition()
        if self._jump_range > 0 and q.distOf2PointsSquare(info.start_position,target_pos) > self._jump_range then --过滤区域
            return false
        end

        if self._jump_distance > 0 and q.distOf2PointsSquare(old_target:getPosition(),target_pos) > self._jump_distance then --过滤距离
            return false
        end

        if self._jump_outside then
            local area = app.grid:getRangeArea()
            if target_pos.x < area.left or target_pos.x>area.right or target_pos.y > area.top or target_pos < area.bottom then --过滤屏幕范围
                return false
            end
        end

        if info.jump_traveled_actors[target] and info.jump_traveled_actors[target] > 0 then -- 过滤重复次数
            return false
        end
        return true
    end

    local target_list = {}
    if self._is_jump_teammate then
        table.mergeForArray(target_list,app.battle:getMyTeammates(self._attacker,true),jump_filter_func)
    else
        table.mergeForArray(target_list,app.battle:getMyEnemies(self._attacker,true),jump_filter_func)
    end
    table.sort(target_list,function(a,b) 
                            return q.distOf2PointsSquare(a:getPosition(),old_target:getPosition()) > q.distOf2PointsSquare(b:getPosition(),old_target:getPosition())
                            end)
    --默认就远弹射，可配置选择就近弹射,随机距离弹射
    local result = target_list[1]
    if self._options.jump_info.near_first then
        result = target_list[#target_list]  --target_list中包括本次命中的目标，-1排除掉
    end
    if self._options.jump_info.random_get_new_target then
        local index = app.random(1, #target_list)   --target_list中包括本次命中的目标，-1排除掉
        result = target_list[index]
    end

    return result   --result可能为nil

end

function QBullet:getAttacker()
    return self._attacker
end

function QBullet:applyBuff(targets)
    if self._options.attacker_buff_id then
        self._attacker:applyBuff(self._options.attacker_buff_id, self._attacker, self._skill)
    end
    if self._options.target_buff_id then
        for k,target in ipairs(targets) do
            target:applyBuff(self._options.target_buff_id, self._attacker, self._skill)
        end
    end
end

return QBullet
