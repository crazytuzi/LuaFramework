local CItemBagBox = class("CItemBagBox", CBox)

CItemBagBox.TestToggle = 0 		--测试开关 1表示开，0表示关闭

CItemBagBox.EnumState = 
{
	None = 1,
	Bind = 2,
	Limit = 3,
	Invail = 4,
	CannotSell = 5,
}

function CItemBagBox.ctor(self, obj, index, parentView)
	self.m_Effect = false
	self.m_Red = false

	self.m_Item = nil
	self.m_ID = nil
	self.m_Name = nil
	self.m_SellCount = 0
	self.m_ItemIndex = nil
	self.m_ParentView = nil

	CBox.ctor(self, obj)

	--克隆模板，没有序号
	if index ~= nil	then
		self.m_ItemIndex = index
		self.m_ParentView = parentView 
	end

	 self.m_InfoWidget = self:NewUI(1, CWidget)
	 self.m_IconSprite = self:NewUI(2, CSprite)	 
	 self.m_QualitySprite = self:NewUI(3, CSprite)	  
	 self.m_NameLabel = self:NewUI(4, CLabel)
	 self.m_CountLabel = self:NewUI(5, CLabel)
	 self.m_SellInfoWidget = self:NewUI(6, CWidget)
	 self.m_SellCountLabel = self:NewUI(7, CLabel)
	 self.m_BingStateWidget = self:NewUI(8, CWidget)
	 self.m_LimitStateWidget = self:NewUI(9, CWidget)
	 self.m_InvailStateWidget = self:NewUI(10, CWidget)
	 self.m_CannotSellStateWidget = self:NewUI(11, CWidget)
	 self.m_ItemIdLabel = self:NewUI(12, CLabel)
	 self.m_ItemBgSprite = self:NewUI(13, CSprite)
	 self.m_SellSelectSprite = self:NewUI(14, CSprite)
	 self.m_ScoreCompareBox = self:NewUI(15, CBox)
	 self.m_ScoreUpSprite = self:NewUI(16, CSprite)
	 self.m_ScoreDownSprite = self:NewUI(17, CSprite)
	 self.m_LockBox = self:NewUI(18, CBox)
	 self.m_LevelLimitSpr = self:NewUI(19, CSprite)
	 self.m_PartnerBgSpr = self:NewUI(20, CSprite)
	 self.m_PartnerShapSpr = self:NewUI(21, CSprite)
	 self.m_PartnerQualitySpr = self:NewUI(22, CSprite)
	 self.m_CurSellSelectSpr = self:NewUI(23, CSprite)

	 self:AddUIEvent("click", callback(self, "OnItemBoxClick"))
	 self:SetClickSounPath(define.Audio.SoundPath.ClickItem)
	 self:AddUIEvent("longpress", callback(self, "OnItemBoxLongpress"))

	self:ResetStatus()
end

function CItemBagBox.RemoveItemFloat(self)
	g_ItemCtrl:RemoveItemEff(self.m_ID)
	g_ItemCtrl:RemoveItemRed(self.m_ID)
end

function CItemBagBox.OnItemBoxClick(self)	
	if self.m_Item then

		--在正常预览状态
		if g_ItemCtrl.m_RecordItembBagViewState == 1 then
			--如果是装备灵石，则打开装备更换
			if self.m_Item:GetValue("sub_type") == define.Item.ItemSubType.EquipStone then
				g_WindowTipCtrl:SetWindowItemTipsEquipItemChange(self.m_Item,
					{widget=  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), openView = self.m_ParentView})				
			else
				g_WindowTipCtrl:SetWindowItemTipsBaseItemInfo(self.m_Item,
					{widget=  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), openView = self.m_ParentView, hideMaskWidget = true })
			end

		--在出售状态
		elseif g_ItemCtrl.m_RecordItembBagViewState == 2 then

			--在出售时，点单物品会关闭预览界面
			local oView = CItemTipsBaseInfoView:GetView()
			if oView then
				oView:CloseView()
			end
			oView = CItemTipsEquipChangeView:GetView()
			if oView then
				oView:CloseView()
			end

			if self.m_Item:GetValue("sale_price") == 0 then
				g_NotifyCtrl:FloatMsg("该道具无法出售")
				return
			end
			if self.m_SellSelectSprite:GetActive() then
				self:SetSellCounttext(0)
				if self.m_ParentView then
					self.m_ParentView:OnValueChange("SelectSellItem", false, self.m_ItemIndex, nil, nil, self)
				end				
			else				
				if self.m_SellCount == 0 then
					self.m_SellCount = 1
				end							
				self:SetSellCounttext(self.m_SellCount)			
				if self.m_ParentView then					
					self.m_ParentView:OnValueChange("SelectSellItem", true, self.m_ItemIndex, self.m_SellCount, self.m_Item, self)
				end				
			end

		end
	end
end

