--[[
    Class name QSBLockTarget
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBLockTarget = class("QSBLockTarget", QSBAction)

local QActor = import("...models.QActor")

function QSBLockTarget:_execute(dt)

    self:_toDo()
    
    self:finished()
end

function QSBLockTarget:_onCancel()
	self:_onRevert()
end

function QSBLockTarget:_toDo()
    local actor
    if self._options.is_target == true then
        actor = self._target
    else
        actor = self._attacker
    end

    if self._options.is_lock_target == true then
        actor:lockTarget()
    else
        actor:unlockTarget()
    end

    if self._options.is_always_lock == true then
        if self._options.is_target then
            actor:setTarget(self._attacker)
        end
        actor:alwaysLockTarget()
    else
        actor:unAlwaysLockTarget()
    end
end

function QSBLockTarget:_onRevert()
    local actor
    if self._options.is_target == true then
        actor = self._target
    else
        actor = self._attacker
    end

    if self._options.is_lock_target == true then
        actor:unlockTarget()
    else
        actor:lockTarget()
    end

    if self._options.is_always_lock == true then
        if self._options.is_target then
            actor:setTarget(nil)
        end
        actor:unAlwaysLockTarget()
    end
end

return QSBLockTarget