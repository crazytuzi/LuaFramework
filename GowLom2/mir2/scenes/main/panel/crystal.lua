local crystal = class("crystal", function ()
	return display.newNode()
end)
local common = import("..common.common")
local item = import("..common.item")

table.merge(slot0, {
	powerExp = 0,
	energyExp = 0,
	judge = false,
	expCanUseNum = 0,
	energyCanAuthNum = 0,
	energyCrystalCanGetNum = 0,
	sret = 0,
	energyCrystalNum = 0,
	vatilityCanAuthNum = 0
})

local pageName_Id = {
	expstall = 3,
	gay = 4,
	energy = 1
}
local BtnidFive = {
	{
		"你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"5元宝",
		cc.c3b(255, 0, 0)
	},
	{
		"鉴定并存储",
		cc.c3b(255, 255, 255)
	},
	{
		"1点",
		cc.c3b(255, 0, 0)
	},
	{
		"精力值么？\n(鉴定后，精力值将存储在水晶鉴定师处，需提取方可使用)",
		cc.c3b(255, 255, 255)
	}
}
local BtnidJ = {
	{
		"你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"1张精力鉴定卷",
		cc.c3b(255, 0, 0)
	},
	{
		"鉴定并存储",
		cc.c3b(255, 255, 255)
	},
	{
		"1点",
		cc.c3b(255, 0, 0)
	},
	{
		"精力值么？\n(鉴定后，精力值将存储在水晶鉴定师处，需提取方可使用)",
		cc.c3b(255, 255, 255)
	}
}
local BtnidT = {
	{
		"你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"10张精力鉴定卷",
		cc.c3b(255, 0, 0)
	},
	{
		"鉴定并存储",
		cc.c3b(255, 255, 255)
	},
	{
		"10点",
		cc.c3b(255, 0, 0)
	},
	{
		"精力值么？\n(鉴定后，精力值将存储在水晶鉴定师处，需提取方可使用)",
		cc.c3b(255, 255, 255)
	}
}
local BtnidFifty = {
	{
		"你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"50元宝",
		cc.c3b(255, 0, 0)
	},
	{
		"鉴定并存储",
		cc.c3b(255, 255, 255)
	},
	{
		"10点",
		cc.c3b(255, 0, 0)
	},
	{
		"精力值么？\n(鉴定后，精力值将存储在水晶鉴定师处，需提取方可使用)",
		cc.c3b(255, 255, 255)
	}
}
local BtnidGayExchange = {
	{
		"\n\n你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"1点信用分",
		cc.c3b(255, 0, 0)
	},
	{
		"和",
		cc.c3b(255, 255, 255)
	},
	{
		"50万",
		cc.c3b(255, 0, 0)
	},
	{
		"存储经验兑换1张老友令么?\n",
		cc.c3b(255, 255, 255)
	}
}
local BtnidGayUse = {
	{
		"\n\n你确定使用",
		cc.c3b(255, 255, 255)
	},
	{
		"1张老友令",
		cc.c3b(255, 0, 0)
	},
	{
		"获得",
		cc.c3b(255, 255, 255)
	},
	{
		"50万",
		cc.c3b(255, 0, 0)
	},
	{
		"存储经验么？",
		cc.c3b(255, 255, 255)
	}
}
local BtnidGayBackUse1 = {
	{
		"\n\n你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"50元宝",
		cc.c3b(255, 0, 0)
	},
	{
		"和",
		cc.c3b(255, 255, 255)
	},
	{
		"10张老友令",
		cc.c3b(255, 0, 0)
	},
	{
		"鉴定并提取10点精力值么？",
		cc.c3b(255, 255, 255)
	}
}
local BtnidGayBackUse2 = {
	{
		"\n\n你确定消耗",
		cc.c3b(255, 255, 255)
	},
	{
		"10张精力鉴定卷",
		cc.c3b(255, 0, 0)
	},
	{
		"和",
		cc.c3b(255, 255, 255)
	},
	{
		"10张老友令",
		cc.c3b(255, 0, 0)
	},
	{
		"鉴定并提取10点精力值么？",
		cc.c3b(255, 255, 255)
	}
}
ccui.CheckBoxEventType = {
	selected = 0,
	unselected = 1
}
ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}

local function allowRequest()
	return not g_data.client.lastTime.crystalOp or 0.2 < socket.gettime() - g_data.client.lastTime.crystalOp
