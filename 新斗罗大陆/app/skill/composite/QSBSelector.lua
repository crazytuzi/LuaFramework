--[[
    Class name QSBSelector
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBSelector = class("QSBSelector", QSBNode)

function QSBSelector:_execute(dt)    
    if self:getOptions().can_be_immuned == true then
        if self._target ~= nil and self._target:isDead() == false then
            if self._target:isImmuneStatus(self._skill:getBehaviorStatus()) then
                self:finished()
                return
            end
        end
    end

    if self._select_index == nil then
        self._select_index = self:getOptions().select
        if self._select_index == true then
            self._select_index = 1
        elseif self._select_index == false then
            self._select_index = 2
        end
        if type(self._select_index) ~= "number" then
            self:finished()
            return
        end
        if self._select_index < 1 or self._select_index > self:getChildrenCount() then
            self:finished()
            return
        end
    end

    local child = self:getChildAtIndex(self._select_index)
    if child:getState() == QSBNode.STATE_WAIT_START then
        child:start()
        child:visit(0)
    elseif child:getState() == QSBNode.STATE_EXECUTING then
        child:visit(dt)
    end

    if child:getState() == QSBNode.STATE_FINISHED then
        if self:getOptions().pass_args then
            self:finished(child:getArguments())
        else
            self:finished()
        end
    end
end

function QSBSelector:revert()
    local index = self._select_index
    if index and index >= 1 and index <= self:getChildrenCount() then
        local child = self:getChildAtIndex(index)
        child:revert()
    end

    if self._state == QSBNode.STATE_FINISHED and self._revertable == true then
        self:_onRevert()
    end
end

function QSBSelector:cancel()
    if self._state ~= QSBNode.STATE_EXECUTING then
        return
    end
    
    self:_onCancel()

    local index = self._select_index
    if index and index >= 1 and index <= self:getChildrenCount() then
        local child = self:getChildAtIndex(index)
        child:cancel()
    end

    self:finished()
end

function QSBSelector:_onReset()
    self._select_index = nil
end

return QSBSelector