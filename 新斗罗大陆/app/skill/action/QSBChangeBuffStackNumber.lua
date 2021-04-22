-- @Author: wanghai
-- @Date:   2020-04-03 18:09:34
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-04-20 18:50:02

--[[
    改变buff的stacknumber
    buff_id                     需要改变的buff id
    status                      改变具有特定status的buff的stacknumber, 目前仅支持单数
    add_stack_number            添加的层数，默认为1
    is_target                   改变目标身上的buffstacknumber，默认为改变攻击者身上的buff
--]]

local QSBAction = import(".QSBAction")
local QSBChangeBuffStackNumber = class("QSBChangeBuffStackNumber", QSBAction)

function QSBChangeBuffStackNumber:_execute(dt)
    assert(self._options.buff_id or self._options.status, "QSBChangeBuffStackNumber buff_id and status are nil")

    local addStackNumber = self._options.add_stack_number
    if not self._options.add_stack_number then addStackNumber = 1 end

    local actor = self._attacker
    if self._options.is_target then
        actor = self._target
    end

    local buff, hasBuff
    if self._options.buff_id then
        hasBuff, buff = actor:hasSameIDBuff(self._options.buff_id)
    else
        for _, v in ipairs(actor:getBuffs()) do
            if v:hasStatus(self._options.status) then
                buff = v
                break
            end
        end
    end

    -- assert(buff, "QSBChangeBuffStackNumber count find buff")

    if buff then
        buff:additionStackNumber(addStackNumber)
    end

    self:finished()
    return
end

return QSBChangeBuffStackNumber