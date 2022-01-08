--[[--
	PageView控件:

	--By: yun.bo
	--2013/7/12
]]

local _create = TFPageView.create
function TFPageView:create()
	local obj = _create(TFPageView)
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFPageView:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEPageView(val, parent)
	return true, obj
end
rawset(TFPageView, "initControl", initControl)

return TFPageView