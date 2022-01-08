--[[--
	图片控件:

	--By: yun.bo
	--2013/7/12
]]

local TFUIBase = TFUIBase
local TFImage = TFImage

local _create = TFImage.create
function TFImage:create(...)
	local obj = _create(TFImage, ...)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFImage:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEImage(val, parent)
	return true, obj
end
rawset(TFImage, "initControl", initControl)

return TFImage