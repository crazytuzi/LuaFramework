local CDialogTipsHud = class("CDialogTipsHud", CAsyncHud)

function CDialogTipsHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/DialogTipsHud.prefab", cb, true)
end

function CDialogTipsHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CDialogTipsHud