-- **************************************************
-- Author               : wanghai
-- FileName             : QSBChangeDamagePercent.lua
-- Description          : 
-- Create time          : 2019-07-05 15:57
-- Last modified        : 2019-07-05 15:57
-- **************************************************

local QSBNode = import("..QSBNode")
local QSBChangeDamagePercent = class("QSBChangeDamagePercent", QSBNode)

QSBChangeDamagePercent.TYPE_DISTANCE = "distance"

function QSBChangeDamagePercent:ctor(director, attacker, target, skill, options)
    QSBChangeDamagePercent.super.ctor(self, director, attacker, target, skill, options)

    self._damagePMin = self._options.damage_p_min
    self._damagePMax = self._options.damage_p_max
    self._thresholdMax = self._options.threshold_max
    self._thresholdMin = self._options.threshold_min
    self._type = self._options.type
end

function QSBChangeDamagePercent:_execute(dt)
    local damageP = 1
    local skill = self._skill
    local skillType = skill:getRangeType()
    if skillType == skill.SINGLE then
        if self._type == QSBChangeDamagePercent.TYPE_DISTANCE then
            local targetPos = self._target:getPosition()
            local actorPos = self._attacker:getPosition()
            local distance = q.distOf2Points(targetPos, actorPos)
            local thresholdMax = self._thresholdMax * global.pixel_per_unit
            local thresholdMin = self._thresholdMin * global.pixel_per_unit
            if distance >= thresholdMax then
                damageP = self._damagePMin
            elseif distance <= thresholdMin then
                damageP = self._damagePMax
            else
                damageP = (1.0 - (distance / (thresholdMax - thresholdMin))) * (self._damagePMax - self._damagePMin) + self._damagePMin
            end
        end
    elseif skillType == skill.MULTIPLE then
    end

    damageP = math.min(self._damagePMax, damageP)
    damageP = math.max(self._damagePMin, damageP)

    self._skill:setDamagePercentFromScript(damageP)

    self:finished()
end

function QSBChangeDamagePercent:_onCancel()
    self._skill:setDamagePercentFromScript(nil)
end

function QSBChangeDamagePercent:_onRevert()
    self._skill:setDamagePercentFromScript(nil)
end

return QSBChangeDamagePercent

