local CRewardBackPage = class("CRewardBackPage", CPageBase)

function CRewardBackPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CRewardBackPage.OnInitPage(self)
	self.m_ResumeGrid = self:NewUI(1, CGrid)
	self.m_ResumeBox = self:NewUI(2, CBox)
	self.m_AllFreeBtn = self:NewUI(3, CButton)
	self.m_AllColorCoinBtn = self:NewUI(4, CButton)
	self.m_CostColorCoinLabel = self:NewUI(5, CLabel)
	self.m_GoldCoinLabel = self:NewUI(6, CLabel)
	self.m_GoldCoinAddBtn = self:NewUI(7, CButton)
	self.m_MainPart = self:NewUI(8, CWidget)
	self.m_WaitPart = self:NewUI(9, CWidget)
	self.m_HelpBtn = self:NewUI(10, CButton)
	self:InitContent()
end

function CRewardBackPage.InitContent(self)
	self.m_Info = {}
	self.m_TotalCost = 0

	self.m_ResumeBox:SetActive(false)
	self.m_MainPart:SetActive(false)
	self.m_WaitPart:SetActive(false)
	self.m_AllFreeBtn:AddUIEvent("click", callback(self, "OnAllFreeBtn"))
	self.m_AllColorCoinBtn:AddUIEvent("click", callback(self, "OnAllColorCoinBtn"))
	self.m_GoldCoinAddBtn:AddUIEvent("click", callback(self, "OnAddGoldCoin"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
	self:RefreshRewardBack()
end

function CRewardBackPage.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("rewardback")
	end)
end

function CRewardBackPage.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnRewardBack then
		self:RefreshRewardBack()
	end
end

function CRewardBackPage.OnAddGoldCoin(self)
	g_SdkCtrl:ShowPayView()
end

function CRewardBackPage.OnAllFreeBtn(self, obj)
	netfuli.C2GSGetRewardBack(0, 0)
end

function CRewardBackPage.OnAllColorCoinBtn(self, obj)
	netfuli.C2GSGetRewardBack(0, 1)
end

function CRewardBackPage.RefreshRewardBack(self)
	self.m_Info = g_WelfareCtrl:GetRewardBackInfo()
	self.m_TotalCost = 0
	for k,v in pairs(self.m_Info) do
		if v.vip then
			self.m_TotalCost = self.m_TotalCost + v.vip
		end
	end
	local goldcoin = g_AttrCtrl.goldcoin
	self.m_GoldCoinLabel:SetNumberString(goldcoin)
	self:RefreshCostColorCoin()
	self:RefreshResumeGrid()
	local bAct = self.m_ResumeGrid:GetCount() > 0
	self.m_MainPart:SetActive(bAct)
	self.m_WaitPart:SetActive(not bAct)
	self.m_AllFreeBtn:SetActive(g_WelfareCtrl:HasRewardBackFree())
end

function CRewardBackPage.RefreshCostColorCoin(self)
	self.m_CostColorCoinLabel:SetText(self.m_TotalCost)
end

function CRewardBackPage.RefreshResumeGrid(self)
	self.m_ResumeGrid:Clear()
	for i,d in ipairs(self.m_Info) do
		local oBox = self:CreateResumeBox()
		oBox = self:UpdateTargetBox(oBox, d)
		if oBox then
			self.m_ResumeGrid:AddChild(oBox)
		else
			oBox:Destroy()
		end
	end
end

function CRewardBackPage.CreateResumeBox(self)
	local oBox = self.m_ResumeBox:Clone()
	oBox.m_NameLabel = oBox:NewUI(1, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(2, CGrid)
	oBox.m_ItemBox = oBox:NewUI(3, CItemRewardBox)
	oBox.m_FreeBtn = oBox:NewUI(4, CButton)
	oBox.m_FreeGotSpr = oBox:NewUI(5, CSprite)
	oBox.m_ColorCoinBtn = oBox:NewUI(6, CButton)
	oBox.m_ColorCoinGotSpr = oBox:NewUI(7, CSprite)
	oBox.m_ColorCoinGotLabel = oBox:NewUI(8, CLabel)
	oBox.m_ItemBox:SetActive(false)
	oBox.m_ItemList = {}
	oBox.m_ItemGrid:Clear()
	oBox.m_FreeBtn:AddUIEvent("click", callback(self, "OnGetFree", oBox))
	oBox.m_ColorCoinBtn:AddUIEvent("click", callback(self, "OnGetVip", oBox))
	return oBox
end

function CRewardBackPage.OnGetFree(self, oBox)
	netfuli.C2GSGetRewardBack(oBox.m_SID, 0)
end

function CRewardBackPage.OnGetVip(self, oBox)
	netfuli.C2GSGetRewardBack(oBox.m_SID, 1)
end

function CRewardBackPage.UpdateTargetBox(self, oBox, d)
	local dData = data.welfaredata.RewardBack[d.sid]
	if not dData then
		return 
	end
	oBox.m_SID = d.sid
	oBox.m_Left = d.left
	oBox.m_NameLabel:SetText(dData.desc)
	local bFree = d.free and d.free == 1
	oBox.m_FreeBtn:SetActive(bFree)
	oBox.m_FreeGotSpr:SetActive(not bFree)

	local bVip = d.vip and d.vip > 0
	oBox.m_ColorCoinBtn:SetActive(bVip)
	oBox.m_ColorCoinGotSpr:SetActive(not bVip)
	oBox.m_ColorCoinGotLabel:SetText(d.vip)

	oBox:SetActive(bFree or bVip)

	local rewarddata = {}
	if bFree then
		rewarddata = dData.before_reward
	else
		rewarddata = dData.after_reward
	end
	oBox.m_ItemGrid:Clear()
	local config = {isLocal = true,}
	for i,v in ipairs(rewarddata) do
		local box = oBox.m_ItemBox:Clone()
		box:SetActive(true)
		box:SetItemBySid(v.sid, v.num * oBox.m_Left, config)
		oBox.m_ItemGrid:AddChild(box)
	end
	oBox.m_ItemGrid:Reposition()
	return oBox
end

return CRewardBackPage