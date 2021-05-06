local CWarriorOrderHud = class("CWarriorOrderHud", CAsyncHud)

function CWarriorOrderHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorOrderHud.prefab", cb, false)
end

function CWarriorOrderHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
	self:SetReady(false)
end

function CWarriorOrderHud.SetReady(self, bDone)
	if Utils.IsInEditorMode() then
		self:SetActive(false)
		return
	end
	if bDone then
		self.m_Sprite:SetSpriteName("text_zhunbeiwancheng")
	else
		self.m_Sprite:SetSpriteName("ready")
	end
	self.m_Sprite:MakePixelPerfect()
end

return CWarriorOrderHud