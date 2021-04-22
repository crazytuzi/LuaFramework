
local QAIAction = import("..base.QAIAction")
local QAIDPS = class("QAIDPS", QAIAction)

function QAIDPS:ctor( options )
    QAIDPS.super.ctor(self, options)
    self:setDesc("")
    self._frameCount = 0
end

function QAIDPS:_evaluate(args)
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

    return true
end

function QAIDPS:_repositionForFanSkill(actor)
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
        -- actor:getMultipleTargetWithSkill(skill, actor:getTarget(), nil)
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

function QAIDPS:_repositionForRectSkill(actor)
    if self._rectSkill == nil then
        return false
    end

    if actor:isWalking() or (actor:getCurrentSkill() and not actor:getCurrentSkill():isTalentSkill()) then
        return false
    end

    local skill = self._rectSkill
    if skill:isReady() == false then
        return false
    end

    if app.battle:isDisableAI() then
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

function QAIDPS:_repositionForMoveSkill(actor)
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

function QAIDPS:_blink(actor)
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
            self.blinkSkill = blinkSkill
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
        local dist_max = 3 / 6 * nx
        local weights = {}
        local index = 1
        for i = 1, nx do
            for j = 1, ny do
                weights[index] = 0
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

function QAIDPS:_charge(actor)
    local chargeSkill = self._chargeSkill

    if chargeSkill == nil then
        for _, skill in pairs(actor:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_ATTACK then
                chargeSkill = skill
                break
            end
        end

        if chargeSkill == nil then
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

function QAIDPS:_attack(actor)
    if app.battle and app.battle:isPausedBetweenWave() then
        return false
    end

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
        local count = 0
        for _, target in ipairs(targets) do
            local pos = target:getPosition()
            if pos.x > BATTLE_AREA.left and pos.x < BATTLE_AREA.right then
                count = count + 1
            end
        end
        if count < 1 then
            return false
        end
    end

    local range = app.grid:getRangeArea()
    local pos = actor:getPosition()
    if pos.x < range.left or pos.x > range.right then
        return false
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

function QAIDPS:_execute(args)
    if not args.actor then
        return false
    end

    local actor = args.actor

    self._frameCount = self._frameCount + 1

    if self:_repositionForRectSkill(actor) then
        return false
    end

    if self:_repositionForFanSkill(actor) then
        return false
    end

    if self:_repositionForMoveSkill(actor) then
        return false
    end

    if not args.actor:isForceAuto() then
        return false
    end

    -- if self:_charge(actor) then
    --     return true
    -- end

    -- if self:_blink(actor) then
    --     return true
    -- end

    if self:_attack(actor) then
        return true
    end

    return false
end

-- dps      需要做的事情优先等级，保命｛躲避aoe--躲避近战攻击，可以使用闪现等快速逃脱技能｝-释放伤害技能{对多目标释放aoe技能--对单体目标释放单体技能}
-- health   需要做的事情优先等级，群体治疗｛群体血量少于一定程度时释放群体治疗技能｝-保命{[同dps保命]--自己血量少于一定比例时治疗自己}-治疗t-治疗血少的角色
-- t        需要做的事情优先等级，拉仇恨｛寻找被攻击的非t魂师，嘲讽其攻击者｝-保命｛血量低时躲避aoe｝

-- local function QAIDPS:_avoidAOE() 
--     -- 检索trap

--     -- 检索敌方正在释放的aoe技能

--     -- 寻找出最近的脱离地点

--     -- 闪现过去，或者走过去
-- end

-- local function QAIDPS:_avoidMeleeAttack() 
--     -- 检索攻击自己的近战

--     -- 反方向闪现，或者走过去
-- end

function QAIDPS:_attackMultiple() 
    -- 寻找自己的可以释放的aoe技能
    local skill
    if skill:getRangeType() ~= skill.MULTIPLE then
        return false
    end

    if skill:isNeedATarget() then

    else
        local targets = actor:getMultipleTargetWithSkill(skill)
        if #targets >= 1 then

        end
    end

    -- 寻找可以释放的中心目标（可能是任何场上任何角色），评估效果

    -- 对达到标准的最高效果的中心目标释放
end

-- local function QAIDPS:_findBestTarget()
--     -- 寻找有效血量最低的目标
-- end

function QAIDPS:_attackSingle() 
    -- 寻找可以释放的单体技能

    -- 释放单体伤害技能
end

function QAIDPS:_treatMultiple() 
    -- 寻找可以释放的群体治疗技能

    -- 寻找可以释放的中心目标（可能是任何场上的角色），评估效果

    -- 对达到标准的最高效果的中心目标释放
end

function QAIDPS:_treatSingle() 
    -- 寻找有效血量最低的目标

    -- 释放单体治疗技能
end

function QAIDPS:_attackHatred() 
    -- 寻找当前没在攻击自己的敌人，设置其为目标
end

-- local function QAIDPS:_tauntMultiple() 
--     -- 寻找当前没在攻击自己的敌人

--     -- 释放群体嘲讽技能
-- end

-- local function QAIDPS:_tauntSingle() 

-- end


return QAIDPS