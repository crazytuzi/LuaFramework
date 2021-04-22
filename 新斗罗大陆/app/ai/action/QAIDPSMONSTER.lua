
local QAIAction = import("..base.QAIAction")
local QAIDPSMONSTER = class("QAIDPSMONSTER", QAIAction)

function QAIDPSMONSTER:ctor( options )
    QAIDPSMONSTER.super.ctor(self, options)
    self:setDesc("")

    if not QAIDPSMONSTER.TARGET_ORDER then
        local TARGET_ORDER = {}
        if options.target_order then
            for _, obj in pairs(options.target_order) do
                TARGET_ORDER[obj.actor_id] = obj.order
            end
        end

        QAIDPSMONSTER.TARGET_ORDER = TARGET_ORDER
    end

    self:createRegulator(5)
end

function QAIDPSMONSTER:_evaluate(args)
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
                if skill:getRangeType() == skill.MULTIPLE and skill:getZoneType() == skill.ZONE_FAN and skill:getSectorCenter() == skill.CENTER_SELF and skill:getAttackType() == skill.ATTACK then
                    self._fanSkill = skill
                    break
                end
            end
        end
        self._checkFanSkill = true
    end

    if not self._target_order then
        self._target_order = QAIDPSMONSTER.TARGET_ORDER[args.actor:getActorID()]
        if not self._target_order then
            self._target_order = {1,2,3,4}
        end
    end

    if not self._targets then
        local enemies = app.battle:getMyEnemies(args.actor)
        local target = nil
        local arr = {}
        for index, enemy in ipairs(enemies) do
            arr[#enemies + 1 - index] = enemy
        end
        self._targets = arr
    end

    return true
end

function QAIDPSMONSTER:_repositionForFanSkill(actor)
    if self._fanSkill == nil then
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

function QAIDPSMONSTER:_repositionForRectSkill(actor)
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

    local pos = clone(actor:getPosition())
    local width = skill:getRectWidth() * global.pixel_per_unit
    local height = skill:getRectHeight() * global.pixel_per_unit
    local xmin, xmax, ymin, ymax = pos.x - width / 2, pos.x + width / 2, pos.y - height / 2, pos.y + height / 2
    if actor:isFlipX() then
        xmin = xmin + width / 2
        xmax = xmax + width / 2
    else
        xmin = xmin - width / 2
        xmax = xmax - width / 2
    end
    local enemies = app.battle:getMyEnemies(actor)
    -- 先在y轴上移动寻找合适的目标
    local candidate, candidatey = nil, nil
    if actor:getTarget() then
        candidate = actor:getTarget()
        candidatey = candidate:getPosition().y
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
    -- 然后检查x轴上的移动
    local cpos = candidate:getPosition()
    actor:_cancelCurrentSkill()
    app.grid:moveActorTo(actor, {x = pos.x + (cpos.x - (xmin + xmax) / 2), y = cpos.y})
    return true
end

function QAIDPSMONSTER:_pickTarget(actor)
    if actor:getTarget() then
        return
    end

    local enemies = app.battle:getMyEnemies(actor)
    local target = nil
    local arr = {}
    for index, enemy in ipairs(enemies) do
        arr[#enemies + 1 - index] = enemy
    end
    self._targets = arr

    for index, enemy in ipairs(self._targets) do
        if enemy:isSupportHero() and not enemy:isActiveSupport() then
            table.remove(self._targets, index)
            break
        end
    end

    local target = nil
    for _, index in ipairs(self._target_order) do
        local enemy = self._targets[index]
        if enemy and not enemy:isDead() then
            target = enemy
            break
        end
    end

    if target and actor:getTarget() ~= target then
        actor:setTarget(target)
    end
end

function QAIDPSMONSTER:_blink(actor)
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

function QAIDPSMONSTER:_charge(actor)
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

function QAIDPSMONSTER:_attack(actor)
    local manualSkill = self._manualSkill
    if manualSkill == nil then
        manualSkill = false
        local npc_skill_list = db:getCharacterByID(actor:getActorID()).npc_skill_list
        for _, skill in pairs(actor:getManualSkills()) do
            local index = string.find(npc_skill_list, tostring(skill:getId()))
            if type(index) == "number" and index > 0 then
                manualSkill = skill
                break
            end
        end
        self._manualSkill = manualSkill
    end

    if manualSkill == false then
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

    actor:attack(manualSkill, true)

    return true
end

function QAIDPSMONSTER:_execute(args)
    local actor = args.actor

    if self._regulator() then
        self:_pickTarget(actor)

        if self:_repositionForRectSkill(actor) then
            return false
        end
        if self:_repositionForFanSkill(actor) then
            return false
        end
        if self:_blink(actor) then
            return true
        end
        if self:_charge(actor) then
            return true
        end
        if self:_attack(actor) then
            return true
        end
    end

    return true
end


return QAIDPSMONSTER