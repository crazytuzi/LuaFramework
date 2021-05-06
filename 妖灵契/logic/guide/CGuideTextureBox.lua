local CGuideTextureBox = class("CGuideTextureBox", CBox)

function CGuideTextureBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Texture = self:NewUI(1, CTexture)
	self.m_PlayTween = true
	self.m_FlipY = false
	self.m_Texture:SetMainTexture(nil)
end

function CGuideTextureBox.SetTextureName(self, sTextureName, sText, vPos, cb)
	local path = string.format("Texture/Guide/%s", sTextureName)
	local function cb()
		if Utils.IsExist(self) then
			self.m_Texture:SetActive(true)
			if self.m_PlayTween then
				self:UITweenPlay()
			else
				self:UITweenStop()
			end
			if self.m_FlipY then
				self.m_Texture:SetFlip(enum.UIBasicSprite.Horizontally)
			else
				self.m_Texture:SetFlip(enum.UIBasicSprite.Nothing)
			end
			self.m_Texture:MakePixelPerfect()
		end
	end
	self.m_Texture:SetActive(false)
	self.m_Texture:LoadPath(path, cb)
end

return CGuideTextureBox