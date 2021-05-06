local CShopCostInfoPart = class("CShopCostInfoPart", CBox)

function CShopCostInfoPart.ctor(self, cb)
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
	self.m_TextColor = Color.New(0.54, 0.38, 0.13, 1)
	self:InitContent()
end

function CShopCostInfoPart.InitContent(self)
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
	self.m_MaxBtn = self:NewUI(18, CButton)

	self.m_ItemInfoBox = self.m_ItemBox:Clone()
	self.m_ItemInfoBox:SetShowTips(false)
	self.m_ItemInfoBox:SetParent(self.m_ItemSlot.m_Transform)
	self.m_ItemInfoBox:SetLocalPos(Vector3.zero)
	self.m_ItemInfoBox:SetActive(true)
	self.m_CloseMask:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_AddCountBtn:SetData({Label = self.m_NumberLabel, LimitNum = self.m_MaxNum, ChangeTable = {{0, 1}}, Callback = callback(self, "OnChangeCount")})
	self.m_DecCountBtn:SetData({Label = self.m_NumberLabel, LimitNum = self.m_MinNum, ChangeTable = {{0, -1}}, Callback = callback(self, "OnChangeCount")})
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnShowKeyboard"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnClickMax"))
	self:SetActive(false)
end

function CShopCostInfoPart.OnClickMax(self)
	if self.m_SelectedItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end
	local iCount = math.modf(self.m_OwnCurrency / self.m_UnitPrice)
	if iCount <= 0 then
		iCount = 1
	end
	if iCount > self.m_CurrentLimit then
		iCount = self.m_CurrentLimit
	end
	
	self:OnChangeCount(iCount)
end

function CShopCostInfoPart.OnChangeCount(self, value)
	if self.m_SelectedItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end
	self.m_NumberLabel:SetText(value)
	self.m_SumPrice = value * self.m_UnitPrice
	if self.m_SelectedItem.m_GoodsData.currency.currency_type == define.Currency.Type.RMB then
		self.m_SumLabel:SetText(self.m_SumPrice .. "元")
	else
		if self.m_SumPrice > self.m_OwnCurrency then
			self.m_SumLabel:SetColor(Color.red)
		else
			self.m_SumLabel:SetColor(self.m_TextColor)
		end
		self.m_SumLabel:SetNumberString(self.m_SumPrice)
	end
end

function CShopCostInfoPart.OnShowKeyboard(self)
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

function CShopCostInfoPart.SetInfo(self, oItemCell)
	self:SetActive(true)
	local sInfo = ""
	if oItemCell.m_Amount ~= nil then
		sInfo = string.format("数量：%s", oItemCell.m_Amount)
		if oItemCell.m_Amount < self.m_MaxNum then
		-- self.m_AmountLabel:SetText(string.format("数量：%s", oItemCell.m_Amount))
			self.m_CurrentLimit = oItemCell.m_Amount
			self.m_AddCountBtn:SetLimitNum(oItemCell.m_Amount)
		end
		if oItemCell.m_GoodsData.cycle_type == "day" then
			sInfo = string.format("%s\n备注：%s", sInfo, "本日限购")
			elseif oItemCell.m_GoodsData.cycle_type == "week" then
			sInfo = string.format("%s\n备注：%s", sInfo, "本周限购")
			elseif oItemCell.m_GoodsData.cycle_type == "month" then
			sInfo = string.format("%s\n备注：%s", sInfo, "本月限购")
		else
			sInfo = string.format("%s\n备注：%s", sInfo, "本次限购")
		end
	else
		-- self.m_AmountLabel:SetText("")
		self.m_CurrentLimit = self.m_MaxNum
		self.m_AddCountBtn:SetLimitNum(self.m_MaxNum)
	end
	
	self.m_AmountLabel:SetText(sInfo)

	self.m_UnitPrice = g_NpcShopCtrl:GetGoodsPrice(oItemCell.m_GoodsInfo.pos)
	self.m_SelectedItem = oItemCell
	self.m_OwnCurrencySprite:SetSpriteName(oItemCell.m_GoodsData.currency.icon)
	self.m_SumCurrencySprite:SetSpriteName(oItemCell.m_GoodsData.currency.icon)
	self.m_OwnCurrency = g_NpcShopCtrl:GetCurrencyValue(oItemCell.m_GoodsData.currency.currency_type)
	self.m_OwnLabel:SetNumberString(self.m_OwnCurrency)
	self.m_ItemInfoLabel:SetText(oItemCell.m_GoodsData.description)
	self.m_ItemInfoScrollView:ResetPosition()
	self.m_ItemNameLabel:SetText(oItemCell.m_GoodsData.name)
	if oItemCell.m_GoodsData.gType == define.Store.GoodsType.Partner then
		self.m_ItemInfoBox:SetItemData(oItemCell.m_GoodsData.item_id, nil, oItemCell.m_GoodsData.exData.partner_type, {isLocal = true, uiType = 2})
	else
		self.m_ItemInfoBox:SetItemData(oItemCell.m_GoodsData.item_id, nil, nil, {isLocal = true, uiType = 2})
	end

	local iCount = math.modf(self.m_OwnCurrency / self.m_UnitPrice)
	if iCount <= 0 then
		iCount = 1
	end
	if self.m_CurrentLimit > iCount then
		self.m_CurrentLimit = iCount
		self.m_AddCountBtn:SetLimitNum(iCount)
	end
	self:OnChangeCount(self.m_DefaultBuyNum)
