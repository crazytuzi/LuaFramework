local CItemPartnerChipExchangeView = class("CItemPartnerChipExchangeView", CViewBase)

function CItemPartnerChipExchangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemPartnerChipExchangeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CItemPartnerChipExchangeView.OnCreateView(self)
	self.m_ItemBox = {}
	self.m_ItemBox[1] = self:NewUI(1, CBox)
	self.m_ItemBox[2] = self:NewUI(2, CBox)
	self.m_ItemLabel = self:NewUI(3, CLabel)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_AmountBtn = self:NewUI(6, CButton)
	self.m_MaxAmountBtn = self:NewUI(7, CButton)
	self.m_DelBtn = self:NewUI(8, CButton)
	self.m_ScrollView = self:NewUI(9, CScrollView)
	self.m_Grid = self:NewUI(10, CGrid)
	self.m_CloneBox = self:NewUI(11, CBox)
	self.m_EmptyBox = self:NewUI(12, CBox)
	self.m_CoinLabel = self:NewUI(13, CLabel)
	self.m_ItemID = nil
	self.m_SelectIdx = nil
	self.m_BoxList = {}
	self.m_ShowCnt = 0
	self:InitContent()	
end

function CItemPartnerChipExchangeView.InitContent(self)
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAdd"))
	self.m_MaxAmountBtn:AddUIEvent("click", callback(self, "OnMaxAmount"))
	self.m_AmountBtn:AddUIEvent("click", callback(self, "OnInput"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_CurAmount = 0
	self.m_MaxAmount = 0
	self.m_ExchangeCoin = 0
	self.m_CloneBox:SetActive(false)
	self.m_ItemLabel:SetText("")
	self.m_AmountBtn:SetText(self.m_CurAmount)
	self:RefreshChipGrid()
	self:InitItem()
	self:UpdateItem()
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CItemPartnerChipExchangeView.InitItem(self)
	self.m_ItemBox[1].m_AmountLabel = self.m_ItemBox[1]:NewUI(1, CLabel)
	self.m_ItemBox[1].m_NameLabel = self.m_ItemBox[1]:NewUI(2, CLabel)
	self.m_ItemBox[1].m_QualityBgSpr = self.m_ItemBox[1]:NewUI(3, CSprite)
	self.m_ItemBox[1].m_IconSpr = self.m_ItemBox[1]:NewUI(4, CButton)
	self.m_ItemBox[1].m_QualitySpr = self.m_ItemBox[1]:NewUI(5, CSprite)

	self.m_ItemBox[2].m_IconSpr = self.m_ItemBox[2]:NewUI(1, CButton)
	self.m_ItemBox[2].m_NameLabel = self.m_ItemBox[2]:NewUI(2, CLabel)
	self.m_ItemBox[2].m_AmountLabel = self.m_ItemBox[2]:NewUI(3, CLabel)	
end

function CItemPartnerChipExchangeView.OnCtrlEvent(self, oCtrl)
	self:RefreshChipGrid()
	self:UpdateItem()
end

function CItemPartnerChipExchangeView.RefreshChipGrid(self, select_chip)
	local d = data.partnerdata.DATA
	local exchangeData = data.partnerdata.ComposeCost
	self.m_Pool = {}
	for k, v in pairs(d) do
		if v.icon ~= 318 then
			local t = table.copy(v)
			t.m_Amount = g_ItemCtrl:GetTargetItemCountBySid(t.icon + 20000)
			local exchange = exchangeData[v.rare].exchange_chip
			if t.m_Amount >= exchangeData[v.rare].exchange_chip then
				t.m_CanExchange = 1
			else
				t.m_CanExchange = 0
			end

			local oPartner = g_PartnerCtrl:GetTargetPartnerByPartnerType(v.icon)
			if oPartner and oPartner:GetValue("star") >= CPartner.GetMaxStar() then
				table.insert(self.m_Pool, t)
			end
		end
	end

	table.sort(self.m_Pool, function (a, b)
		if a.m_CanExchange ~= b.m_CanExchange then
			return a.m_CanExchange > b.m_CanExchange
		else
			if a.rare ~= b.rare then				
				return a.rare > b.rare
			else
				if a.m_Amount ~= b.m_Amount then
					return a.m_Amount > b.m_Amount 
				else
					return a.icon < b.icon	
				end
			end
		end
	end)

	local showCnt = 0
	for i, v in ipairs(self.m_Pool) do		
		local oBox = self.m_BoxList[i]
		if not oBox then
			oBox = self.m_CloneBox:Clone()
			oBox.m_CntLabel = oBox:NewUI(1, CLabel)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			oBox.m_QualityBgSpr = oBox:NewUI(3, CSprite)
			oBox.m_ShapeSpr = oBox:NewUI(4, CSprite)
			oBox.m_QualitySpr = oBox:NewUI(5, CSprite)
			oBox:SetGroup(self.m_Grid:GetInstanceID())
			self.m_BoxList[i] = oBox
			self.m_Grid:AddChild(oBox)
		end		
		local cnt = g_ItemCtrl:GetTargetItemCountBySid(20000 + v.icon)
		if cnt > 0 then
			showCnt = showCnt + 1				
			oBox.m_Sid = v.icon
			oBox:SetActive(true)
			oBox:AddUIEvent("click", callback(self, "OnClickItem", i, v.icon, oBox))
			oBox.m_ShapeSpr:SpriteAvatarBig(v.icon)
			oBox.m_QualityBgSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(v.rare))
			oBox.m_QualitySpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(v.rare))	
			oBox.m_CntLabel:SetText(string.format("拥有:%d", cnt))
			oBox.m_SelectSpr:SetActive(self.m_ItemID == v.icon)	
			if select_chip == 20000 + v.icon then
				oBox.m_SelectSpr:SetAlpha(1)				
			end					
		else
			if oBox then
				oBox:SetActive(false)	
			end
			if select_chip == 20000 + v.icon then
				self.m_ItemID = nil
				self:UpdateItem()					
			end							
		end
	end
	self.m_Grid:Reposition()
	self.m_CoinLabel:SetActive(self.m_ExchangeCoin ~= 0)
	self.m_ScrollView:SetActive(showCnt > 0)
	self.m_EmptyBox:SetActive(showCnt == 0)
	self.m_ShowCnt = showCnt
