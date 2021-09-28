local wechatRecharge = class("wechatRecharge", function ()
	return display.newNode()
end)

table.merge(slot0, {})

wechatRecharge.ctor = function (self)
	self._supportMove = true
	local panelBg = res.get2("pic/panels/weChatRP/wechatRechage.png"):anchor(0, 0):addto(self)

	self.size(self, panelBg.getContentSize(panelBg)):anchor(0.5, 0.5):pos(display.cx, display.cy)
	an.newLabel("", 22, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):pos(panelBg.getw(panelBg)/2, panelBg.geth(panelBg) - 22):addto(panelBg)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot2, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addto(self, 20)

	return 
end

return wechatRecharge
