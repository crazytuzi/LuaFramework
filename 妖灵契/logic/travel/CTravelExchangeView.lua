local CTravelExchangeView = class("CTravelExchangeView", CViewBase)

function CTravelExchangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelExchangeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Black"
end

function CTravelExchangeView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_TravelHelpBtn = self:NewUI(4, CButton)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CBox)
	self.m_BuyBtn = self:NewUI(7, CButton)
	self.m_LeftScoreLabel = self:NewUI(8, CLabel)
	self.m_CostScoreLabel = self:NewUI(9, CLabel)

	self:InitContent()
end

function CTravelExchangeView.InitContent(self)
	self.m_ItemBox:SetActive(false)
	self.m_TravelHelpBtn:AddHelpTipClick("travel_exchange")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuyBtn"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrl"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrl"))
end

function CTravelExchangeView.OnItemCtrl(self, oCtrl)
	self:RefreshHasLabel()
end

function CTravelExchangeView.OnAttrCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshLeftScore()
		self:RefreshCostScore()
	end
end

function CTravelExchangeView.OnBuyBtn(self, oBtn)
	if self.m_LeftScore < self.m_Cost then
		g_NotifyCtrl:FloatMsg("游历积分不足，兑换失败")
		return
	end
	if self.m_Cost == 0 then
		g_NotifyCtrl:FloatMsg("请选择购买的商品")
		return
	end 
	local buylist = {}
	for i,oItemBox in ipairs(self.m_ItemGrid:GetChildList()) do
		if oItemBox.m_Total > 0 then
			table.insert(buylist, {
					buy_id = oItemBox.m_BuyID,
					buy_count = oItemBox.m_BuyCount,
					buy_price = oItemBox.m_Total,
					pos = oItemBox.m_Pos,
				})
		end
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSStoreBuyList"]) then
		netstore.C2GSStoreBuyList(buylist)
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSOpenShop"]) then
		netstore.C2GSOpenShop(define.Store.Page.TravelShop)
	end
end

function CTravelExchangeView.RefreshView(self, goodslist, defaultSid)
	self:RefreshLeftScore()
	self:RefreshCostScore()
	self:RefreshItemGrid(goodslist, defaultSid)
end

function CTravelExchangeView.RefreshLeftScore(self)
	self.m_LeftScore = g_AttrCtrl.travel_score
	self.m_LeftScoreLabel:SetText(string.format("剩余积分:%d", self.m_LeftScore))
end

function CTravelExchangeView.RefreshCostScore(self)
	self.m_Cost = 0
	for i,oItemBox in ipairs(self.m_ItemGrid:GetChildList()) do
		self.m_Cost = self.m_Cost + oItemBox.m_Total
	end
	local color = "73532E"
	if self.m_LeftScore < self.m_Cost then
		color = "FF0000"
	end
	self.m_CostScoreLabel:SetText(string.format("[73532E]合计积分:[%s]%d", color, self.m_Cost))
end