end

local function queryCrystalInfo(queryType)
	slot1 = allowRequest() or slot1
	local rsb = DefaultClientMessage(CM_QUERY_CRYSTAL)
	rsb.CrystalType = queryType

	MirTcpClient:getInstance():postRsb(rsb)
	g_data.client:setLastTime("crystalOp", true)

	return 
end

local wanNum = 10000
local yiNum = 1000000000
local exp_big = {
	[wanNum] = "万",
	[yiNum] = "亿"
}
crystal.expToText = function (self, expNum)
	expNum = tonumber(expNum)
	local expText = ""

	if wanNum < expNum then
		expText = math.ceil(expNum/wanNum) .. exp_big[wanNum]
	elseif yiNum < expNum then
		expText = math.ceil(expNum/yiNum) .. exp_big[yiNum]
	else
		expText = tostring(math.ceil(expNum))
	end

	return expText
end
crystal.ctor = function (self, param)
	local writePath = WRITABLEPATH
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/uicrystal/uicrystal.csb")
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	self.lbl_energys = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_energyExp")
	self.lbl_powers = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_powerExp")
	self.lbl_vatilityNum = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_value_energy")
	self.lbl_minNum = ccui.Helper:seekWidgetByName(self.rootPanel, "Label_54_1_2_3_0")
	self.lbl_minNum_text = ccui.Helper:seekWidgetByName(self.rootPanel, "Label_54_1_2_5_6_0")
	self.OneVatilityBtn = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_energy_use")
	self.TenVatilityBtn = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_energy_use_1")
	self.vatilityBtnUseOne = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_energy_use_0")
	self.vatilityBtnUseFive = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_energy_use_0_1")
	self.vatilityBtnUseFifty = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_energy_use_0_2")
	self.vatilityBtnUseTen = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_energy_use_0_3")
	self.lbl_expCanUseNum = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_value_exp")
	self.btn_gay_exchange = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_gay_exchange")
	self.btn_gay_use = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_gay_use")
	self.btn_gay_back_use1 = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_gay_back_use1")
	self.btn_gay_back_use2 = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_gay_back_use2")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):center()
	self.add(self, bg)

	local function clickClose(btn, chk_eventType)
		if chk_eventType == ccui.TouchEventType.began then
			return 
		end

		self:hidePanel()

		return 
	end

	self.closeBtn = ccui.Helper.seekWidgetByName(slot5, self.rootPanel, "btn_close")

	self.closeBtn:addTouchEventListener(clickClose)

	local texts = {
		"energy",
		"expstall",
		"gay",
		"gay_back"
	}
	local tabs = {}

	local function selectFunc(btn, chk_eventType)
		if chk_eventType == ccui.CheckBoxEventType.selected then
			if btn.page ~= self.page then
				self.page = btn.page

				if pageName_Id[btn.page] then
					queryCrystalInfo(pageName_Id[btn.page])
				elseif btn.page == "gay_back" then
					self:showPageInfo(btn.page)
				else
					print("unknown select widget")
				end
			end

			for i, v in ipairs(tabs) do
				if v.page ~= btn.page then
					v.setSelected(v, false)
					v.setTouchEnabled(v, true)
				end
			end

			btn.setTouchEnabled(btn, false)
		end

		sound.playSound("103")

		return 
	end

	for i, v in ipairs(slot5) do
		local widgetName = "chk_" .. v
		tabs[i] = ccui.Helper:seekWidgetByName(self.rootPanel, widgetName)

		tabs[i]:addEventListener(selectFunc)

		tabs[i].page = v
	end

	local gayBackTab = ccui.Helper:seekWidgetByName(self.rootPanel, "chk_gay_back")

	gayBackTab.setVisible(gayBackTab, false)

	local rsb = DefaultClientMessage(CM_QueryServerStatus)

	MirTcpClient:getInstance():postRsb(rsb)

	local page = 1

	if param and param.panelType then
		page = param.panelType
	end

	tabs[page]:setSelected(true)
	selectFunc(tabs[page], ccui.CheckBoxEventType.selected)
	queryCrystalInfo(pageName_Id[tabs[page].page])
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_QUERY_CRYSTAL, self, self.onSM_QUERY_CRYSTAL)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_QUERY_EXCHANGE_EXP, self, self.onSM_QUERY_EXCHANGE_EXP)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Query_OldFriendWand, self, self.onSM_Query_OldFriendWand)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Exchange_OldFriendWand, self, self.onSM_Exchange_OldFriendWand)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Use_OldFriendWand, self, self.onSM_Use_OldFriendWand)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_QueryServerStatus, self, self.onSM_QueryServerStatus)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_OldFriendBackGetEnergy, self, self.onSM_OldFriendBackGetEnergy)

	return 
