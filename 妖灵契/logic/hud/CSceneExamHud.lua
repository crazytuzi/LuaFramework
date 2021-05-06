local CSceneExamHud = class("CSceneExamHud", CAsyncHud)

function CSceneExamHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/SceneExamHud.prefab", cb, true)
end

function CSceneExamHud.OnCreateHud(self)
	self.m_AmountLabel = self:NewUI(1, CLabel)
	self.m_RewardLabel = self:NewUI(2, CLabel)
	self.m_OwnerSpr = self:NewUI(3, CSprite)
end

function CSceneExamHud.SetAmount(self, iAmount, sReward, bIsSelf)
	self.m_AmountLabel:SetText(tostring(iAmount))
	self.m_RewardLabel:SetText(sReward)
	if bIsSelf then
		self.m_OwnerSpr:SetSpriteName("pic_cjdi_liandui")
	else
		self.m_OwnerSpr:SetSpriteName("pic_cjdi_liandui2")
	end
end

return CSceneExamHud