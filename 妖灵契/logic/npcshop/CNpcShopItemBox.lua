local CNpcShopItemBox = class("CNpcShopItemBox", CBox)

function CNpcShopItemBox.ctor(self, ob)
	CBox.ctor(self, ob)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_CostLabel = self:NewUI(3, CLabel)
	self.m_CurrencySprite = self:NewUI(4, CSprite)
	self.m_BaseCostLabel = self:NewUI(5, CLabel)
	self.m_CostTable = self:NewUI(6, CTable)
	
	self.m_QualitySprite = self:NewUI(8, CSprite)
	-- self.m_AmountLabel = self:NewUI(9, CLabel)
	self.m_PartnerQualitySprite = self:NewUI(10, CSprite)
	self.m_SkinTexture = self:NewUI(11, CTexture)
	self.m_PartnerEquipGrid = self:NewUI(12, CGrid)
	self.m_PartnerEquipPart = self:NewUI(13, CSprite)
	self.m_PartnerEquipStar = self:NewUI(14, CSprite)
	self.m_PartnerSprite = self:NewUI(15, CSprite)
	self.m_EquipSprite = self:NewUI(16, CSprite)
	self.m_ChipsQualityBgSprite = self:NewUI(17, CSprite)
	self.m_ChipSprite = self:NewUI(18, CSprite)
	self.m_ChipsQualitySprite = self:NewUI(19, CSprite)
	self.m_SoldoutMark = self:NewUI(20, CSprite)
	self.m_LimitMark = self:NewUI(21, CSprite)
	self.m_Effect = self:NewUI(22, CUIEffect)
	self.m_DescLabel = self:NewUI(23, CLabel)
	self.m_AboveSprite = self:NewUI(24, CSprite)
	self:InitContent()
end

function CNpcShopItemBox.InitContent(self)
	self:SetActive(true)
	self.m_Currency = nil
	self.m_SpriteList = {
		[define.Store.GoodsType.PartnerSkin] = {self.m_SkinTexture},
		[define.Store.GoodsType.Partner] = {self.m_PartnerSprite, self.m_PartnerQualitySprite},
		[define.Store.GoodsType.PartnerEquip] = {self.m_EquipSprite, self.m_PartnerEquipPart, },
		[define.Store.GoodsType.PartnerChip] = {self.m_ChipsQualityBgSprite, self.m_ChipSprite, self.m_ChipsQualitySprite},
	}
	self.m_DefaultList = {self.m_QualitySprite, self.m_Icon}
	self:SetClickSounPath(define.Audio.SoundPath.ClickItem)
end


function CNpcShopItemBox.SetData(self, goodsData)
	self:SetActive(false)
	self.m_GoodsData = goodsData
	if not g_NpcShopCtrl:IsGradeOK(goodsData.id) then
		return
	end
	self.m_LimitMark:SetActive(true)
	self.m_LimitMark:SetSpriteName(g_NpcShopCtrl:GetMarkName(goodsData.mark))
	self.m_EquipSprite:SetActive(false)
	self.m_QualitySprite:SetActive(false)
	self.m_PartnerQualitySprite:SetActive(false)
	self.m_SkinTexture:SetActive(false)
	self.m_ChipsQualityBgSprite:SetActive(false)
	self:SetActive(true)
	self.m_Effect:Above(self.m_AboveSprite)
	self.m_CurrencySprite:SetSpriteName(goodsData.currency.icon)
	-- self.m_NameLabel:SetText(goodsData.name)
	if goodsData.gType == define.Store.GoodsType.PartnerSkin then
		self.m_SkinTexture:LoadCardPhoto(goodsData.exData.show)
		self.m_SkinTexture:SetActive(true)
		self.m_SoldoutMark:SetLocalPos(self.m_SkinTexture:GetLocalPos())
	elseif goodsData.gType == define.Store.GoodsType.Partner then
		self.m_PartnerSprite:SpriteAvatar(goodsData.icon)
		self.m_PartnerQualitySprite:SetActive(true)
		g_PartnerCtrl:ChangeRareBorder(self.m_PartnerQualitySprite, goodsData.exData.rare)
		self.m_SoldoutMark:SetLocalPos(self.m_PartnerQualitySprite:GetLocalPos())
	elseif goodsData.gType == define.Store.GoodsType.PartnerEquip then
		self.m_EquipSprite:SpriteItemShape(goodsData.icon)
		self.m_EquipSprite:SetActive(true)
		self.m_PartnerEquipPart:SetSpriteName("pic_fuwen_xj" .. tonumber(goodsData.exData.quality))
		local pos2angle = {90, 180, -90, 0}
		local v = Quaternion.Euler(0, 0, pos2angle[goodsData.exData.pos] or 0)
		self.m_PartnerEquipPart:SetLocalRotation(v)

		self.m_PartnerEquipGrid:Clear()
		for i = 1, goodsData.exData.equip_star do
			local oStar = self.m_PartnerEquipStar:Clone()
			oStar:SetActive(true)
			self.m_PartnerEquipGrid:AddChild(oStar)
		end
		self.m_PartnerEquipStar:SetActive(false)
		self.m_PartnerEquipGrid:Reposition()
		self.m_SoldoutMark:SetLocalPos(self.m_EquipSprite:GetLocalPos())
	elseif goodsData.gType == define.Store.GoodsType.PartnerChip then
		self.m_ChipsQualityBgSprite:SetActive(true)
		self.m_ChipsQualityBgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(goodsData.exData.rare))
		self.m_ChipSprite:SpriteAvatar(goodsData.icon)
		self.m_ChipsQualitySprite:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(goodsData.exData.rare))
		self.m_SoldoutMark:SetLocalPos(self.m_ChipsQualityBgSprite:GetLocalPos())
	else
		self.m_QualitySprite:SetActive(true)
		-- self.m_NameLabel:SetText(goodsData.name)
		self.m_Icon:SpriteItemShape(goodsData.icon)
		self.m_Icon:MakePixelPerfect()
		-- self.m_QualitySprite:SetItemQuality(goodsData.exData.quality)
		self.m_SoldoutMark:SetLocalPos(self.m_QualitySprite:GetLocalPos())
	end
	-- printc("goodsData.name: " .. goodsData.name)