function CItemBagBox.OnItemBoxLongpress(self,...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end 
	--在出售状态
	if g_ItemCtrl.m_RecordItembBagViewState == 2 then
		if self.m_Item:GetValue("sub_type") == define.Item.ItemSubType.EquipStone then
			g_WindowTipCtrl:SetWindowItemTipsEquipItemSell(self.m_Item,
			{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
		else		
			g_WindowTipCtrl:SetWindowItemTipsSellItemInfo(self.m_Item,
			{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), hideMaskWidget = true})
		end
	end
end

function CItemBagBox.SetBagItem(self, oItem)
	self.m_Item = oItem
	if oItem then
		self.m_ID = oItem:GetValue("id")
		self.m_Name = oItem:GetValue("name")
	end
	self:RefreshBox()
end

function CItemBagBox.ResetStatus(self)
	self.m_Item = nil
	self.m_ID = nil
	self.m_Name = nil
	self.m_SellCount = 0
	self:RefreshBox()
end

function CItemBagBox.RefreshBox(self)
	local showItem = self.m_Item ~= nil
	local isTouch = false
	self.m_CurSellSelectSpr:SetActive(false)
	self.m_ScoreCompareBox:SetActive(false)
	self.m_IconSprite:SetActive(showItem)
	if showItem then
		self.m_InfoWidget:SetActive(true)
		local shape = self.m_Item:GetValue("icon") or 0
		local count = self.m_Item:GetValue("amount") or 0
		local quality = self.m_Item:GetValue("itemlevel") or 0
		local name = self.m_Item:GetValue("name") or ""
		local isLock = self.m_Item:IsEuqipLock()
		local minGrade = self.m_Item:GetValue("min_grade") or 0
		local itemType = self.m_Item:GetValue("type")

		if itemType == define.Item.ItemType.PartnerChip then
			self.m_IconSprite:SetActive(false)
			self.m_PartnerBgSpr:SetActive(true)
			local rare = self.m_Item:GetValue("rare")			
			self.m_PartnerShapSpr:SpriteAvatarBig(shape)			
			self.m_PartnerBgSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
			self.m_PartnerQualitySpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))	
			self:SetItemQuality(rare+2)
		else
			self.m_IconSprite:SetActive(true)
			self.m_PartnerBgSpr:SetActive(false)
			self.m_IconSprite:SpriteItemShape(shape)
			if quality then
				self:SetItemQuality(quality)
			end			
		end

		self:SetCounttext(count)
		self.m_NameLabel:SetText(name)

		self:SetSellCounttext(0)
		self:UpdateItemState()
		self:UpdateItemScoreCompare()
		isTouch = true

		self.m_ItemIdLabel:SetActive(false)
		if CItemBagBox.TestToggle == 1 then
			self.m_ItemIdLabel:SetActive(true)
			self.m_ItemIdLabel:SetText(self.m_Item:GetValue("id"))
		end
		self.m_LockBox:SetActive(isLock)
		self.m_LevelLimitSpr:SetActive(minGrade > g_AttrCtrl.grade and (itemType == define.Item.ItemType.EquipStone))
	else
		self.m_InfoWidget:SetActive(false)
	end
	self:SetEnableTouch(isTouch)
end

function CItemBagBox.GetBagItem(self)
	return self.m_Item
end

function CItemBagBox.SetEnableTouch(self, isTouch)
	self:EnableTouch(isTouch)
end

function CItemBagBox.SetCounttext(self, count)
	local showCount = count > 1
	self.m_CountLabel:SetActive(showCount)
	if showCount then self.m_CountLabel:SetText(count) end
end

function CItemBagBox.SetSellCounttext(self, count)
	local cnt = self.m_Item:GetValue("amount") or 1
	local showSellCmount = count >= 1
	self.m_SellSelectSprite:SetActive(showSellCmount)
	self.m_SellCountLabel:SetActive(true)

	if self.m_Item:GetValue("type") == define.Item.ItemType.EquipStone then
		self.m_SellCountLabel:SetText("")
	else
		self.m_SellCountLabel:SetText(string.format("%d/%d", count, cnt))
	end
	self.m_SellCount = count
end

function CItemBagBox.SetSellWidgetActive(self, bActive)
	self.m_SellInfoWidget:SetActive(bActive)
	local count = self.m_Item:GetValue("amount") or 0
	if bActive then
		self.m_CountLabel:SetActive(false)
	else
		self:SetCounttext(count)	
	end
	
end

function CItemBagBox.SetItemQuality(self, quality)
	self.m_QualitySprite:SetBagNameBgQuality(quality)
end

function CItemBagBox.SetItemStateCanSell(self, isCanSell)
	if isCanSell then
		self.m_CannotSellStateWidget:SetActive(false)
	else
		self.m_CannotSellStateWidget:SetActive(true)
	end	
end

function CItemBagBox.UpdateItemState(self)
	self.m_InvailStateWidget:SetActive(false)	
	self.m_LimitStateWidget:SetActive(false)	
	self.m_BingStateWidget:SetActive(false)	
	if self.m_Item:IsInvaildItem() then
		self.m_InvailStateWidget:SetActive(true)
	elseif self.m_Item:IsLimitItem() then
		self.m_LimitStateWidget:SetActive(true)	
	elseif self.m_Item:IsBingdingItem() then
		self.m_BingStateWidget:SetActive(true)			
	end
end

function CItemBagBox.UpdateItemScoreCompare(self)
	if self.m_Item then
		if self.m_Item:GetValue("sub_type") == define.Item.ItemSubType.EquipStone then
			local pos = self.m_Item:GetValue("pos")
			local score = self.m_Item:GetEquipBaseScore()
			local equip = g_ItemCtrl:GetEquipedByPos(pos)
			local equipedScore = equip:GetEquipBaseScore()

			if score ~= equipedScore then
				self.m_ScoreCompareBox:SetActive(true)
				if score > equipedScore then
					self.m_ScoreUpSprite:SetActive(true)
					self.m_ScoreDownSprite:SetActive(false)
				else
					self.m_ScoreUpSprite:SetActive(false)
					self.m_ScoreDownSprite:SetActive(true)
				end
			end
		end
	end
end

function CItemBagBox.SetIndexAndParentview(self, index, parentView)
	self.m_ItemIndex = index
	self.m_ParentView = parentView 
end

function CItemBagBox.SetSellSelectActive(self, b)
	self.m_CurSellSelectSpr:SetActive(b)
end

return CItemBagBox