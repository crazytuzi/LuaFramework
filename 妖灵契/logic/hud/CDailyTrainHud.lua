local CDailyTrainHud = class("CDailyTrainHud", CAsyncHud)

function CDailyTrainHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/DailyTrainHud.prefab", cb, true)
end

function CDailyTrainHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CDailyTrainHud