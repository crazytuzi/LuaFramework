-- **************************************************
-- Author               : wanghai
-- FileName             : QSBPlunderRage.lua
-- Description          : 掠夺怒气 
-- Create time          : 2019-04-04 15:50
-- Last modified        : 2019-04-09 10:40
-- **************************************************

local QSBAction = import(".QSBAction")
local QSBPlunderRage = class("QSBPlunderRage", QSBAction)

function QSBPlunderRage:ctor(director, attacker, target, skill, options)
    QSBPlunderRage.super.ctor(self, director, attacker, target, skill, options)
    self._percent = self._options.plunder_rage_percent
    self._plunderRage = nil
    self._curTarget = nil
    self._plunderRageMax = self._options.plunder_rage_max
end

function QSBPlunderRage:_execute(dt)
    if self._options.selectTarget ~= nil then
        self._curTarget = self._options.selectTarget
    else
        self._curTarget = self._target
    end
    if self._curTarget:isDead() then 
        self:finished()
        return
    end
    
    local maxRage = self._curTarget:getRageTotal()
    local plunderTotalRage = self._director:getPlunderTotalRage() 
    if plunderTotalRage >= self._plunderRageMax * maxRage then
        self:finished()
        return
    end

    if self._percent == nil or type(self._percent) ~= "number" then
        self:finished()
        return
    end

    local targetRage = self._curTarget:getRage() 
    local plunderRage = targetRage * self._percent
    if (plunderRage + plunderTotalRage) > self._plunderRageMax * maxRage then
        plunderRage = self._plunderRageMax * maxRage - plunderTotalRage
    end
    self._plunderRage = plunderRage

    self._curTarget:changeRage(-plunderRage)
    self._attacker:changeRage(plunderRage)
    self._director:setPlunderTotalRage(self._plunderRage)

    self:finished()
end

function QSBPlunderRage:_onCancel()
    self:_onRevert()
end

function QSBPlunderRage:_onRevert()
    if self._plunderRage ~= nil then
        self._curTarget:changeRage(self._plunderRage)
        self._attacker:changeRage(-self._plunderRage)
        self._director:setPlunderTotalRage(-self._plunderRage)
    end
end

return QSBPlunderRage

