local CTeamHud = class("CTeamHud", CAsyncHud)

function CTeamHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/TeamHud.prefab", cb, true)
end

function CTeamHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CTeamHud