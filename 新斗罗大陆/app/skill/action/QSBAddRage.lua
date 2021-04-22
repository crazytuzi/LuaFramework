-- @Author: wanghai
-- @Date:   2020-04-16 17:12:01
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-07-01 16:42:31

--[[
    增加怒气值
    coefficient                         增幅系数默认为1
    coef_type                           系数类型
    selectTargets                       接收来自QSBArgsFindTargets脚本返回的参数
    selectTarget                        接收来自QSBArgsSelectTarget脚本的返回的参数
    min                                 最小值默认为0
    max                                 最大值默认为1000
    type                                根据什么类型来增加怒气
    value                               直接添加rage的数值
--]]

local QSBAction = import(".QSBAction")
local QSBAddRage = class("QSBAddRage", QSBAction)

QSBAddRage.TYPE_BE_KILL = "be_kill"                                         --增加的为击杀怒气的百分比
QSBAddRage.TYPE_BEATTACK_RAGE = "beattack_rage"                             --根据skill rage增加怒气
QSBAddRage.TYPE_VALUE = "value"                                             --直接添加某个数值的rage 

QSBAddRage.COEF_TYPE_MAXHP_ATTACK = "attack_max_hp"                         --系数类型为血量和攻击的比值

function QSBAddRage:_execute(dt)
    local actor = self._attacker
    local targetList = {self._target}
    if self._options.selectTargets then
        targetList = self._options.selectTargets
    elseif self._options.selectTarget then
        targetList = {self._options.selectTarget}
    end

    local min = self._options.min or 0
    local max = self._options.max or 1000

    if self._options.type == QSBAddRage.TYPE_BE_KILL then
        for _, target in ipairs(targetList) do
            if target:hasRage() and not target:isCopyHero() then
                local targetRageInfo = target:getRageInfo()
                local actorRageInfo = actor:getRageInfo()
                local dRage = actorRageInfo.bekill_rage * targetRageInfo.kill_coefficient
                if app.battle:isPVPMode() then
                    dRage = dRage + target:getActorPropValue("pvp_kill_rage")
                end
                dRage = dRage * self:getCoefficient()
                dRage = math.clamp(dRage, min, max)

                target:changeRage(dRage, nil, self._options.show_tip)
            end
        end
    end

    if self._options.type == QSBAddRage.TYPE_BEATTACK_RAGE then
        for _, target in ipairs(targetList) do
            if target:hasRage() and not target:isCopyHero() then
                local targetRageInfo = target:getRageInfo()
                local dRage = targetRageInfo.beattack_coefficient
                dRage = dRage * self:getCoefficient(self._attacker, self._target)
                dRage = math.clamp(dRage, min, max)

                target:changeRage(dRage, nil, self._options.show_tip)
            end
        end
    end

    if self._options.type == QSBAddRage.TYPE_VALUE then
        for _, target in ipairs(targetList) do
            if target:hasRage() and not target:isCopyHero() then
                target:changeRage(self._options.value, nil, self._options.show_tip)
            end
        end
    end

    self:finished()
end

function QSBAddRage:getCoefficient(attacker, target)
    local coefficient = self._options.coefficient or 1
    if self._options.coef_type == QSBAddRage.COEF_TYPE_MAXHP_ATTACK 
        and attacker and target then

        coefficient = attacker:getAttack() / target:getMaxHp() * coefficient
    end

    return coefficient
end

return QSBAddRage
