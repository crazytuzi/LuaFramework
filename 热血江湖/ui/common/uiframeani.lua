
local UIBase = require "ui/common/UIBase"

local UIFrameAni=class("UIFrameAni", UIBase)

function UIFrameAni:ctor(ccNode, prop)
    UIFrameAni.super.ctor(self, ccNode, prop)
	self._prop = prop
end

function UIFrameAni:play(times)
	local times = times or -1
	if times == 0 then
		return
	end
	if self.ccNode_._ani then
		local action = times < 0 and cc.RepeatForever:create(self.ccNode_._ani) or cc.Repeat:create(self.ccNode_._ani, times)
		self.ccNode_._sprite:runAction(action)
	end
end

return UIFrameAni
