local CFightHud = class("CFightHud", CAsyncHud)

function CFightHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/FightHud.prefab", cb, true)
end

function CFightHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CFightHud