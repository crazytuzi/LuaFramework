CConnectView = class("CConnectView", CViewBase)

function CConnectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/ConnectView.prefab", cb)

	self.m_DepthType = "Top"
	self.m_ExtendClose = "Shelter"
end

function CConnectView.OnCreateView(self)
	self.m_Texture = self:NewUI(1, CTexture)
	UITools.ResizeToRootSize(self.m_Texture, 4, 4)
end

return CConnectView