-- **************************************************
-- Author               : wanghai
-- FileName             : QSBArgsSelectTarget.lua
-- Description          : 
-- Create time          : 2019-04-08 17:10
-- Last modified        : 2019-04-15 11:39
-- **************************************************

local QSBAction = import(".QSBAction")
local QSBArgsSelectTarget = class("QSBArgsSelectTarget", QSBAction)

function QSBArgsSelectTarget:_execute(dt)
    if self._executed then
        return
    end
    self._executed = true

    local actor = self._attacker

    if self._options.is_target then
        self:finished({selectTarget = self._target})
        return
    elseif self._options.is_attacker then
        self:finished({selectTarget = self._attacker})
        return
    end

    local range_min = 0
    local range_max = 9999
    if self._options.range then
        local min = self._options.range.min
        if min then
            range_min = min
        end
        local max = self._options.range.max
        if max then
            range_max = max
        end
    end
    range_min = range_min * range_min * global.pixel_per_unit * global.pixel_per_unit
    range_max = range_max * range_max * global.pixel_per_unit * global.pixel_per_unit

    local enemies = nil
    if self._options.is_teammate then
        enemies = app.battle:getMyTeammates(self._attacker, self._options.include_self, self._options.just_hero)
    else
        enemies = app.battle:getMyEnemies(actor, self._options.just_hero)
    end

    local candidates = {}

    for _, enemy in ipairs(enemies) do
        if not enemy:isDead() and not enemy:isSupport() and
        (not enemy:isCopyHero() or not self._options.not_copy_hero) then
            local x = enemy:getPosition().x - actor:getPosition().x
            local y = enemy:getPosition().y - actor:getPosition().y
            local d = x * x + y * y * 4
            if d <= range_max and d >= range_min then
                table.insert(candidates, enemy)
            end
        end
    end

    local targetList = {}
    for _, enemy in ipairs(candidates) do
        local isSelect = true

        local prior_role = self._options.prior_role
        if prior_role and prior_role ~= enemy:getTalentFunc() then
            isSelect = false
        end
        local prior_attack_type = self._options.prior_attack_type
        if prior_attack_type and prior_attack_type ~= enemy:getAttackType() then
            isSelect = false
        end

        if self._options.except_actor and enemy == self._options.except_actor then
            isSelect = false
        end

        if isSelect then
            table.insert(targetList, enemy)
        end
    end
    
    candidates = targetList

    if self._options.furthest then
        table.sort(candidates, function(e1, e2)
            local d1 = q.distOf2PointsSquare(actor:getPosition(), e1:getPosition())
            local d2 = q.distOf2PointsSquare(actor:getPosition(), e2:getPosition())
            if d1 ~= d2 then
                return d1 > d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        candidates = {candidates[1]}
    elseif self._options.lowest_hp then
        table.sort(candidates, function(e1, e2)
            local d1 = e1:getHp() / e1:getMaxHp()
            local d2 = e2:getHp() / e2:getMaxHp()
            if d1 ~= d2 then
                return d1 < d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        candidates = {candidates[1]}
    elseif self._options.max_haste_coefficient then
        table.sort(candidates, function(e1, e2)
            local d1 = e1:getMaxHasteCoefficient()
            local d2 = e2:getMaxHasteCoefficient()
            if d1 ~= d2 then
                return d1 < d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        candidates = {candidates[1]}
    elseif self._options.min_distance then
        local self_pos = self._attacker:getPosition()
        table.sort(candidates,function(e1,e2)
            local d1 = q.distOf2PointsSquare(e1:getPosition(),self_pos)
            local d2 = q.distOf2PointsSquare(e2:getPosition(),self_pos)
            if d1 ~= d2 then
                return d1 < d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        candidates = {candidates[1]}
    elseif self._options.max_distance then
        local self_pos = self._attacker:getPosition()
        table.sort(candidates,function(e1,e2)
            local d1 = q.distOf2PointsSquare(e1:getPosition(),self_pos)
            local d2 = q.distOf2PointsSquare(e2:getPosition(),self_pos)
            if d1 ~= d2 then
                return d1 > d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        candidates = {candidates[1]}
    elseif self._options.under_status then
        for _, actor in ipairs(candidates) do
            if actor:isUnderStatus(self._options.under_status) then
                candidates = {actor} 
                break
            end
        end
    elseif self._options.lowest_rage then
        table.sort(candidates, function(e1, e2)
            local d1 = e1:getRage()
            local d2 = e2:getRage()
            if d1 ~= d2 then
                return d1 < d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        candidates = {candidates[1]}
    elseif self._options.highest_attack then
        table.sort(candidates, function(e1, e2) return (e1:getAttack() or 0) > (e2:getAttack() or 0) end)
        candidates = {candidates[1]}
    elseif self._options.highest_force then
        table.sort(candidates, function(e1, e2) return e1:getBattleForce() > e2:getBattleForce() end)
        candidates = {candidates[1]}
    end

    if #candidates > 0 then
        local target = candidates[app.random(1, #candidates)]
        if self._options.change_all_node_target == true then
            self._director:changeAllNodeTarget(target)
        end
        self:finished({selectTarget = target})
    elseif self._options.default_select then
        self:finished({selectTarget = self._target})
    elseif self._options.cancel_if_not_found then
        app.battle:performWithDelay(function()
            if self._director == actor:getCurrentSBDirector() then
                actor:_cancelCurrentSkill()
            else
                self._director:cancel()
            end
        end, 0)
    else
        self:finished()
    end
end

return QSBArgsSelectTarget