end

function CItemPartnerChipExchangeView.UpdateItem(self)
	self.m_ItemBox[1].m_AmountLabel:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[1].m_NameLabel:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[1].m_QualityBgSpr:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[1].m_IconSpr:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[1].m_QualitySpr:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[2].m_IconSpr:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[2].m_NameLabel:SetActive(self.m_ItemID ~= nil)
	self.m_ItemBox[2].m_AmountLabel:SetActive(self.m_ItemID ~= nil)
	if self.m_ItemID then
		self:SetItem(self.m_ItemID)		
	end
end

function CItemPartnerChipExchangeView.SetItem(self, shape)
	self.m_CoinLabel:SetActive(false)
	local d = data.partnerdata.DATA[shape]
	if not d then
		return
	end
	local oItem = CItem.NewBySid(20000 + shape)
	
	local amount1 = g_ItemCtrl:GetTargetItemCountBySid(oItem:GetValue("sid"))
	self.m_ItemBox[1].m_AmountLabel:SetText(string.format("拥有数量:%d", amount1))
	self.m_ItemBox[1].m_NameLabel:SetText(oItem:GetValue("name"))
	self.m_ItemBox[1].m_QualityBgSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(d.rare))
	self.m_ItemBox[1].m_IconSpr:SpriteAvatarBig(oItem:GetValue("icon"))
	self.m_ItemBox[1].m_IconSpr:AddUIEvent("click", callback(self, "ShowMaterailTips", oItem:GetValue("sid")))
	self.m_ItemBox[1].m_QualitySpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(d.rare))

	local d2 = CItem.NewBySid(14002)
	self.m_ItemBox[2].m_NameLabel:SetText(d2:GetValue("name"))
	local amount2 = g_ItemCtrl:GetTargetItemCountBySid(d2:GetValue("id"))
	self.m_ItemBox[2].m_AmountLabel:SetText(string.format("拥有数量:%d", amount2))
	self.m_ItemBox[2].m_IconSpr:SpriteItemShape(d2:GetValue("icon"))	
	self.m_ItemBox[2].m_IconSpr:AddUIEvent("click", callback(self, "ShowMaterailTips", 14002))

	local exchangeData = data.partnerdata.ComposeCost
	local exchage_amount = 5
	self.m_ExchangeCoin = 0
	if exchangeData then
		exchage_amount = exchangeData[d.rare].exchange_chip
		self.m_ExchangeCoin = exchangeData[d.rare].exchange_coin
	end
	self.m_MaxAmount = math.floor(amount1 / exchage_amount)
	self.m_ItemLabel:SetText(string.format("%d转化%d", exchage_amount, 1))
	if amount1 >= exchage_amount then
		self.m_CurAmount = 1
	else
		self.m_CurAmount = 0
	end
	local cost = self.m_CurAmount * self.m_ExchangeCoin
	if cost > g_AttrCtrl.coin then
		self.m_CoinLabel:SetText(string.format("%d", cost))
	else
		self.m_CoinLabel:SetText(string.format("[4a3b1a]%d", cost))
	end
	self.m_CoinLabel:SetActive(cost ~= 0)
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CItemPartnerChipExchangeView.OnDel(self)
	self.m_CurAmount = math.max(0, self.m_CurAmount-1)
	self.m_AmountBtn:SetText(self.m_CurAmount)
	local cost = self.m_CurAmount * self.m_ExchangeCoin
	if cost > g_AttrCtrl.coin then
		self.m_CoinLabel:SetText(string.format("%d", cost))
	else
		self.m_CoinLabel:SetText(string.format("[4a3b1a]%d", cost))
	end
