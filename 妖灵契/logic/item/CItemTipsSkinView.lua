---------------------------------------------------------------
--伙伴的基本信息界面


---------------------------------------------------------------

local CItemTipsSkinView = class("CItemTipsSkinView", CViewBase)

function CItemTipsSkinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsSkinView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Black"
	self.m_ItemInfo = nil
	self.m_ExtendClose = true
end

function CItemTipsSkinView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_QualitySprite = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_ActorTexture = self:NewUI(5, CActorTexture)
	self.m_DescLabel = self:NewUI(6, CLabel)
	self:InitContent()
end

function CItemTipsSkinView.InitContent(self)

end

function CItemTipsSkinView.SetPartnerSkin(self, shape)
	self:RefreshPartnerSkinInfo(shape)
end

function CItemTipsSkinView.RefreshPartnerSkinInfo(self, iShape)
	local dInfo = DataTools.GetItemData(iShape)
	if dInfo then
		local partnerInfo = data.partnerdata.DATA[dInfo.partner_type]
		g_PartnerCtrl:ChangeRareBorder(self.m_QualitySprite, partnerInfo.rare)
		self.m_IconSprite:SpriteAvatar(dInfo.icon)
		self.m_ActorTexture:ChangeShape(dInfo.shape, {})
		self.m_NameLabel:SetText(dInfo.name)
		self.m_DescLabel:SetText(dInfo.introduction)
	else
		self.m_NameLabel:SetText(string.format("皮肤%d", iShape))
	end
end

function CItemTipsSkinView.SetRoleSkin(self, shape)
	self:RefreshRoleSkinInfo(shape)
end

function CItemTipsSkinView.RefreshRoleSkinInfo(self, iShape)
	local dInfo = data.roleskindata.DATA[iShape]
	if dInfo then
		local dSchool = data.schooldata.DATA[dInfo.school]
		self.m_NameLabel:SetText(dInfo.name)
		local partnerInfo = data.partnerdata.DATA[dInfo.partner_type]
		self.m_QualitySprite:SetSpriteName("bg_haoyoukuang")
		self.m_IconSprite:SpriteAvatar(dInfo.shape)
		self.m_ActorTexture:ChangeShape(dInfo.shape, {})
		self.m_DescLabel:SetText(dInfo.desc)
	else
		self.m_NameLabel:SetText(string.format("皮肤%d", iShape))
	end
end

function CItemTipsSkinView.ExtendCloseView(self)
	if self.m_ExtendClose == false then
		self.m_ExtendClose = true
		return
	end
	self:CloseView()
end

return CItemTipsSkinView