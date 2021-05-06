local CLevelHud = class("CLevelHud", CAsyncHud)

function CLevelHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/LevelHud.prefab", cb, false)
end

function CLevelHud.OnCreateHud(self)
	self.m_LvLabel = self:NewUI(1, CLabel)
end

function CLevelHud.Recycle(self)
	self.m_LvLabel:SetText("")
end

function CLevelHud.SetLevel(self, lv)
	self.m_LvLabel:SetActive(lv and lv > 0 )
	self.m_LvLabel:SetText(lv and string.format("lv.%d", lv) or "")
end

return CLevelHud