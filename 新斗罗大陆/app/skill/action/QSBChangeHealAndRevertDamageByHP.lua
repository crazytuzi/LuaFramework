--[[
    天使套装脚本
    render_damage_limit:           可反伤总和上限
    heal_revert_min_cofficient:    治疗和反伤下限系数
    heal_revert_max_cofficient:    治疗和反伤上限系数
    absorb_render_damage_percent:  反伤系数
    absorb_render_heal_percent:    治疗系数
--]]
local QSBAction = import(".QSBAction")
local QSBChangeHealAndRevertDamageByHP  = class("QSBChangeHealAndRevertDamageByHP", QSBAction)

function QSBChangeHealAndRevertDamageByHP:ctor(director, attacker, target, skill, options)
    QSBChangeHealAndRevertDamageByHP.super.ctor(self, director, attacker, target, skill, options)               --战斗持续时间    
end

function QSBChangeHealAndRevertDamageByHP:_execute(dt)
    self._targets = self._options.selectTargets or {}    --通过QSBArgsFindTargets获取
    self:_changeHealRevertPercent()
    self:finished()
end

--根据当前血量实时改变治疗和反伤系数
function QSBChangeHealAndRevertDamageByHP:_changeHealRevertPercent()
    if self._options.heal_revert_min_cofficient and self._options.heal_revert_max_cofficient then
        for k,actor in ipairs(self._targets) do
            local currentHPPercent = actor:getHp() / actor:getMaxHp()
            local detal = math.min(1 - currentHPPercent, 0.5) * 2
            local cofficient = self._options.heal_revert_min_cofficient + 
            detal * (self._options.heal_revert_max_cofficient - self._options.heal_revert_min_cofficient)

            local stub = "QSBChangeHealAndRevertDamageByHP"
            local value = cofficient * self._options.absorb_render_damage_percent
            local propName = "absorb_render_damage_cofficient"
            if actor:getPropertyValue(propName, stub) == nil then
                actor:insertPropertyValue(propName,stub, "+", value)
            else
                actor:modifyPropertyValue(propName,stub, "+",value)
            end

            value = cofficient * self._options.absorb_render_heal_percent
            propName = "absorb_render_heal_cofficient"
            if actor:getPropertyValue(propName, stub) == nil then
                actor:insertPropertyValue(propName,stub, "+", value)
            else
                actor:modifyPropertyValue(propName, stub, "+", value)
            end

            actor:setAbsorbRenderLimit(self._options.render_damage_limit * actor:getMaxHp())
        end
    end
end

return QSBChangeHealAndRevertDamageByHP