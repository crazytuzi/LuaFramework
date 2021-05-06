local COrgShopInfoPart = class("COrgShopInfoPart", CBox)

function COrgShopInfoPart.ctor(self, cb)
	CBox.ctor(self, cb)
	self.m_MinNum = 0
	self.m_MaxNum = 1000
	self.m_DefaultBuyNum = 1
	self.m_UnitPrice = 0
	self.m_SumPrice = 0
	self.m_OwnCurrency = 0
	self.m_BuyNum = 1
	self.m_CurrentLimit = self.m_MaxNum
	self.m_SelectedItem = nil
	self.m_Currency = nil
	
	self:InitContent()
end

function COrgShopInfoPart.InitContent(self)
	self.m_DecCountBtn = self:NewUI(1, CAddorDecButton)
	self.m_AddCountBtn = self:NewUI(2, CAddorDecButton)
	self.m_CountBtn = self:NewUI(3, CButton)
	self.m_NumberLabel = self:NewUI(4, CLabel)
	self.m_SumLabel = self:NewUI(5, CLabel)
	self.m_BuyBtn = self:NewUI(6, CButton)
	self.m_SumCurrencySprite = self:NewUI(7, CSprite)
	self.m_ItemTipBox = self:NewUI(8, CItemTipsBox)
	self.m_ItemSlot = self:NewUI(9, CBox)
	self.m_MaxBtn = self:NewUI(10, CButton)
	-- self.m_QualitySprite = self:NewUI(8, CSprite)
	-- self.m_ItemSprite = self:NewUI(9, CSprite)
	-- self.m_PartnerQualitySprite = self:NewUI(10, CSprite)
	self.m_ItemNameLabel = self:NewUI(11, CLabel)
	self.m_ItemInfoLabel = self:NewUI(12, CLabel)
	self.m_ItemInfoScrollView = self:NewUI(13, CScrollView)
	self.m_AmountLabel = self:NewUI(14, CLabel)
	self.m_CloseMask = self:NewUI(15, CBox)
	self.m_CloseBtn = self:NewUI(16, CButton)

	self.m_ItemBox = self.m_ItemTipBox:Clone()
	self.m_ItemBox:SetParent(self.m_ItemSlot.m_Transform)
	self.m_ItemBox:SetLocalPos(Vector3.zero)
	self.m_ItemBox:SetActive(true)
	self.m_TextColor = self.m_SumLabel:GetColor()

	self.m_AddCountBtn:SetData({Label = self.m_NumberLabel, LimitNum = self.m_MaxNum, ChangeTable = {{0, 1}}, Callback = callback(self, "OnChangeCount")})
	self.m_DecCountBtn:SetData({Label = self.m_NumberLabel, LimitNum = self.m_MinNum, ChangeTable = {{0, -1}}, Callback = callback(self, "OnChangeCount")})
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnMaxBtn"))
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnShowKeyboard"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
	self.m_CloseMask:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self:SetActive(false)
end

function COrgShopInfoPart.OnMaxBtn(self)
	local maxCnt = math.modf(self.m_OwnCurrency / self.m_UnitPrice)
	if maxCnt < self.m_CurrentLimit then
		self:OnChangeCount(maxCnt)
	else
		self:OnChangeCount(self.m_CurrentLimit)
	end
end

function COrgShopInfoPart.OnClickClose(self)
	self:SetActive(false)
end

function COrgShopInfoPart.OnChangeCount(self, value)
	if self.m_SelectedItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end
	self.m_SumPrice = value * self.m_UnitPrice
	if self.m_SumPrice > self.m_OwnCurrency then
		self.m_SumLabel:SetColor(Color.red)
	else
		self.m_SumLabel:SetColor(self.m_TextColor)
	end
	self.m_NumberLabel:SetText(value)
	self.m_SumLabel:SetNumberString(self.m_SumPrice)
end

function COrgShopInfoPart.OnShowKeyboard(self)
	if self.m_SelectedItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end
	local function syncCallback(self, count)
		self:OnChangeCount(count)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_BuyNum, min = self.m_MinNum, max = self.m_CurrentLimit, syncfunc = syncCallback, obj = self},
		{widget = self.m_CountBtn, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0,0), extendClose = true}
	)
