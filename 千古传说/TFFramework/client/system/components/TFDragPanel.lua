--[[--
	拖动面板控件:

	--By: yun.bo
	--2013/9/30
]]
TFDragPanel = TFDragPanel or {}

local _dpcreate = TFScrollView.create
function TFDragPanel:create()
	local obj = _dpcreate(TFScrollView)
	if  not obj then return end
	TFUIBase:extends(obj)
	obj:setDirection(SCROLLVIEW_DIR_BOTH)
	return obj
end

local function new(val, parent)
	local obj
	obj = TFDragPanel:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEDragPanel(val, parent)
	return true, obj
end
rawset(TFDragPanel, "initControl", initControl)

return TFDragPanel