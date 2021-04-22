--[[
    status                         状态
--]]
local QSBAction = import(".QSBAction")
local QSBAddApplyCount  = class("QSBAddApplyCount", QSBAction)

function QSBAddApplyCount:_execute(dt)
    if not self._options.status then
        return
    end
    self._attacker:addApplyCountByStatus(self._options.status)
    if self._options.set_apply_count_num then
        self._attacker:setApplyCountByStatus(self._options.status, self._options.set_apply_count_num)
    end
    self:finished()
end

function QSBAddApplyCount:_onCancel()
    self:_onRevert()
end

function QSBAddApplyCount:_onRevert()
    self._attacker:reduceApplyCountByStatus(self._options.status)
end


return QSBAddApplyCount