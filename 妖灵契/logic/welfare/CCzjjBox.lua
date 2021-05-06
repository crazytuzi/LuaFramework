local CCzjjBox = class("CCzjjBox", CBox)

function CCzjjBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_GetBtn = self:NewUI(1, CButton)
	self.m_HuibenLabel = self:NewUI(2, CLabel)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_RewardCntLabel = self:NewUI(4, CLabel)
	self.m_RewardSpr = self:NewUI(5, CSprite)
	self.m_Data = nil
	self.m_HasGet = false
	self.m_CanGet = false

	self.m_RewardSpr:AddUIEvent("click", callback(self, "OnShowTip"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGet"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CCzjjBox.OnShowTip(self, oSpr)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(1001, {widget = oSpr, side = enum.UIAnchor.Side.Left})
end

function CCzjjBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnCzjj then
		local dData = oCtrl.m_EventData
		if dData.key == "get_flags" then
			self:RefreshState()
		end
	end
end

function CCzjjBox.SetData(self, d)
	self.m_Data = d
	self:RefreshState()
end

function CCzjjBox.RefreshState(self)
	if not self.m_Data then
		return
	end
	self.m_RewardSpr:SpriteItemShape(1003) --彩晶
	self.m_RewardCntLabel:SetText(tostring(self.m_Data.goldcoin))
	self.m_DescLabel:SetText(string.format("达到#G%d#n级可领取", self.m_Data.grade))
	self.m_HuibenLabel:SetActive(self.m_Data.huiben == 1)
	local bBuy = g_WelfareCtrl:IsBuyCzjj()
	local bCanGet = bBuy and (g_AttrCtrl.grade >= self.m_Data.grade)
	local bHasGet = g_WelfareCtrl:IsGetCzjjReward(self.m_Data.key)
	local bGrey = not bCanGet or bHasGet
	self.m_GetBtn:SetEnabled(not bGrey)
	if bHasGet then
		self.m_GetBtn:SetText("已领取")
	else
		if bCanGet then
			self.m_GetBtn:SetText("领取")
		else
			if bBuy then
				self.m_GetBtn:SetText("领取")
			else
				self.m_GetBtn:SetText("未购买")
			end
			
		end
	end

	self.m_HasGet = bHasGet
	self.m_CanGet = bCanGet
	self.m_GetBtn:SetGrey(bGrey)
end

function CCzjjBox.OnGet(self)
	if self.m_CanGet then
		if self.m_HasGet then
			g_NotifyCtrl:FloatMsg("已领取过改奖励")
		else
			nethuodong.C2GSChargeRewardGradeGift(self.m_Data.grade)
		end
	else
		g_NotifyCtrl:FloatMsg("请先购买成长基金")
	end
end

return CCzjjBox