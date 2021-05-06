local CLoadingView = class("CLoadingView", CViewBase)

function CLoadingView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/LoadingView.prefab", cb)

	self.m_DepthType = "Top"
end

function CLoadingView.OnCreateView(self)
	self.m_Texture = self:NewUI(1, CTexture)
	self.m_TipLabel = self:NewUI(2, CLabel)
	UITools.ResizeToRootSize(self.m_Texture)
	self.m_Texture:SetActive(false)
end

function CLoadingView.SetTextureShow(self, bShow)
	self.m_Texture:SetActive(bShow)
end

function CLoadingView.SetTips(self, sText)
	self.m_TipLabel:SetText(sText)
end

return CLoadingView