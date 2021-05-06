local CQRCodePage = class("CQRCodePage", CPageBase)

function CQRCodePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_LoginBtn = self:NewUI(1, CButton)
	self.m_LoginBtn:AddUIEvent("click", callback(self, "OnLogin"))
end

function CQRCodePage.OnLogin(self)
	CQRCodeLoginView:ShowView()
	--CQRCodeEnsureView:ShowView()
end

return CQRCodePage