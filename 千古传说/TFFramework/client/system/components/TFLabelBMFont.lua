--[[--
	图片字体控件:

	--By: yun.bo
	--2013/7/12
]]

local _create = TFLabelBMFont.create
function TFLabelBMFont:create()
	local obj = _create(TFLabelBMFont)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFLabelBMFont:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMELabelBMFont(val, parent)
	return true, obj
end
rawset(TFLabelBMFont, "initControl", initControl)

return TFLabelBMFont
