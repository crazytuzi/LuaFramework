local focusVIPWechat = class("focusVIPWechat", function ()
	return display.newNode()
end)

table.merge(slot0, {})

focusVIPWechat.ctor = function (self)
	self._supportMove = true
	local panelBg = res.get2("pic/common/black_2.png"):anchor(0, 0):addto(self)

	self.size(self, panelBg.getContentSize(panelBg)):anchor(0.5, 0.5):pos(display.cx, display.cy)
	an.newLabel("关注VIP公众号", 22, 0, {
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

	local vipBg = res.get2("pic/panels/vip/vipBG.png"):addto(panelBg):pos(panelBg.getw(panelBg)/2, panelBg.geth(panelBg)/2 - 20)
	local headBg = res.get2("pic/panels/vip/headBg.png"):addto(vipBg):anchor(0, 0):pos(450, 190)

	res.get2("pic/panels/vip/headIcon.jpg"):addto(headBg):pos(headBg.getw(headBg)/2, headBg.geth(headBg)/2)
	res.get2("pic/panels/vip/zskf.png"):addto(vipBg):anchor(0, 0):pos(429, 168)
	res.get2("pic/panels/vip/QQ.png"):addto(vipBg):anchor(0, 0):pos(437, 145)
	an.newLabel("? ? ? ? ? ?", 18, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0):pos(480, 145):addto(vipBg)
	res.get2("pic/panels/vip/strBg.png"):addto(vipBg):anchor(0, 0):pos(12, 264)

	local labelM1 = an.newLabelM(500, 20, 0, {
		manual = false
	}):pos(23, 282):add2(vipBg):anchor(0, 0.5)

	labelM1.addLabel(labelM1, "打开微信-点击右上角", def.colors.Cdcd2be)
	labelM1.addLabel(labelM1, "\"+\"", def.colors.Ce66946)
	labelM1.addLabel(labelM1, "号添加朋友", def.colors.Cdcd2be)
	res.get2("pic/panels/vip/strBg.png"):addto(vipBg):anchor(0, 0):pos(12, 204)

	local labelM2 = an.newLabelM(500, 20, 0, {
		manual = false
	}):pos(23, 222):add2(vipBg):anchor(0, 0.5)

	labelM2.addLabel(labelM2, "查找公众号-输入官方微信号：", def.colors.Cdcd2be)
	labelM2.addLabel(labelM2, "\"SVIP3975\"", def.colors.Ce66946)
	labelM2.addLabel(labelM2, "关注", def.colors.Cdcd2be)
	res.get2("pic/panels/vip/strBg.png"):addto(vipBg):anchor(0, 0):pos(12, 144)

	local labelM3 = an.newLabelM(500, 20, 0, {
		manual = false
	}):pos(23, 162):add2(vipBg):anchor(0, 0.5)

	labelM3.addLabel(labelM3, "添加", def.colors.Cdcd2be)
	labelM3.addLabel(labelM3, "\"专属客服QQ\"", def.colors.Ce66946)
	labelM3.addLabel(labelM3, "领取VIP专享礼包", def.colors.Cdcd2be)
	res.get2("pic/panels/vip/zstd.png"):addto(vipBg):anchor(0, 0):pos(8, 85)
	an.newLabel("美女客服一对一贴身服务，意见直通策划", 18, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):pos(10, 75):addto(vipBg)
	res.get2("pic/panels/vip/zsyx.png"):addto(vipBg):anchor(0, 0):pos(8, 34)
	an.newLabel("游戏第一手新资料，优先获取", 18, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):pos(10, 24):addto(vipBg)
	res.get2("pic/panels/vip/zslb.png"):addto(vipBg):anchor(0, 0):pos(344, 85)
	an.newLabel("成为超级会员，领取超级大礼包", 18, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):pos(346, 75):addto(vipBg)
	res.get2("pic/panels/vip/zshd.png"):addto(vipBg):anchor(0, 0):pos(344, 34)
	an.newLabel("专属不定时活动和福利", 18, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):pos(346, 24):addto(vipBg)

	return 
end

return focusVIPWechat
