--[[
    Class name QSBLoop
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBLoop = class("QSBLoop", QSBNode)

function QSBLoop:_execute(dt)
    if self:getOptions().can_be_immuned == true then
        if self._target ~= nil and self._target:isDead() == false then
            if self._target:isImmuneStatus(self._skill:getBehaviorStatus()) then
                self:finished()
                return
            end
        end
    end

    if self._count == nil then self._count = 0 end
    local loopCount = self:getOptions().loop_count or 1

    if self._count >= loopCount then
        self:finished()
        return
    else
        local child = self:getChildAtIndex(1)
        if child:getState() == QSBNode.STATE_EXECUTING then
            child:visit(dt)
        elseif child:getState() == QSBNode.STATE_WAIT_START then
            child:start()
            child:visit(0)
        else
            self._count = self._count + 1
            child:reset()
        end

        if child:getState() ~= QSBNode.STATE_FINISHED then
            return
        end
    end
end

function QSBLoop:revert()
end

function QSBLoop:cancel()
end

return QSBLoop