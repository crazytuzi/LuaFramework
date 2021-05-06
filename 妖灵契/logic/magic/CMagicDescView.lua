local CMagicDescView = class("CMagicDescView", CViewBase)

function CMagicDescView.ctor(self, cb)
	CViewBase.ctor(self, "UI/skill/SkillDescView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
	self.m_IsShort = false
end

function CMagicDescView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_Bg = self:NewUI(3, CSprite)
end

function CMagicDescView.SetShortDesc(self, bShort)
	self.m_IsShort = bShort
end

function CMagicDescView.SetMagic(self, iMagicID)
	local dMagic = DataTools.GetMagicData(iMagicID)
	self.m_NameLabel:SetText(dMagic.name)
	self.m_DescLabel:SetText(self.m_IsShort and dMagic.short_desc or dMagic.desc)
end

return CMagicDescView