end

function CShopCostInfoPart.OnBuy(self)
	local num = tonumber(self.m_NumberLabel:GetText())
	if self.m_SelectedItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	elseif self.m_SelectedItem.m_GoodsData.vip == 1 and not (g_WelfareCtrl:HasYueKa() or g_WelfareCtrl:HasZhongShengKa()) then
		g_NotifyCtrl:FloatMsg("限月卡、终身卡购买")
	elseif self.m_SelectedItem.m_GoodsData.grade_limit ~= nil 
			and (
					(self.m_SelectedItem.m_GoodsData.grade_limit.max ~= nil and self.m_SelectedItem.m_GoodsData.grade_limit.max < g_AttrCtrl.grade)
					or(self.m_SelectedItem.m_GoodsData.grade_limit.min ~= nil and self.m_SelectedItem.m_GoodsData.grade_limit.min > g_AttrCtrl.grade)
				) then
			g_NotifyCtrl:FloatMsg("当前等级无法购买")
			return
	elseif self.m_SelectedItem.m_Amount == 0 then
		g_NotifyCtrl:FloatMsg("剩余数量不足")
	elseif self.m_SelectedItem.m_GoodsData.currency.currency_type == define.Currency.Type.RMB then
		if g_LoginCtrl:IsSdkLogin() then
			g_SdkCtrl:Pay(self.m_SelectedItem.m_GoodsData.payid, 1, {request_value = tostring(self.m_SelectedItem.m_GoodsData.id), request_key = "goods_key"})
		else
			if Utils.IsDevUser() and Utils.IsEditor() then
				netother.C2GSGMCmd(string.format("huodong charge 1003 %s", self.m_SelectedItem.m_GoodsData.id))
				g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
			else
				g_NotifyCtrl:FloatMsg("当前环境不支持购买")
			end
		end
	elseif self.m_SumPrice > self.m_OwnCurrency then
		if self.m_SelectedItem.m_GoodsData.currency.currency_type == define.Currency.Type.GoldCoin then
			g_SdkCtrl:ShowPayView()
		elseif self.m_SelectedItem.m_GoodsData.currency.currency_type == define.Currency.Type.ColorCoin then
			g_SdkCtrl:ShowPayView()
		elseif self.m_SelectedItem.m_GoodsData.currency.currency_type == define.Currency.Type.Gold then
			g_NpcShopCtrl:ShowGold2CoinView()
		end
		g_NotifyCtrl:FloatMsg(string.format("您的%s不足", self.m_SelectedItem.m_GoodsData.currency.name))
	elseif num <= 0 then
		g_NotifyCtrl:FloatMsg("购买数量最少为1")
	else
		self.m_BuyNum = num
		-- printc("self.m_SelectedItem.m_GoodsInfo.pos: " .. self.m_SelectedItem.m_GoodsInfo.pos)
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSNpcStoreBuy"]) then
			netstore.C2GSNpcStoreBuy(self.m_SelectedItem.m_GoodsData.id, num, self.m_SumPrice, self.m_SelectedItem.m_GoodsInfo.pos)
		else
			g_NotifyCtrl:FloatMsg("你的手速成功超越了网速")
		end
		self:OnClickClose()
	end
end

function CShopCostInfoPart.OnClickClose(self)
	self:SetActive(false)
end

return CShopCostInfoPart