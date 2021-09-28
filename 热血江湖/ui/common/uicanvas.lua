
local UIBase = require "ui/common/UIBase"

local UIDefault = require "ui/common/DefaultValue"

local UICommon = require "ui/common/UICommon"

local UICanvas=class("UICanvas", UIBase)

function UICanvas:ctor(ccNode, propConfig)
    UICanvas.super.ctor(self, ccNode, propConfig)
end
	
function UICanvas:drawing(scales)
	local drawType = #scales==5 and 1 or (#scales==6 and 2) or UIDefault.DefCanvas.drawType
	self.ccNode_:setDrawType(drawType)
	for i,v in ipairs(scales) do
		if v>1 then
			scales[i] = 1
		end
	end
	if drawType==1 then
		self.ccNode_:setFloatParam(0, scales[1] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(1, scales[2] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(2, scales[3] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(3, scales[4] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(4, scales[5] or UIDefault.DefCanvas.scale)
	elseif drawType==2 then
		self.ccNode_:setFloatParam(0, scales[1] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(1, scales[2] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(2, scales[3] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(3, scales[4] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(4, scales[5] or UIDefault.DefCanvas.scale)
		self.ccNode_:setFloatParam(5, scales[6] or UIDefault.DefCanvas.scale)
		self:setRotation(-(360/6/2))
	end
end

function UICanvas:setFillColor(color)
	color = color or  UIDefault.DefCanvas.fillColor
	self.ccNode_:setFillColor(UICommon.getColorC4BByStr(color))
end

function UICanvas:setLineColor(color)
	color = color or UIDefault.DefCanvas.lineColor
	self.ccNode_:setLineColor(UICommon.getColorC4BByStr(color))
end

function UICanvas:drawingWithCustomValue(scales, lineColor, fillColor)
	self:setLineColor(lineColor)
	self:setFillColor(fillColor)
	self:drawing(scales)
end

return UICanvas