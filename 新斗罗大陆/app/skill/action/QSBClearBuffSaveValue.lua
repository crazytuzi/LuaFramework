--[[
    根据某个值来添加护盾
    is_save_treat           清除存储治疗量
    is_save_damage          清除存储伤害
    buff_id                 要清除的buff id
--]]
local QSBNode = import("..QSBNode")
local QSBClearBuffSaveValue = class("QSBClearBuffSaveValue", QSBNode)

function QSBClearBuffSaveValue:_execute(dt)    
    local buff_id = self._options.buff_id
    local hasBuff, buff = self._attacker:hasSameIDBuff(buff_id)
    if not hasBuff then
        self:finished()
        return
    end

    if self._options.is_save_damage then
        local totalSaveDamage = buff:getSavedDamage()
        buff:saveDamage(-totalSaveDamage)
    end
    if self._options.is_save_treat then
        local totalSaveTreat = buff:getSaveTreat()
        buff:saveTreat(-totalSaveTreat)
    end

    self:finished()
end

return QSBClearBuffSaveValue
