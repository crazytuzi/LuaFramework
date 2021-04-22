

local QUIDBNode = import("..QUIDBNode")
local QUIDBSequence = class("QUIDBSequence", QUIDBNode)

function QUIDBSequence:_execute(dt)

    if self._index == nil then
        self._index = 1
    end

    if self._index > self:getChildrenCount() then
        self:finished()
    else
        local child = self:getChildAtIndex(self._index)
        if child:getState() == QUIDBNode.STATE_EXECUTING then
            child:visit(dt)
        elseif child:getState() == QUIDBNode.STATE_WAIT_START then
            child:start()
            child:visit(0)
        else
            self._index = self._index + 1
            if self._index > self:getChildrenCount() then
                self:finished()
            end
        end
    end

end

return QUIDBSequence