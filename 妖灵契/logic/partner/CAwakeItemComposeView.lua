local CAwakeItemComposeView = class("CAwakeItemComposeView", CViewBase)

function CAwakeItemComposeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/AwakeItemComposeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CAwakeItemComposeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemBox = {}
	self.m_ItemBox[1] = self:NewUI(2, CBox)
	self.m_ItemBox[2] = self:NewUI(3, CBox)

	self.m_ItemLabel = self:NewUI(4, CLabel)
	self.m_GoldLabel = self:NewUI(5, CLabel)
	self.m_ComposeBtn = self:NewUI(6, CButton)

	self.m_AddBtn = self:NewUI(7, CButton)
	self.m_AmountBtn = self:NewUI(8, CButton)
	self.m_MaxAmountBtn = self:NewUI(9, CButton)
	self.m_DelBtn = self:NewUI(10, CButton)
	self:InitContent()
	
end

function CAwakeItemComposeView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAdd"))
	self.m_MaxAmountBtn:AddUIEvent("click", callback(self, "OnMaxAmount"))
	self.m_AmountBtn:AddUIEvent("click", callback(self, "OnInput"))
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_CurAmount = 0
	self.m_MaxAmount = 0
	self:InitItem()
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CAwakeItemComposeView.InitItem(self)
	for i = 1, 2 do
		local box = self.m_ItemBox[i]
		box.m_Icon = box:NewUI(1, CSprite)
		box.m_NameLabel = box:NewUI(2, CLabel)
		box.m_AmountBtn = box:NewUI(3, CLabel)
		box.m_RareSpr = box:NewUI(4, CSprite)
	end
end

function CAwakeItemComposeView.OnCtrlEvent(self, oCtrl)
	self:UpdateItem()
end

function CAwakeItemComposeView.UpdateItem(self)
	if self.m_ItemID then
		self:SetItem(self.m_ItemID)
	end
end

function CAwakeItemComposeView.SetItem(self, itemid)
	self.m_ItemID = itemid
	local awakedata = data.partnerdata.AWAKEITEM
	local needdata = self:GetAwakeItemData(itemid)
	if not needdata then
		return
	end
	local itemid2 = needdata[1]["sid"]
	local needamount = needdata[1]["amount"]
	
	local d1 = awakedata[itemid2]
	self.m_ItemBox[1].m_NameLabel:SetText(d1["name"])
	local amount1 = g_ItemCtrl:GetTargetItemCountBySid(d1["id"])
	self.m_ItemBox[1].m_AmountBtn:SetText(string.format("拥有数量:%d", amount1))
	self.m_ItemBox[1].m_Icon:SpriteItemShape(d1["icon"])
	self.m_ItemBox[1].m_RareSpr:SetItemQuality(d1["quality"])

	local d2 = awakedata[itemid]
	self.m_ItemBox[2].m_NameLabel:SetText(d2["name"])
	local amount2 = g_ItemCtrl:GetTargetItemCountBySid(d2["id"])
	self.m_ItemBox[2].m_AmountBtn:SetText(string.format("拥有数量:%d", amount2))
	self.m_ItemBox[2].m_Icon:SpriteItemShape(d2["icon"])
	self.m_ItemBox[2].m_RareSpr:SetItemQuality(d2["quality"])

	self.m_MaxAmount = math.floor(amount1 / needamount)
	self.m_ItemLabel:SetText(string.format("%d合1", needamount))
	self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount)
	self.m_AmountBtn:SetText(self.m_CurAmount)
	self.m_Cost = d2["coin_cost"]
	self:UpdateCost()
end

function CAwakeItemComposeView.GetAwakeItemData(self, itemid)
	local awakedata = data.partnerdata.AWAKEITEM
	if awakedata[itemid] then
		return awakedata[itemid]["compose_item"]
	else
		return {}
	end
end

function CAwakeItemComposeView.UpdateCost(self)
	local cost = self.m_CurAmount*self.m_Cost
	if g_AttrCtrl.coin < cost then
		self.m_GoldLabel:SetText(string.format("#R#w1%d", cost))
	else
		self.m_GoldLabel:SetText(string.format("#w1%d", cost))
	end
end

function CAwakeItemComposeView.OnDel(self)
	self.m_CurAmount = math.max(0, self.m_CurAmount-1)
	self.m_AmountBtn:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CAwakeItemComposeView.OnAdd(self)
	self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount+1)
	self.m_AmountBtn:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CAwakeItemComposeView.OnMaxAmount(self)
	self.m_CurAmount = self.m_MaxAmount
	self.m_AmountBtn:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CAwakeItemComposeView.OnConfirm(self)
	if self.m_CurAmount > 0 then
		netpartner.C2GSComposeAwakeItem(self.m_ItemID ,self.m_CurAmount)
	else
		g_NotifyCtrl:FloatMsg("数量不足")
	end
end

function CAwakeItemComposeView.OnInput(self)
	local function syncCallback(self, count)
		self.m_CurAmount = count
		self.m_AmountBtn:SetText(self.m_CurAmount)
		self:UpdateCost()
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurAmount, min = 1, max = self.m_MaxAmount, syncfunc = syncCallback , obj = self},
	{widget=  self.m_AmountBtn, side = enum.UIAnchor.Side.Up ,offset = Vector2.New(0, 0)})
end

return CAwakeItemComposeView