function CTravelExchangeView.RefreshItemGrid(self, goodslist, defaultSid)
	local defaultPos = nil
	self.m_ItemGrid:Clear()
	local itemlist = {}
	for i,v in ipairs(goodslist) do
		local dData = data.npcstoredata.DATA[v.item_id]
		if dData then
			dData = table.copy(dData)
			dData.pos = v.pos
			table.insert(itemlist, dData)
			if dData.item_id == defaultSid then
				defaultPos = v.pos
			end
		end
	end
	table.sort(itemlist, function (a, b)
			if a.sortId == b.sortId then
				return a.id < b.id
			else
				return a.sortId < b.sortId
			end
		end)
	for i,v in ipairs(itemlist) do
		local oItemBox = self.m_ItemBox:Clone()
		oItemBox:SetActive(true)
		oItemBox.m_IconSprite = oItemBox:NewUI(1, CSprite)	 
		oItemBox.m_QualitySprite = oItemBox:NewUI(2, CSprite)	  
		oItemBox.m_PriceLabel = oItemBox:NewUI(3, CLabel)
		oItemBox.m_AddBtn = oItemBox:NewUI(4, CButton)
		oItemBox.m_DecBtn = oItemBox:NewUI(5, CButton)
		oItemBox.m_ExchangeNumBtn = oItemBox:NewUI(6, CButton)
		oItemBox.m_ExchangeNumLabel = oItemBox:NewUI(7, CLabel)
		oItemBox.m_HasLabel = oItemBox:NewUI(8, CLabel)
		oItemBox.m_NameLabel = oItemBox:NewUI(9, CLabel)

		local oItem = CItem.NewBySid(v.item_id)
		oItemBox.m_SID = oItem:GetValue("sid")
		oItemBox.m_BuyID = v.id
		oItemBox.m_Pos = v.pos
		oItemBox.m_Self = self
		oItemBox.m_MaxNum = 10000
		oItemBox.m_MinNum = 0
		oItemBox.m_DefaultBuyNum = 0
		oItemBox.m_ExchangeNum = 1
		oItemBox.m_ExchangeRate = 0
		oItemBox.m_CoinCount = v.coin_count
		oItemBox.m_NameLabel:SetText(oItem:GetValue("name"))
		oItemBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		oItemBox.m_QualitySprite:SetItemQuality(oItem:GetValue("quality"))
		oItemBox.m_PriceLabel:SetText(string.format("积分：%d", oItemBox.m_CoinCount))
		oItemBox.m_HasLabel:SetText(string.format("拥有数量:%d", g_ItemCtrl:GetTargetItemCountBySid(oItemBox.m_SID)))
		oItemBox.m_BuyCount = oItemBox.m_DefaultBuyNum
		oItemBox.m_Total = oItemBox.m_BuyCount * oItemBox.m_CoinCount

		oItemBox.m_ExchangeNumLabel:SetText(oItemBox.m_BuyCount)
		oItemBox.m_IconSprite:AddUIEvent("click", callback(self, "OnIcon", oItem, oItemBox)) 
		oItemBox.m_AddBtn:AddUIEvent("click", callback(self, "OnAddBtn", oItemBox))
		oItemBox.m_DecBtn:AddUIEvent("click", callback(self, "OnDecBtn", oItemBox))
		oItemBox.m_ExchangeNumBtn:AddUIEvent("click", callback(self, "OnShowKeyboard", oItemBox))
		self.m_ItemGrid:AddChild(oItemBox)
	end
	self.m_ItemGrid:Reposition()
	if defaultPos then
		local cnt = #itemlist
		if defaultPos > #itemlist - 2 then
			defaultPos = #itemlist - 2
		end
		local oBox = self.m_ItemGrid:GetChild(defaultPos)
		if oBox then
			UITools.MoveToTarget(self.m_ScrollView, oBox, 5)
		end
	end
end

function CTravelExchangeView.OnIcon(self, oItem, oItemBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItem:GetValue("sid"), 
		{widget = oItemBox.m_IconSprite}, nil, {quality = oItem:GetValue("quality")})
end

function CTravelExchangeView.RefeshItemBox(self, oItemBox, value)
	oItemBox.m_BuyCount = value
	oItemBox.m_ExchangeNumLabel:SetText(oItemBox.m_BuyCount)
	oItemBox.m_Total = oItemBox.m_BuyCount * oItemBox.m_CoinCount
end

function CTravelExchangeView.OnAddBtn(self, oItemBox, oBtn)
	local cur = tonumber(oItemBox.m_ExchangeNumLabel:GetText())
	local value = cur + 1
	if value > oItemBox.m_MaxNum then
		return
	else
		self:RefeshItemBox(oItemBox, value)
	end
	self:RefreshCostScore()
end

function CTravelExchangeView.OnDecBtn(self, oItemBox, oBtn)
	local cur = tonumber(oItemBox.m_ExchangeNumLabel:GetText())
	local value = cur - 1
	if value < oItemBox.m_MinNum then
		return
	else
		self:RefeshItemBox(oItemBox, value)
	end
	self:RefreshCostScore()
end

function CTravelExchangeView.OnChangeCost(self, value, oItemBox)
	self:RefeshItemBox(oItemBox, value)
	self:RefreshCostScore()
end

function CTravelExchangeView.OnShowKeyboard(self, oItemBox)
	local function syncCallback(self, count)
		self.m_Self:OnChangeCost(count, oItemBox)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = oItemBox.m_ExchangeNum, min = oItemBox.m_MinNum, max = oItemBox.m_MaxNum, syncfunc = syncCallback, obj = oItemBox},
		{widget = oItemBox.m_ExchangeNumBtn, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0, 0), extendClose = true}
	)
end

function CTravelExchangeView.RefreshHasLabel(self)
	for i,oItemBox in ipairs(self.m_ItemGrid:GetChildList()) do
		oItemBox.m_HasLabel:SetText(string.format("拥有数量:%d", g_ItemCtrl:GetTargetItemCountBySid(oItemBox.m_SID)))
	end
end

return CTravelExchangeView