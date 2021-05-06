local CConvoyView = class("CConvoyView", CViewBase)

function CConvoyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Convoy/ConvoyView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
	self.m_DepthType = "Login"  --层次
end

function CConvoyView.OnCreateView(self)
	self.m_HelpBtn = self:NewUI(1, CButton)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_RefreshBtn = self:NewUI(3, CButton)
	self.m_StartBtn = self:NewUI(4, CButton)
	self.m_MonsterGrid = self:NewUI(5, CGrid)
	self.m_RefreshCostLabel = self:NewUI(6, CLabel)
	self.m_Container = self:NewUI(7, CWidget)
	self.m_ServerGradeLabel = self:NewUI(8, CLabel)
	-- self.m_BgTexture = self:NewUI(8, CTexture)
	self:InitContent()
end

function CConvoyView.InitContent(self)
	self.m_ServerGradeLabel:SetText(g_AttrCtrl:GetServerGradeWarDesc(g_AttrCtrl.grade))
	self.m_CurrentMonsterBtn = nil
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	-- UITools.ScaleToFit(self.m_BgTexture)
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefresh"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_StartBtn:AddUIEvent("click", callback(self, "OnClickStart"))
	g_ConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnConvoyEvent"))
	self.m_MonsterBoxArr = {}
	self.m_MonsterGrid:InitChild(function(obj, idx)
		local oBtn = CBox.New(obj, false)
		oBtn.m_Btn = oBtn:NewUI(1, CBox)
		self.m_MonsterBoxArr[idx] = oBtn
		oBtn.m_OnSelectSprite = oBtn:NewUI(2, CSprite)
		oBtn.m_ActorTexture = oBtn:NewUI(3, CActorTexture)
		oBtn.m_CoinLabel = oBtn:NewUI(4, CLabel)
		oBtn.m_ExpLabel = oBtn:NewUI(5, CLabel)
		oBtn.m_TalkLabel = oBtn:NewUI(6, CLabel)
		oBtn.m_TalkLabel:SetActive(false)
		return oBtn
	end)
	g_GuideCtrl:AddGuideUI("convoy_refresh_btn", self.m_RefreshBtn)
	g_GuideCtrl:AddGuideUI("convoy_start_btn", self.m_StartBtn)
	self:SetData()
end

function CConvoyView.OnClickRefresh(self)
	local iFreeCnt = g_ConvoyCtrl:GetFreeRefreshCnt()
	if g_ConvoyCtrl:IsMaxLv() then
		g_NotifyCtrl:FloatMsg("当前已获得最高档次的护送任务")
	elseif g_AttrCtrl.goldcoin < g_ConvoyCtrl:GetRefreshCost() then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	elseif iFreeCnt <= 0 and g_WindowTipCtrl:IsShowTips("refresh_convoy_tip") then
			local windowConfirmInfo = {
				msg				= string.format("是否消耗#w2%d进行刷新？", g_ConvoyCtrl:GetRefreshCost()),
				okCallback		= callback(g_ConvoyCtrl, "SendRefresh"),
				selectdata		={
					text = "今日内不再提示",
					CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "refresh_convoy_tip")
				},
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_ConvoyCtrl:SendRefresh()
	end
end

function CConvoyView.SetData(self)
	local iFreeCnt = g_ConvoyCtrl:GetFreeRefreshCnt()
	if iFreeCnt > 0 then
		self.m_RefreshCostLabel:SetText(string.format("免费次数：%s", iFreeCnt))
	else
		self.m_RefreshCostLabel:SetText(string.format("#w2%s", g_ConvoyCtrl:GetRefreshCost()))
	end
	for i, oBtn in ipairs(self.m_MonsterBoxArr) do
		local oData = g_ConvoyCtrl:GetRewardData(i)
		if oData then
			oBtn.m_CoinLabel:SetText(string.eval(oData.coin, {lv = g_AttrCtrl.grade}))
			oBtn.m_ExpLabel:SetText(string.eval(oData.exp, {lv = g_AttrCtrl.grade}))
			oBtn.m_ActorTexture:ChangeShape(g_ConvoyCtrl:GetShapeByPos(i))
			oBtn.m_ActorTexture:SetColor(Color.New(0.5,0.5,0.5,1))
			oBtn.m_Data = oData
			oBtn.m_OnSelectSprite:SetActive(false)
			oBtn:SetActive(true)
		else
			oBtn:SetActive(false)
		end
	end
	self:OnSelect(self.m_MonsterBoxArr[g_ConvoyCtrl:GetCurrentLv()])
end

function CConvoyView.OnConvoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Convoy.Event.UpdateConvoyInfo then
		if g_ConvoyCtrl:IsConvoying() then
			self:OnClose()
		end
		self:SetData()
	end
end

function CConvoyView.OnSelect(self, oMonsterBox)
	if self.m_CurrentMonsterBtn ~= nil then
		self.m_CurrentMonsterBtn.m_OnSelectSprite:SetActive(false)
		self.m_CurrentMonsterBtn.m_ActorTexture:SetColor(Color.New(0.5,0.5,0.5,1))
		self.m_CurrentMonsterBtn.m_TalkLabel:SetActive(false)
	end
	self.m_CurrentMonsterBtn = oMonsterBox
	self.m_CurrentMonsterBtn.m_OnSelectSprite:SetActive(true)
	self.m_CurrentMonsterBtn.m_ActorTexture:SetColor(Color.white)
	self.m_CurrentMonsterBtn.m_TalkLabel:SetText(g_ConvoyCtrl:GetViewTalkText())
	self.m_CurrentMonsterBtn.m_TalkLabel:SetActive(true)
end

function CConvoyView.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("convoy")
	end)
end

function CConvoyView.OnClickStart(self)
	g_ConvoyCtrl:AcceptTask()
end

return CConvoyView