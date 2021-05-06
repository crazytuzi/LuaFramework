local CBuyGiftCntView = class("CBuyGiftCntView", CViewBase)
--伙伴交流界面
function CBuyGiftCntView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/BuyGiftCntView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "House"
end

function CBuyGiftCntView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_InfoLabel = self:NewUI(2, CLabel)
	self.m_CostLabel = self:NewUI(3, CLabel)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_OKBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CBuyGiftCntView.InitContent(self)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnClickOK"))
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	self:Refresh()
end

function CBuyGiftCntView.OnClickOK(self)
	if self.m_Paying then
		g_NotifyCtrl:FloatMsg("操作过快")
		return
	end
	if self.m_Cost > g_AttrCtrl.goldcoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
		self:OnClose()
	else
		self.m_Paying = true
		nethouse.C2GSAddPartnerGift(1, self.m_Cost)
	end
end

function CBuyGiftCntView.Refresh(self)
	self.m_Paying = false
	self.m_Cost = string.eval(data.globaldata.GLOBAL.house_gift_count_cost.value, {n = g_HouseCtrl.m_GiftBuyCount + 1})
	local maxCost = tonumber(data.globaldata.GLOBAL.house_gift_count_max_cost.value)
	if self.m_Cost > maxCost then
		self.m_Cost = maxCost
	end
	self.m_InfoLabel:SetText(string.format("是否花费#w2%s购买送礼次数", self.m_Cost))
	self.m_CostLabel:SetText(self.m_Cost)
end

function CBuyGiftCntView.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.GiveCntRefresh then
		self:Refresh()
	end
end

return CBuyGiftCntView