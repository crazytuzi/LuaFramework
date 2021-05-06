---------------------------------------------------------------
--打造界面的 合成 子界面


---------------------------------------------------------------
local CForgeCompositePage = class("CForgeCompositePage", CPageBase)

CForgeCompositePage.Canposite = 
{
	Can = 1,
	NeedItem = 2,
	NeedCoin = 3,
}

function CForgeCompositePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_EquipPosSidList = {}
	self.m_EquipPosBoxList = {}	
	self.m_ItemSidList = {}
	self.m_ItemBoxList = {}
	self.m_LevelList = {}
	self.m_SelectLevel = 0
	self.m_EquipPos = define.Equip.Pos.Weapon
	self.m_SelectItemId = 0
	self.m_SelectItemIdx = 1
	self.m_MyEquipId = 0
	self.m_UpgradeItem = nil
	self.m_CompositeEquipSid = {}
	self.m_IsCanComposite = CForgeCompositePage.Canposite.Can
end

function CForgeCompositePage.OnInitPage(self)
	self.m_CompositeBtn = self:NewUI(1, CButton)
	self.m_CompositeGrid = self:NewUI(2, CGrid)
	self.m_PreviewBox = self:NewUI(3, CBox)
	self.m_CoinLabel = self:NewUI(4, CLabel)	
	self.m_EquipPosGrid = self:NewUI(6, CGrid)
	self.m_ItemGrid = self:NewUI(7, CGrid)
	self.m_ItemCloneBox = self:NewUI(8, CBox)
	self.m_PreviewBox.m_IconSpr = self.m_PreviewBox:NewUI(1, CSprite)
	self.m_PreviewBox.m_QualitySpr = self.m_PreviewBox:NewUI(2, CSprite)	
	self.m_PreviewBox.m_LevelLabel = self.m_PreviewBox:NewUI(3, CLabel)
	self.m_ItemCloneBoxMaterail = self:NewUI(9, CBox)
	self.m_TipsBtn = self:NewUI(10, CButton)
	self.m_MyEquipBox = self:NewUI(11, CBox)
	self.m_RandomTispBtn = self:NewUI(12, CButton)
	self.m_AttrLabel = {}
	self.m_AttrLabel[1] = self:NewUI(13, CLabel)
	self.m_AttrLabel[2] = self:NewUI(14, CLabel)
	self.m_AttrLabel[1].m_TipSrp = self:NewUI(15, CSprite)
	self.m_AttrLabel[2].m_TipSrp = self:NewUI(16, CSprite)

	self:InitContent()
end

function CForgeCompositePage.InitContent(self)
	self.m_ItemCloneBox:SetActive(false)
	self.m_ItemCloneBoxMaterail:SetActive(false)
	self.m_CompositeBtn:AddUIEvent("click", callback(self, "OnClickComposite"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_TipsBtn:AddHelpTipClick("forge_composite")
	self:InitData()
	self:RefreshGrid()
	self:RefreshPopupBox()
	self:InitCompositeGird()
	self:OnClickEquipBox(define.Equip.Pos.Weapon)
end

function CForgeCompositePage.RefreshGrid( self )
	for i = 1, #self.m_EquipPosSidList do
		local oBox = self.m_EquipPosBoxList[i]
		if not oBox then
			oBox = self:CreateCloneBox(self.m_ItemCloneBox)
			oBox.m_SelNameLabel = oBox:NewUI(5, CLabel)
			oBox.m_SelCountLabel = oBox:NewUI(6, CLabel)
			self.m_EquipPosGrid:AddChild(oBox)
			table.insert(self.m_EquipPosBoxList, oBox)
		end
		oBox:SetActive(true)
		local oItem = CItem.NewBySid(self.m_EquipPosSidList[i])	
		local count = g_ItemCtrl:GetTargetItemCountBySid(self.m_EquipPosSidList[i])
		--oBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("quality"))
		oBox.m_NameLabel:SetText(define.Equip.PosName[i])
		oBox.m_SelNameLabel:SetText(define.Equip.PosName[i])
		oBox.m_CountLabel:SetText("")
		oBox.m_SelCountLabel:SetText("")
		oBox:SetGroup(self.m_EquipPosGrid:GetInstanceID())	
		oBox:SetSelected(i == self.m_EquipPos)
		oBox:AddUIEvent("click", callback(self, "OnClickEquipBox", i))
	end

	if #self.m_EquipPosSidList < #self.m_EquipPosBoxList then
		for i = #self.m_EquipPosSidList + 1, #self.m_EquipPosBoxList do
			local oBox = self.m_EquipPosBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
	self:RefreshGridIcon()

	for i = 1, #self.m_ItemSidList do
		local oBox = self.m_ItemBoxList[i]
		if not oBox then
			oBox = self:CreateCloneBox(self.m_ItemCloneBoxMaterail)
			self.m_ItemGrid:AddChild(oBox)
			table.insert(self.m_ItemBoxList, oBox)
		end
		oBox:SetActive(true)
		local oItem = CItem.NewBySid(self.m_ItemSidList[i])	
		local count = g_ItemCtrl:GetTargetItemCountBySid(self.m_ItemSidList[i])
		oBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("quality"))
		oBox.m_NameLabel:SetText(oItem:GetValue("name"))
		oBox.m_CountLabel:SetText(string.format("%d", count))
		oBox:AddUIEvent("click", callback(self, "OnClickItemBox", self.m_ItemSidList[i], i, oBox))
		oBox:SetGroup(self.m_ItemGrid:GetInstanceID())	
		oBox:SetSelected(i == self.m_SelectItemIdx)
	end
	if #self.m_ItemSidList < #self.m_ItemBoxList then
		for i = #self.m_ItemSidList + 1, #self.m_ItemBoxList do
			local oBox = self.m_ItemBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end	

