local CBottomView = class("CBottomView", CViewBase)

function CBottomView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/BottomView.prefab", cb)
	self.m_DepthType = "Bottom"
end

function CBottomView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	self.m_Texture = self:NewUI(2, CTexture)
	self.m_DialogueAniEffctBottomRoot = self:NewUI(3, CSprite)
	UITools.ResizeToRootSize(self.m_Contanier, 4, 4)
end

function CBottomView.SetBottomTexture(self, texture)
	if texture then
		self.m_Texture:SetAlpha(1)
		self.m_Texture:SetActive(true)
	else
		self.m_Texture:SetActive(false)
	end
	self.m_Texture:SetMainTexture(texture)
	g_ActionCtrl:StopTarget(self.m_Texture)
end

function CBottomView.FadeHide(self)
	local oAction = CActionFloat.New(self.m_Texture, 0.6, "SetAlpha", 1, 0)
	oAction:SetEndCallback(callback(self, "SetBottomTexture", nil))
	g_ActionCtrl:AddAction(oAction)
end

return CBottomView