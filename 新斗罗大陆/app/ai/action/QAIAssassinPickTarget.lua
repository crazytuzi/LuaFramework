
local QAIAction = import("..base.QAIAction")
local QAIAssassinPickTarget = class("QAIAssassinPickTarget", QAIAction)

function QAIAssassinPickTarget:ctor( options )
    QAIAssassinPickTarget.super.ctor(self, options)
    self:setDesc("")

    if not QAIAssassinPickTarget.TARGET_ORDER then
        local TARGET_ORDER = {}
        if options.target_order then
            for _, obj in pairs(options.target_order) do
                TARGET_ORDER[obj.actor_id] = obj.order
            end
        end

        QAIAssassinPickTarget.TARGET_ORDER = TARGET_ORDER
    end
    self._frameCount = 0
    self:createRegulator(5)
end

function QAIAssassinPickTarget:_evaluate(args)
    if not args.actor then
        return false
    end

    if not self._target_order then
        self._target_order = QAIAssassinPickTarget.TARGET_ORDER[args.actor:getActorID()]
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

function QAIAssassinPickTarget:_pickTarget(actor)
    if app.battle:isInSunwell() or app.battle:isInGlory() then
        if actor:getTarget() and not actor:getTarget():isDead() then
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
        if enemy and not enemy:isDead() then
            target = enemy
            break
        end
    end

    if target and actor:getTarget() ~= target then
        actor:setTarget(target)
    end
end

function QAIAssassinPickTarget:_execute(args)
    local actor = args.actor
    self._frameCount =  self._frameCount + 1
    if self._regulator() then
        self:_pickTarget(actor)
    end

    return true
end


return QAIAssassinPickTarget
