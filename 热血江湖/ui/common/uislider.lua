
local UIBase = require "ui/common/UIBase"

local UISlider=class("UISlider", UIBase)

function UISlider:ctor(ccNode, propConfig)
    UISlider.super.ctor(self, ccNode, propConfig)
end

function UISlider:setPercent(percent)
	self.ccNode_:setPercent(percent)
end

function UISlider:getPercent()
	return self.ccNode_:getPercent()
end

function UISlider:addEventListener(cb)
	self.ccNode_:addEventListener(cb)
end

return UISlider
