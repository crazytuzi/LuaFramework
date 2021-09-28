local h = 118
local btnEx = class("btnEx", function ()
	return display.newNode()
end)
local pointTip = import("..common.pointTip")

table.merge(slot1, {
	bg,
	content,
	btns
})

btnEx.hide = function (self)
	if main_scene then
		main_scene:stopAllActions()
		main_scene:moveTo(0.2, 0, 0)
		main_scene.ground:stopAllActions()
		main_scene.ground:moveTo(0.2, 0, 0)
	end

	main_scene.ui.ui_btnEx:runs({
		cc.MoveTo:create(0.2, cc.p(0, 0)),
		cc.CallFunc:create(function ()
			self:removeSelf()

			if main_scene and main_scene.ui then
				main_scene.ui.ui_btnEx = nil
			end

			return 
		end)
	})

	if main_scene.ui.panels.secondMenu then
		main_scene.ui.panels.secondMenu.hidePanel(slot1)
	end

	return 
end
btnEx.ctor = function (self)
	self.setNodeEventEnabled(self, true)

	self.btns = {}

	if main_scene then
		main_scene:stopAllActions()
		main_scene:moveTo(0.2, 0, h)
		main_scene.ground:stopAllActions()
		main_scene.ground:moveTo(0.2, 0, -h/2)
	end

	self.size(self, display.width, display.height):add2(display.getRunningScene(), an.z.max)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			self:hide()
		end

		return 
	end)

	self.bg = display.newScale9Sprite(res.getframe2("pic/console/boardscale.png")).anchor(slot1, 0, 1):add2(self):size(display.width, h)

	self.loadMain(self)

	return 
end
btnEx.onCleanup = function (self)
	return 
end
btnEx.loadMain = function (self)
	self.content = display.newNode():pos(0, -h):size(display.width, h):add2(self):enableClick(function ()
		return 
	end)
	local btns = {
		"equip",
		"bag",
		"skill",
		"guild",
		"community",
		"trade",
		"activity",
		"picIdentify",
		"setting",
		"shop",
		"recharge",
		"ebag"
	}

	if VERSION_REVIEW then
		btns = {
			"bag",
			"equip",
			"skill",
			"deal",
			"guild",
			"community",
			"shop",
			"setting"
		}
	end

	local notShowRecharge = g_data.login.showShopAndRechargeBtn(slot2) == false

	if notShowRecharge then
		btns = {
			"equip",
			"bag",
			"skill",
			"guild",
			"community",
			"trade",
			"activity",
			"picIdentify",
			"setting"
		}
	end

	local space = 85
	local allwidth = #btns*space
	local scale = (allwidth < display.width and 1) or display.width/allwidth
	allwidth = allwidth*scale
	space = space*scale
	local devicefixH = 0

	if game.deviceFix and device.platform == "ios" then
		devicefixH = 9
	end

	for i, v in ipairs(btns) do
		local btn = nil
		btn = an.newBtn(res.gettex2("pic/console/iconbg11.png"), function ()
			sound.playSound("103")

			btn.config = {
				btnid = v
			}

			main_scene.ui.console.btnCallbacks:handle("panel", btn)

			if v == "trade" or v == "community" then
				return 
			end

			self:hide()

			return 
		end, {
			pressBig = true,
			sprite = res.gettex2("pic/console/panel-icons/" .. slot11 .. ".png")
		}):pos(display.cx - allwidth/2 + (i - 0.5)*space, h/2 + devicefixH):scale(scale):add2(self.content)
		self.btns[v] = btn

		btn.setName(btn, "btnEx_" .. v)

		if self[v .. "Extend"] then
			self[v .. "Extend"](self, btn)
		end
	end

	g_data.eventDispatcher:addListener("M_POINTTIP", self, self.onPointTip)
	self.onCommunityPointTip(self, nil, nil)
	self.onTradePointTip(self, nil, nil)
	self.onEquipPointTip(self, nil, nil)
	self.onActivityPointTip(self, "activity", g_data.pointTip:isVisible("activity"))

	return 
end
btnEx.onPointTip = function (self, type, visible)
	local a = {
		"mail",
		"relation",
		"group",
		"redPacket"
	}
	local b = {
		"trade0",
		"trade1"
	}
	local c = {
		"gemstone_active",
		"gemstone_upgrade",
		"wing_upgrade",
		"wing_activate",
		"solider_upgrade",
		"god_ring_upgrade",
		"horseSoul_upgrade",
		"maoyu_upgrade",
		"feiyu_upgrade",
		"lingyu_upgrade"
	}
	local d = {
		"activity"
	}

	if table.indexof(a, type) then
		self.onCommunityPointTip(self, type, visible)
	elseif table.indexof(b, type) then
		self.onTradePointTip(self, type, visible)
	elseif table.indexof(c, type) then
		self.onEquipPointTip(self, type, visible)
	elseif table.indexof(d, type) then
		self.onActivityPointTip(self, type, visible)
	end

	return 
end
btnEx.onCommunityPointTip = function (self, type, visible)
	for i, v in ipairs({
		"mail",
		"relation",
		"group",
		"redPacket"
	}) do
		if g_data.pointTip:isVisible(v) then
			self.setPointTip(self, "community", true)

			return 
		end
	end

	self.setPointTip(self, "community", false)

	return 
end
btnEx.onTradePointTip = function (self, type, visible)
	for i, v in ipairs({
		"trade0",
		"trade1"
	}) do
		if g_data.pointTip:isVisible(v) then
			self.setPointTip(self, "trade", true)

			return 
		end
	end

	self.setPointTip(self, "trade", false)

	return 
end
btnEx.onEquipPointTip = function (self, type, visible)
	if g_data.pointTip:isVisible("gemstone_active") or g_data.pointTip:isVisible("gemstone_upgrade") or g_data.pointTip:isVisible("wing_activate") or g_data.pointTip:isVisible("solider_upgrade") or g_data.pointTip:isVisible("god_ring_upgrade") or g_data.pointTip:isVisible("horseSoul_upgrade") or g_data.pointTip:isVisible("maoyu_upgrade") or g_data.pointTip:isVisible("feiyu_upgrade") or g_data.pointTip:isVisible("lingyu_upgrade") then
		self.setPointTip(self, "equip", true)

		return 
	end

	self.setPointTip(self, "equip", false)

	return 
end
btnEx.onActivityPointTip = function (self, type, visible)
	self.setPointTip(self, type, visible)

	return 
end
btnEx.setPointTip = function (self, moudle, visible)
	local btn = self.btns[moudle]

	if not btn then
		return 
	end

	local tip = btn.getChildByName(btn, "tip")

	if not tip then
		tip = pointTip.attach(btn, {
			dir = "right",
			type = 0,
			visible = false
		})

		tip.setName(tip, "tip")
	end

	tip.visible(tip, visible == true)

	return 
end

return btnEx
