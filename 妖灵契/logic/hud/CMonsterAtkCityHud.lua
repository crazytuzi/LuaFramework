local CMonsterAtkCityHud = class("CMonsterAtkCityHud", CAsyncHud)

function CMonsterAtkCityHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/MonsterAtkCityHud.prefab", cb, true)
end

function CMonsterAtkCityHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

function CMonsterAtkCityHud.SetNpcType(self, npctype)
	if npctype == "small" then
		self.m_Sprite:SetSpriteName("pic_monster_canatk_1")
	elseif npctype == "middle" then
		self.m_Sprite:SetSpriteName("pic_monster_canatk_2")
	elseif npctype == "large" then
		self.m_Sprite:SetSpriteName("pic_monster_canatk_3")
	else
		self.m_Sprite:SetActive(false)
	end
end

return CMonsterAtkCityHud