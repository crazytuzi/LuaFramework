local CFirstChargeView = class("CFirstChargeView", CViewBase)

function CFirstChargeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Welfare/FirstChargeView.prefab", cb)
	self.m_ExtendClose = "Shelter"
	self.m_GroupName = "main"
end

function CFirstChargeView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CItemRewardBox)
	self.m_ChargeBtn = self:NewUI(5, CButton)
	self.m_BehindTexture = self:NewUI(6, CTexture)
	self.m_GetBtn = self:NewUI(7, CButton)
	self.m_PartnerTexture = self:NewUI(8, CTexture)
	self:InitContent()
end

function CFirstChargeView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ItemBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_BehindTexture:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ChargeBtn:AddUIEvent("click", callback(self, "OnChargeBtn"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGetBtn"))
	self.m_PartnerTexture:AddUIEvent("click", callback(self, "OnClickPartner"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	self:InitItemGrid()
	self:Refresh()
end

function CFirstChargeView.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnFirstCharge then
		self:Refresh()
	end
end

function CFirstChargeView.Refresh(self)
	if g_WelfareCtrl:IsFirstChargeRedDot() then
		self.m_GetBtn:SetActive(true)
		self.m_ChargeBtn:SetActive(false)
	elseif g_WelfareCtrl:IsOpenFirstCharge() then
		self.m_GetBtn:SetActive(false)
		self.m_ChargeBtn:SetActive(true)
	else
		self.m_GetBtn:SetActive(false)
		self.m_ChargeBtn:SetActive(true)
	end
end

function CFirstChargeView.OnChargeBtn(self, obj)
	g_SdkCtrl:ShowPayView()
	self:CloseView()
end

function CFirstChargeView.OnGetBtn(self, obj)
	netfuli.C2GSReceiveFirstCharge()
	self:CloseView()
end

function CFirstChargeView.InitItemGrid(self)
	local dFirstCharge = data.welfaredata.FirstCharge[100001].reward
	local rewardlist = {}
	for i,v in ipairs(dFirstCharge) do
		table.insert(rewardlist, data.rewarddata.WELFARE.reward[v])
	end
	self.m_ItemGrid:Clear()
	local config = {isLocal = true,}
	for i,v in ipairs(rewardlist) do
		local box = self.m_ItemBox:Clone()
		box:SetActive(true)
		box:SetItemBySid(v.sid, v.amount)
		self.m_ItemGrid:AddChild(box)
		if i == 1 then
			box.m_IgnoreCheckEffect = true
			box:AddEffect("bordermove", nil, nil, 7)
			box:AddUIEvent("click", callback(self, "OnClickPartner"))
		end
	end
	self.m_ItemGrid:Reposition()
end

function CFirstChargeView.OnClickPartner(self)
	CPartnerGainView:ShowView(function (oView)
		oView:SetPartnerByType(503)
	end)
end

return CFirstChargeView