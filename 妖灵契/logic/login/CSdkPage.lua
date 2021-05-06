local CSdkPage = class("CSdkPage", CPageBase)

function CSdkPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_LoginBtn = self:NewUI(1, CButton)
	self.m_LoginBtn:AddUIEvent("click", callback(self, "OnLogin"))
end

function CSdkPage.OnLogin(self)
	g_SdkCtrl:Login()
end

return CSdkPage