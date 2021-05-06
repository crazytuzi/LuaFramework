---------------------------------------------------------------
--打造界面的 转换 子界面


---------------------------------------------------------------
local CForgeExchangePage = class("CForgeExchangePage", CPageBase)

function CForgeExchangePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

CForgeExchangePage.Exchange = 
{
	Can = 1,
	NeedItem = 2,
	NeedCoin = 3,
}

function CForgeExchangePage.OnInitPage(self)
	self.m_ExchangeBtn = self:NewUI(1, CButton)
	self.m_TipsBtn = self:NewUI(2, CButton)
	self.m_SelecEquipBox = self:NewUI(3, CBox)
	self.m_SelecEquipBox.m_IconSpr = self.m_SelecEquipBox:NewUI(1, CSprite)
	self.m_SelecEquipBox.m_LevelLabel = self.m_SelecEquipBox:NewUI(2, CLabel)
	self.m_MaterialBox = self:NewUI(4, CBox)
	self.m_MaterialBox.m_IconSpr = self.m_MaterialBox:NewUI(1, CSprite)
	self.m_MaterialBox.m_CountLabel = self.m_MaterialBox:NewUI(2, CLabel)
	self.m_EquipGrid = self:NewUI(5, CGrid)
	self.m_EquipCloneBox = self:NewUI(6, CBox)
	self.m_ExchangeGoldWidget = self:NewUI(7, CBox)
	self.m_ExchangeGoldLabel = self:NewUI(8, CLabel)
	self.m_NoneTipsLabel = self:NewUI(9, CLabel)

	self.m_EquipList = {}
	self.m_EquipBoxList = {}
	self.m_SuccessIds = {}
	self.m_SelIdx = 0
	self.m_SelId = 0
	self:InitContent()
	self.m_IsCanExchange = CForgeExchangePage.Exchange.Can
end

function CForgeExchangePage.InitContent(self)
	self.m_EquipCloneBox:SetActive(false)
	self.m_ExchangeGoldWidget:SetActive(false)
	self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnClickExchange"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_TipsBtn:AddHelpTipClick("forge_exchange")

	self:RefreshAll()
end

function CForgeExchangePage.RefreshAll(self)
	self:RefreshSelectItem()
	self:RefreshEquipList()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
end

