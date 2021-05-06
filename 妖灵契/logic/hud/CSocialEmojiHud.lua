local CSocialEmojiHud = class("CSocialEmojiHud", CAsyncHud)

function CSocialEmojiHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/SocialEmojiHud.prefab", cb, true)
end

function CSocialEmojiHud.OnCreateHud(self)
	self.m_TaskSpr = self:NewUI(1, CSprite)
end

function CSocialEmojiHud.SetEmoji(self, type)
	local spriteName = g_DialogueAniCtrl:GetEmojiSprName(type)
	self.m_TaskSpr:SetSpriteName(spriteName)
	self.m_TaskSpr:MakePixelPerfect()
end

return CSocialEmojiHud