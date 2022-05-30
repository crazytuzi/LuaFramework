local HuaShanDescLayer = class("HuaShanDescLayer", function()
	return require("utility.ShadeLayer").new()
end)

function HuaShanDescLayer:ctor()
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_desc.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local scrollview = self._rootnode.scrollview
	local size = scrollview:getContentSize()
	local viewsize = scrollview:getViewSize()
	local des_label = ui.newTTFLabel({
	text = common:getLanguageString("@HuashanText"),
	color = cc.c3b(153, 102, 51),
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	dimensions = cc.size(viewsize.width, 0)
	})
	local contentViewSize = des_label:getContentSize()
	des_label:align(display.LEFT_BOTTOM)
	scrollview:addChild(des_label)
	scrollview:setContentSize(contentViewSize)
	scrollview:updateInset()
	scrollview:setContentOffset(cc.p(0, -contentViewSize.height + viewsize.height - 10), false)
	scrollview:setDirection(kCCScrollViewDirectionVertical)
	
	local function close()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.okBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
end

return HuaShanDescLayer