function CForgeExchangePage.RefreshEquipList(self)
	self.m_EquipList = g_ItemCtrl:GetCanResolveEquip(true)
	for i = 1, #self.m_EquipList do
		local oBox = self.m_EquipBoxList[i]
		if not oBox then
			oBox = self.m_EquipCloneBox:Clone()
			oBox.m_IconSpr = oBox:NewUI(1, CSprite)
			oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
			oBox.m_NameLabel = oBox:NewUI(3, CLabel)
			oBox.m_LvLabel = oBox:NewUI(4, CLabel)
			oBox.m_SelNameLabel = oBox:NewUI(5, CLabel)
			oBox.m_SelLvLabel = oBox:NewUI(6, CLabel)			
			oBox.m_SelectSpr = oBox:NewUI(7, CSprite)
			oBox.m_EquipedSpr = oBox:NewUI(8, CSprite)
			self.m_EquipGrid:AddChild(oBox)
			table.insert(self.m_EquipBoxList, oBox)
		end
		oBox:SetActive(true)
		local oItem = self.m_EquipList[i]
		oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("itemlevel"))
		oBox.m_NameLabel:SetText(oItem:GetValue("name"))
		local level = 0
		if oItem:IsEquiped() then
			level = oItem:GetValue("equip_level")
			oBox.m_EquipedSpr:SetActive(true)
		else
			level = oItem:GetValue("level")
			oBox.m_EquipedSpr:SetActive(false)
		end
		oBox.m_LvLabel:SetText(string.format("Lv.%d", level))
		oBox.m_SelNameLabel:SetText(oItem:GetValue("name"))
		oBox.m_SelLvLabel:SetText(string.format("Lv.%d", level))		
		oBox.m_SelectSpr:SetActive(self.m_SelIdx == i)
		oBox:AddUIEvent("click", callback(self, "OnClickEquipBox", i))
		oBox:AddUIEvent("longpress", callback(self, "OnLongPressEquipBox", i))
		if self.m_SuccessIds[oItem:GetValue("id")] then
			oBox:AddEffect("RedDot")			
		else
			oBox:DelEffect("RedDot")
		end		
	end
	if #self.m_EquipList < #self.m_EquipBoxList then
		for i = #self.m_EquipList + 1, #self.m_EquipBoxList do
			local oBox = self.m_EquipBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
	self.m_NoneTipsLabel:SetActive(#self.m_EquipList == 0)
end

function CForgeExchangePage.RefreshSelectItem(self)
	if self.m_SelIdx == 0 then
		self.m_SelecEquipBox:SetActive(false)
		self.m_MaterialBox:SetActive(false)
	else
		self.m_IsCanExchange = CForgeExchangePage.Exchange.Can
		self.m_SelecEquipBox:SetActive(true)
		self.m_MaterialBox:SetActive(true)
		local oItem = self.m_EquipList[self.m_SelIdx]
		if oItem then
			self.m_SelecEquipBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
			local exchangedata = data.forgedata.COMPOSITE_EXCHANGE[oItem:GetValue("stone_sid")]
			local needItem = exchangedata.cost_item[1]
			local oMat = CItem.NewBySid(needItem.sid)
			if oMat then
				self.m_MaterialBox.m_IconSpr:SpriteItemShape(oMat:GetValue("icon"))
				self.m_MaterialBox:AddUIEvent("click", callback(self, "OnClickItemTips", oMat:GetValue("stone_sid")))
				local myCnt = g_ItemCtrl:GetTargetItemCountBySid(exchangedata.cost_item[1].sid)
				local matCnt = needItem.amount
				if myCnt >= matCnt then
					self.m_MaterialBox.m_CountLabel:SetText(string.format("[4a3b1a]%d/%d", myCnt, matCnt))
				else
					self.m_IsCanExchange = CForgeExchangePage.Exchange.NeedItem
					self.m_MaterialBox.m_CountLabel:SetText(string.format("[dd380c]%d/%d", myCnt, matCnt))
				end
				local cost = exchangedata.cost_coin				
				self.m_ExchangeGoldWidget:SetActive(cost ~= 0)
				if g_AttrCtrl.coin >= cost then
					self.m_ExchangeGoldLabel:SetText(string.format("[4a3b1a]%d", cost))
				else
					self.m_IsCanExchange = CForgeExchangePage.Exchange.NeedCoin
					self.m_ExchangeGoldLabel:SetText(string.format("[dd380c]%d", cost))
				end
			end
		end		
	end
end

function CForgeExchangePage.OnClickEquipBox(self, idx)
	local oItem = self.m_EquipList[idx]
	if oItem then
		local id = oItem:GetValue("id")
		local oBox = self.m_EquipBoxList[self.m_SelIdx]
		if oBox then
			oBox.m_SelectSpr:SetActive(false)
		end
		oBox = self.m_EquipBoxList[idx]
		if oBox then
			oBox.m_SelectSpr:SetActive(true)
		end		
		self.m_SelIdx = idx
		self.m_SelId = id
		if self.m_SuccessIds[id] then
			self.m_SuccessIds[id] = nil
		end
		self:RefreshSelectItem()
	end
end

function CForgeExchangePage.OnLongPressEquipBox(self, idx)
	local oItem = self.m_EquipList[idx]
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemSell(oItem,
		{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), showCenterMaskWidget = true}, nil , {ignoreCloseOwnerView = true})
	end
end

function CForgeExchangePage.OnClickExchange(self)
	if self.m_SelId == 0 then
		g_NotifyCtrl:FloatMsg("请选择装备")	
	else
		if self.m_IsCanExchange == CForgeExchangePage.Exchange.NeedItem then
			g_NotifyCtrl:FloatMsg("材料不足")	
		elseif self.m_IsCanExchange == CForgeExchangePage.Exchange.NeedCoin then
			g_NpcShopCtrl:ShowGold2CoinView()				
			g_NotifyCtrl:FloatMsg("金币不足")	
		else
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSExChangeEquip"]) then
				netitem.C2GSExChangeEquip(self.m_SelId)
			end			
		end
	end
end

function CForgeExchangePage.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.ForgeExchangeSuccess then		
		local id = oCtrl.m_EventData.id or 0
		if id ~= 0 then
			self.m_SuccessIds[id] = true
		end
		self.m_SelIdx = 0
		self.m_SelId = 0
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then				
		self:RefreshAll()
	end
end

function CForgeExchangePage.OnClickItemTips(self, sid, oBox)
	if sid and oBox then
		local oItem = CItem.NewBySid(sid)
		if oItem then
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget = oBox, openView = self.m_ParentView}, nil, {showQuickBuy = true, ignoreCloseOwnerView = true, quality = oItem:GetValue("quality")})
		end		
	end
end

function CForgeExchangePage.ShowPage(self)
	if self.m_IsInitPage then
		self.m_SuccessIds = {}
		self.m_SelIdx = 0
		self.m_SelId = 0		
		self:RefreshAll()
	else
		self.m_IsInitPage = true
	end
	CPageBase.ShowPage(self)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
end

return CForgeExchangePage