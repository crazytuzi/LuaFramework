local CItemTipsQuickBuyBox = class("CItemTipsQuickBuyBox", CBox)

function CItemTipsQuickBuyBox.ctor(self, ob)
	CBox.ctor(self, ob)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_AddBtn = self:NewUI(2, CAddorDecButton)
	self.m_DecBtn = self:NewUI(3, CAddorDecButton)
	self.m_BuyNumLabel = self:NewUI(4, CLabel)
	self.m_BuyBtn = self:NewUI(5, CButton)
	self.m_CostLabel = self:NewUI(6, CLabel)
	self.m_BuyNumBtn = self:NewUI(7, CButton)
	self.m_DiscountMark = self:NewUI(8, CSprite)
	self.m_CurrencySprite = self:NewUI(9, CSprite)
	self:InitContent()
end

function CItemTipsQuickBuyBox.InitContent(self)
	self.m_BuyNumBtn:AddUIEvent("click", callback(self, "OnShowKeyboard"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuyBox"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CItemTipsQuickBuyBox.SetData(self, oData, index)
	self.m_ItemData = oData
	self.m_Data = oData.buy_cost[index]
	self.m_Currency = g_NpcShopCtrl:GetCurrency(self.m_Data.coin)
	self.m_CurrencySprite:SpriteItemShape(tonumber(self.m_Currency.icon))

	self.m_TitleLabel:SetText(string.format("%s购买%s", self.m_Currency.name, oData.name))
	self.m_MaxNum = self.m_Data.limit
	self.m_TotalPrice = 0
	self.m_MinNum = 1
	self.m_BuyNum = 1
	self.m_AddBtn:SetData({Label = self.m_BuyNumLabel, LimitNum = self.m_MaxNum, ChangeTable = {{0, 10},{5, 50}}, Callback = callback(self, "OnChangeValue")})
	self.m_DecBtn:SetData({Label = self.m_BuyNumLabel, LimitNum = self.m_MinNum, ChangeTable = {{0, -10},{5, -50}}, Callback = callback(self, "OnChangeValue")})
	self.m_DiscountMark:SetActive(self.m_Data.discount == 1)
	self:OnChangeValue(self.m_BuyNum)
end

function CItemTipsQuickBuyBox.OnChangeValue(self, value)
	if self.m_MaxNum and value > self.m_MaxNum then
		self.m_BuyNum = self.m_MaxNum
		g_NotifyCtrl:FloatMsg("输入数字超出范围")
	elseif value < self.m_MinNum then
		self.m_BuyNum = self.m_MinNum
	else
		self.m_BuyNum = value
	end
	self.m_TotalPrice = self.m_Data.cost * self.m_BuyNum
	self.m_BuyNumLabel:SetText(self.m_BuyNum)
	self:Refresh()
	self.m_CostLabel:SetText(self.m_TotalPrice)
end

function CItemTipsQuickBuyBox.OnShowKeyboard(self)
	local function syncCallback(self, count)
		self:OnChangeValue(count)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_BuyNum, min = self.m_MinNum, max = self.m_MaxNum, syncfunc = syncCallback, obj = self},
		{widget = self.m_BuyNumLabel, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0, 0), extendClose = true}
	)
end

function CItemTipsQuickBuyBox.OnBuyBox(self)
	--特殊材料快捷购买
	-- printc("self.m_TotalPrice " .. self.m_TotalPrice)

	if self.m_TotalPrice > g_NpcShopCtrl:GetCurrencyValue(self.m_Currency.currency_type) then
		if self.m_Currency.currency_type == define.Currency.Type.GoldCoin then
			g_SdkCtrl:ShowPayView()
		elseif self.m_Currency.currency_type == define.Currency.Type.ColorCoin then
			g_SdkCtrl:ShowPayView()
		elseif self.m_Currency.currency_type == define.Currency.Type.Gold then
			g_NpcShopCtrl:ShowGold2CoinView()
		end
		g_NotifyCtrl:FloatMsg(string.format("您的%s不足", self.m_Currency.name))
	else
		netstore.C2GSBuyItemByCoin(self.m_Data.coin, self.m_ItemData.id, self.m_BuyNum)
	end
end

function CItemTipsQuickBuyBox.Refresh(self)
	if g_NpcShopCtrl:GetCurrencyValue(self.m_Currency.currency_type) >= self.m_TotalPrice then
		self.m_CostLabel:SetColor(Color.New(0.85,0.81,0.73))
	else
		self.m_CostLabel:SetColor(Color.red)
	end
end

function CItemTipsQuickBuyBox.OnCtrlAttrEvent(self, oCtrl)
	if not self.m_Data then
		return
	end
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:Refresh()
	end
end

return CItemTipsQuickBuyBox