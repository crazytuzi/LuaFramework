--[[
    options_target                      来自技能脚本传递的目标
--]]

local QSBAction = import(".QSBAction")
local QSBArgsFindTargets = class("QSBArgsFindTargets", QSBAction)

function QSBArgsFindTargets:_execute(dt)
    local targets, actors, candidates
    local target_num = self._options.target_num
    local actor = self._attacker
    if self._options.teammate_and_self then
        actors = app.battle:getMyTeammates(actor, true, self._options.just_hero)
    elseif self._options.teammate then
        actors = app.battle:getMyTeammates(actor, false, self._options.just_hero)
    elseif self._options.multiple_target_with_skill then
        if self._skill:getRangeType() == self._skill.MULTIPLE then
            local target
            if self._options.options_target then
                target = self._options.options_target
            elseif self._options.selectTarget then
                target = self._options.selectTarget
            elseif self._options.sector_target then
                target = self._target
            end
            actors = self._attacker:getMultipleTargetWithSkill(self._skill, target)
        end
    elseif self._options.my_enemies then
        actors = app.battle:getMyEnemies(actor, self._options.just_hero)
    end

    if actors and #actors > 0 then
        -- 是否在战斗区域里面
        if self._options.is_in_battle_area then
            candidates = actors
            actors = {}
            for _, actor in ipairs(candidates) do
                if actor:isInBattleArea() then
                    table.insert(actors, actor)
                end
            end
        end
        -- 过滤掉援助英雄
        if self._options.no_support then
            candidates = actors
            actors = {}
            for _, actor in ipairs(candidates) do
                if not actor:isSupport() then
                    table.insert(actors, actor)
                end
            end
        end
        -- 是否在某个状态下
        local status = self._options.is_under_status
        if status then
            candidates = actors
            actors = {}
            for _, actor in ipairs(candidates) do
                if actor:isUnderStatus(status) then
                    table.insert(actors, actor)
                end
            end
        end 
        --战力高到低排序
        if self._options.select_name == "max_battle_force" then      
            table.sort(actors, function(a, b)        
                if a:getBattleForce() ~= b:getBattleForce() then
                    return a:getBattleForce() > b:getBattleForce()
                end
            end)
        end
        --能量高到低排序
        if self._options.select_name == "max_rage" then      
            table.sort(actors, function(a, b)        
                if a:getRage() ~= b:getRage() then
                    return a:getRage() > b:getRage()
                end
            end)
        end
    end

    if actors and #actors > 0 then
        targets = actors
        if target_num and target_num < #targets then
            local len = #targets
            for i = 1, len - target_num, 1 do
                table.remove(targets)
            end
        end
        self:finished({selectTargets = targets})
        return
    end

    self:finished({selectTargets = {}})
    return
end

return QSBArgsFindTargets
