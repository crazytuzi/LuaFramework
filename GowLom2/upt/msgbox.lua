local msgbox = class("upt_msgbox", function ()
	return display.newNode()
end)
msgbox.ctor = function (self, text, callback)
	self.size(self, display.width, display.height):addTo(display.getRunningScene(), 70001)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function ()
		return 
	end)

	local bg = display.newSprite("public/msgbox.png").center(slot3):addTo(self)
	local text = display.newTTFLabel({
		size = 18,
		x = 20,
		text = text,
		y = bg.getContentSize(bg).height - 20,
		dimensions = cc.size(400, 170)
	}):addTo(bg)

	text.setAnchorPoint(text, cc.p(0, 1))

	local ok = cc.ui.UIPushButton.new({
		pressed = "public/ok2.png",
		normal = "public/ok1.png"
	}):addTo(bg)

	ok.setAnchorPoint(ok, 1, 0)
	ok.pos(ok, bg.getContentSize(bg).width - 120, 20)
	ok.onButtonClicked(ok, function ()
		callback(true)

		return 
	end)
	ok.updateButtonImage_(slot5)

	local cancel = cc.ui.UIPushButton.new({
		pressed = "public/cancel2.png",
		normal = "public/cancel1.png"
	}):addTo(bg)

	cancel.setAnchorPoint(cancel, 1, 0)
	cancel.pos(cancel, bg.getContentSize(bg).width - 20, 20)
	cancel.onButtonClicked(cancel, function ()
		callback()

		return 
	end)
	cancel.updateButtonImage_(slot6)

	return 
end

return msgbox
