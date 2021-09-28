local current = ...
local btnEx = import("..btnEx")
local pointTip = import("...common.pointTip")
local hp = class("widget_hp", function ()
	return display.newNode()
end)

table.merge(slot3, {
	config,
	data,
	mpPercent = 0,
	hpPercent = 0
})

hp.ctor = function (self, config, data)
	self.size(self, 120, 120):anchor(0.5, 0.5):pos(data.x, data.y)
	display.newNode():size(self.getContentSize(self)):pos(self.centerPos(self)):anchor(0.5, 0.5):add2(self):enableClick(function ()
		main_scene.ui.ui_btnEx = btnEx.new()

		return 
	end).setName(slot3, "diyhp")

	local hpbg = res.get2("pic/console/hp/hpbg.png"):anchor(0.5, 1):pos(self.getw(self)/2, self.geth(self) + 14):addto(self)
	self.hpNull = res.get2("pic/console/hp/hp4.png"):anchor(0, 0):pos(70, 36):addto(hpbg)
	self.hpSpr = res.get2("pic/console/hp/hp3.png"):anchor(0, 0):pos(70, 36):addto(hpbg)
	self.mpSpr = res.get2("pic/console/hp/hp2.png"):anchor(0, 0):pos(70, 36):addto(hpbg):hide()
	local hpvaluebg = res.get2("pic/console/hp/hpValueBg.png"):add2(hpbg)

	hpvaluebg.pos(hpvaluebg, hpbg.getw(hpbg)/2 - hpvaluebg.getw(hpvaluebg)/2 - 2, 8)

	local mpvaluebg = res.get2("pic/console/hp/hpValueBg.png"):add2(hpbg)

	mpvaluebg.pos(mpvaluebg, (hpbg.getw(hpbg)/2 + mpvaluebg.getw(mpvaluebg)/2) - 2, 8)

	self.hplabel = an.newLabel("0/0", 14, 1):anchor(0.5, 0.5):pos(hpvaluebg.getw(hpvaluebg)/2 - 2, hpvaluebg.geth(hpvaluebg)/2 + 1):add2(hpvaluebg)
	self.mplabel = an.newLabel("0/0", 14, 1):anchor(0.5, 0.5):pos(mpvaluebg.getw(mpvaluebg)/2 - 2, mpvaluebg.geth(mpvaluebg)/2 + 1):add2(mpvaluebg)
	local offsetX = 24
	local offsetY = 13
	local menubg = an.newBtn(res.gettex2("pic/console/hp/cmd.png"), function ()
		main_scene.ui.ui_btnEx = btnEx.new()

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/console/hp/cmd2.png")
	}).add2(slot8, hpbg)
	self.menubg = menubg

	menubg.pos(menubg, menubg.getw(menubg)/2 + offsetX, menubg.geth(menubg)/2 + offsetY)

	if not VERSION_REVIEW then
		local function faqCallback()
			local rsb = DefaultClientMessage(CM_FAQ)

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end

		local offsetX = 150
		local offsetY = 13
		local faqbg = an.newBtn(res.gettex2("pic/console/hp/FAQ.png"), slot9, {
			pressBig = true,
			pressImage = res.gettex2("pic/console/hp/FAQ2.png")
		}):add2(hpbg)

		faqbg.pos(faqbg, faqbg.getw(faqbg)/2 + offsetX, faqbg.geth(faqbg)/2 + offsetY)
	end

	g_data.eventDispatcher:addListener("M_POINTTIP", self, self.onPointTip)

	return 
end
hp.update = function (self, dt)
	local ability = g_data.player.ability

	if not ability then
		return 
	end

	if not self.isDoublePost and ((g_data.player.job == 0 and 28 <= ability.FLevel) or (g_data.player.job == 1 and 7 <= ability.FLevel) or (g_data.player.job == 2 and 7 <= ability.FLevel)) then
		self.isDoublePost = true

		self.hpNull:removeSelf()

		self.hpNull = nil

		self.hpSpr:setTex(res.gettex2("pic/console/hp/hp1.png"))
		self.mpSpr:show()
	end

	local hpPercent = ability.FHP/ability.FMaxHP

	if 1 < hpPercent then
		hpPercent = 1
	end

	if hpPercent < 0 then
		hpPercent = 0
	end

	if hpPercent ~= self.hpPercent then
		self.hpPercent = hpPercent
		local size = self.hpSpr:getTexture():getContentSize()

		self.hpSpr:setTextureRect(cc.rect(0, size.height*(hpPercent - 1), size.width, size.height*hpPercent))
	end

	local mpPercent = ability.FMP/ability.FMaxMP

	if 1 < mpPercent then
		mpPercent = 1
	end

	if mpPercent < 0 then
		mpPercent = 0
	end

	if mpPercent ~= self.mpPercent then
		self.mpPercent = mpPercent
		local size = self.mpSpr:getTexture():getContentSize()

		self.mpSpr:setTextureRect(cc.rect(0, size.height*(mpPercent - 1), size.width, size.height*mpPercent))
	end

	self.hplabel:setString(ability.FHP .. "/" .. ability.FMaxHP)
	self.mplabel:setString(ability.FMP .. "/" .. ability.FMaxMP)

	return 
end
hp.setEquipLockVisible = function (self, visible)
	return 
end
hp.onPointTip = function (self, type, visible)
	local chk_tab = {
		"relation",
		"mail",
		"trade0",
		"trade1",
		"activity",
		"gemstone_active",
		"gemstone_upgrade",
		"wing_activate",
		"wing_show",
		"redPacket",
		"solider_upgrade",
		"god_ring_upgrade",
		"horseSoul_upgrade",
		"maoyu_upgrade",
		"feiyu_upgrade",
		"lingyu_upgrade"
	}

	for i, v in ipairs(chk_tab) do
		if g_data.pointTip:isVisible(v) then
			self.setPointTip(self, true)

			return 
		end
	end

	self.setPointTip(self, false)

	return 
end
hp.setPointTip = function (self, visible)
	if self.tip then
		self.tip:removeFromParent()

		self.tip = nil
	end

	if not visible or not self.menubg then
		return 
	end

	self.tip = pointTip.attach(self.menubg, {
		dir = "left",
		ui = "small",
		type = 0
	})

	self.tip.sprite:scale(1.5)

	return 
end

return hp
