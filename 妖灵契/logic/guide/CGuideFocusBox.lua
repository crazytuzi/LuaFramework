local CGuideFocusTipBox = class("CGuideFocusTipBox", CBox)

function CGuideFocusTipBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_FocusSpr = self:NewUI(1, CSprite)
	self.m_TopSpr = self:NewUI(2, CSprite)
	self.m_BottomSpr = self:NewUI(3, CSprite)
	self.m_LeftSpr = self:NewUI(4, CSprite)
	self.m_RightSpr = self:NewUI(5, CSprite)
	self.m_CoverTexture = self:NewUI(6, CTexture)
	self.m_Collider = self:NewUI(7, CObject)
	self.m_CoverTexture2 = self:NewUI(8, CTexture)
	-- self.m_FocusSpr:SetActive(false)
	self.m_Mat = self.m_CoverTexture:GetMaterial()
	self.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 1, 1))
	self.m_Mat2 = self.m_CoverTexture2:GetMaterial()
	self.m_Mat2:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 1, 1))	
	self:SimulateOnEnable()
	g_GuideCtrl:AddGuideUI("guide_focus_spr",self.m_FocusSpr)

	self.m_TopSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
	self.m_BottomSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
	self.m_LeftSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
	self.m_RightSpr:AddUIEvent("click", callback(g_GuideCtrl, "ShowWrongTips"))
end

function CGuideFocusTipBox.SetFocusCommon(self, x, y, w, h)
	local rootw, rooth = UITools.GetRootSize()
	self.m_Mat:SetVector("_SkipRange", Vector4.New(x, y, w, h))
	self.m_Mat2:SetVector("_SkipRange", Vector4.New(x, y, w, h))
	self.m_FocusSpr:SetPos(g_GuideCtrl:View2WorldPos(x, y))
	self.m_FocusSpr:SetSize(w*rootw*2, h*rooth*2)
	self:SimulateOnEnable()
	self.m_Collider:SetActive(true)
end

function CGuideFocusTipBox.SetEffect(self, sEffect, pos)
	if sEffect then
		self.m_FocusSpr:AddEffect(sEffect, nil, pos)
	else
		self.m_FocusSpr:ClearEffect()
	end
end

function CGuideFocusTipBox.Black(self)
	self.m_Mat:SetVector("_SkipRange", Vector4.zero)
	self.m_Mat2:SetVector("_SkipRange", Vector4.zero)
	self:SimulateOnEnable()
	self.m_FocusSpr:ClearEffect()
	self.m_Collider:SetActive(false)
	self:CoverTextureReSetAplha()
	self:SetCoverMode(1)
end

function CGuideFocusTipBox.CoverTextureReSetAplha(self)
	self.m_CoverTexture:SetAlpha(170/255)
	self.m_CoverTexture2:SetAlpha(170/255)
end

function CGuideFocusTipBox.CoverTextureSetAplha(self, aplha)
	self.m_CoverTexture:SetAlpha(aplha/255)
	self.m_CoverTexture2:SetAlpha(aplha/255)
end

function CGuideFocusTipBox.SetCoverMode(self, mode)
	self.m_CoverTexture:SetActive(mode == 1)
	self.m_CoverTexture2:SetActive(mode == 2)
end

return CGuideFocusTipBox