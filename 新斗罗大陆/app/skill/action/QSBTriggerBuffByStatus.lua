--[[
    触发一次指定status的buff
    参数
    status:状态名
    target_is_target:buff的触发目标 默认是自己 填true为技能目标
    is_target:触发谁身上的buff 默认是自己 填true为技能目标
--]]
local QSBAction = import(".QSBAction")
local QSBTriggerBuffByStatus  = class("QSBTriggerBuffByStatus", QSBAction)

function QSBTriggerBuffByStatus:_execute(dt)
    local status = self._options.status
    local target = self._attacker
    local actor = self._attacker
    if self._options.target_is_target then
        target = self._target
    end
    if self._options.is_target then
        actor = self._target
    end

    if actor then
        for i,buff in ipairs(actor:getBuffs()) do
            if buff:hasStatus(status) then
                actor:_triggerAlreadyAppliedBuff(buff, buff:getTriggerCondition() or buff:getTriggerCondition2() or buff:getTriggerCondition3(), target, 0, self._director)
            end
        end
    end
    self:finished()
end

return QSBTriggerBuffByStatus