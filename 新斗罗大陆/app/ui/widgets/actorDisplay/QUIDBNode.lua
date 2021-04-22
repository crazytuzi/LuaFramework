
local QNode = import("....base.QNode")
local QUIDBNode = class("QUIDBNode", QNode)

QUIDBNode.STATE_WAIT_START = "QUIDBNode_STATE_WAIT_START"
QUIDBNode.STATE_EXECUTING = "QUIDBNode_STATE_EXECUTING"
QUIDBNode.STATE_FINISHED = "QUIDBNode_STATE_FINISHED"

function QUIDBNode:ctor(widgetActor, director, options)
	QUIDBNode.super.ctor(self, options)
	self._widgetActor = widgetActor
    self._director = director
	self._state = QUIDBNode.STATE_WAIT_START
end

function QUIDBNode:getState()
    return self._state
end

function QUIDBNode:start()
    if self._state ~= QUIDBNode.STATE_WAIT_START then
        return
    end

    self._state = QUIDBNode.STATE_EXECUTING
end

function QUIDBNode:finished()
    self._state = QUIDBNode.STATE_FINISHED
end

function QUIDBNode:visit(dt)
    if self._state ~= QUIDBNode.STATE_EXECUTING then
        return
    end

    self:_execute(dt)
end

function QUIDBNode:_execute(dt)
    self:finished()
end

function QUIDBNode:cancel()
    if self._state ~= QUIDBNode.STATE_EXECUTING then
        return
    end
    
    self:_onCancel()

    local count = self:getChildrenCount()
    for index = 1, count, 1 do
        local child = self:getChildAtIndex(index)
        child:cancel()
    end

    self:finished()
end

function QUIDBNode:_onCancel()
    
end

return QUIDBNode;