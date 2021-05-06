local CExchangeEnergyView = class("CExchangeEnergyView", CViewBase)

function CExchangeEnergyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/ExchangeEnergyView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CExchangeEnergyView.OnCreateView(self)

	self.m_ExchangeTipsLabel = self:NewUI(2, CLabel)
	self.m_EnergyBuytimeLabel = self:NewUI(3, CLabel)
	self.m_ExcangeBtn = self:NewUI(4, CButton)
	self.m_CancelBtn = self:NewUI(5, CButton)

	self:InitContent()
end

function CExchangeEnergyView.InitContent(self)
	self.m_OwnerView = nil
	self.m_ExchangeCost = 0
	self.m_Buytime2Gold = string.split(data.globaldata.GLOBAL.buyenergy_rate.value, ",")
	self.m_ExchangeRate = g_NpcShopCtrl:GetRatio(define.Store.ExchangeType.GoldCoin2Energy)

	self.m_ExcangeBtn:AddUIEvent("click", callback(self, "OnExcange"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyRefresh"))
	g_NpcShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))

	self:RefreshUI()
end

function CExchangeEnergyView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CExchangeEnergyView.CloseView(self)
	CViewBase.CloseView(self)
end

function CExchangeEnergyView.OnExcange(self)
	local cur = tonumber(g_ChapterFuBenCtrl:GetEnergyBuytime())
	local max = tonumber(data.globaldata.GLOBAL.buyenergy_maxtime.value)
	if cur == max then
		g_NotifyCtrl:FloatMsg("今日可兑换次数已达到最大值")
	elseif self.m_ExchangeCost > g_AttrCtrl.goldcoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	else
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSGold2Coin"]) then
			netstore.C2GSGold2Coin(self.m_ExchangeCost, self.m_ExchangeRate, define.Store.ExchangeType.GoldCoin2Energy)
		end
	end
end

function CExchangeEnergyView.OnNotifyRefresh(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshUI()
	end
end

function CExchangeEnergyView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Store.Event.CloseGold2Coin then
		self:CloseView()
	end
end

function CExchangeEnergyView.RefreshUI(self)
	local cur = tonumber(g_ChapterFuBenCtrl:GetEnergyBuytime())
	local max = tonumber(data.globaldata.GLOBAL.buyenergy_maxtime.value)
	local key = math.min(cur+1, #self.m_Buytime2Gold)
	local tips = string.format("是否消耗#w2%d兑换#tl%d", self.m_Buytime2Gold[key], tonumber(data.globaldata.GLOBAL.buyenergy_value.value))
	self.m_ExchangeTipsLabel:SetText(tips)
	self.m_EnergyBuytimeLabel:SetText(string.format("今日已兑换:%d/%d", cur, max))
	self.m_ExchangeCost = tonumber(data.globaldata.GLOBAL.buyenergy_cost.value)
end

return CExchangeEnergyView