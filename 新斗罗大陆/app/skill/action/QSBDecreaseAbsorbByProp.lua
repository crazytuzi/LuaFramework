--[[
    二选零，默认护盾削减目标为自己的目标
    selectTargets                           通过QSBArgsFindTargets获取
    target_enemy                            目标为全体敌人
    三选一
    max_hp_percent                          根据目标最大血量百分比计算护盾削减值
    current_hp_percent                      根据目标当前血量百分比计算护盾削减值
    lost_hp_percent                         根据目标已损失血量百分比计算护盾削减值
    三选零
    attacker_max_hp_percent_limit           根据自己最大血量百分比计算护盾削减上限
    attacker_current_hp_percent_limit       根据自己当前血量百分比计算护盾削减上限
    attacker_attack_prop_percent_limit      根据自己攻击属性百分比计算护盾削减上限
--]]
local QSBAction = import(".QSBAction")
local QSBDecreaseAbsorbByProp  = class("QSBDecreaseAbsorbByProp", QSBAction)

function QSBDecreaseAbsorbByProp:_execute(dt)
    local targets = {self._target}
    if self._options.selectTargets then
        targets = self._options.selectTargets or {}   --通过QSBArgsFindTargets获取
    elseif self._options.target_enemy then
        targets = app.battle:getMyEnemies(self._attacker) or {}
    -- elseif self._skill:getRangeType() == self._skill.MULTIPLE then
    --     targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition()) or {}
    else
        targets = {self._target}
    end
    for k,target in ipairs(targets) do
        local decreaseAbsorbValue = self:getDecreaseAbsorbValue(target)
        if not self:isDeflection(self._attacker, target) then
            if 0 < decreaseAbsorbValue then
                decreaseAbsorbValue = decreaseAbsorbValue * self:getDragonModifier()
                target:decreaseHp(decreaseAbsorbValue, self._attacker, self._skill)
            end
        end
    end
    self:finished()
end

function QSBDecreaseAbsorbByProp:getDecreaseAbsorbValue(target)
    local ret = 0
    if self._options.max_hp_percent then
        ret = target:getMaxHp() * self._options.max_hp_percent
    elseif self._options.current_hp_percent then
        ret = target:getHp() * self._options.current_hp_percent
    elseif self._options.lost_hp_percent then
        ret = target:getLostHp() * self._options.lost_hp_percent
    end
    --护盾削减值不高于限制数值
    local maxValue = self:getDecreaseAbsorbMaxValue()
    if 0 < maxValue then
        ret = math.min(ret, maxValue)
    end
    --护盾削减值不高于当前最大护盾值
    local totalAbsorbValue = target:getAbsorbDamageValue()
    ret = math.min(ret, totalAbsorbValue)
    return ret
end

function QSBDecreaseAbsorbByProp:getDecreaseAbsorbMaxValue()
    local maxValue = 0
    if self._options.attacker_max_hp_percent_limit then
        maxValue = self._attacker:getMaxHp() * self._options.attacker_max_hp_percent_limit
    elseif self._options.attacker_current_hp_percent_limit then
        maxValue = self._attacker:getHp() * self._options.attacker_current_hp_percent_limit
    elseif self._options.attacker_attack_prop_percent_limit then
        maxValue = self._attacker:_getActorNumberPropertyValue("attack_value") * self._options.attacker_attack_prop_percent_limit
    end
    return maxValue
end

return QSBDecreaseAbsorbByProp