--[[
    重置某个buff的tick
    buff_id:buff的id
    is_target:是否是技能的目标否则为技能释放者
]]
local QSBAction = import(".QSBAction")
local QSBResetBuffCooldown = class("QSBResetBuffCooldown", QSBAction)

function QSBResetBuffCooldown:_execute(dt)
    local buff_id = self._options.buff_id
    local status = self._options.status
    local actor = self._attacker
    if self._options.is_target then
        actor = self._target
    end
    if (buff_id or status) and actor then
        for i, buff in ipairs(actor:getBuffs()) do
            local trigger = false
            if buff:getId() == buff_id then
                buff:resetCoolDown()
                trigger = true
            end
            if status and buff:hasStatus(status) and not trigger then
                buff:resetCoolDown()
                trigger = true
            end
        end
    end
    self:finished()
end

return QSBResetBuffCooldown