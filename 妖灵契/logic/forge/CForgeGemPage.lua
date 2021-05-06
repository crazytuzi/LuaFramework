---------------------------------------------------------------
--打造界面的 宝石 子界面


---------------------------------------------------------------
local CForgeGemPage = class("CForgeGemPage", CPageBase)

CForgeGemPage.DefineGemBagCol = 3
CForgeGemPage.DefineGemBagDefaultCount = 12
CForgeGemPage.GemMaxLevel = 10

CForgeGemPage.PosItem = {
	[1] = {itemId = 16160, buyId = 18002},
	[2] = {itemId = 16161, buyId = 18102},
	[3] = {itemId = 16162, buyId = 18202},
	[4] = {itemId = 16163, buyId = 18302},
	[5] = {itemId = 16164, buyId = 18402},
	[6] = {itemId = 16165, buyId = 18502},
}

function CForgeGemPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_SelectEquipIndex = 1
	self.m_SelectGemItem = nil
	self.m_SelectGemIndex = nil
	self.m_EquipType = nil
	self.m_EquipGemList = {}
	self.m_EquipGemSlotCount = 0
	self.m_GemBagBtnList = {}
	self.m_GemBagItemList = {}
	self.m_MainAttrLabelList = {}
end

function CForgeGemPage.OnInitPage(self)
	self.m_AutoInsertGemBtn = self:NewUI(1, CButton)
	self.m_GemGrid = self:NewUI(7, CGrid)
	self.m_GemGridBox = self:NewUI(8, CBox)
	self.m_EquipGemGrid = self:NewUI(9, CGrid)
	self.m_GemScrollView = self:NewUI(10, CScrollView)
	self.m_CompositeBtn = self:NewUI(11, CButton)
	self.m_MainAttrGrid = self:NewUI(12, CGrid)
	self.m_MainAttrLabel = self:NewUI(13, CLabel)
	self.m_MainAttrBox = self:NewUI(15, CBox)
	self.m_EquipIconSpr = self:NewUI(16, CSprite)
	self.m_EquipItemLevelSpr = self:NewUI(17, CSprite)
	self.m_TipsBtn = self:NewUI(18, CButton)
	self.m_GemGridBox:SetActive(false)
	self.m_AutoInsertGemBtn:AddUIEvent("click", callback(self, "OnAutoInsertGem"))
	self.m_CompositeBtn:AddUIEvent("click", callback(self, "OnComposite"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_TipsBtn:AddHelpTipClick("forge_gem")
	self:InitEquipGrid()
	self:RefreshAll()
end

function CForgeGemPage.OnAutoInsertGem(self)
	g_ItemCtrl:CtrlC2GSInlayAllGem()
end

function CForgeGemPage.OnComposite(self)
	CForgeGemCompositeView:ShowView(function (oView)
		oView:SetContent(self.m_EquipType)
	end)
end

function CForgeGemPage.ShowPage(self, pos)
	self.m_EquipType = pos
	local tEquipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	self.m_EquipGemSlotCount =  g_ItemCtrl:GetGemSlotCountByLevel(g_AttrCtrl.grade) 

	if  self.m_IsInit then
		self:RefreshAll()
	end
	CPageBase.ShowPage(self)
end

function CForgeGemPage.UpdateEquip(self, pos)
	self.m_EquipType = pos
	local tEquipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	self.m_EquipGemSlotCount = g_ItemCtrl:GetGemSlotCountByLevel(g_AttrCtrl.grade) 
	self:RefreshAll()
end

function CForgeGemPage.InitEquipGrid(self)
	self.m_EquipGemList = {}
	self.m_EquipGemGrid:InitChild(function(obj,idx )		
		local oBox = CBox.New(obj)
		oBox.m_ItemSprite = oBox:NewUI(1, CSprite)
		oBox.m_SelectedSprite = oBox:NewUI(2, CSprite)
		oBox.m_ItemLockSprite = oBox:NewUI(3, CSprite)
		oBox.m_ItemBtn = oBox:NewUI(4, CButton)
		oBox.m_Label = oBox:NewUI(5, CLabel)
		oBox.m_AddBtn = oBox:NewUI(6, CButton)
		oBox.m_DelBtn = oBox:NewUI(7, CButton)
		oBox.m_RedDotSpr = oBox:NewUI(8, CSprite)				
		oBox.m_ItemBtn:SetGroup(self.m_EquipGemGrid:GetInstanceID())
		oBox.m_ItemBtn:AddUIEvent("click", callback(self, "OnSelcetEquipGem", idx, oBox))
		oBox.m_DelBtn:AddUIEvent("click", callback(self, "OnSelcetEquipGemDel", idx, oBox.m_DelBtn))
		oBox.m_ItemSid = nil
		oBox.m_ItemLevel = nil
		oBox.m_ItemIslock = true
		self.m_EquipGemList[idx] = oBox
		oBox.m_RedDotSpr:SetActive(false)
		oBox.m_SelectedSprite:SetActive(self.m_SelectEquipIndex == idx)
		oBox.m_DelBtn:SetActive(self.m_SelectEquipIndex == idx)
		return oBox
	end)
end

function CForgeGemPage.RefreshEquipGemGrid(self)
	local equipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType) 
	local tGem = equipData and equipData:GetEquipAttrGem() or {}
	for i = 1, 6 do
		local oBox = self.m_EquipGemList[i]
		oBox.m_AddBtn:SetActive(false)
		oBox.m_DelBtn:SetActive(false)
		oBox.m_ItemLockSprite:SetActive(false)
		oBox.m_Label:SetActive(false)
		oBox.m_RedDotSpr:SetActive(g_ItemCtrl:IsTargetGemSoltHaveRodDot(self.m_EquipType, i))
		if i <= self.m_EquipGemSlotCount then	
			oBox.m_ItemIslock = false	
			if equipData then
				local gemData = equipData:GetEquipPerGemDataByPos(i)
				if gemData ~= nil then
					local data = data.itemdata.GEM[gemData.sid]
					oBox.m_ItemSprite:SpriteItemShape(data.icon)
					oBox.m_ItemSid = data.id
					oBox.m_ItemLevel = data.level
					oBox.m_Label:SetActive(true)
					oBox.m_Label:SetText(string.format("%d级", data.level))
					oBox.m_DelBtn.m_Sid = data.id
					oBox.m_DelBtn:SetActive(self.m_SelectEquipIndex == i)
				else
					oBox.m_ItemSprite:SetSpriteName("")
					oBox.m_ItemSid = nil		
					oBox.m_ItemLevel = nil
					oBox.m_AddBtn:SetActive(true)
				end
			else
				oBox.m_AddBtn:SetActive(true)
			end
			oBox.m_SelectedSprite:SetActive(self.m_SelectEquipIndex == i)
		else
			oBox.m_ItemSprite:SetSpriteName("")
			oBox.m_ItemLockSprite:SetActive(true)
			oBox.m_Label:SetActive(true)
			oBox.m_Label:SetText(string.format("[ff5454]%d级解锁", g_ItemCtrl:GetGemSlotOpenLevelCountByPos(i)))
		end
	end
end

function CForgeGemPage.OnSelcetEquipGem( self, idx, tBox)
	if self.m_SelectEquipIndex ~= idx then
		if tBox.m_ItemIslock == true then
			g_NotifyCtrl:FloatMsg(string.format("%d级解锁", g_ItemCtrl:GetGemSlotOpenLevelCountByPos(idx)))
			return
		end
		local oBox = self.m_EquipGemGrid:GetChild(self.m_SelectEquipIndex)
		if oBox then
			oBox.m_DelBtn:SetActive(false)
			oBox.m_SelectedSprite:SetActive(false)
		end
		self.m_SelectEquipIndex = idx
		local oEquipGem = self.m_EquipGemList[idx]
		if tBox then
			tBox.m_SelectedSprite:SetActive(true)
			tBox.m_DelBtn:SetActive(oEquipGem ~= nil and oEquipGem.m_ItemSid ~= nil)
		end
	end
end

function CForgeGemPage.OnSelcetEquipGemDel( self, idx, oBox)
	if idx and oBox and oBox.m_Sid then
		g_ItemCtrl:CtrlC2GSUnInlayGem(self.m_EquipType, idx, oBox.m_Sid)
	end
end

function CForgeGemPage.RefreshAll(self)
	self.m_SelectGemItem = nil
	self.m_SelectGemIndex = nil
	self:RefreshEquipGemGrid()
	self:RefreshGemBagGrid()
	self:RefreshMainAttr()
end

function CForgeGemPage.ResetGemBagGrid(self, size)
	local length = size + 1
	for i = 1, length do
		if self.m_GemBagBtnList[i] == nil then
			local oBox = self.m_GemGridBox:Clone()
			oBox:SetActive(true)
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)		
			oBox.m_SelectedSprite = oBox:NewUI(2, CSprite)
			oBox.m_CountLabel = oBox:NewUI(3, CLabel)
			oBox.m_QulitySprite = oBox:NewUI(4, CSprite)
			oBox.m_DefaultShowBtn = oBox:NewUI(5, CButton)
			oBox.m_NameLabel = oBox:NewUI(6, CLabel)
			oBox.m_UseforLabel = oBox:NewUI(7, CLabel)
			oBox.m_IconSprite:AddUIEvent("click", callback(self, "OnGemItemBoxClick", oBox))	
			oBox.m_DefaultShowBtn:AddUIEvent("click", callback(self, "OnGemDefaultShowClick"))	
			oBox.m_Idx = i
			oBox.m_SelectedSprite:SetActive(false)
			self.m_GemGrid:AddChild(oBox)
			self.m_GemBagBtnList[i] = oBox
		else
			self.m_GemBagBtnList[i]:SetActive(true)
		end			
	end

	if length < #self.m_GemBagBtnList then
		for i = length + 1, #self.m_GemBagBtnList do
			self.m_GemBagBtnList[i]:SetActive(false)
		end
	end
	return length
