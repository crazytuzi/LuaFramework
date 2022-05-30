local SplitResultLayer = class("SplitResultLayer", function()
	return require("utility.ShadeLayer").new()
end)

function SplitResultLayer:ctor(data, callback)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("lianhualu/lianhualu_result_layer.ccbi", proxy, rootnode)
	self:addChild(node)
	node:setPosition(display.cx, display.cy)
	rootnode.titleLabel:setString(common:getLanguageString("@lianhuacg"))
	
	rootnode.tag_close:addHandleOfControlEvent(function()
		self:removeSelf()
	end,
	CCControlEventTouchDown)
	
	rootnode.closeBtn:addHandleOfControlEvent(function()
		self:removeSelf()
	end,
	CCControlEventTouchDown)
	
end

return SplitResultLayer