end

function CForgeCompositePage.RefreshGridIcon(self )
	for i = 1, 6 do		
		local oBox = self.m_EquipPosBoxList[i]
		local cpd = g_ItemCtrl:GetCompositeDataByPosAndLevel(i, self.m_SelectLevel)		
		if oBox and cpd then			
			local showSid = g_ItemCtrl:GetFitCompositeSidFromSidList(cpd.compose_item) 
			local oItem = CItem.NewBySid(showSid)
			if oItem then				
				oBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
			end
		end
	end
end

function CForgeCompositePage.OnClickEquipBox(self, idx)
	local oBox = self.m_EquipPosBoxList[idx]
	if oBox then
		oBox:SetSelected(true)
	end
	self.m_EquipPos = idx 
	self.m_RandomTispBtn:AddHelpTipClick(string.format("forge_composite_random_%d", idx))
	self:RefreshCompositeBox()
end

function CForgeCompositePage.OnClickItemBox(self, sid, idx, oBox)
	if oBox then
		oBox:SetSelected(true)
	end	
	self.m_SelectItemId = sid
	self.m_SelectItemIdx = idx
	self.m_UpgradeItem = nil
	self:RefreshCompositeBox()
end

function CForgeCompositePage.CreateCloneBox(self, oClone)
	local oBox = oClone:Clone()
	oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_NameLabel = oBox:NewUI(3, CLabel)
	oBox.m_CountLabel = oBox:NewUI(4, CLabel)
	return oBox
end

function CForgeCompositePage.GetCanCompositeLevel(self)
	local level = self.m_LevelList[#self.m_LevelList]
	local idx = #self.m_LevelList
	return level, idx
end

function CForgeCompositePage.RefreshPopupBox(self)
	local idx = 0
	self.m_SelectLevel, idx = self:GetCanCompositeLevel()
	self.m_LevelPopupBox = self:NewUI(5, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, idx, true)	
	self.m_LevelPopupBox:ShowAniConfig()
	for i = 1, #self.m_LevelList do
		self.m_LevelPopupBox:AddSubMenu(string.format("%d级", self.m_LevelList[i]), nil, nil, true)
	end
	self.m_LevelPopupBox:SetPopupShowAni(true)
	self.m_LevelPopupBox:SetCallback(callback(self, "OnSelectLevel"))
end

function CForgeCompositePage.InitCompositeGird(self)
	self.m_CompositeGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_IconSpr = oBox:NewUI(1, CSprite)
		oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
		oBox.m_NameLabel = oBox:NewUI(3, CLabel)
		oBox.m_CountLabel = oBox:NewUI(4, CLabel)
		return oBox
	end)

	local oBox = self.m_MyEquipBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_CountLabel = oBox:NewUI(3, CLabel)
	oBox.m_AddTipsBtn = oBox:NewUI(4, CButton)	
	oBox.m_AddTipsBtn:AddUIEvent("click", callback(self, "ShowDefaultAddTips"))
end

