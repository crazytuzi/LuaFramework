--[[--
	滚动条控件:

	--By: yun.bo
	--2013/8/13
]]

local _create = TFScrollView.create
function TFScrollView:create()
	local obj = _create(TFScrollView)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFScrollView:create()
	if parent then
		parent:addChild(obj) 
	end	
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	-- obj:scrollToBottom()
	obj:initMEScrollView(val, parent)
	return true, obj
end
rawset(TFScrollView, "initControl", initControl)

return TFScrollView
