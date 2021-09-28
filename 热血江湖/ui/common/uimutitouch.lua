
local UIBase = require "ui/common/UIBase"

local UIMutiTouch=class("UIMutiTouch", UIBase)

function UIMutiTouch:ctor(ccNode, propConfig)
    UIMutiTouch.super.ctor(self, ccNode, propConfig)
end

function UIMutiTouch:getMutiTouchScaleRatio()
	return self.ccNode_:getMutiTouchScaleRatio()
end

function UIMutiTouch:isTouchEnabled()
	return self.ccNode_:isTouchEnabled()
end

function UIMutiTouch:onMutiTouch(hoster, cb)
	local function touchEvent(sender, eventType)
		if cb then
			cb(hoster, self, eventType);
		end
	end
	self:setTouchEnabled(true)
	self.ccNode_:addMutiTouchListener(touchEvent)
end

return UIMutiTouch