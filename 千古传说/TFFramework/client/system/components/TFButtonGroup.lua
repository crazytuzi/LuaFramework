--[[--
	按钮控件:

	--By: yun.bo
	--2013/8/27
]]

local _create = TFButtonGroup.create
function TFButtonGroup:create()
	local obj = _create(TFButtonGroup)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	obj 	= TFButtonGroup:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEButtonGroup(val, parent)
	return true, obj
end
rawset(TFButtonGroup, "initControl", initControl)

return TFButtonGroup