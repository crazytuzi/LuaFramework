-- **************************************************
-- Author               : wanghai
-- FileName             : QSBArgsRandomByActor.lua
-- Description          : 
-- Create time          : 2019-10-28 19:12
-- Last modified        : 2019-10-28 19:25
-- **************************************************

local QSBNode = import("..QSBNode")
local QSkill = import("..models.QSkill")
local QSBArgsRandomByActor= class("QSBArgsRandomByActor", QSBNode) 

function QSBArgsRandomByActor:ctor(...)
    self.super.ctor(self, ...)
    local options = self:getOptions()
    self._randomType = options.random_type
    self._randomPools = options.random_pools
end

function QSBArgsRandomByActor:_execute(dt)
    local candidates = {} 
    local targetType = self._skill:getTargetType()
    if targetType == QSkill.TARGET then
        table.insert(candidates, self._target)
    elseif targetType == QSkill.SELF then
        table.insert(candidates, self._attacker)
    elseif targetType == QSkill.TEAMMATE then
        candidates = app.battle:getMyTeammates(self._attacker, false, true)
    end

    local count = app.battle:getFromMap(self._attacker, self._skill:getId())
    if count == nil then count = 1 end
    count = count % 3
    if count == 0 then count = 1 end

    if #candidates == 1 and not candidates[1]:isSupport() then
        self:finished({actorId = candidates[1]:getActorID(true)})
        return
    elseif #candidates == 0 then
        self:finished()
        return
    end
    
    local randomPool = self._randomPools[count]
    local hasT, hasDps, hasHealth
    local actorType = {t = {}, dps = {}, health = {}}

    for _, actor in ipairs(candidates) do
        if not actor:isDead() and not actor:isSupport() then 
            if actor:isT() then hasT = true table.insert(actorType.t, actor)
            elseif actor:isDps() then hasDps = true table.insert(actorType.dps, actor)
            elseif actor:isHealth() then hasHealth = true table.insert(actorType.health, actor) end
        end
    end

    local total = 0
    if hasT then total = total + randomPool.t
    else randomPool.t = nil end
    if hasDps then total = total + randomPool.dps
    else randomPool.dps = nil end
    if hasHealth then total = total + randomPool.health
    else randomPool.health = nil end

    local p = app.random(total)
    for k, v in pairs(randomPool) do 
        if p > 0 and p < v then 
            if #actorType[k] > 0 then
                local actor = actorType[k][app.random(#actorType[k])]
                self:finished({actorId = actor:getActorID(true)})
                return
            end
        else
            p = p - v
        end
    end

    self:finished()
end

function QSBArgsRandomByActor:finished(args)
    if args ~= nil then
        local count = app.battle:getFromMap(self._attacker, self._skill:getId())
        if count == nil then count = 1 end
        count = count + 1
        app.battle:setFromMap(self._attacker, self._skill:getId(), count)
    end
    QSBArgsRandomByActor.super.finished(self, args)
end

return QSBArgsRandomByActor

