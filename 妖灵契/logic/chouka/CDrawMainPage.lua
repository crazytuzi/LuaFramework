local CDrawMainPage = class("CDrawMainPage", CPageBase)

function CDrawMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CDrawMainPage.OnInitPage(self)
	self.m_BackBtn = self:NewUI(2, CButton)
	self.m_HelpBtn = self:NewUI(3, CButton)
	self.m_JoinUpBtn = self:NewUI(4, CButton)
	self.m_WuLingCard = self:NewUI(5, CButton)
	self.m_WuHunCard = self:NewUI(6, CButton)
	self.m_ZhongshenTexture = self:NewUI(8, CTexture)
	self.m_ZhongshenBtn = self:NewUI(9, CButton)
	self.m_WuHunPart = self:NewUI(10, CBox)

	self.m_WuLingCard:AddUIEvent("click", callback(self, "OpenWuLing"))
	self.m_WuHunCard:AddUIEvent("click", callback(self, "OnShowWuhunPart"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OpenWuHunChance"))
	self.m_ZhongshenBtn:AddUIEvent("click", callback(g_OpenUICtrl, "OpenYueKa"))

	g_StateCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnStateEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrl"))
	g_GuideCtrl:AddGuideUI("draw_wl_card", self.m_WuLingCard)
	g_GuideCtrl:AddGuideUI("draw_wh_card", self.m_WuHunCard)
	local guide_ui = {"draw_wl_card", "draw_wh_card"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)
	self:InitEffect()
	self:InitWuHunPart()
	self:UpdateZhongshenkai()
end

-- function CDrawMainPage.OnShowPage(self)
-- 	g_ChoukaCtrl:ShowMainPage()
-- end

function CDrawMainPage.OnStateEvent(self, oCtrl)
	self:RefreshOQState()
end

function CDrawMainPage.OnPartnerEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdateChoukaConfig then
		self:RefreshOQState()
	end
end

function CDrawMainPage.OnWelfareCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnYueKa then
		self:UpdateZhongshenkai()
		netpartner.C2GSOpenDrawCardUI()
	end
end

function CDrawMainPage.InitEffect(self)
	local path = "Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_chouka_yueliang_lan.prefab"
	self.m_WLEffect =  CEffect.New(path, self:GetLayer(), false, nil)
	self.m_WLEffect:SetParent(self.m_WuLingCard.m_Transform)
	
	local function cb()
		local comp = self.m_WHEffect.m_Eff:GetComponent(classtype.DataContainer)
		local replaceAnimObj = comp.gameObjectValue
	
		self.m_EffectBox = CBox.New(replaceAnimObj.gameObject)
		self.m_OQLabel = self.m_EffectBox:NewUI(1, CLabel)
		self.m_BaodiLabel = self.m_EffectBox:NewUI(2, CLabel)
		self.m_FreeLabel = self.m_EffectBox:NewUI(3, CLabel)
		self.m_BaodiLabel2 = self.m_EffectBox:NewUI(4, CLabel)
		self:RefreshOQState()
	end
	path = "Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_chouka_yueliang_huang.prefab"
	self.m_WHEffect =  CEffect.New(path, self:GetLayer(), false, cb)
	self.m_WHEffect:SetParent(self.m_WuHunCard.m_Transform)
end

function CDrawMainPage.InitWuHunPart(self)
	self.m_WHDrawOnceBtn = self.m_WuHunPart:NewUI(1, CButton)
	self.m_WHDrawOnceLabel = self.m_WuHunPart:NewUI(2, CLabel)
	self.m_WHDrawFiveBtn = self.m_WuHunPart:NewUI(3, CButton)
	self.m_WHDrawFiveLabel = self.m_WuHunPart:NewUI(4, CLabel)
	self.m_WHDrawFreeLabel = self.m_WuHunPart:NewUI(5, CLabel)
	self.m_WHDrawOnceBtn:AddUIEvent("click", callback(self, "ShowWuHunTip"))
	self.m_WHDrawFiveBtn:AddUIEvent("click", callback(self, "OnDrawFiveWuHun"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBackMain"))
	self.m_BackBtn:SetActive(false)
	self.m_WuHunPart:SetActive(false)
	self.m_WHDrawFreeLabel:SetActive(false)
	g_GuideCtrl:AddGuideUI("draw_wh_card_again", self.m_WHDrawOnceBtn)
end

function CDrawMainPage.UpdateZhongshenkai(self)
	local d = data.welfaredata.WelfareControl[define.Welfare.ID.Zsk]
	local bShow = true
	if main.g_AppType  == "shenhe" or 
		data.globalcontroldata.GLOBAL_CONTROL.welfare.is_open ~= "y" or 
		g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.welfare.open_grade then
		bShow = false
	end
	if d.open ~= 1 or g_AttrCtrl.grade < d.grade then
		bShow = false
	end
	if not g_WelfareCtrl:HasZhongShengKa() and bShow then
		self.m_ZhongshenTexture:SetActive(true)
	else
		self.m_ZhongshenTexture:SetActive(false)
	end
end

function CDrawMainPage.DoShowEffect(self)
	g_ChoukaCtrl:ForceShowMain()
end

function CDrawMainPage.RefreshOQState(self)
	if self.m_OQLabel then
		local statedata = g_StateCtrl:GetState(1003)
		if statedata then
			self.m_LeftTime = statedata["time"] - g_TimeCtrl:GetTimeS()
			if self.m_LeftTime > 0 then
				self:CreateOQTimer()
			else
				self.m_OQLabel:SetActive(false)
			end
		else
			self.m_OQLabel:SetActive(false)
		end

		local cost = g_PartnerCtrl:GetChoukaCost()
		self:RefreshFresTime()
		self.m_WHDrawOnceLabel:SetText(tostring(cost))
		self.m_WHDrawFiveLabel:SetText(tostring(g_PartnerCtrl:GetChoukaMulCost()))
	end
end

function CDrawMainPage.RefreshFresTime(self)
	local t = g_PartnerCtrl:GetChoukaFreeCD()
	if not self.m_FreeLabel then
		return
	end
	local baodi = g_PartnerCtrl:GetBaodiTimes() or 9
	if baodi == 1 then
		self.m_BaodiLabel:SetActive(false)
		self.m_BaodiLabel2:SetActive(true)
	else
		self.m_BaodiLabel:SetText(tostring(baodi))
		self.m_BaodiLabel:SetActive(true)
		self.m_BaodiLabel2:SetActive(false)
	end
	if g_PartnerCtrl:IsChoukaFree() then
		self.m_FreeLabel:SetText("本次王者招募免费")
		self.m_WHDrawFreeLabel:SetActive(true)
		self.m_WHDrawOnceLabel:SetActive(false)
		return
	else
		self.m_WHDrawFreeLabel:SetActive(false)
		self.m_WHDrawOnceLabel:SetActive(true)
		self.m_FreeLabel:SetText("\n\n\n"..g_TimeCtrl:GetLeftTime(t-g_TimeCtrl:GetTimeS()).."后可免费")
	end

	local function update()
		if Utils.IsNil(self) then
			return
		end
		local leftTime = g_PartnerCtrl:GetChoukaFreeCD() - g_TimeCtrl:GetTimeS()
		if leftTime > 0 then
			self.m_FreeLabel:SetText(g_TimeCtrl:GetLeftTime(leftTime).."后可免费")
			return true
		else
			self.m_FreeLabel:SetText("本次王者招募免费")
		end
	end
	
	if self.m_FreeTimer then
		Utils.DelTimer(self.m_FreeTimer)
	end
	self.m_FreeTimer = Utils.AddTimer(update, 1, 0)
end

function CDrawMainPage.CreateOQTimer(self)
	local function update()
		if Utils.IsNil(self) then
			return
		end
		self.m_LeftTime = self.m_LeftTime - 1
		if self.m_LeftTime >= 0 then
			local timestr = g_TimeCtrl:GetLeftTime(self.m_LeftTime)
			self.m_OQLabel:SetText("欧气："..timestr)
			return true
		else
			self.m_OQLabel:SetActive(false)
		end
	end
	self.m_OQLabel:SetActive(true)
	self.m_OQLabel:SetText("欧气："..g_TimeCtrl:GetLeftTime(self.m_LeftTime))
	
	if self.m_OQTimer then
		Utils.DelTimer(self.m_OQTimer)
	end
	self.m_OQTimer = Utils.AddTimer(update, 1, 0)
end

function CDrawMainPage.OpenWuLing(self)
	if not g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSDrawWuLingCard"], 5) then
		return
	end
	local bUp = self.m_JoinUpBtn:GetSelected()
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	netpartner.C2GSDrawWuLingCard(1, istate == 0, 0)
end

function CDrawMainPage.OpenWuLingMore(self)
	local bUp = self.m_JoinUpBtn:GetSelected()
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	netpartner.C2GSDrawWuLingCard(5, istate == 0, 0)
end

function CDrawMainPage.OpenWuHun(self, itype)
	local bUp = self.m_JoinUpBtn:GetSelected()
	local iSend = bUp and 1 or 0
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	itype = itype or 0
	netpartner.C2GSDrawWuHunCard(iSend, istate == 0, itype, 1)
end

function CDrawMainPage.OnShowWuhunPart(self)
	self.m_WuLingCard:SetActive(false)
	self.m_WuHunCard:SetLocalPos(Vector3.New(0, 20, 0))
	self.m_WuHunPart:SetActive(true)
	self.m_HelpBtn:SetActive(false)
	self.m_BackBtn:SetActive(true)
end

function CDrawMainPage.OnBackMain(self)
	self.m_WuLingCard:SetActive(true)
	self.m_WuHunCard:SetLocalPos(Vector3.New(292, 20, 0))
	self.m_WuHunPart:SetActive(false)
	self.m_HelpBtn:SetActive(true)
	self.m_BackBtn:SetActive(false)
end


function CDrawMainPage.ShowWuHunTip(self)
	g_GuideCtrl:ReqTipsGuideFinish("draw_wh_card")
	if not g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSDrawWuHunCard"], 5) then
		return
	end	
	
	self.m_UseSSRItem = 0
	if g_ItemCtrl:GetBagItemAmountBySid(10019) + g_ItemCtrl:GetBagItemAmountBySid(10018) <= 0 or CGuideView:GetView() ~= nil then
		self:ShowWuHunTip2()
	else
		CDrawSelectView:ShowView(function (oView)
			oView:SetCallBack(callback(self, "OpenWuHun"))
		end)
	end
end

function CDrawMainPage.OnDrawFiveWuHun(self)
	if g_WindowTipCtrl:IsShowTips("draw_five_tip") then
		local windowConfirmInfo = {
			msg				= string.format("你的王者契约不足，是否消耗#w2%d进行招募？", g_PartnerCtrl:GetChoukaMulCost()),
			okCallback		= callback(self, "OnDrawFiveAction"),
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "draw_five_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OnDrawFiveAction()
	end
end

function CDrawMainPage.OnDrawFiveAction(self)
	local bUp = self.m_JoinUpBtn:GetSelected()
	local iSend = bUp and 1 or 0
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	netpartner.C2GSDrawWuHunCard(iSend, istate == 0, 0, 5)
end

function CDrawMainPage.ShowWuHunTip2(self)
	local isfree = g_PartnerCtrl:IsChoukaFree()
	if g_ItemCtrl:GetBagItemAmountBySid(10021) < 1 and not isfree and g_WindowTipCtrl:IsShowTips("draw_whcard_tip") then
		local windowConfirmInfo = {
			msg				= string.format("你的王者契约不足，是否消耗#w2%d进行招募？", g_PartnerCtrl:GetChoukaCost()),
			okCallback		= callback(self, "OpenWuHun"),
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "draw_whcard_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OpenWuHun()
	end
end

function CDrawMainPage.OpenWuLingChance(self)
	CLuckyChanceView:ShowView()
end

function CDrawMainPage.OpenWuHunChance(self)
	CLuckyChanceView:ShowView()
end

return CDrawMainPage