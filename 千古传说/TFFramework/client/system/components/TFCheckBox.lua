
local _pcreate = TFCheckBox.create
function TFCheckBox:create()
	local obj = _pcreate(TFCheckBox)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	obj = TFCheckBox:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMECheckBox(val, parent)
	return true, obj
end
rawset(TFCheckBox, "initControl", initControl)

return TFCheckBox