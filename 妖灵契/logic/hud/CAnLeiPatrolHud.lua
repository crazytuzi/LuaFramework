local CAnLeiPatrolHud = class("CAnLeiPatrolHud", CAsyncHud)

function CAnLeiPatrolHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/AnLeiPatrolHud.prefab", cb, true)
	--CAsyncHud.ctor(self, "UI/Hud/PatrolHud.prefab", cb, true)
end

function CAnLeiPatrolHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CAnLeiPatrolHud