local CGuideOpenBox = class("CGuideOpenBox", CBox)

function CGuideOpenBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Sprite = self:NewUI(1, CSprite)
	self.m_OpenLabel = self:NewUI(2, CLabel)
	self.m_HideWidget = self:NewUI(3, CWidget)
	self.m_EffctSprite = self:NewUI(4, CSprite)
	self.m_OriginPos = self.m_Sprite:GetPos()
end

function CGuideOpenBox.SetOpen(self, sSpriteName, sOpen, oUI)
	self.m_Sprite:SetPos(self.m_OriginPos)
	self.m_Sprite:SetSpriteName(sSpriteName)
	self.m_OpenLabel:SetText(sOpen)

	self.m_HideWidget:SetActive(true)
	self.m_EffctSprite:AddEffect("Guide")
	self.m_Sprite:AddEffect("Trail")
	local time = 2.2
	if Utils.IsExist(oUI) then
		if oUI.GetSpriteName and oUI:GetSpriteName() == self.m_Sprite:GetSpriteName() then
			--oUI:SetActive(false)
			oUI:DelayCall(0.1, "SetActive", false)
		end
		local function anim()
			if Utils.IsExist(self) then 
				self.m_HideWidget:SetActive(false)
				self.m_EffctSprite:DelEffect("Guide")
				self.m_Sprite:AddEffect("Trail")
				local tween = DOTween.DOMove(self.m_Sprite.m_Transform, oUI:GetPos(), 1.4)
				DOTween.SetEase(tween, enum.DOTween.Ease.OutExpo)
			end
		end
		Utils.AddTimer(anim, 2, 2)
		time = time + 1.4
	end
	local function compelte()
		if Utils.IsExist(self) then
			self.m_Sprite:DelEffect("Trail")
			if Utils.IsExist(oUI) and (oUI.GetSpriteName and oUI:GetSpriteName() == self.m_Sprite:GetSpriteName()) then
				--oUI:SetActive(true)
				oUI:DelayCall(0.1, "SetActive", true)
			end
			g_GuideCtrl:Continue()
		end
	end
	Utils.AddTimer(compelte, time, time)
end

function CGuideOpenBox.IsNeedHide(self, oUI)

end

return CGuideOpenBox