function CForgeCompositePage.OnSelectLevel(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local idx = self.m_LevelPopupBox:GetSelectedIndex()
	oBox:SetMainMenu(subMenu.m_Label:GetText())
	self.m_SelectLevel = self.m_LevelList[idx]
	self.m_UpgradeItem = nil
	self:RefreshGridIcon()
	self:RefreshCompositeBox()
end

function CForgeCompositePage.RefreshCompositeBox(self)
	local compositedata = g_ItemCtrl:GetCompositeDataByPosAndLevel(self.m_EquipPos, self.m_SelectLevel)
	if not compositedata then
		return
	end
	local t = g_ItemCtrl:GetCompositeUpgradeBySid(self.m_EquipPos, compositedata.upgrade_weapon)
	if #t > 0 then
		self.m_UpgradeItem = t[1]
	else
		self.m_UpgradeItem = nil
	end
	--刷新低级材料装备
	self:RefreshMyEuqip(self.m_UpgradeItem)
	local item_list = {}
	local cost = 0
	if self.m_UpgradeItem then
		self.m_MyEquipId = self.m_UpgradeItem:GetValue("id")
		item_list = compositedata.upgrade_material
		cost = compositedata.upgrade_coin		
	else
		item_list = compositedata.sid_item_list
		cost = compositedata.cost
		self.m_MyEquipId = 0
	end
	self.m_IsCanComposite = CForgeCompositePage.Canposite.Can	
	for i,v in ipairs(item_list) do
		local oBox = self.m_CompositeGrid:GetChild(i)
		if oBox then
			local oItem = CItem.NewBySid(v.sid)
			local count = g_ItemCtrl:GetTargetItemCountBySid(v.sid)
			oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
			oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("quality"))
			oBox.m_NameLabel:SetText(oItem:GetValue("name"))
			local amount = v.amount
			if count >= amount then
				oBox.m_CountLabel:SetText(string.format("[4a3b1a]%d/%d", count, amount))
			else
				self.m_IsCanComposite = CForgeCompositePage.Canposite.NeedItem
				oBox.m_CountLabel:SetText(string.format("[dd380c]%d/%d", count, amount))
			end
			oBox:AddUIEvent("click", callback(self, "OnClickTipsBox", v.sid, oBox))
		end
	end

	if cost > g_AttrCtrl.coin then
		self.m_IsCanComposite = CForgeCompositePage.Canposite.NeedCoin
		self.m_CoinLabel:SetText(string.format("%d", cost))
	else
		self.m_CoinLabel:SetText(string.format("[4a3b1a]%d", cost))
	end

	local showSid = g_ItemCtrl:GetFitCompositeSidFromSidList(compositedata.compose_item)
	local tItem = CItem.NewBySid(showSid)
	if tItem then
		self.m_PreviewBox.m_IconSpr:SpriteItemShape(tItem:GetValue("icon"))
		self.m_PreviewBox.m_QualitySpr:SetItemQuality(tItem:GetValue("quality"))
		self.m_PreviewBox.m_LevelLabel:SetText(string.format("Lv.%d", tItem:GetValue("level")))
		--self.m_PreviewBox:AddUIEvent("click", callback(self, "OnClickPreBox", showSid))
	end

	--获取装备的波动属性
	local t = {}
	self.m_AttrLabel[1]:SetActive(false)
	self.m_AttrLabel[2]:SetActive(false)
	local sidItem = data.itemdata.EQUIPSTONE[showSid]
	if sidItem then
		local min, max = g_ItemCtrl:GetEquipWaveRange()
		min = min / 100
		max = max / 100		
		for k,v in pairs (sidItem) do
			if define.Attr.String[k] ~= nil and type(v) == "number" and v ~= 0 then
				t[k] = v
			end
		end
		t = g_ItemCtrl:SortAttr(t)		
		for k,v in pairs (t) do
			if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
				local sKey = define.Attr.String[v.key] or v.key
				local str = string.format("%s+%s~%s", sKey, g_ItemCtrl:AttrStringConvert(v.key, v.value * min) , g_ItemCtrl:AttrStringConvert(v.key, v.value * max))
				self.m_AttrLabel[k]:SetActive(true)
				self.m_AttrLabel[k]:SetText(str)
				self.m_AttrLabel[k].m_TipSrp:ReActive()
			end
		end		
	end
end

function CForgeCompositePage.OnClickPreBox(self, sid)
	CItemTipsAttrEquipChangeView:ShowView(function (oView)
		local tItem = CItem.NewBySid(sid)
		oView:SetData(tItem, nil, CItemTipsAttrEquipChangeView.enum.Composite, true)
	end)	
