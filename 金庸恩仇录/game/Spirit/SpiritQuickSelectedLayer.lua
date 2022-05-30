local SpiritQuickSelectedLayer = class("SpiritQuickSelectedLayer", function ()
	return require("utility.ShadeLayer").new()
end)

local btn_effect = function (sender, callback)
	sender:runAction(transition.sequence({
	CCScaleTo:create(0.08, 0.8),
	CCScaleTo:create(0.1, 1.01),
	CCScaleTo:create(0.01, 1),
	CCCallFunc:create(function ()
		if callback then
			callback()
		end
	end)
	}))
end

function SpiritQuickSelectedLayer:ctor(callback)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_quick_select.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@xuanzezqxj"))
	local selected = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false
	}
	local function onSelecteAllBtn()
		for i = 1, 4 do
			selected[i] = true
			self._rootnode["selectedFlag_" .. tostring(i)]:setVisible(true)
		end
	end
	
	local function onConfirmBtn()
		if callback then
			callback(selected)
		end
		self:removeSelf()
	end
	
	local function onSelectedStar(tag)
		if selected[tag] then
			selected[tag] = false
		else
			selected[tag] = true
		end
		self._rootnode["selectedFlag_" .. tostring(tag)]:setVisible(selected[tag])
	end
	
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		btn_effect(sender, function ()
			self:removeSelf()
		end)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.chooseAllBtn:addHandleOfControlEvent(function(sender, eventName)
		btn_effect(sender, onSelecteAllBtn)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function (sender, eventName)
		btn_effect(sender, onConfirmBtn)
	end,
	CCControlEventTouchUpInside)
	
	for i = 1, 4 do
		self._rootnode["chooseStarBtn_" .. tostring(i)]:registerScriptTapHandler(onSelectedStar)
	end
end

return SpiritQuickSelectedLayer