end

local function sendCrystalRsb(num, opType)
	if not allowRequest() then
		main_scene.ui:tip("操作太频繁,请稍候再试")

		return 
	end

	local rsb = DefaultClientMessage(CM_NORMAL_CRYSTAL_USE)
	rsb.CrystalType = opType
	rsb.CrystalCnt = num

	MirTcpClient:getInstance():postRsb(rsb)
	g_data.client:setLastTime("crystalOp", true)

	if 3 < opType then
		opType = 3
	end

	queryCrystalInfo(opType)

	return 
end

local page_func = {
	expstall = "showExpStallPage",
	gay = "showGayPage",
	gay_back = "showGayBackPage",
	energy = "showEnergyPage"
}
crystal.showPageInfo = function (self, page)
	if self.content then
		self.content:setVisible(false)
	end

	local panelName = "panel_" .. page
	self.content = ccui.Helper:seekWidgetByName(self.rootPanel, panelName)

	self.content:setVisible(true)
	self[page_func[page]](self)

	return 
end
crystal.GSon_getNum = function (self, result)
	if not result then
		return 
	end

	if result.Flag == 1 then
		self.lbl_minNum_text:setVisible(false)
		self.lbl_minNum:setString("无上限")
	else
		self.lbl_minNum_text:setVisible(true)

		if self.lbl_minNum then
			self.lbl_minNum:setString(result.EnergyCrystalCanGetNum)
		end
	end

	if self.lbl_vatilityNum then
		self.lbl_vatilityNum:setString(result.EnergyCrystalNum)
	end

	return 
end
crystal.GSM_getNum = function (self, result)
	if not result then
		return 
	end

	if result.Ret == 1 then
		if result.Flag == 1 then
			self.lbl_minNum_text:setVisible(false)
			self.lbl_minNum:setString("无上限")
		else
			self.lbl_minNum_text:setVisible(true)
			self.lbl_minNum:setString(result.EnergyCrystalCanGetNum)
		end

		self.lbl_vatilityNum:setString(result.EnergyCrystalNum)
	elseif result.Ret == 0 then
		main_scene.ui:tip("非法数据!", 6)
	elseif result.Ret == -1 then
		main_scene.ui:tip("提取失败，精力值不足!", 6)
	elseif result.Ret == -2 then
		main_scene.ui:tip("提取失败，提取次数不足!", 6)
	elseif result.Ret == -3 then
		main_scene.ui:tip("提取失败，精力值已达上限!", 6)
	else
		print("crystal:GSM_getNum：" .. (result.Ret or "nil"))
	end

	return 
end
crystal.FSM_YB_CRYSTAL_USE = function (self, result)
	return 
end
crystal.FSM_NORMAL_CRYSTAL_USE = function (self, result)
	return 
