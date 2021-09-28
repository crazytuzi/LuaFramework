local pointTip = import("..common.pointTip")
local secondMenu = class("secondMenu", function ()
	return display.newNode()
end)

table.merge(slot1, {
	content,
	btnNum,
	menuName,
	menuBtns,
	offsetX,
	tipBtns
})

local btn_panels = {
	community = {
		"group",
		"relation",
		"mail",
		"top",
		"redPacket",
		"arena"
	},
	trade = {
		function ()
			if g_data.player:getIsCrossServer() then
				main_scene.ui:tip("该功能不能使用")

				return 
			end

			if g_data.client:checkLastTime("deal", 3) then
				g_data.client:setLastTime("deal", true)

				local rsb = DefaultClientMessage(CM_F2F_DEAL)
				rsb.dealStatus = 0

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end,
		function ()
			if g_data.player:getIsCrossServer() then
				main_scene.ui:tip("该功能不能使用")

				return 
			end

			if main_scene.ui:isPanelVisible("bag") then
				main_scene.ui:hidePanel("bag")
			end

			main_scene.ui:togglePanel("tradeshop", {
				default = 1,
				type = 0
			})

			return 
		end,
		function ()
			if g_data.player:getIsCrossServer() then
				main_scene.ui:tip("该功能不能使用")

				return 
			end

			if main_scene.ui:isPanelVisible("bag") then
				main_scene.ui:hidePanel("bag")
			end

			main_scene.ui:togglePanel("tradeshop", {
				default = 1,
				type = 1
			})

			return 
		end
	}
}
secondMenu.ctor = function (self, param)
	self._supportMove = false
	self.tipBtns = {}
	self.menuBtns = {}
	self.menuName = param[1]
	self.minBtnNum = param[2]
	self.offsetX = (param[3] and param[3]:getPositionX()) or 0
	local btnWidth = 75
	local btnGap = 6
	local btnXBase = btnWidth/2 + btnGap
	local btnXOffset = btnWidth + btnGap
	local actualBtnNum = self.minBtnNum
	self.content = display.newScale9Sprite(res.getframe2("pic/panels/secondMenu/btnsBg.png"), 0, 0, cc.size(0, 90)):addTo(self, an.z.max):pos(0, 73)

	self.size(self, self.content:getw(), self.content:geth())
	self.content:setPositionX(self.offsetX)

	local function btnCB(sender)
		local tag = sender.getTag(sender)
		local name = self.menuName
		local panelName = btn_panels[name][tag]

		if panelName and type(panelName) == "string" and g_data.player:getIsCrossServer() and (panelName == "redPacket" or panelName == "top") then
			main_scene.ui:tip("该功能不能使用")
		elseif panelName and type(panelName) == "string" and panelName == "arena" then
			self:openAranaPanel()
		elseif panelName and type(panelName) == "string" and panelName ~= "" then
			main_scene.ui:togglePanel(panelName)
		elseif panelName and type(panelName) == "function" then
			panelName()
		end

		self:hidePanel()
		sound.playSound("103")

		if main_scene.ui.ui_btnEx then
			main_scene.ui.ui_btnEx:hide()
		end

		return 
	end

	local additionalBtnPosX = btnXBase + btnXOffset*3

	if param[1] == "community" then
		additionalBtnPosX = btnXBase + btnXOffset*3
		self.menuBtns[1] = an.newBtn(res.gettex2("pic/console/panel-icons/group.png"), slot7):addTo(self.content)

		self.menuBtns[1]:pos(btnXBase, 45):setTag(1)

		self.menuBtns[2] = an.newBtn(res.gettex2("pic/console/panel-icons/relation.png"), btnCB):addTo(self.content)

		self.menuBtns[2]:pos(btnXBase + btnXOffset, 45):setTag(2)

		self.menuBtns[3] = an.newBtn(res.gettex2("pic/console/panel-icons/mail.png"), btnCB):addTo(self.content)

		self.menuBtns[3]:pos(btnXBase + btnXOffset*2, 45):setTag(3)

		if g_data.serConfig and g_data.serConfig.rankClose == 0 then
			self.menuBtns[#self.menuBtns + 1] = an.newBtn(res.gettex2("pic/console/panel-icons/top.png"), btnCB):addTo(self.content)

			self.menuBtns[#self.menuBtns]:pos(additionalBtnPosX, 45):setTag(4)

			additionalBtnPosX = additionalBtnPosX + btnXOffset
			actualBtnNum = actualBtnNum + 1
		end

		if g_data.serConfig and g_data.serConfig.cashGiftClose == 0 then
			self.menuBtns[#self.menuBtns + 1] = an.newBtn(res.gettex2("pic/panels/redPacket/BtnRedPacket.png"), btnCB):addTo(self.content)

			self.menuBtns[#self.menuBtns]:pos(additionalBtnPosX, 45):setTag(5)

			additionalBtnPosX = additionalBtnPosX + btnXOffset
			actualBtnNum = actualBtnNum + 1
		end

		if 40 <= g_data.client.openDay and not g_data.player:getIsCrossServer() then
			self.menuBtns[#self.menuBtns + 1] = an.newBtn(res.gettex2("pic/console/panel-icons/arena.png"), btnCB):addTo(self.content)

			self.menuBtns[#self.menuBtns]:pos(additionalBtnPosX, 45):setTag(6)

			additionalBtnPosX = additionalBtnPosX + btnXOffset
			actualBtnNum = actualBtnNum + 1
		end
	else
		additionalBtnPosX = btnXBase + btnXOffset
		self.menuBtns[1] = an.newBtn(res.gettex2("pic/console/panel-icons/deal.png"), btnCB):addTo(self.content)

		self.menuBtns[1]:pos(btnXBase, 45):setTag(1)

		if g_data.isYBTradeShopClose == false then
			self.menuBtns[#self.menuBtns + 1] = an.newBtn(res.gettex2("pic/console/panel-icons/yb.png"), btnCB):addTo(self.content)

			self.menuBtns[#self.menuBtns]:pos(additionalBtnPosX, 45):setTag(2)

			additionalBtnPosX = additionalBtnPosX + btnXOffset
			actualBtnNum = actualBtnNum + 1
		end

		if g_data.isJBTradeShopClose == false then
			self.menuBtns[#self.menuBtns + 1] = an.newBtn(res.gettex2("pic/console/panel-icons/jb.png"), btnCB):addTo(self.content)

			self.menuBtns[#self.menuBtns]:pos(additionalBtnPosX, 45):setTag(3)

			additionalBtnPosX = additionalBtnPosX + btnXOffset
			actualBtnNum = actualBtnNum + 1
		end
	end

	local bgWidth = btnWidth*actualBtnNum + btnGap*(actualBtnNum + 1)

	self.content:setContentSize(bgWidth, 90)
	res.get2("pic/panels/secondMenu/arrow.png"):anchor(0.5, 1):addto(self, an.z.max + 1):pos(self.offsetX, 30)

	for i, v in ipairs(self.menuBtns) do
		if param[1] == "community" then
			local panelName = btn_panels[self.menuName][i]

			if table.indexof({
				"mail",
				"relation",
				"redPacket"
			}, panelName) then
				g_data.eventDispatcher:addListener("M_POINTTIP", self, self.onPointTip)

				self.tipBtns[panelName] = self.menuBtns[i]

				self.setPointTip(self, self.menuBtns[i], g_data.pointTip:isVisible(panelName))
			end
		else
			local key = ""

			if v.getTag(v) == 2 then
				key = "trade0"
			elseif v.getTag(v) == 3 then
				key = "trade1"
			end

			if v.getTag(v) ~= 1 then
				g_data.eventDispatcher:addListener("M_POINTTIP", self, self.onPointTip)

				self.tipBtns[key] = self.menuBtns[i]

				self.setPointTip(self, self.menuBtns[i], g_data.pointTip:isVisible(key))
			end
		end
	end

	return 
end
secondMenu.onPointTip = function (self, type, visible)
	if type == "mail" and type == "relation" and type == "redPacket" and string.find(type, "trade") then
		local btn = self.tipBtns[type]

		if not btn then
			return 
		end

		self.setPointTip(self, btn, visible)
	end

	return 
end
secondMenu.setPointTip = function (self, btn, visible)
	local tip = btn.getChildByName(btn, "tip")

	if not visible then
		if tip then
			tip.removeFromParent(tip)
		end

		return 
	end

	if not tip then
		tip = pointTip.attach(btn, {
			dir = "right",
			type = 0,
			r = 38,
			visible = true
		})

		tip.setName(tip, "tip")
	end

	return 
end
secondMenu.openAranaPanel = function (self)
	if main_scene.ui:isPanelVisible("arena") then
		main_scene.ui:togglePanel("arena")

		return 
	end

	if g_data.player:getIsCrossServer() then
		main_scene.ui:tip("该功能不能使用")

		return 
	end

	if g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
		local rsb = DefaultClientMessage(CM_ArenaReqList)
		rsb.Fdorefresh = false

		MirTcpClient:getInstance():postRsb(rsb)
	else
		main_scene.ui:tip("在安全区才可以参加跨服竞技")
	end

	return 
end

return secondMenu
