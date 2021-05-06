local CAutoFindHud = class("CAutoFindHud", CAsyncHud)

function CAutoFindHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/AutoFindHud.prefab", cb, true)
end

function CAutoFindHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CAutoFindHud