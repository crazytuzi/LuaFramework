local CItemTipsPropComposeView = class("CItemTipsPropComposeView", CViewBase)

function CItemTipsPropComposeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsPropComposeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CItemTipsPropComposeView.OnCreateView(self)
	self.m_ItemBox = {}
	self.m_ItemBox[1] = self:NewUI(2, CBox)
	self.m_ItemBox[2] = self:NewUI(3, CBox)

	self.m_ItemLabel = self:NewUI(4, CLabel)
	self.m_ComposeBtn = self:NewUI(6, CButton)

	self.m_AddBtn = self:NewUI(7, CButton)
	self.m_AmountBtn = self:NewUI(8, CButton)
	self.m_MaxAmountBtn = self:NewUI(9, CButton)
	self.m_DelBtn = self:NewUI(10, CButton)
	self:InitContent()	
end

function CItemTipsPropComposeView.InitContent(self)
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

function CItemTipsPropComposeView.InitItem(self)
	for i = 1, 2 do
		local box = self.m_ItemBox[i]
		box.m_Icon = box:NewUI(1, CSprite)
		box.m_NameLabel = box:NewUI(2, CLabel)
		box.m_AmountBtn = box:NewUI(3, CLabel)
		box.m_RareSpr = box:NewUI(4, CSprite)
	end
end

function CItemTipsPropComposeView.OnCtrlEvent(self, oCtrl)
	self:UpdateItem()
end

function CItemTipsPropComposeView.UpdateItem(self)
	if self.m_ItemID then
		self:SetItem(self.m_ItemID)
	end
end

function CItemTipsPropComposeView.SetItem(self, itemid)
	self.m_ItemID = itemid
	local d1 = CItem.NewBySid(itemid)
	if not d1 then
		return
	end
	local compose_item = d1:GetValue("compose_item")
	if not compose_item or not next(compose_item) then
		return	
	end

	self.m_ItemBox[1].m_NameLabel:SetText(d1:GetValue("name"))
	local amount1 = g_ItemCtrl:GetTargetItemCountBySid(d1:GetValue("id"))
	self.m_ItemBox[1].m_AmountBtn:SetText(string.format("拥有数量:%d", amount1))
	self.m_ItemBox[1].m_Icon:SpriteItemShape(d1:GetValue("icon"))
	self.m_ItemBox[1].m_RareSpr:SetItemQuality(d1:GetValue("quality"))

	local d2 = CItem.NewBySid(compose_item[1].sid)
	self.m_ItemBox[2].m_NameLabel:SetText(d2:GetValue("name"))
	local amount2 = g_ItemCtrl:GetTargetItemCountBySid(d2:GetValue("id"))
	self.m_ItemBox[2].m_AmountBtn:SetText(string.format("拥有数量:%d", amount2))
	self.m_ItemBox[2].m_Icon:SpriteItemShape(d2:GetValue("icon"))
	self.m_ItemBox[2].m_RareSpr:SetItemQuality(d2:GetValue("quality"))

	local compose_amount = d1:GetValue("compose_amount")
	self.m_MaxAmount = math.floor(amount1 / compose_amount)
	self.m_ItemLabel:SetText(string.format("%d合%d", compose_amount, compose_item[1].amount))
	if amount1 >= compose_amount then
		self.m_CurAmount = 1
	end
	self.m_AmountBtn:SetText(self.m_CurAmount)
end


function CItemTipsPropComposeView.OnDel(self)
	self.m_CurAmount = math.max(0, self.m_CurAmount-1)
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CItemTipsPropComposeView.OnAdd(self)
	if self.m_CurAmount >= self.m_MaxAmount then
		g_NotifyCtrl:FloatMsg("输入的数量超过最大数！")
	else
		self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount+1)
	end	
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CItemTipsPropComposeView.OnMaxAmount(self)
	self.m_CurAmount = self.m_MaxAmount
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CItemTipsPropComposeView.OnConfirm(self)
	if self.m_CurAmount > 0 then
		netitem.C2GSComposeItem(self.m_ItemID, self.m_CurAmount)
	else
		g_NotifyCtrl:FloatMsg("合成数量不足")
	end
end

function CItemTipsPropComposeView.OnInput(self)
	local function syncCallback(self, count)
		self.m_CurAmount = count
		self.m_AmountBtn:SetText(self.m_CurAmount)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurAmount, min = 1, max = self.m_MaxAmount, syncfunc = syncCallback , obj = self},
	{widget=  self.m_AmountBtn, side = enum.UIAnchor.Side.Up ,offset = Vector2.New(0, 0)})
end

return CItemTipsPropComposeView