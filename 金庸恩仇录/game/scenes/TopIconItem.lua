local TopIconItem = class("TopIconItem", function()
	return display.newNode()
end)

function TopIconItem:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("mainmenu/top_icon_item.ccbi", proxy, self._rootnode)
	self:addChild(node)
	self._rootnode.tag_kuanghuangou:addHandleOfControlEvent(function(sender, eventName)
		if param.callback ~= nil then
			param.callback(param.type)
		end
	end,
	CCControlEventTouchUpInside)
	self._rootnode.kuanghuangou_num:setString("")
	if param.num > 0 then
		self._rootnode.kuanghuangou_notice:setVisible(true)
	else
		self._rootnode.kuanghuangou_notice:setVisible(false)
	end
	return self
end

return TopIconItem