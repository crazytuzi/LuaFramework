local CSpecialTitleHud = class("CSpecialTitleHud", CAsyncHud)

function CSpecialTitleHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/SpecialTitleHud.prefab", cb, true)
end

function CSpecialTitleHud.OnCreateHud(self)
	self.m_SpecialLab = self:NewUI(1, CLabel)
	self.m_SpecialSpr = self:NewUI(2, CSprite)
end

function CSpecialTitleHud.SetSpecialTitle(self, title, spriteName)
	local titleSta = title and string.len(title) > 0
	local spriteSta = spriteName and string.len(spriteName) > 0
	if not titleSta and not spriteSta then
		printerror("错误：检查特殊称号设置")
		return
	end
	local xPos = 0
	if titleSta then
		if spriteSta then
			xPos = 16
		end
	elseif spriteSta then
		xPos = 64
	end
	self.m_SpecialLab:SetLocalPos(Vector3.New(xPos, 0, 0))

	self.m_SpecialLab:SetActive(titleSta)
	if titleSta then
		self.m_SpecialLab:SetText(title)
	end
	self.m_SpecialSpr:SetActive(spriteSta)
	if spriteSta then
		self.m_SpecialSpr:SetSpriteName(spriteName)
		-- self.m_SpecialSpr:MakePixelPerfect()
	end
end

return CSpecialTitleHud