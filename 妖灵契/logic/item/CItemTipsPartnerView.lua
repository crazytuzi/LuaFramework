---------------------------------------------------------------
--伙伴的基本信息界面


---------------------------------------------------------------

local CItemTipsPartnerView = class("CItemTipsPartnerView", CViewBase)

function CItemTipsPartnerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsPartnerView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Black"
	self.m_ItemInfo = nil
	self.m_ExtendClose = true
end

function CItemTipsPartnerView.OnCreateView(self)
	self.m_BgSprite = self:NewUI(1, CSprite)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_QualitySprite = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_PrintRareLabel = self:NewUI(5, CLabel)
	self.m_DesLabel = self:NewUI(6, CLabel)
	self.m_BgSprite.m_OriHeight = self.m_BgSprite:GetHeight()

	self:InitContent()
end

function CItemTipsPartnerView.InitContent(self)

end

function CItemTipsPartnerView.SetContent(self, shape)
	self:RefreshInfo(shape)
end

function CItemTipsPartnerView.RefreshInfo(self, shape)
	local oPartner = data.partnerdata.DATA[shape]
	if oPartner then
		self.m_NameLabel:SetText(oPartner["name"])
		if oPartner["rare"] == 1 then
			self.m_PrintRareLabel:SetText("[d9ceba]◆精英伙伴")
		else
			self.m_PrintRareLabel:SetText("[d9ceba]◆传说伙伴")
		end
		self.m_DesLabel:SetText("[d9ceba]◆"..oPartner["tips"].."[-]")
		self.m_IconSprite:SpriteAvatar(oPartner["icon"])
		g_PartnerCtrl:ChangeRareBorder(self.m_QualitySprite, oPartner["rare"])
	else
		self.m_NameLabel:SetText(string.format("伙伴%d", shape))
		self.m_DesLabel:SetText("")
	end
	self:ResetBg()
end

function CItemTipsPartnerView.ResetBg(self)
	local h = self.m_DesLabel:GetHeight() + self.m_PrintRareLabel:GetHeight() 
	self.m_BgSprite:SetHeight(self.m_BgSprite.m_OriHeight + math.max(0, h-45))
end

function CItemTipsPartnerView.ExtendCloseView(self)
	if self.m_ExtendClose == false then
		self.m_ExtendClose = true
		return
	end
	self:CloseView()
end

function CItemTipsPartnerView.RefreshYJBossInfo(self, oData)
	local shape = oData["shape"]
	local oPartner = data.partnerdata.DATA[shape]
	if oPartner then
		self.m_NameLabel:SetText(oPartner["name"])
		g_PartnerCtrl:ChangeRareBorder(self.m_QualitySprite, oPartner["rare"])
	else
		self.m_NameLabel:SetText(oData.name)
	end
	self.m_PrintRareLabel:SetText("[d9ceba]"..oData["desc"])
	self.m_DesLabel:SetText("[d9ceba]◇"..oData["content"])
	self.m_IconSprite:SpriteAvatar(shape)
	self:ResetBg()
end

return CItemTipsPartnerView