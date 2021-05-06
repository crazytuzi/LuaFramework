local CLimitRewardView = class("CLimitRewardView", CViewBase)

function CLimitRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/LimitReward/LimRewardMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
	self.m_GroupName = "main"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CLimitRewardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SideBtnGrid = self:NewUI(2, CGrid)
	self.m_Container = self:NewUI(3, CWidget)
	self.m_LimitDrawPage = self:NewPage(4, CLimitDrawPage)
	self.m_TotalPayPage = self:NewPage(5, CTotalPayPage)
	self.m_CostScorePage = self:NewPage(6, CCostScorePage)
	self.m_LimitSkinPage = self:NewPage(7, CLimitSkinPage)
	self.m_RechargeScorePage = self:NewPage(8, CRechargeScorePage)
	self.m_MaskWidget = self:NewUI(9, CWidget)
	self.m_ChargeBackPage = self:NewPage(10, CChargeBackPage)
	self.m_YiYuanLiBaoPage = self:NewPage(11, CYiYuanLiBaoPage)
	self.m_RushPayPage = self:NewPage(12, CRushPayPage)
	self.m_LimitPayPage = self:NewPage(13, CLimitPayPage)
	self.m_LoopPayPage = self:NewPage(14, CLoopPayPage)
	self:InitContent()
end