end

function CForgeGemPage.RefreshGemBagGrid(self)
	self.m_GemBagItemList = g_ItemCtrl:GetGemByEquipPos(self.m_EquipType)
	local tGemBag = self.m_GemBagItemList
	--得到背包宝石，先排序
	table.sort( tGemBag, function(a, b)
		if a:GetValue("level") > b:GetValue("level") then
			return true
		elseif a:GetValue("level") == b:GetValue("level") then
			return a:GetValue("create_time") > b:GetValue("create_time")
		else
			return false
		end
	end)

	--重置宝石背包的格子
	local length = self:ResetGemBagGrid(#tGemBag)

	for i = 1, length do
		local oBox = self.m_GemBagBtnList[i]
		oBox.m_SelectedSprite:SetActive(false)
		if tGemBag[i] ~= nil then
			local data = tGemBag[i]
			self:SetGemBagItem(oBox, data)
			oBox.m_ItemSid = data:GetValue("sid")
			oBox.m_ItemId = data:GetValue("id")
			oBox.m_ItemCount = data:GetValue("amount")
		else
			self:SetGemBagItem(oBox, nil)
			oBox.m_ItemSid = nil
			oBox.m_ItemId = nil
			oBox.m_ItemCount = nil
		end
	end
	--重置ScrollView位置
	self.m_GemGrid:Reposition()
	self.m_GemScrollView:ResetPosition()
end

function CForgeGemPage.RefreshSpecificGemBagItem(self, oItem)
	for i = 1, #self.m_GemBagBtnList do
		local oBox = self.m_GemBagBtnList[i]
		if oBox.m_ItemId ~= nil and oBox.m_ItemId == oItem:GetValue("id") then
			self:SetGemBagItem(oBox, oItem)
			oBox.m_ItemCount = oItem:GetValue("amount")
			break
		end
	end
end

function CForgeGemPage.OnGemItemBoxClick( self, oBox)
	local oEquipGemBox = self.m_EquipGemGrid:GetChild(self.m_SelectEquipIndex)
	if oBox.m_ItemSid ~= nil and oEquipGemBox then 
		if oEquipGemBox.m_ItemSid ~= oBox.m_ItemSid then
			local serverId = g_ItemCtrl:GetItemSerberIdListBySid(oBox.m_ItemSid)
			if serverId then
				g_ItemCtrl:CtrlC2GSInlayGem(self.m_EquipType, self.m_SelectEquipIndex, serverId)			
			end			
		end
	end
end

function CForgeGemPage.OnCtrlItemEvent( self, oCtrl)
	if not self:GetActive() then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then	
		--self:RefreshGemBagGrid()	
		self:RefreshSpecificGemBagItem(oCtrl.m_EventData)
		self:RefreshMainAttr()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self.m_SelectGemItem = nil
		self.m_SelectGemIndex = nil		
		self:RefreshGemBagGrid()
		self:RefreshMainAttr()

	elseif oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		self:RefreshEquipGemGrid()
		self:RefreshMainAttr()
	end
end

function CForgeGemPage.SetGemBagItem(self, oBox, item)
	if item ~= nil then
		oBox.m_CountLabel:SetActive(true)	
		oBox.m_IconSprite:SetActive(true)
		oBox.m_QulitySprite:SetActive(true)
		oBox.m_NameLabel:SetActive(true)
		oBox.m_UseforLabel:SetActive(true)
		oBox.m_DefaultShowBtn:SetActive(false)
		oBox.m_CountLabel:SetText(tostring(item:GetValue("amount")))
		oBox.m_IconSprite:SpriteItemShape(item:GetValue("icon"))
		oBox.m_QulitySprite:SetItemQuality(item:GetValue("itemlevel"))
		oBox.m_NameLabel:SetText(item:GetValue("name"))
		oBox.m_UseforLabel:SetText(item:GetValue("introduction"))
	else
		oBox.m_CountLabel:SetActive(false)	
		oBox.m_IconSprite:SetActive(false)
		oBox.m_QulitySprite:SetActive(false)
		oBox.m_NameLabel:SetActive(false)
		oBox.m_UseforLabel:SetActive(false)	
		oBox.m_DefaultShowBtn:SetActive(true)	
	end	
end

function CForgeGemPage.ShowMaterailTips(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
	{widget =  oBox, openView = self.m_ParentView}, nil, {ignoreCloseOwnerView = true})
end

function CForgeGemPage.RefreshMainAttr(self)
	local tEquipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	if tEquipData then
		local t = tEquipData:GetEquipGemAttr()
		local str = nil
		if next(t) ~= nil then
			for k, v in pairs(t) do
				if str ~= nil then
					str = str .. "\n"
				end			
				str = string.format("[4a3b1a]属性加成:  [00896e]%s+%s", define.Attr.String[k], g_ItemCtrl:AttrStringConvert(k, v)) 
			end
		end
		if str then
			self.m_MainAttrBox:SetActive(true)
			self.m_MainAttrLabel:SetText(str)
		else
			self.m_MainAttrBox:SetActive(false)
		end
	end
end

function CForgeGemPage.RefreshEquip(self, equipPos)
	local tData = g_ItemCtrl:GetEquipedByPos(equipPos)
	local shape = tData:GetValue("icon") or 0
	local itemLevel = tData:GetValue("itemlevel")	
	self.m_EquipIconSpr:SpriteItemShape(shape)
	self.m_EquipItemLevelSpr:SetItemQuality(itemLevel)
end

function CForgeGemPage.OnGemDefaultShowClick(self)
	CItemTipsSimpleInfoView:ShowView(function (oView)
		oView:SetInitBox(CForgeGemPage.PosItem[self.m_EquipType].buyId, nil, {showQuickBuy = true})
		oView:ForceShowFindWayBox(true)
		local oData = DataTools.GetItemData(CForgeGemPage.PosItem[self.m_EquipType].itemId)
		oView.m_NameLabel:SetText(oData.name)
		oView.m_DesLabel:SetText(oData.introduction)
	end)
	-- g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(16021, {widget = self, openView = self.m_ParentView })
end

return CForgeGemPage
