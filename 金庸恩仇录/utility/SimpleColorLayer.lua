local SimpleColorLayer = class("SimpleColorLayer", function (color)
	return display.newColorLayer(color or ccc4(0, 0, 0, 170))
end)
function SimpleColorLayer:ctor(param)
	self:setNodeEventEnabled(true)
	self:setTouchSwallowEnabled(true)
end
function SimpleColorLayer:onEnter()
end
function SimpleColorLayer:onExit()
	ResMgr.blueLayer = nil
end
return SimpleColorLayer
