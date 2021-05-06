local CTerraWarHud = class("CTerraWarHud", CAsyncHud)

function CTerraWarHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/TerraWarHud.prefab", cb, true)
end

function CTerraWarHud.OnCreateHud(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_FlagSprite = self:NewUI(2, CSprite)
	self.m_FlagLabel = self:NewUI(3, CLabel)
	self.m_NameBG = self:NewUI(4, CSprite)
	self:SetActive(false)
end

function CTerraWarHud.SetTerraWarHud(self, orgid, sFlag, sOwner)
	self:SetActive(true)
	self.m_NameLabel:SetText(sOwner)
	self.m_FlagLabel:SetText(sFlag)
	self:SetName(sOwner)
	if sFlag and sFlag ~= "" then
		self.m_FlagSprite:SetGrey(false)
		if orgid == g_AttrCtrl.org_id then
			self.m_FlagSprite:SetSpriteName("pic_lanse_qizi01")
		else
			self.m_FlagSprite:SetSpriteName("pic_hongse_qizi01")
		end
	else
		self.m_FlagSprite:SetGrey(true)
	end
	self.m_NameBG:ResetAndUpdateAnchors()
end

return CTerraWarHud