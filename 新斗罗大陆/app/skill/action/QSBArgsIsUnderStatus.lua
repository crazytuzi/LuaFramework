--[[
    Class name QSBArgsIsUnderStatus
    Create by Tdy
    @common
--]]


local QSBNode = import("..QSBNode")
local QActor = import("..models.QActor")
local QSBArgsIsUnderStatus = class("QSBArgsIsUnderStatus", QSBNode)

function QSBArgsIsUnderStatus:_execute(dt)    
    local actor
	-- 确定actor
    if self:getOptions().is_attacker then
        actor = self._attacker
    elseif self:getOptions().is_attackee then
        actor = self._target
    end
	-- 确定状态
	local myStatus = self:getOptions().status
	-- 结果是否反转
	local reverse_result = self:getOptions().reverse_result or false
    if nil == actor then
        self:finished({select = true})
    else
        if actor:isUnderStatus(myStatus) then
            self:finished({select = not reverse_result})
        else
            self:finished({select = reverse_result})
        end
    end
end

return QSBArgsIsUnderStatus