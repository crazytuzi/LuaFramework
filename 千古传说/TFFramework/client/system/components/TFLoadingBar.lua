--[[--
	进度条控件:

	--By: yun.bo
	--2013/8/5
]]

local _create = TFLoadingBar.create
function TFLoadingBar:create(texture)
	local obj = _create(TFLoadingBar)
	if  not obj then return end
	if texture then
		obj:setTexture(texture)
	end
	TFUIBase:extends(obj)
	
	return obj
end

local function new(val, parent)
	local obj = TFLoadingBar:create()
	obj:setPercent(0)
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMELoadingBar(val, parent)
	return true, obj
end
rawset(TFLoadingBar, "initControl", initControl)

return TFLoadingBar