end

function CItemPartnerChipExchangeView.OnAdd(self)
	if self.m_CurAmount >= self.m_MaxAmount then
		g_NotifyCtrl:FloatMsg("已达到最大转化数量")
	else
		self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount+1)
	end	
	self.m_AmountBtn:SetText(self.m_CurAmount)
	local cost = self.m_CurAmount * self.m_ExchangeCoin
	if cost > g_AttrCtrl.coin then
		self.m_CoinLabel:SetText(string.format("%d", cost))
	else
		self.m_CoinLabel:SetText(string.format("[4a3b1a]%d", cost))
	end
end

function CItemPartnerChipExchangeView.OnMaxAmount(self)
	self.m_CurAmount = self.m_MaxAmount
	self.m_AmountBtn:SetText(self.m_CurAmount)
	local cost = self.m_CurAmount * self.m_ExchangeCoin
	if cost > g_AttrCtrl.coin then
		self.m_CoinLabel:SetText(string.format("%d", cost))
	else
		self.m_CoinLabel:SetText(string.format("[4a3b1a]%d", cost))
	end
end

function CItemPartnerChipExchangeView.OnConfirm(self)
	if not self.m_ItemID then
		g_NotifyCtrl:FloatMsg("请选择需要转化的伙伴碎片")

	elseif self.m_CurAmount > 0 then
		netpartner.C2GSExchangePartnerChip(20000 + self.m_ItemID ,self.m_CurAmount)
		
	else
		g_NotifyCtrl:FloatMsg("请输入需要转化的数量")
	end
end

function CItemPartnerChipExchangeView.OnInput(self)
	local function syncCallback(self, count)
		self.m_CurAmount = count
		self.m_AmountBtn:SetText(self.m_CurAmount)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurAmount, min = 1, max = self.m_MaxAmount, syncfunc = syncCallback , obj = self},
	{widget=  self.m_AmountBtn, side = enum.UIAnchor.Side.Up ,offset = Vector2.New(0, 0)})
end

function CItemPartnerChipExchangeView.OnClickItem(self, idx, itemId, oBox)
	local oBox = self.m_BoxList[self.m_SelectIdx]
	if oBox then
		oBox.m_SelectSpr:SetActive(false)
	end
	oBox = self.m_BoxList[idx]
	if oBox then
		oBox.m_SelectSpr:SetActive(true)
	end	
	self.m_SelectIdx = idx
	self.m_ItemID = itemId
	self:UpdateItem()
end

function CItemPartnerChipExchangeView.DefaultSelect(self)
	if self.m_ShowCnt ~= 0 then
		local oBox = self.m_BoxList[1]
		table.print(self.m_BoxList)
		if oBox then
			self:OnClickItem(1, oBox.m_Sid, oBox)
			oBox.m_SelectSpr:SetActive(true)
			oBox.m_SelectSpr:SetAlpha(1)
		end
	end	
end

function CItemPartnerChipExchangeView.ShowMaterailTips(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
	{widget=  oBox, openView = self.m_ParentView}, nil, {showQuickBuy = true, ignoreCloseOwnerView = true})
end

return CItemPartnerChipExchangeView