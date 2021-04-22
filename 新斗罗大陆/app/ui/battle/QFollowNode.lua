-- Author: MOUSECUTE
-- Date: 2016-08-13
-- Brief: QFollowNode auto update itself position to anchor to another node

local QFollowNode = class("QFollowNode", function()
	return display.newNode()
end)

function QFollowNode.createWithFollowedNode(followedNode)
	if followedNode == nil then
		return nil
	end

	return QFollowNode.new(followedNode)
end

function QFollowNode:ctor(followedNode)
	self._followedNode = followedNode
end

local _point = ccp(0, 0)

function QFollowNode:onFrame(dt)
	local followedNode = self._followedNode
	local x, y = followedNode:getPosition()
	if x and y then
		_point.x, _point.y = x, y
		local p = _point
		if p then
			local wpos = followedNode:getParent():convertToWorldSpace(p)
			self:setPosition(self:getParent():convertToNodeSpace(wpos))
		end
	end
end

return QFollowNode