--[[--
	文本控件:

	--By: yun.bo
	--2013/7/29
]]

local TFUIBase = TFUIBase
local TFLabel = TFLabel

local _create = TFLabel.create
function TFLabel:create()
	local obj = _create(TFLabel)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	obj = TFLabel:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMELabel(val, parent)
	return true, obj
end
rawset(TFLabel, "initControl", initControl)

return TFLabel