end

function CForgeCompositePage.OnClickComposite(self)
	if self.m_IsCanComposite == CForgeCompositePage.Canposite.Can then		
		g_ItemCtrl:SetShowAttrChangeFlag(true)
		if self.m_MyEquipId ~= 0 then
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSUpgradeEquip"]) then
				netitem.C2GSUpgradeEquip(self.m_EquipPos, self.m_SelectLevel, self.m_MyEquipId)
			end
		else
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSComposeEquip"]) then
				netitem.C2GSComposeEquip(self.m_EquipPos, self.m_SelectLevel)
			end
		end		
	else
		if self.m_IsCanComposite == CForgeCompositePage.Canposite.NeedCoin then
			g_NpcShopCtrl:ShowGold2CoinView()
			g_NotifyCtrl:FloatMsg("金币不足")	
		else
			g_NotifyCtrl:FloatMsg("材料不足")	
		end		
	end
end

function CForgeCompositePage.InitData(self)
	local function StringToSidList(str)
		local t = {}
		local list = string.split(str, ",")
		for i = 1, #list do
			table.insert(t, tonumber(list[i]))
		end
		return t
	end
	self.m_EquipPosSidList = StringToSidList(data.forgedata.COMPOSITE_DEFINE.compose_equip_stone.value)
	self.m_ItemSidList = StringToSidList(data.forgedata.COMPOSITE_DEFINE.exchange_item_list.value)
	self.m_LevelList = g_ItemCtrl:GetCompositeLevelPool()
	self.m_SelectItemId = self.m_ItemSidList[1]
	self.m_SelectLevel = self.m_LevelList[#self.m_LevelList]
end

function CForgeCompositePage.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.ForgeCompositeSuccess or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshEquip then	
		self:RefreshGrid()
		self:RefreshCompositeBox()		
	end
end

function CForgeCompositePage.OnClickTipsBox(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget = oBox, openView = self.m_ParentView}, nil, {showQuickBuy = true, ignoreCloseOwnerView = true})
end

function CForgeCompositePage.SetEquipPosAndItemIdx(self, pos , idx)
	self.m_EquipPos = pos or define.Equip.Pos.Weapon
	self.m_SelectItemIdx = idx or 1
	self.m_SelectItemId = self.m_ItemSidList[self.m_SelectItemIdx]
	self.m_UpgradeItem = nil
	self:RefreshGrid()
	self:RefreshCompositeBox()	
end

function CForgeCompositePage.RefreshMyEuqip(self, upgradeItem)
	if self.m_SelectLevel == self.m_LevelList[1] then
		self.m_MyEquipBox:SetActive(false)
	else
		self.m_MyEquipBox:SetActive(true)
		self.m_MyEquipBox.m_AddTipsBtn:SetActive(true)
		self.m_MyEquipBox.m_IconSpr:SetActive(false)
		if upgradeItem then
			self.m_MyEquipBox.m_AddTipsBtn:SetActive(false)
			self.m_MyEquipBox.m_IconSpr:SetActive(true)
			self.m_MyEquipBox.m_IconSpr:SpriteItemShape(upgradeItem:GetValue("icon"))
			self.m_MyEquipBox.m_IconSpr:AddUIEvent("click", callback(self, "ShowEquipSelect"))
			--self.m_MyEquipBox.m_IconSpr:AddUIEvent("click", callback(self, "OnClickMyEquip", upgradeItem:GetValue("id")))
		end	
	end
end

function CForgeCompositePage.ShowEquipSelect(self)
	CForgeCompositeSelectView:ShowView(function (oView)
		oView:SetData(self.m_EquipPos, self.m_SelectLevel)
	end)
end

function CForgeCompositePage.SelectUpgradeItem(self, oItem)
	self.m_UpgradeItem = oItem
	self:RefreshMyEuqip(oItem)
end

function CForgeCompositePage.OnClickMyEquip(self, id)
	local oItem = g_ItemCtrl:GetBagItemById(id)
	if oItem then
		if oItem:IsEquip() then
			g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem, {isLink = true,})
		else
			g_WindowTipCtrl:SetWindowItemTipsSellItemInfo(oItem)
		end
	end
end

function CForgeCompositePage.ShowDefaultAddTips(self)
	g_NotifyCtrl:FloatMsg("没有找到合适的装备")
end

return CForgeCompositePage