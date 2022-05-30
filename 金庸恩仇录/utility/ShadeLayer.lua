--“ı”∞≤„
local ShadeLayer = class("ShadeLayer", function (color)
	return display.newColorLayer(color or cc.c4b(0, 0, 0, 170))
end)

function ShadeLayer:ctor()
	self.touchFunc = nil
	self:setNodeEventEnabled(true)
	self.notice = ""
	local layer = tolua.cast(self,"cc.Layer")
	layer:setTouchEnabled(true)
	layer:setTouchSwallowEnabled(true)
	layer:registerScriptTouchHandler(function (eventName, x, y)
		if self.touchFunc ~= nil then
			self.touchFunc({name = eventName, x = x, y = y})
		end
		return true
	end)
end

function ShadeLayer:setTouchHandler(handler)
	self.touchFunc  = handler
end

function ShadeLayer:setNotice(str)
	self.notice = str
	RegNotice(self, function ()
		self:removeSelf()
	end,
	str)
end

function ShadeLayer:onExit()
	if self.notice ~= "" then
		UnRegNotice(self, self.notice)
	end
end

function ShadeLayer:setTouchFunc(func)
	self.touchFunc = func
end

return ShadeLayer