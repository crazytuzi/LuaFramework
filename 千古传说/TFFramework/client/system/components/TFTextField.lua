--[[--
	文本控件:

	--By: yun.bo
	--2013/7/12
]]

local TFTextField = TFTextField

local _create = TFTextField.create
function TFTextField:create()
	local obj = _create(TFTextField)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFTextField:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMETextField(val, parent)
	return true, obj
end
rawset(TFTextField, "initControl", initControl)

return TFTextField