function CLimitRewardView.InitContent(self)
	UITools.ResizeToRootSize(self.m_MaskWidget)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MaskWidget:AddUIEvent("click", callback(self, "OnClickMask"))
	self.m_MaskWidget:SetActive(false)
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
	
	self.m_BtnList = {}
	self.m_SideBtnGrid:InitChild(function (obj, index)
		local oBtn = CButton.New(obj)
		oBtn.m_Idx = index
		oBtn:SetGroup(self.m_SideBtnGrid:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnSwitchPage", index))
		self.m_BtnList[index] = oBtn
		return oBtn
	end)
	
	self.m_BtnList[1].m_IgnoreCheckEffect = true
	self.m_BtnList[2].m_IgnoreCheckEffect = true
	self.m_BtnList[5].m_IgnoreCheckEffect = true
	self.m_BtnList[6].m_IgnoreCheckEffect = true
	self.m_BtnList[9].m_IgnoreCheckEffect = true
	self.m_BtnList[10].m_IgnoreCheckEffect = true
	self:UpdateShow()

	local oBtn = self.m_SideBtnGrid:GetChild(1)
	self:OnSwitchPage(oBtn.m_Idx)

	self.m_BtnList[2]:AddEffect("bordermove", Vector4.New(-84, 84, -34, 34))	
	self.m_BtnList[5]:AddEffect("bordermove", Vector4.New(-84, 84, -34, 34))	
	self.m_BtnList[6]:AddEffect("bordermove", Vector4.New(-84, 84, -34, 34))	
	self.m_BtnList[6]:SetActive(g_WelfareCtrl:IsInChargeBack())

	self:UpdateRedDot()
end

function CLimitRewardView.SetActive(self, bAct)
	CViewBase.SetActive(self, bAct)
	if bAct and self.m_RechargeScorePage:GetActive() then
		self.m_RechargeScorePage:OnShowPage()
	end
end

function CLimitRewardView.ShowDrawPage(self)
	self:ShowSubPage(self.m_LimitDrawPage)
end

function CLimitRewardView.ShowTotalPayPage(self)
	local oBtn = self.m_SideBtnGrid:GetChild(2)
	if oBtn then
		oBtn:SetSelected(true)
	end
	self:ShowSubPage(self.m_TotalPayPage)
end

function CLimitRewardView.ShowCostScorePage(self)
	g_WelfareCtrl:ClearNewCostPoint()
	self:ShowSubPage(self.m_CostScorePage)
end

function CLimitRewardView.ShowSkinPage(self)
	g_WelfareCtrl:ClearFirstOpenSkin()
	self:ShowSubPage(self.m_LimitSkinPage)
end

function CLimitRewardView.ShowRechargeScorePage(self)
	self:ShowSubPage(self.m_RechargeScorePage)
end

function CLimitRewardView.ShowChargeBackPage(self)
	self:ShowSubPage(self.m_ChargeBackPage)
end

function CLimitRewardView.ShowYiYuanLiBaoPage(self)
	self:ShowSubPage(self.m_YiYuanLiBaoPage)
end

function CLimitRewardView.ShowRushPayPage(self)
	self:ShowSubPage(self.m_RushPayPage)
end

function CLimitRewardView.ShowLimitPayPage(self)
	self:ShowSubPage(self.m_LimitPayPage)
end

function CLimitRewardView.ShowLoopPayPage(self)
	self:ShowSubPage(self.m_LoopPayPage)
end

function CLimitRewardView.OnSwitchPage(self, index)
	if index == 1 then
		self:ShowDrawPage()
	elseif index == 2 then
		self:ShowTotalPayPage()
	elseif index == 3 then
		self:ShowCostScorePage()
	elseif index == 4 then
		self:ShowSkinPage()
	elseif index == 5 then
		self:ShowRechargeScorePage()
	elseif index == 6 then
		self:ShowChargeBackPage()
	elseif index == 7 then
		self:ShowYiYuanLiBaoPage()
	elseif index == 8 then
		self:ShowRushPayPage()
	elseif index == 9 then
		self:ShowLimitPayPage()
	elseif index == 10 then
		self:ShowLoopPayPage()
	end
	if self.m_BtnList[index] then
		self.m_BtnList[index]:SetSelected(true)
	end
end

function CLimitRewardView.UpdateCostPoint(cls, iPoint, lItemList, version, iPlan, iStartTime, iEndTime)
	local oView = CLimitRewardView:GetView()
	if oView and oView.m_CostScorePage:GetActive() then
		oView.m_CostScorePage:UpdateCostPoint(iPoint, lItemList, version, iPlan, iStartTime, iEndTime)
	end
end

function CLimitRewardView.UpdateRechargeScore(cls, iPoint, lItemList)
	local oView = CLimitRewardView:GetView()
	if oView and oView.m_RechargeScorePage:GetActive() then
		oView.m_RechargeScorePage:UpdateRechargeScore(iPoint, lItemList)
	end
end

function CLimitRewardView.OnWelfareEvnet(self, oCtrl)
	self:UpdateRedDot()
end

function CLimitRewardView.UpdateShow(self)
	if data.welfaredata.WelfareControl[define.Welfare.ID.TotalRecharge].open == 0 then
		self.m_BtnList[2]:SetActive(false)
	end
	self.m_BtnList[3]:SetActive(g_WelfareCtrl:IsOpenCostScore())
	self.m_BtnList[7]:SetActive(g_WelfareCtrl:IsYiYuanLiBaoOpen())
	self.m_BtnList[8]:SetActive(g_WelfareCtrl:IsRushRechargeOpen())
	self.m_BtnList[5]:SetActive(g_WelfareCtrl:IsChargeScoreOpen())
	self.m_BtnList[4]:SetActive(false)
	self.m_BtnList[9]:SetActive(g_WelfareCtrl:IsOpenLimitPay())
	self.m_BtnList[10]:SetActive(g_WelfareCtrl:IsOpenLoopPay())
	self.m_SideBtnGrid:Reposition()
end

function CLimitRewardView.UpdateRedDot(self)
	if self:IsNewLimitDraw() then
		self.m_BtnList[1]:AddEffect("RedDot")
	else
		self.m_BtnList[1]:DelEffect("RedDot")
	end

	if self:IsNewHasTotalPay() then
		self.m_BtnList[2]:AddEffect("RedDot")
	else
		self.m_BtnList[2]:DelEffect("RedDot")
	end

	if self:IsNewCostScore() then
		self.m_BtnList[3]:AddEffect("RedDot")
	else
		self.m_BtnList[3]:DelEffect("RedDot")
	end

	if self:IsNewLimitSkin() then
		self.m_BtnList[4]:AddEffect("RedDot")
	else
		self.m_BtnList[4]:DelEffect("RedDot")
	end

	if g_WelfareCtrl:IsHasLimitPayRedDot() then
		self.m_BtnList[9]:AddEffect("RedDot")
	else
		self.m_BtnList[9]:DelEffect("RedDot")
	end

	if g_WelfareCtrl:IsHasLoopPayRedDot() then
		self.m_BtnList[10]:AddEffect("RedDot")
	else
		self.m_BtnList[10]:DelEffect("RedDot")
	end
end

function CLimitRewardView.IsHasRedDot(cls)
	if cls:IsNewHasTotalPay() then
		return true
	end
	if cls:IsNewLimitSkin() then
		return true
	end
	if cls:IsNewCostScore() then
		return true
	end
	if cls:IsNewLimitDraw() then
		return true
	end
	if g_WelfareCtrl:IsHasLimitPayRedDot() then
		return true
	end

	if g_WelfareCtrl:IsHasLoopPayRedDot() then
		return true
	end
end

function CLimitRewardView.IsNewHasTotalPay(cls)
	return g_WelfareCtrl:IsTotalRechargeNeedRedDot()
end

function CLimitRewardView.IsNewLimitSkin(cls)
	return false
end

function CLimitRewardView.IsNewCostScore(cls)
	return g_WelfareCtrl:IsNewCostPoint()
end

function CLimitRewardView.IsNewLimitDraw(cls)
	return g_WelfareCtrl:IsNewLimitDraw()
end

function CLimitRewardView.UpdateDrawData(cls, iCnt, dIDList, iCost)
	local oView = CLimitRewardView:GetView()
	if oView and oView.m_LimitDrawPage:GetActive() then
		oView.m_LimitDrawPage:UpdateDrawData(iCnt, dIDList, iCost)
	end
end

function CLimitRewardView.UpdateDrawResult(cls, iPos, iCnt, iCost)
	local oView = CLimitRewardView:GetView()
	if oView and oView.m_LimitDrawPage:GetActive() then
		oView.m_LimitDrawPage:UpdateDrawResult(iPos, iCnt, iCost)
	end
end

function CLimitRewardView.SetLock(self, bLock)
	self.m_MaskWidget:SetActive(bLock)
end

function CLimitRewardView.OnClickMask(self)
	g_NotifyCtrl:FloatMsg("转盘正在飞速转动中")
end

return CLimitRewardView