---------------------------------------------------------------
--宅邸伙伴的基本信息界面


---------------------------------------------------------------

local CItemTipsHousePartnerView = class("CItemTipsHousePartnerView", CViewBase)

function CItemTipsHousePartnerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsHousePartnerView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Black"
	self.m_ItemInfo = nil
	self.m_ExtendClose = true
end

function CItemTipsHousePartnerView.OnCreateView(self)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_QualitySprite = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_DesLabel = self:NewUI(5, CLabel)
	self.m_BgSprite = self:NewUI(6, CSprite)
	self.m_BgSprite.m_OriHeight = self.m_BgSprite:GetHeight()

	self:InitContent()
end

function CItemTipsHousePartnerView.InitContent(self)

end

function CItemTipsHousePartnerView.SetContent(self, shape)
	self:RefreshInfo(shape)
end

function CItemTipsHousePartnerView.RefreshInfo(self, shape)
	local oHousePartner = data.housedata.HousePartner[shape]
	if oHousePartner then
		self.m_NameLabel:SetText(oHousePartner["name"])
		self.m_DesLabel:SetText("解锁宅邸伙伴－"..oHousePartner["name"])
		self.m_IconSprite:SpriteAvatar(tonumber(oHousePartner["shape"]))
		--g_PartnerCtrl:ChangeRareBorder(self.m_QualitySprite, oHousePartner["rare"])
	else
		self.m_NameLabel:SetText(string.format("宅邸伙伴%d", shape))
		self.m_DesLabel:SetText("")
	end
	self:ResetBg()
end

function CItemTipsHousePartnerView.ResetBg(self)
	local h = self.m_DesLabel:GetHeight()
	self.m_BgSprite:SetHeight(self.m_BgSprite.m_OriHeight + math.max(0, h-75))
end

function CItemTipsHousePartnerView.ExtendCloseView(self)
	if self.m_ExtendClose == false then
		self.m_ExtendClose = true
		return
	end
	self:CloseView()
end

return CItemTipsHousePartnerView