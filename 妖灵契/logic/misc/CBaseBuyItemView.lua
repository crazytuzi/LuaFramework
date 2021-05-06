local CBaseBuyItemView = class("CBaseBuyItemView", CViewBase)

--常规需求，可以直接调用base类，需求比较特殊，可继承此类
function CBaseBuyItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/LimitReward/CCostScoreBuyView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_CostShape = 1002   --价格类型
end

function CBaseBuyItemView.OnCreateView(self)
	self.m_MinNum = 0
	self.m_MaxNum = 200
	self.m_DefaultBuyNum = 1
	self.m_UnitPrice = 0
	self.m_SumPrice = 0
	self.m_OwnCurrency = 0
	self.m_BuyNum = 1
	self.m_Currency = nil
	self.m_TextColor = Color.New(0.54, 0.38, 0.13, 1)
	self.m_DecCountBtn = self:NewUI(1, CAddorDecButton)
	self.m_AddCountBtn = self:NewUI(2, CAddorDecButton)
	self.m_CountBtn = self:NewUI(3, CButton)
	self.m_NumberLabel = self:NewUI(4, CLabel)
	self.m_SumLabel = self:NewUI(5, CLabel)
	self.m_OwnLabel = self:NewUI(6, CLabel)
	self.m_BuyBtn = self:NewUI(7, CButton)
	self.m_SumCurrencySprite = self:NewUI(8, CSprite)
	self.m_OwnCurrencySprite = self:NewUI(9, CSprite)
	self.m_ItemInfoLabel = self:NewUI(10, CLabel)
	self.m_ItemInfoScrollView = self:NewUI(11, CScrollView)
	self.m_ItemNameLabel = self:NewUI(12, CLabel)
	self.m_ItemBox = self:NewUI(13, CItemTipsBox)
	self.m_CloseBtn = self:NewUI(14, CBox)
	self.m_CloseMask = self:NewUI(15, CBox)
	self.m_ItemSlot = self:NewUI(16, CBox)
	self.m_AmountLabel = self:NewUI(17, CLabel)
	self.m_TotalGoldNameLabel = self:NewUI(18, CLabel)
	self.m_CurGoldNameLabel = self:NewUI(19, CLabel)
	self:InitContent()
end

function CBaseBuyItemView.InitContent(self)
	self.m_OwnCurrencySprite:SetSpriteName(tostring(self.m_CostShape))
	self.m_SumCurrencySprite:SetSpriteName(tostring(self.m_CostShape))
	self.m_ItemInfoBox = self.m_ItemBox:Clone()
	self.m_ItemInfoBox:SetShowTips(false)
	self.m_ItemInfoBox:SetParent(self.m_ItemSlot.m_Transform)
	self.m_ItemInfoBox:SetLocalPos(Vector3.zero)
	self.m_ItemInfoBox:SetActive(true)
	self.m_CloseMask:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddCountBtn:SetData({Label = self.m_NumberLabel, LimitNum = self.m_MaxNum, ChangeTable = {{0, 1}}, Callback = callback(self, "OnChangeCount")})
	self.m_DecCountBtn:SetData({Label = self.m_NumberLabel, LimitNum = self.m_MinNum, ChangeTable = {{0, -1}}, Callback = callback(self, "OnChangeCount")})
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnShowKeyboard"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
	g_GuideCtrl:AddGuideUI("partner_cost_buy_fuwen_btn",self.m_BuyBtn)
	self:InitDerive()
end

function CBaseBuyItemView.InitDerive(self)
	
end

function CBaseBuyItemView.SetInfo(self, iShape, iRestAmount, iPrice , iGold)
	local sAmount = string.format("数量：%s", iRestAmount)
	self.m_AmountLabel:SetText(sAmount)
	self.m_MaxNum = math.min(math.floor(iGold / iPrice), iRestAmount)
	self.m_MaxNum = math.max(self.m_MaxNum, 1)
	self.m_AddCountBtn:SetLimitNum(self.m_MaxNum)
	self.m_UnitPrice = iPrice
	self.m_Shpae = iShape
	self.m_OwnCurrency = iGold
	self.m_DefaultBuyNum = math.min(1, self.m_MaxNum)

	self.m_OwnLabel:SetNumberString(iGold)
	local dItemInfo = DataTools.GetItemData(iShape) or {}
	self.m_ItemInfoLabel:SetText(dItemInfo.introduction)
	self.m_ItemInfoScrollView:ResetPosition()
	self.m_ItemNameLabel:SetText(dItemInfo.name)
	
	self.m_ItemInfoBox:SetItemData(iShape, nil, nil, {isLocal = true, uiType = 1})
	self:OnChangeCount(self.m_DefaultBuyNum)
end

function CBaseBuyItemView.SetBuyCb(self, cb)
	self.m_BuyCb = cb
end

function CBaseBuyItemView.OnChangeCount(self, value)
	self.m_SumPrice = value * self.m_UnitPrice
	if self.m_SumPrice > self.m_OwnCurrency then
		self.m_SumLabel:SetColor(Color.red)
	else
		self.m_SumLabel:SetColor(self.m_TextColor)
	end
	self.m_NumberLabel:SetText(value)
	self.m_BuyNum = value
	self.m_SumLabel:SetNumberString(self.m_SumPrice)
end

function CBaseBuyItemView.OnShowKeyboard(self)
	local function syncCallback(self, count)
		self:OnChangeCount(count)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_BuyNum, min = self.m_MinNum, max = self.m_MaxNum, syncfunc = syncCallback, obj = self},
		{widget = self.m_CountBtn, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0,0), extendClose = true}
	)
end

function CBaseBuyItemView.OnBuy(self)
	if self.m_BuyCb then
		self.m_BuyCb(self.m_BuyNum)
	end
	self:CloseView()
end

return CBaseBuyItemView