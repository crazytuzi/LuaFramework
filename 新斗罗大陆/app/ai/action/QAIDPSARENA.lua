
local QAIAction = import("..base.QAIAction")
local QAIDPSARENA = class("QAIDPSARENA", QAIAction)

function QAIDPSARENA:ctor( options )
    QAIDPSARENA.super.ctor(self, options)
    self:setDesc("")

    if not QAIDPSARENA.TARGET_ORDER then
        local TARGET_ORDER = {}
        if options.target_order then
            for _, obj in pairs(options.target_order) do
                TARGET_ORDER[obj.actor_id] = obj.order
            end
        end

        QAIDPSARENA.TARGET_ORDER = TARGET_ORDER
    end
    self._frameCount = 0
    self:createRegulator(5)
end

function QAIDPSARENA:_evaluate(args)
    if not args.actor then
        return false
    end

    -- 检查远程魂师是否有需要走位的矩形AOE技能
    if self._checkRectSkill == nil then
        if args.actor:isRanged() then
            for _, skill in pairs(args.actor:getActiveSkills()) do
                if skill:getRangeType() == skill.MULTIPLE and skill:getZoneType() == skill.ZONE_RECT and skill:getAttackType() == skill.ATTACK then
                    self._rectSkill = skill
                    break
                end
            end
        end
        self._checkRectSkill = true
    end
    -- 检查远程魂师是否有需要走位的扇形AOE技能
    if self._checkFanSkill == nil then
        if args.actor:isRanged() then
            for _, skill in pairs(args.actor:getActiveSkills()) do
                if skill:getRangeType() == skill.MULTIPLE and skill:getZoneType() == skill.ZONE_FAN and skill:getSectorCenter() == skill.CENTER_SELF and skill:getAttackType() == skill.ATTACK and skill:getTriggerCondition() ~= skill.TRIGGER_CONDITION_DRAG then
                    self._fanSkill = skill
                    break
                end
            end
        end
        self._checkFanSkill = true
    end
    -- 检查是否有需要提前走位的技能
    if self._checkMoveSkill == nil then
        for _, skill in pairs(args.actor:getActiveSkills()) do
            if skill:getAttackType() == skill.ATTACK and skill:isMoveSkill() then
                self._moveSkill = skill
                break
            end
        end
        self._checkMoveSkill = true
    end

    if not self._target_order then
        self._target_order = QAIDPSARENA.TARGET_ORDER[args.actor:getActorID()]
        if not self._target_order then
            if app.battle:isInSunwell() or app.battle:isInGlory() or app.battle:isInSilverMine() or app.battle:isInTotemChallenge() then
                self._target_order = {1,2,3,4}
            elseif app.battle:isInArena() then
                -- self._target_order = {4,3,2,1}
                self._target_order = {1,2,3,4}
            else
                self._target_order = {1,2,3,4}
            end
        end

        if app.battle:isInSunwell() and args.actor:getType() == ACTOR_TYPES.NPC then
            local sunwarTargetOrder = app.battle:getSunWarCurrentWaveTargetOrder() 
            if sunwarTargetOrder and #sunwarTargetOrder > 0 then
                self._target_order = sunwarTargetOrder
            end
        end

        if app.battle:isInGlory() and args.actor:getType() == ACTOR_TYPES.NPC then
            local gloryTargetOrder = app.battle:getGloryCurrentFloorTargetOrder()
            if gloryTargetOrder and #gloryTargetOrder > 0 then
                self._target_order = gloryTargetOrder
            end
        end
        
        -- nzhang: 处理由于服务器错误导致的多于4个魂师上场的情况
        table.insert(self._target_order, 5)
        table.insert(self._target_order, 6)
        table.insert(self._target_order, 7)
        table.insert(self._target_order, 8)
    end

    if not self._targets or args.actor:getAIReloadTargets() then
        if args.actor:getAIReloadTargets() then
            args.actor:setAIReloadTargets(false)
        end
        local enemies = app.battle:getMyEnemies(args.actor)
        local filted_enemies = {}
        for _, enemy in ipairs(enemies) do
            if not enemy:isPet() and not enemy:isSupport() and not enemy:isSoulSpirit() then
                if enemy:isGhost() then
                    if enemy:isAttackedGhost() then
                      table.insert(filted_enemies, enemy)
                    end
                else
                   table.insert(filted_enemies, enemy)
                end
            end
        end
        local target = nil
        local arr = {}
        for index, enemy in ipairs(filted_enemies) do
            arr[#filted_enemies + 1 - index] = enemy
        end
        self._targets = arr
    end

    return true
end

function QAIDPSARENA:_repositionForFanSkill(actor)
    if self._fanSkill == nil then
        return false
    end

    if app.battle:isDisableAI() then
        return false
    end

    if self._lastFanSkillReposition and app.battle:getTime() - self._lastFanSkillReposition < 1.0 then
        return false
    else
        self._lastFanSkillReposition = app.battle:getTime()
    end

    if actor:isWalking() or (actor:getCurrentSkill() and not actor:getCurrentSkill():isTalentSkill()) then
        return false
    end

    local skill = self._fanSkill
    if skill:isReady() == false then
        return false
    end

    if #actor:getMultipleTargetWithSkill(skill) > 0 then
        return false
    end

    local pos = clone(actor:getPosition())
    local radius_half = skill:getSectorRadius() * global.pixel_per_unit / 2
    local xmin, xmax = pos.x - radius_half, pos.x + radius_half
    if actor:isFlipX() then
        xmin = xmin + radius_half
        xmax = xmax + radius_half
    else
        xmin = xmin - radius_half
        xmax = xmax - radius_half
    end
    if actor:getTarget() then
        local candidate = actor:getTarget()
        local candidatey = candidate:getPosition().y
        -- 然后检查x轴上的移动
        local cpos = candidate:getPosition()
        actor:_cancelCurrentSkill()
        app.grid:moveActorTo(actor, {x = pos.x + (cpos.x - (xmin + xmax) / 2), y = cpos.y})
        return true
    else
        return false
    end
end

local function calcX(actor, targetPos, distance)
    local x = 0
    if actor:isFlipX() then
        x = targetPos.x - distance
    else
        x = targetPos.x + distance
    end
    return x
end

local function isXOut(x)
    return x < BATTLE_AREA.left or x > BATTLE_AREA.right
end

function QAIDPSARENA:_repositionForRectSkill(actor)
    if self._rectSkill == nil then
        return false
    end

    if app.battle:isDisableAI() then
        return false
    end

    if actor:isWalking() or (actor:getCurrentSkill() and not actor:getCurrentSkill():isTalentSkill()) then
        return false
    end

    local skill = self._rectSkill
    if skill:isReady() == false then
        return false
    end

    local pos = clone(actor:getPosition())
    local width = skill:getRectWidth() * global.pixel_per_unit
    local height = skill:getRectHeight() * global.pixel_per_unit

    -- local xmin, xmax, ymin, ymax = pos.x - width / 2, pos.x + width / 2, pos.y - height / 2, pos.y + height / 2
    -- if actor:isFlipX() then
    --     xmin = xmin + width / 2
    --     xmax = xmax + width / 2
    -- else
    --     xmin = xmin - width / 2
    --     xmax = xmax - width / 2
    -- end

    local enemies = app.battle:getMyEnemies(actor)
    -- 先在y轴上移动寻找合适的目标
    local candidate, candidatey = nil, nil
    if actor:getTarget() then
        candidate = actor:getTarget()
        -- candidatey = candidate:getPosition().y
    else
        return false
        -- for _, enemy in ipairs(enemies) do
        --     if not enmey:isDead() then
        --         local epos = enemy:getPosition()
        --         -- 完全在AOE区域里了，不需要移动
        --         if epos.x > xmin and epos.x < xmax and epos.y > ymin and epos.y < ymax then
        --             return false
        --         end
        --         if candidate == nil then
        --             candidate = enemy
        --             candidatey = epos.y
        --         elseif math.abs(epos.y - pos.y) < math.abs(candidatey - pos.y) then
        --             candidate = enmey
        --             candidatey = epos.y
        --         end
        --     end
        -- end
    end
    if candidate == nil then
        return false
    end

    local newFrame = self._frameCount

    -- 防止抽搐,2帧内连续调用这个会走这个函数
    if self._rect_last_frame and self._rect_last_pos then
        if (newFrame - self._rect_last_frame) <= 2 then
            self._rect_invalid_count = self._rect_invalid_count + 1
            if self._rect_invalid_count >= 2 then
                self._rect_last_pos.x = calcX(actor, self._rect_last_pos, actor:getRect().size.width)
                actor:_cancelCurrentSkill()
                app.grid:moveActorTo(actor, self._rect_last_pos)

                self._rect_last_frame = self._frameCount
                self._rect_invalid_count = 0
                self._rect_last_pos = nil
                return true
            else
                return false
            end
        end
    end

    -- 然后检查x轴上的移动
    local cpos = candidate:getPosition()

    --[[
        1、当攻击者和目标之间的X轴距离大于技能攻击范围，则攻击者走到离目标2/3技能攻击范围的点上；
        2、当攻击者和目标之间的X轴距离在1/3~2/3的技能攻击范围之间，则攻击者直接在Y轴上位移；
        3、当攻击者和目标之间的X轴距离在0~1/3的技能攻击范围之间，则攻击者走到离目标1/3技能攻击范围的点上；
        4、若攻击者位移发生无法位移到坐标上时，则向远处多一个攻击者包围框直径位移移动；
    ]]
    local finalPos = {x = 0, y = cpos.y}
    local d13 = 0.33333 * width
    local d23 = 0.66667 * width

    local xDistance = math.abs(pos.x - cpos.x)
    if xDistance > d23 then
        finalPos.x = calcX(actor, cpos, d23)
    elseif xDistance > d13 and xDistance <= d23 then
        finalPos.x = pos.x
    else
        finalPos.x = calcX(actor, cpos, d13)
    end

    --算出来的位置在屏幕区域外
    if isXOut(finalPos.x) then
        local out1 = isXOut(cpos.x - candidate:getRect().size.width / 2)
        local out2 = isXOut(cpos.x + candidate:getRect().size.width / 2)
        --目标贴着墙
        if out1 or out2 then
            finalPos.x = calcX(actor, cpos, -d13)
        else
            --目标没有贴着墙
            actor:_cancelCurrentSkill()
            app.grid:moveActorTo(actor, {x = pos.x, y = cpos.y})
            return true
        end
    end

    actor:_cancelCurrentSkill()
    app.grid:moveActorTo(actor, finalPos)

    self._rect_last_pos = finalPos
    self._rect_last_frame = self._frameCount
    self._rect_invalid_count = 0
    return true
end

function QAIDPSARENA:_repositionForMoveSkill(actor)
    if self._moveSkill == nil then
        return false
    end

    if actor:isWalking() or (actor:getCurrentSkill() and not actor:getCurrentSkill():isTalentSkill()) then
        return false
    end

    local skill = self._moveSkill
    if skill:isReady() == false then
        return false
    end

    local pos = clone(actor:getPosition())
    local target = actor:getTarget()
    
    if target == nil or target:isDead() then
        return fasle
    end

    local targetPos = clone(target:getPosition())

    if pos.y == targetPos.y then
        return false
    end

    app.grid:moveActorTo(actor, {x = pos.x, y = targetPos.y})

    return true
end

function QAIDPSARENA:_pickTarget(actor)
    if app.battle:isInSunwell() or app.battle:isInGlory() or app.battle:isInTotemChallenge() then
        if actor:getTarget() and not actor:getTarget():isDead() and not actor:getTarget():isExile() then
            return
        end
    elseif app.battle:isInArena() then
        -- if actor:getTarget() then
        --     return
        -- end
    end    

    for index, enemy in ipairs(self._targets) do
        if enemy:isSupportHero() and not enemy:isActiveSupport() then
            table.remove(self._targets, index)
            break
        end
    end

    local target = nil
    for _, index in ipairs(self._target_order) do
        local enemy = self._targets[index]
        if enemy and not enemy:isDead() and not enemy:isExile() then
            target = enemy
            break
        end
    end

    if target and actor:getTarget() ~= target then
        actor:setTarget(target)
    end
end

function QAIDPSARENA:_blinkOrCharge(actor)
    if self._blinkOrChargeSkill == false then
        return
    end

    local blinkOrChargeSkill = self._blinkOrChargeSkill

    if blinkOrChargeSkill == nil then
        for _, skill in pairs(actor:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK then
                blinkOrChargeSkill = skill
                break
            end
        end

        if blinkOrChargeSkill == nil then
            self._blinkOrChargeSkill = false
            return
        end
    end

    if not actor:canAttack(blinkOrChargeSkill) then
        return false
    end

    --远程闪现 近战冲锋
    if actor:isRanged() then
        if blinkOrChargeSkill:isExtraConditionMet() == false then
            return false
        end

        local enemies = app.battle:getMyEnemies(actor)
        local beingattacked = false
        for _, enemy in ipairs(enemies) do
            if not enemy:isRanged() then
                if enemy:isAttacking() and enemy:getCurrentSkillTarget() == actor then
                    beingattacked = true
                    break
                end
            end
        end

        if beingattacked then
            local positions = {}
            for _, enemy in ipairs(enemies) do
                if not enemy:isRanged() then
                    local _, gridPos = app.grid:_toGridPos(enemy:getPosition().x, enemy:getPosition().y)
                    table.insert(positions, gridPos)
                end
            end
            local nx, ny = app.grid._nx, app.grid._ny
            local forbid_length = math.ceil(ny / 3)
            local dist_max = 3 / 6 * nx
            local weights = {}
            local index = 1
            for i = 1, nx do
                for j = 1, ny do
                    weights[index] = 0

                    if (i < forbid_length and j > ny - forbid_length)
                        or (i > nx - forbid_length and j > ny - forbid_length)
                        or (i > nx - forbid_length and j < forbid_length) then
                        weights[index] = -999999
                    end

                    index = index + 1
                end
            end
            for _, pos in ipairs(positions) do
                local index = 1
                for i = 1, nx do
                    for j = 1, ny do
                        weights[index] = weights[index] + math.min(q.distOf2Points(pos, {x = i, y = j}), dist_max)
                        index = index + 1
                    end
                end
            end
            local weight = 0
            local candidates = {}
            local index = 1
            for i = 1, nx do
                for j = 1, ny do
                    if weight > weights[index] then
                    elseif weight == weights[index] then
                        table.insert(candidates, {x = i, y = j})
                    else
                        weight = weights[index]
                        candidates = {}
                        table.insert(candidates, {x = i, y = j})
                    end
                    index = index + 1
                end
            end
            if #candidates > 0 then
                local screenPos = app.grid:_toScreenPos(candidates[app.random(1, #candidates)])
                actor._dragPosition = screenPos
                actor._targetPosition = screenPos
                actor:attack(blinkOrChargeSkill)
                return true
            end
        end
    else
        if blinkOrChargeSkill:isNeedATarget() then
            local target = actor:getTarget()
            if target == nil or target:isDead() then
                return false
            elseif blinkOrChargeSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
                return false
            end
        end
        actor:attack(blinkOrChargeSkill, true)
        return true
    end

end

function QAIDPSARENA:_blink(actor)
    if not actor:isRanged() or self._blinkSkill == false then
        return
    end

    local blinkSkill = self._blinkSkill

    if blinkSkill == nil then
        for _, skill in pairs(actor:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG then
                blinkSkill = skill
                break
            end
        end

        if blinkSkill == nil then
            self._blinkSkill = false
            return
        else
            self._blinkSkill = blinkSkill
        end
    end

    if not actor:canAttack(blinkSkill) then
        return false
    end

    local enemies = app.battle:getMyEnemies(actor)
    local beingattacked = false
    for _, enemy in ipairs(enemies) do
        if not enemy:isRanged() then
            if enemy:isAttacking() and enemy:getCurrentSkillTarget() == actor then
                beingattacked = true
                break
            end
        end
    end

    if beingattacked then
        local positions = {}
        for _, enemy in ipairs(enemies) do
            if not enemy:isRanged() then
                local _, gridPos = app.grid:_toGridPos(enemy:getPosition().x, enemy:getPosition().y)
                table.insert(positions, gridPos)
            end
        end
        local nx, ny = app.grid._nx, app.grid._ny
        local forbid_length = math.ceil(ny / 3)
        local dist_max = 3 / 6 * nx
        local weights = {}
        local index = 1
        for i = 1, nx do
            for j = 1, ny do
                weights[index] = 0

                if (i < forbid_length and j > ny - forbid_length)
                    or (i > nx - forbid_length and j > ny - forbid_length)
                    or (i > nx - forbid_length and j < forbid_length) then
                    weights[index] = -999999
                end

                index = index + 1
            end
        end
        for _, pos in ipairs(positions) do
            local index = 1
            for i = 1, nx do
                for j = 1, ny do
                    weights[index] = weights[index] + math.min(q.distOf2Points(pos, {x = i, y = j}), dist_max)
                    index = index + 1
                end
            end
        end
        local weight = 0
        local candidates = {}
        local index = 1
        for i = 1, nx do
            for j = 1, ny do
                if weight > weights[index] then
                elseif weight == weights[index] then
                    table.insert(candidates, {x = i, y = j})
                else
                    weight = weights[index]
                    candidates = {}
                    table.insert(candidates, {x = i, y = j})
                end
                index = index + 1
            end
        end
        if #candidates > 0 then
            local screenPos = app.grid:_toScreenPos(candidates[app.random(1, #candidates)])
            actor._dragPosition = screenPos
            actor._targetPosition = screenPos
            actor:attack(blinkSkill)
        end
        candidates = nil
    end
end

function QAIDPSARENA:_charge(actor)
    if actor:isRanged() or self._chargeSkill == false then
        return
    end

    local chargeSkill = self._chargeSkill

    if chargeSkill == nil then
        for _, skill in pairs(actor:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_ATTACK then
                chargeSkill = skill
                break
            end
        end

        if chargeSkill == nil then
            self._chargeSkill = false
            return
        else
            self._chargeSkill = chargeSkill
        end
    end

    if not actor:canAttack(chargeSkill) then
        return false
    end

    if chargeSkill:isNeedATarget() then
        local target = actor:getTarget()
        if target == nil or target:isDead() then
            return false
        elseif chargeSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
            return false
        end
    end

    actor:attack(chargeSkill, true)

    return true
end

function QAIDPSARENA:_attack(actor)
    local manualSkill = actor:getManualSkills()[next(actor:getManualSkills())]
    if manualSkill == nil then
        return false
    end

    -- 检查自动释放的连击点数
    if manualSkill:isNeedComboPoints() and actor:getComboPoints() < actor:getComboPointsAuto() then
        return false
    end

    -- 检查技能是否能够使用
    if not actor:canAttack(manualSkill) then
        return false
    end

    if manualSkill:isNeedATarget() then
        local target = actor:getTarget()
        if target == nil or target:isDead() then
            return false
        elseif manualSkill:getRangeType() == manualSkill.SINGLE and manualSkill:isInSkillRange(actor:getPosition(), target:getPosition(), actor, target, false) == false then
            return false
        end
    end

    local skill = manualSkill
    if skill:getRangeType() == skill.MULTIPLE and skill:isNeedATarget() == false then
        local targets = actor:getMultipleTargetWithSkill(skill)
        if #targets < 1 then
            return false
        end
    end

    -- 检查斩杀线
    local execute_percent = skill:getExecutePercent()
    if execute_percent and execute_percent > 0 then
        local target = actor:getTarget()
        if target and not target:isBoss() then
            local current_percent = target:getHp() / target:getMaxHp()
            if current_percent > execute_percent then
                return false
            end
        end
    end

    actor:attack(manualSkill, true)

    return true
end

function QAIDPSARENA:_execute(args)
    local actor = args.actor
    self._frameCount =  self._frameCount + 1
    if self._regulator() then
        self:_pickTarget(actor)

        if self:_repositionForRectSkill(actor) then
            return false
        end

        if self:_repositionForFanSkill(actor) then
            return false
        end

        if self:_repositionForMoveSkill(actor) then
            return false
        end

        if actor:isForceAuto() then
            if not (((app.battle:isInSunwell() and app.battle:isSunwellAllowControl()) or (app.battle:isInArena() and app.battle:isArenaAllowControl())) and actor:getType() == ACTOR_TYPES.HERO) then
                if self:_blinkOrCharge(actor) then
                    return true
                end
                if self:_blink(actor) then
                    return true
                end
                if self:_charge(actor) then
                    return true
                end
            end

            if self:_attack(actor) then
                return true
            end
        end
    else
        if actor:isForceAuto() then
            if self:_attack(actor) then
                return true
            end
        end
    end

    return true
end


return QAIDPSARENA