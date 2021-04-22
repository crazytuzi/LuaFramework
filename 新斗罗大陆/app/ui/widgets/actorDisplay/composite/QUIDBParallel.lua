

local QUIDBNode = import("..QUIDBNode")
local QUIDBParallel = class("QUIDBParallel", QUIDBNode)

function QUIDBParallel:_execute(dt)

	local count = self:getChildrenCount()
	local isAllChildFinished = true
    for index = 1, count, 1 do
        local child = self:getChildAtIndex(index)
        if child:getState() == QUIDBNode.STATE_EXECUTING then
        	child:visit(dt)
        	isAllChildFinished = false
        elseif child:getState() == QUIDBNode.STATE_WAIT_START then
        	child:start()
            child:visit(0)
        	isAllChildFinished = false
        end
    end

    if isAllChildFinished == true then
    	self:finished()
    end
    
end

return QUIDBParallel