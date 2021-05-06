local CPartnerHouseBuffView = class("CPartnerHouseBuffView", CViewBase)

function CPartnerHouseBuffView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/PartnerHouseBuffView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_OpenEffect = "Scale"
end

function CPartnerHouseBuffView.OnCreateView(self)
	self.m_BuffSprite = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_LvLabel = self:NewUI(3, CLabel)
	self.m_AttrLabel = self:NewUI(4, CLabel)

	self:InitContent()
end

function CPartnerHouseBuffView.InitContent(self)
	local oInfo = g_PlayerBuffCtrl:GetHouseBuff()
	local oData = data.housedata.LoveBuff[oInfo.stage]
	self.m_LvLabel:SetText(string.format("%s阶", oData.level))
	self.m_BuffSprite:SpriteHouseBuff(oData.icon)
	self.m_AttrLabel:SetText(g_PlayerBuffCtrl:GetHouseAttrStr(oData.level, "[ffe6a3]%s◆%s[ff9c00]+%s[-]\n"))
	self.m_NameLabel:SetText(oData.name)
end

return CPartnerHouseBuffView