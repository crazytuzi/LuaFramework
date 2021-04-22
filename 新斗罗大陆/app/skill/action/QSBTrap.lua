--[[
    Class name QSBTrap
    Create by wanghai 

    ignore_dead                 释放者死亡时会继续释放trap
--]]

local QSBNode = import("..QSBNode")
local QSBTrap = class("QSBTrap", QSBNode)
local QTrapDirector = import("...trap.QTrapDirector")

function QSBTrap:ctor(director, attacker, target, skill, options)
    QSBTrap.super.ctor(self, director, attacker, target, skill, options)
    self._passTime = 0
    self._trapOptions = clone(self._options.args)
end

function QSBTrap:_execute(dt)
    self._trapId = self._options.trapId
    local actor
    if self._options.is_attackee then
        actor = self._target
    elseif self._options.teammate_lowest_hp then
        local actors = app.battle:getMyTeammates(self._attacker, true)
        table.sort(actors, function(e1, e2)
            local d1 = e1:getHp() / e1:getMaxHp()
            local d2 = e2:getHp() / e2:getMaxHp()
            if d1 ~= d2 then
                return d1 < d2
            else
                return e1:getUUID() < e2:getUUID()
            end
        end)
        actor = actors[1]
    else
        actor = self._attacker
    end
    if nil == actor or (not self._options.ignore_dead and actor:isDead()) then
        self:finished()
        return
    end

    self._passTime = self._passTime + dt

    for _, option in ipairs(self._trapOptions) do
        local delay_time = option.delay_time or 0
        if not option.initialized and self._passTime > delay_time then
            local pos
            if option.pos then
                pos = option.pos
            elseif option.target_pos then
                pos = clone(self._target:getPosition())    
            else
                pos = option.relative_pos
                local curPos = actor:getPosition()
                pos.x = pos.x + curPos.x
                pos.y = pos.y + curPos.y
            end
            local trapDirector = QTrapDirector.new(self._trapId, pos, self._attacker:getType(), self._attacker, nil, self._skill)
            app.battle:addTrapDirector(trapDirector)
            option.initialized = true
        end
    end

    local allInitialize = true
    for _, option in ipairs(self._trapOptions) do
        if not option.initialized then
            allInitialize = false
        end
    end

    if allInitialize then
        self:finished()
        return
    end
end

return QSBTrap