local CItemTipsAwakeItemPage = class("CItemTipsAwakeItemPage", CPageBase)
--觉醒技能显示界面

function CItemTipsAwakeItemPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_CItem = nil
	self.m_BG = self:NewUI(1, CSprite)
	self.m_IconSpr = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_ComposeBtn = self:NewUI(5, CButton)
	self.m_UseBtn = self:NewUI(6, CButton)
	self:InitContent()
end

function CItemTipsAwakeItemPage.InitContent(self)
	self.m_ComposeBtn:SetActive(false)
	self.m_UseBtn:SetActive(false)
end

function CItemTipsAwakeItemPage.ShowPage(self, info, args)
	CPageBase.ShowPage(self)
	self:SetInitBox(info)
end

function CItemTipsAwakeItemPage.SetInitBox(self, info)
	self.m_IconSpr:SpriteSkill(info["icon"])
	self.m_NameLabel:SetText(info["name"])
	self.m_DescLabel:SetText(info["desc"])
	local iH = self.m_DescLabel:GetHeight()
	self.m_BG:SetHeight((iH-100)+240)
end

return CItemTipsAwakeItemPage