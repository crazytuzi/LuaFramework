local CPatrolHud = class("CPatrolHud", CAsyncHud)

function CPatrolHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/PatrolHud.prefab", cb, true)
end

function CPatrolHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CPatrolHud