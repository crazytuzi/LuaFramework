
local UIBase = require "ui/common/UIBase"

local UICooler = class("UICooler", UIBase)

function UICooler:ctor(ccNode, propConfig)
    UICooler.super.ctor(self, ccNode, propConfig)
	local progressTimer = ccNode:getVirtualRenderer()
	if progressTimer then -- cc.ProgressTimer
		self.ccNode_ = progressTimer 
	end
	self._percent = propConfig.percent
end

--TODO
--
function UICooler:setPercent(percent)
	self._percent = percent<100 and percent or 100
	self.ccNode_:setPercentage(percent)
end

function UICooler:getPercent()
	return self._percent
end

function UICooler:createProgressAction(coolTime, fromPercent, toPercent)
	local progressToAction = cc.ProgressFromTo:create(coolTime,fromPercent, toPercent);
	return progressToAction
end

function UICooler:runAction(action)
	if action and self.ccNode_ then
		self.ccNode_:runAction(action)
	end
end

return UICooler