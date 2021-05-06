local CAniSwitchBox = class("CAniSwitchBox", CBox)

function CAniSwitchBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BlackBg = self:NewUI(1, CSprite)
	self.m_Texture = self:NewUI(2, CTexture)
end

function CAniSwitchBox.SetAniSwichBgActive(self, b, bFadeIn)
	self.m_Texture:SetMainTextureNil()
	self.m_Texture:SetActive(false)
	self.m_BlackBg:SetActive(b)
	if b == true then
		if bFadeIn == true then
			self.m_BlackBg:SetAlpha(0)
			self.m_AlphaAction1 = CActionFloat.New(self.m_BlackBg, 0.5, "SetAlpha", 0, 1)
			g_ActionCtrl:AddAction(self.m_AlphaAction1)
		else
			self.m_BlackBg:SetAlpha(1)
		end
	end
end

function CAniSwitchBox.SetAniSwichBgFadeOut(self)
	self.m_AlphaAction1 = CActionFloat.New(self.m_BlackBg, 1, "SetAlpha", 1, 0)
	self.m_AlphaAction1:SetEndCallback(callback(self, "ResetAniSwitchBox"))
	g_ActionCtrl:AddAction(self.m_AlphaAction1)
end

function CAniSwitchBox.SetAniSwichTextrueActive(self, path, bFadeIn)
	local sPath = string.format("Texture/Guide/"..path..".png")
	local cb = function ()
		self.m_Texture:SetActive(false)
		self.m_Texture:SetActive(true)
	end 
	self.m_Texture:LoadPath(sPath, cb)
	self.m_BlackBg:SetActive(false)
	if bFadeIn == true then
		self.m_Texture:SetAlpha(0)
		self.m_AlphaAction2 = CActionFloat.New(self.m_Texture, 0.5, "SetAlpha", 0, 1)
		g_ActionCtrl:AddAction(self.m_AlphaAction2)
	else
		self.m_Texture:SetAlpha(1)
	end
end

function CAniSwitchBox.SetAniSwichTextrueFadeOut(self)
	self.m_AlphaAction2 = CActionFloat.New(self.m_Texture, 1, "SetAlpha", 1, 0)
	self.m_AlphaAction2:SetEndCallback(callback(self, "ResetAniSwitchBox"))
	g_ActionCtrl:AddAction(self.m_AlphaAction2)
end

function CAniSwitchBox.ResetAniSwitchBox(self)
	self.m_Texture:SetMainTextureNil()
	self.m_Texture:SetActive(false)
	self.m_BlackBg:SetActive(false)
end

return CAniSwitchBox

