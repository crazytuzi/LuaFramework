--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-24
-- Time: 下午4:18
-- To change this template use File | Settings | File Templates.
--

local PopBaseNode = class("PopBaseNode", function ()
	return display.newNode()
end)


function PopBaseNode:onExit()
	if self._closeListener then
		self._closeListener()
	end
end

function PopBaseNode:setClosedListener(listener)
	self._closeListener = listener
end

function PopBaseNode:ctor()
	self:setNodeEventEnabled(true)
end

return PopBaseNode