end

function CNpcShopItemBox.Refresh(self, oInfo)
	self.m_GoodsInfo = oInfo

	local sPrice = g_NpcShopCtrl:GetGoodsPrice(oInfo.pos)
	self.m_BaseCostLabel:SetActive(g_NpcShopCtrl:IsDaZhe(oInfo.pos))

	self.m_BaseCostLabel:SetText(self.m_GoodsData.coin_count)
	if self.m_GoodsData.currency.currency_type == define.Currency.Type.RMB then
		self.m_CostLabel:SetText(sPrice .. "元")
	else
		self.m_CostLabel:SetText(sPrice)
	end
	self.m_CostTable:Reposition()
	if self.m_GoodsData.vip == 1 and not (g_WelfareCtrl:HasYueKa() or g_WelfareCtrl:HasZhongShengKa()) then
		self.m_DescLabel:SetText("月卡/终身卡\n可购买")
	else
		self.m_DescLabel:SetText("")
	end
	if self.m_GoodsInfo.limit == 0 then
		self.m_Amount = nil
		self.m_NameLabel:SetText(self.m_GoodsData.name)
		-- self.m_AmountLabel:SetText("")
	else
		self.m_Amount = self.m_GoodsInfo.amount
		-- printc("self.m_Amount: " .. self.m_Amount)
		if data.npcstoredata.StoreTag[self.m_ParentView.m_CurrentTagBtn.m_TagData.id].show_limit == 1 then
			self.m_NameLabel:SetText(string.format("%s(%s)", self.m_GoodsData.name, self.m_Amount))
		else
			self.m_NameLabel:SetText(self.m_GoodsData.name)
		end
		
		-- self.m_AmountLabel:SetText(string.format("(%s)", self.m_Amount))
		-- if self.m_Amount == 0 then
			-- self.m_NameLabel:SetColor(Color.red)
			-- self.m_AmountLabel:SetColor(Color.red)
			-- self.m_AmountLabel:SetText("")
		-- else
			-- self.m_NameLabel:SetColor(self.m_ParentView.m_TextColor)
			-- self.m_AmountLabel:SetColor(self.m_ParentView.m_TextColor)
		-- end
	end
	--售完置灰效果
	
	self.m_SoldoutMark:SetActive(false)
	
	local spriteList = self.m_SpriteList[self.m_GoodsData.gType] or self.m_DefaultList
	for i = 1, #spriteList do
		spriteList[i]:SetGrey(self.m_Amount == 0)
	end
	if self.m_GoodsData.gType == define.Store.GoodsType.PartnerEquip then
		local childlist = self.m_PartnerEquipGrid:GetChildList()
		for i = 1, #childlist do
			childlist[i]:SetGrey(self.m_Amount == 0)
		end
	end
	self.m_SoldoutMark:SetActive(self.m_Amount == 0)
end

return CNpcShopItemBox