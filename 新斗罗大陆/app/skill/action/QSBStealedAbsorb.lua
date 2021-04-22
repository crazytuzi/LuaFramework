--[[
    Class name QSBStealedAbsorb
    Create by wanghai

    buff_id:用于存储偷取的护盾值的ID
    value:偷取的护盾值
    percent:偷取的护盾百分比
    支持value和percent一起使用但是偷取时的护盾变化表现是分开的.
--]]
local QSBAction = import(".QSBAction")
local QSBStealedAbsorb = class("QSBStealedAbsorb", QSBAction)

local QActor = import("...models.QActor")

function QSBStealedAbsorb:_execute(dt)
    local actor = self._attacker
    local target = self._target
    local buffId = self._options.buff_id
    
    local value = self._options.value
    if value then
        local newbuff = actor:applyBuff(buffId, self._attacker, self._skill)
        local buffs = target:getBuffs()
        local addValue = 0
        if newbuff then
            for _, buff in ipairs(buffs) do
                if buff:isAbsorbDamage() then
                    local absorbValue = buff:getAbsorbDamageValue()
                    value = value - absorbValue
                    buff:absorbDamageValue(absorbValue)
                    addValue = addValue + absorbValue
                    if value <= 0 then
                        break
                    end
                end
            end
            local old_value = newbuff:getAbsorbDamageValue()
            newbuff:setAbsorbDamageValue(old_value + addValue, true)
            actor:dispatchAbsorbChangeEvent(addValue)
        end
    end

    local percent = self._options.percent
    if percent then
        local newbuff = actor:applyBuff(buffId, self._attacker, self._skill)
        local buffs = target:getBuffs()
        local addValue = 0
        if newbuff then
            for _, buff in ipairs(buffs) do
                if buff:isAbsorbDamage() then
                    local absorbValue = buff:getAbsorbDamageValue()
                    addValue = addValue + absorbValue * percent
                end
            end
            local old_value = newbuff:getAbsorbDamageValue()
            newbuff:setAbsorbDamageValue(old_value + addValue, true)
            actor:dispatchAbsorbChangeEvent(addValue)
        end
    end
    
    self:finished()
end

return QSBStealedAbsorb
