local CGuideTipsHud = class("CGuideTipsHud", CAsyncHud)

function CGuideTipsHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/GuideTipsHud.prefab", cb, true)
end

function CGuideTipsHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

function CGuideTipsHud.SetLocalPos(self, pos)
	self.m_Sprite:SetLocalPos(pos)
end

return CGuideTipsHud