end

function COrgShopInfoPart.SetInfo(self, oItemCell, shopID)
	self:SetActive(true)
	if oItemCell.m_Amount ~=nil and oItemCell.m_Amount < self.m_MaxNum then
		self.m_CurrentLimit = oItemCell.m_Amount
		self.m_AddCountBtn:SetLimitNum(oItemCell.m_Amount)
	else
		self.m_CurrentLimit = self.m_MaxNum
		self.m_AddCountBtn:SetLimitNum(self.m_MaxNum)
	end
	self.m_UnitPrice = oItemCell.m_Price
	self.m_SelectedItem = oItemCell
	self.m_SumCurrencySprite:SetSpriteName(oItemCell.m_GoodsData.currency.icon)
	self.m_OwnCurrency = g_NpcShopCtrl:GetCurrencyValue(oItemCell.m_GoodsData.currency.currency_type)
	self.m_ItemInfoLabel:SetText(oItemCell.m_GoodsData.description)
	self.m_ItemInfoScrollView:ResetPosition()
	self.m_ItemNameLabel:SetText(oItemCell.m_GoodsData.name)
	if oItemCell.m_GoodsData.gType == define.Store.GoodsType.Partner then
		self.m_ItemBox:SetItemData(oItemCell.m_GoodsData.item_id, nil, oItemCell.m_GoodsData.exData.partner_type, {isLocal = true, uiType = 1})
	else
		self.m_ItemBox:SetItemData(oItemCell.m_GoodsData.item_id, nil, nil, {isLocal = true, uiType = 1})
	end
	-- if oItemCell.m_GoodsData.gType == define.Store.GoodsType.Partner then
	-- 	self.m_ItemSprite:SpriteAvatar(oItemCell.m_GoodsData.icon)
	-- else
	-- 	self.m_ItemSprite:SpriteItemShape(oItemCell.m_GoodsData.icon)
	-- end
	self:OnChangeCount(self.m_DefaultBuyNum)
end

function COrgShopInfoPart.OnBuy(self)
	local num = tonumber(self.m_NumberLabel:GetText())
	if self.m_CurrentShopId == define.Store.Page.OrgFuLiShop and g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos).buy ~= COrgCtrl.Has_Power then
		g_NotifyCtrl:FloatMsg("限会长和副会长购买")
	elseif self.m_SelectedItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	elseif self.m_SumPrice > self.m_OwnCurrency then
		g_NotifyCtrl:FloatMsg(string.format("您的%s不足哦", self.m_SelectedItem.m_GoodsData.currency.name))
	elseif num <= 0 then
		g_NotifyCtrl:FloatMsg("购买数量最少为1")
	else
		self.m_BuyNum = num
		
		printc("self.m_SelectedItem.m_GoodsInfo.pos: " .. self.m_SelectedItem.m_GoodsInfo.pos)
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSNpcStoreBuy"]) then
			netstore.C2GSNpcStoreBuy(self.m_SelectedItem.m_GoodsData.id, num, self.m_SumPrice, self.m_SelectedItem.m_GoodsInfo.pos)
		else
			-- g_NotifyCtrl:FloatMsg("你的手速成功超越了网速")
		end
		
		self:OnClickClose()
	end
end

function COrgShopInfoPart.RefreshUI(self)
	if self.m_SelectedItem ~= nil then
		self.m_OwnCurrency = g_NpcShopCtrl:GetCurrencyValue(self.m_SelectedItem.m_GoodsData.currency.currency_type)

		if self.m_SelectedItem.m_Amount ~= nil and self.m_BuyNum > self.m_SelectedItem.m_Amount then
			self:OnChangeCount(self.m_SelectedItem.m_Amount)
		else
			self:OnChangeCount(self.m_BuyNum)
		end
		self.m_BuyNum = self.m_MinNum
	else
		self.m_OwnCurrency = g_NpcShopCtrl:GetCurrencyValue(g_NpcShopCtrl:GetTagData(self.m_CurrentShopId).coin_typ)

	end
end

return COrgShopInfoPart