end
crystal.showEnergyPage = function (self)
	local rsb = DefaultClientMessage(CM_QueryEnergyCrystalInfo)

	MirTcpClient:getInstance():postRsb(rsb)

	local playerData = g_data.player
	local vality = self.energyCrystalNum
	local stamina = self.energyCrystalCanGetNum
	local space = 130

	local function vatilityBtnUseCallbackOne(sender, eventType)
		if eventType ~= ccui.TouchEventType.began then
			self.judge = true

			if self.OneVatilityBtn then
				self.OneVatilityBtn:setTouchEnabled(false)
			end

			if self.closeBtn then
				self.closeBtn:setTouchEnabled(false)
			end

			if self.TenVatilityBtn then
				self.TenVatilityBtn:setTouchEnabled(false)
			end

			return 
		end

		sound.playSound("103")

		local opType = 1

		if not self.judge then
			local msgbox = nil
			slot4 = an.newMsgbox(BtnidFive, function (idx)
				if idx == 1 then
					local rsb = DefaultClientMessage(CM_YB_CRYSTAL_USE)
					rsb.CrystalCnt = 1

					MirTcpClient:getInstance():postRsb(rsb)
					queryCrystalInfo(2)

					self.judge = false

					if self.OneVatilityBtn then
						self.OneVatilityBtn:setTouchEnabled(true)
					end

					if self.closeBtn then
						self.closeBtn:setTouchEnabled(true)
					end

					if self.TenVatilityBtn then
						self.TenVatilityBtn:setTouchEnabled(true)
					end
				else
					self.judge = false

					if self.OneVatilityBtn then
						self.OneVatilityBtn:setTouchEnabled(true)
					end

					if self.closeBtn then
						self.closeBtn:setTouchEnabled(true)
					end

					if self.TenVatilityBtn then
						self.TenVatilityBtn:setTouchEnabled(true)
					end

					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot4

			msgbox.pos(msgbox, -space, 0)
		end

		return 
	end

	local function vatilityBtnUseCallbackFive(sender, eventType)
		if eventType ~= ccui.TouchEventType.began then
			self.judge = true

			self.TenVatilityBtn:setTouchEnabled(false)
			self.closeBtn:setTouchEnabled(false)
			self.OneVatilityBtn:setTouchEnabled(false)
		end

		sound.playSound("103")

		local msgbox = nil

		if not self.judge then
			slot3 = an.newMsgbox(BtnidJ, function (idx)
				if idx == 1 then
					self.OneVatilityBtn:setTouchEnabled(true)
					self.closeBtn:setTouchEnabled(true)
					self.TenVatilityBtn:setTouchEnabled(true)

					local rsbss = DefaultClientMessage(CM_NORMAL_CRYSTAL_USE)
					rsbss.CrystalType = 2
					rsbss.CrystalCnt = 1

					MirTcpClient:getInstance():postRsb(rsbss)

					self.judge = false
				else
					self.judge = false

					self.OneVatilityBtn:setTouchEnabled(true)
					self.closeBtn:setTouchEnabled(true)
					self.TenVatilityBtn:setTouchEnabled(true)

					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot3

			msgbox.pos(msgbox, -space, 0)
		end

		return 
	end

	local function vatilityBtnUseCallbackTen(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local msgbox = nil

		if not self.judge then
			self.judge = true
			slot3 = an.newMsgbox(BtnidT, function (idx)
				if idx == 1 then
					self.OneVatilityBtn:setTouchEnabled(true)
					self.closeBtn:setTouchEnabled(true)
					self.TenVatilityBtn:setTouchEnabled(true)

					local rsbss = DefaultClientMessage(CM_NORMAL_CRYSTAL_USE)
					rsbss.CrystalType = 2
					rsbss.CrystalCnt = 10

					MirTcpClient:getInstance():postRsb(rsbss)

					self.judge = false
				else
					self.judge = false

					self.OneVatilityBtn:setTouchEnabled(true)
					self.closeBtn:setTouchEnabled(true)
					self.TenVatilityBtn:setTouchEnabled(true)

					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot3

			msgbox.pos(msgbox, -space, 0)
		end

		return 
	end

	local function vatilityBtnUseCallbackFifty(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			self.TenVatilityBtn:setTouchEnabled(false)
			self.closeBtn:setTouchEnabled(false)
			self.OneVatilityBtn:setTouchEnabled(false)

			return 
		end

		sound.playSound("103")

		local opType = 1
		local msgbox = nil

		if not self.judge then
			self.judge = true
			slot4 = an.newMsgbox(BtnidFifty, function (idx)
				if idx == 1 then
					local rsb = DefaultClientMessage(CM_YB_CRYSTAL_USE)
					rsb.CrystalCnt = 10

					MirTcpClient:getInstance():postRsb(rsb)
					queryCrystalInfo(2)

					self.judge = false

					self.OneVatilityBtn:setTouchEnabled(true)
					self.closeBtn:setTouchEnabled(true)
					self.TenVatilityBtn:setTouchEnabled(true)
				else
					self.judge = false

					self.OneVatilityBtn:setTouchEnabled(true)
					self.closeBtn:setTouchEnabled(true)
					self.TenVatilityBtn:setTouchEnabled(true)
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot4

			msgbox.pos(msgbox, -space, 0)
		end

		return 
	end

	local function vatilityBtnOneVatilityBtn(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local rsbs = DefaultClientMessage(CM_QueryGetEnergyCrystal)
		rsbs.GetNum = 1

		MirTcpClient:getInstance():postRsb(rsbs)

		return 
	end

	local function vatilityBtnTenVatilityBtn(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local rsbs = DefaultClientMessage(CM_QueryGetEnergyCrystal)
		rsbs.GetNum = 10

		MirTcpClient:getInstance():postRsb(rsbs)

		return 
	end

	if self.isNodeListenerRegistered ~= true then
		self.vatilityBtnUseOne.setTouchEnabled(slot12, true)
		self.vatilityBtnUseOne:addTouchEventListener(vatilityBtnUseCallbackOne)
		self.vatilityBtnUseTen:setTouchEnabled(true)
		self.vatilityBtnUseTen:addTouchEventListener(vatilityBtnUseCallbackTen)
		self.vatilityBtnUseFive:setTouchEnabled(true)
		self.vatilityBtnUseFive:addTouchEventListener(vatilityBtnUseCallbackFive)
		self.vatilityBtnUseFifty:setTouchEnabled(true)
		self.vatilityBtnUseFifty:addTouchEventListener(vatilityBtnUseCallbackFifty)
		self.OneVatilityBtn:setTouchEnabled(true)
		self.OneVatilityBtn:addTouchEventListener(vatilityBtnOneVatilityBtn)
		self.TenVatilityBtn:setTouchEnabled(true)
		self.TenVatilityBtn:addTouchEventListener(vatilityBtnTenVatilityBtn)
	end

	self.isNodeListenerRegistered = true

	return 
end
crystal.updateExp = function (self, energyExpNum, powerExpNum)
	if self.lbl_energyExp == nil or self.lbl_powerExp == nil then
		return 
	end

	self.lbl_energys:setString(self.expToText(self, energyExpNum))
	self.lbl_powers:setString(self.expToText(self, powerExpNum))

	return 
end
crystal.showExpStallPage = function (self)
	local rsb = DefaultClientMessage(CM_QUERY_EXCHANGE_EXP)

	MirTcpClient:getInstance():postRsb(rsb)

	local expNum = self.expCanUseNum
	local expText = self.expToText(self, expNum)
	local lbl_expNum = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_num_expstall")

	if lbl_expNum then
		lbl_expNum.setString(lbl_expNum, "" .. expText)
	end

	if self.lbl_expCanUseNum then
		self.lbl_expCanUseNum:setString(expText)
	end

	local img_bottom = ccui.Helper:seekWidgetByName(self.rootPanel, "img_bottom")

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/ExpOut/ExpOut.csb")

	if not self.animSchHandle then
		if self.expAnim then
			self.expAnim:removeSelf()

			self.expAnim = nil
		end

		self.expAnim = ccs.Armature:create("ExpOut")
		local parent = self.expAnim:getParent()

		if parent then
			self.expAnim:removeSelf()
		end

		img_bottom.addChild(img_bottom, self.expAnim)

		parent = self.expAnim:getParent()
		local size = parent.getContentSize(parent)
		local x = size.width/2
		local y = size.height/2

		self.expAnim:anchor(0.5, 0.5)
		self.expAnim:setPosition(x, y)
		self.expAnim:setVisible(false)
	end

	local function showAnim()
		if not self.expAnim then
			return 
		end

		self.expAnim:setVisible(true)
		self.expAnim:getAnimation():play("ExpOut", -1, -1)

		if self.animSchHandle then
			scheduler.unscheduleGlobal(self.animSchHandle)

			self.animSchHandle = nil
		end

		self.animSchHandle = scheduler.performWithDelayGlobal(function ()
			if self.expAnim then
				self.expAnim:setVisible(false)
			end

			if self.animSchHandle then
				scheduler.unscheduleGlobal(self.animSchHandle)

				self.animSchHandle = nil
			end

			return 
		end, 1.5)

		return 
	end

	local function btnVatilityExpCallback(sender, eventType, num)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local opType = 3

		sendCrystalRsb(num, opType)
		showAnim()

		return 
	end

	local valityExpBtn = ccui.Helper.seekWidgetByName(slot8, self.rootPanel, "btn_vatilityExp_use")

	valityExpBtn.setTouchEnabled(valityExpBtn, true)
	valityExpBtn.addTouchEventListener(valityExpBtn, function (sender, eventType)
		btnVatilityExpCallback(sender, eventType, 1)

		return 
	end)

	local valityExpBtn_10 = ccui.Helper.seekWidgetByName(slot9, self.rootPanel, "btn_vatilityExp_use_10")

	valityExpBtn_10.setTouchEnabled(valityExpBtn_10, true)
	valityExpBtn_10.addTouchEventListener(valityExpBtn_10, function (sender, eventType)
		btnVatilityExpCallback(sender, eventType, 10)

		return 
	end)

	local function btnEnergyExpCallback(sender, eventType, num)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local opType = 4

		sendCrystalRsb(num, opType)
		showAnim()

		return 
	end

	local energyExpBtn = ccui.Helper.seekWidgetByName(slot11, self.rootPanel, "btn_energyExp_use")

	energyExpBtn.setTouchEnabled(energyExpBtn, true)
	energyExpBtn.addTouchEventListener(energyExpBtn, function (sender, eventType)
		btnEnergyExpCallback(sender, eventType, 1)

		return 
	end)

	local energyExpBtn_10 = ccui.Helper.seekWidgetByName(slot12, self.rootPanel, "btn_energyExp_use_10")

	energyExpBtn_10.setTouchEnabled(energyExpBtn_10, true)
	energyExpBtn_10.addTouchEventListener(energyExpBtn_10, function (sender, eventType)
		btnEnergyExpCallback(sender, eventType, 10)

		return 
	end)

	self.lbl_powerExp = ccui.Helper.seekWidgetByName(slot13, self.rootPanel, "lbl_vatility_exp_num")
	self.lbl_energyExp = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_energy_exp_num")

	self.updateExp(self, self.energyExp, self.powerExp)

	return 
end
crystal.showGayPage = function (self)
	local rsb = DefaultClientMessage(CM_Query_OldFriendWand)

	MirTcpClient:getInstance():postRsb(rsb)

	if self.gay_label then
		self.gay_label:clear()
	end

	local panel = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_gay_x")

	panel.hide(panel)

	local function btnExchangeCallback(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local opType = 1

		if not self.judge then
			self.judge = true
			local msgbox = nil
			slot4 = an.newMsgbox(BtnidGayExchange, function (idx)
				self.judge = false

				if idx == 1 then
					local rsb = DefaultClientMessage(CM_Exchange_OldFriendWand)

					MirTcpClient:getInstance():postRsb(rsb)
				else
					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot4
		end

		return 
	end

	local function btnUseCallback(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		local opType = 1

		if not self.judge then
			local msgbox = nil
			self.judge = true
			slot4 = an.newMsgbox(BtnidGayUse, function (idx)
				self.judge = false

				if idx == 1 then
					local rsb = DefaultClientMessage(CM_Use_OldFriendWand)

					MirTcpClient:getInstance():postRsb(rsb)
				else
					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot4
		end

		return 
	end

	if self.isGayNodeListenerRegistered ~= true then
		self.btn_gay_exchange.setTouchEnabled(slot5, true)
		self.btn_gay_exchange:addTouchEventListener(btnExchangeCallback)
		self.btn_gay_use:setTouchEnabled(true)
		self.btn_gay_use:addTouchEventListener(btnUseCallback)
	end

	self.isGayNodeListenerRegistered = true

	return 
end
local value_name = {
	"vatilityCanAuthNum",
	"energyCanAuthNum",
	"expCanUseNum",
	"value_energy"
}
crystal.showGayBackPage = function (self)
	local gayPanel = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_gay_back_x")

	local function btnUse1Callback(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		if not self.judge then
			self.judge = true
			local msgbox = nil
			slot3 = an.newMsgbox(BtnidGayBackUse1, function (idx)
				self.judge = false

				if idx == 1 then
					local rsb = DefaultClientMessage(CM_OldFriendBackGetEnergy)
					rsb.FGetType = 0

					MirTcpClient:getInstance():postRsb(rsb)
				else
					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot3
		end

		return 
	end

	local function btnUse2Callback(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			return 
		end

		sound.playSound("103")

		if not self.judge then
			local msgbox = nil
			self.judge = true
			slot3 = an.newMsgbox(BtnidGayBackUse2, function (idx)
				self.judge = false

				if idx == 1 then
					local rsb = DefaultClientMessage(CM_OldFriendBackGetEnergy)
					rsb.FGetType = 1

					MirTcpClient:getInstance():postRsb(rsb)
				else
					return 
				end

				return 
			end, {
				noclose = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot3
		end

		return 
	end

	if self.isGayBackNodeListenerRegistered ~= true then
		self.btn_gay_back_use1.setTouchEnabled(slot4, true)
		self.btn_gay_back_use1:addTouchEventListener(btnUse1Callback)
		self.btn_gay_back_use2:setTouchEnabled(true)
		self.btn_gay_back_use2:addTouchEventListener(btnUse2Callback)
	end

	self.isGayBackNodeListenerRegistered = true

	return 
end
crystal.updateLblInfo = function (self, infoName, value)
	if self == nil or self[infoName] == nil then
		print("crystal:updateRoleInfo: panel crystal has no element named " .. infoName)

		return 
	end

	if infoName == value_name[3] then
		value = self.expToText(self, value)
	end

	self[infoName]:setString(tostring(value))

	return 
end
crystal.updateData = function (self, valueName, value)
	if self == nil or self[valueName] == nil then
		print("crystal:updateData: panel crystal has no element named " .. valueName)

		return 
	end

	self[valueName] = value

	self.updateLblInfo(self, "lbl_" .. valueName, value)

	return 
end
crystal.onSM_QUERY_CRYSTAL = function (self, result, protoId)
	if not result then
		return 
	end

	local crystalType = result.CrystalType

	self.showPageInfo(self, self.page)
	self.updateData(self, value_name[crystalType], result.CanUseCnt)

	return 
end
local lbl_name = {
	[1.0] = "lbl_energyNum",
	[2.0] = "lbl_vatilityNum"
}
crystal.onSM_Query_OldFriendWand = function (self, result, protoId)
	if not result then
		return 
	end

	local panel = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_gay_x")

	if result.FRemainDays <= 0 then
		panel.show(panel)

		local lbl_gay_level_down = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_gay_level_down")

		lbl_gay_level_down.setString(lbl_gay_level_down, tostring(result.FLevelLimit) .. "级")

		local downlvl = result.FMinLevelLimit or 0
		local lbl_gay_level_up = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_gay_level_up")
		local lbl_title_up = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_title_up")

		if 0 < downlvl then
			lbl_gay_level_up.setString(lbl_gay_level_up, tostring(downlvl) .. "级")
		else
			lbl_title_up.setVisible(lbl_title_up, false)
			lbl_gay_level_up.setVisible(lbl_gay_level_up, false)
		end
	else
		panel.hide(panel)

		if self.gay_label then
			self.gay_label:clear()
		else
			local panel_gay = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_gay")
			self.gay_label = an.newLabelM(420, 18, 0):add2(panel_gay):pos(30, 150)
		end

		self.gay_label:addLabel("开区"):addLabel(tostring(result.FOpenDays) .. "天", cc.c3b(255, 0, 0)):addLabel("后才可兑换老友令，还有 "):addLabel(tostring(result.FRemainDays) .. "天", cc.c3b(255, 0, 0)):addLabel("开放")
	end

	return 
end
crystal.onSM_Exchange_OldFriendWand = function (self, result, protoId)
	return 
end
crystal.onSM_Use_OldFriendWand = function (self, result, protoId)
	return 
end
crystal.onSM_QueryServerStatus = function (self, result, protoId)
	if not result then
		return 
	end

	if g_data.player.ability.FLevel <= result.FServerStatus*99 then
		local gayBackTab = ccui.Helper:seekWidgetByName(self.rootPanel, "chk_gay_back")

		gayBackTab.setVisible(gayBackTab, true)

		local num1 = ccui.Helper:seekWidgetByName(self.rootPanel, "LabelServerStatus1")
		local num2 = ccui.Helper:seekWidgetByName(self.rootPanel, "LabelServerStatus2")

		num1.setString(num1, tostring(result.FServerStatus))
		num2.setString(num2, tostring(result.FServerStatus))
	end

	return 
end
crystal.onSM_OldFriendBackGetEnergy = function (self, result, protoId)
	if not result then
		return 
	end

	return 
end
crystal.onSM_QUERY_EXCHANGE_EXP = function (self, result, protoId)
	self.energyExp = result.FEnergyExp
	self.powerExp = result.FPowerExp

	self.updateExp(self, result.FEnergyExp, result.FPowerExp)

	return 
end
crystal.onExit = function (self)
	if self.animSchHandle then
		scheduler.unscheduleGlobal(self.animSchHandle)

		self.animSchHandle = nil
	end

	return 
end

return crystal
