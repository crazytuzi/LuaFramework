--[[--
	文本按钮控件:

	--By: yun.bo
	--2013/9/30
]]

TFTextButton = {}

function TFTextButton:create(texture)
	local obj = TFButton:create()
	if obj and texture then 
		obj:setTextureNormal(texture)
	end
	return obj
end

local function new(val, parent)
	local obj
	obj 	= TFTextButton:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMETextButton(val, parent)
	return true, obj
end
rawset(TFTextButton, "initControl", initControl)

return TFTextButton