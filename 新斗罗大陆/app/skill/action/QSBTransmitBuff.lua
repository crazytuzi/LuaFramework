-- @Author: wanghai
-- @Date:   2020-04-07 16:14:05
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-04-24 15:56:28

--[[
    传递buff，复制的形式
    from_target                                             buff来源目标类型为target,默认为attacker
    from_multiple_target_with_skill                         buff来源类型为群体技能目标类型
    to_multiple_target_with_skill                           buff传递目标类型为群体技能目标类型，默认为target
    buff_id                                                 需要传递的buff id
    status                                                  需要传递的具有特定status的buff
    is_max_stack                                            传递层数最多的buff
--]]

local QSBAction = import(".QSBAction")
local QSBTransmitBuff = class("QSBTransmitBuff", QSBAction)

function QSBTransmitBuff:_execute(dt)
    local srcActors = {self._attacker}
    local destActors = {self._target}

    -- 获取buff来源目标
    if self._options.from_target then
        srcActors = {self._target}
    elseif self._options.from_multiple_target_with_skill then
        local target = self._target
        if self._options.selectTarget then
            target = self._options.selectTarget
        end
        srcActors = srcActors[1]:getMultipleTargetWithSkill(self._skill, target)
        self._isSelectMultipleTarget = true
    end

    -- 获取传递目标
    if self._options.to_multiple_target_with_skill then
        if self._isSelectMultipleTarget then
            destActors = srcActors
        else
            local target = self._target
            if self._options.selectTarget then
                target = self._options.selectTarget
            end
            destActors = srcActors[1]:getMultipleTargetWithSkill(self._skill, target)
        end
    end

    local hasBuff, buff
    if self._options.buff_id then
        hasBuff, buff = srcActors[1]:hasSameIDBuff(self._options.buff_id)
    elseif self._options.status then
        if self._options.from_multiple_target_with_skill then
            if self._options.is_max_stack then
                local realActor, realBuff
                local stack = 0
                for _, actor in ipairs(srcActors) do
                    for _, vBuff in ipairs(actor:getBuffs()) do
                        if vBuff:hasStatus(self._options.status) then
                            if vBuff:getStatckCount() > stack  then
                                realActor = actor
                                realBuff = vBuff
                                stack = vBuff:getStatckCount()
                            end
                        end
                    end
                end

                -- assert(realActor and realBuff, "QSBTransmitBuff count found buff!!!")
                if realActor and realBuff then
                    for _, actor in ipairs(destActors) do
                        if actor ~= realActor then
                            actor:removeSameBuffByID(realBuff:getId(), true)
                            for i = 1, stack, 1 do
                                actor:applyBuff(realBuff:getId(), self._attacker, self._skill)
                            end
                        end
                    end
                end
            end
        end
    end

    self:finished()
    return
end

return QSBTransmitBuff
