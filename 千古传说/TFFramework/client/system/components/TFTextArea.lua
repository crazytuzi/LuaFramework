--[[--
	文本块控件:

	--By: yun.bo
	--2013/9/30
]]

TFTextArea = {}

function TFTextArea:create()
	local obj = TFLabel:create()
	return obj
end

local function new(val, parent)
	local obj
	obj = TFTextArea:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMETextArea(val, parent)
	return true, obj
end
rawset(TFTextArea, "initControl", initControl)

return TFTextArea
