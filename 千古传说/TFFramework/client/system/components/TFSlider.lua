
local _pcreate = TFSlider.create
function TFSlider:create()
	local obj = _pcreate(TFSlider)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	obj = TFSlider:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMESlider(val, parent)
	return true, obj
end
rawset(TFSlider, "initControl", initControl)

return TFSlider