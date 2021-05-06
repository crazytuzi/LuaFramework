local CFurnitureHud = class("CFurnitureHud", CAsyncHud)

function CFurnitureHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/FurnitureHud.prefab", cb, false)
end

function CFurnitureHud.OnCreateHud(self)
	self.m_ItemSprite = self:NewUI(1, CSprite)
	self.m_BgSprite = self:NewUI(2, CSprite)
	self.m_FingerBgSprite = self:NewUI(3, CSprite)
	-- "task_npcfinish"--问号
	-- "task_npcaccept" -- 叹号
	self.m_FingerBgSprite:SetActive(false)
end

function CFurnitureHud.ShowFingerEffect(self, b)
	if b then
		self.m_BgSprite:SetActive(false)
		self.m_FingerBgSprite:SetActive(true)	
		self.m_FingerBgSprite:AddEffect("Finger")
	else
		self.m_BgSprite:SetActive(true)
		self.m_FingerBgSprite:SetActive(false)	
	end
end

return CFurnitureHud