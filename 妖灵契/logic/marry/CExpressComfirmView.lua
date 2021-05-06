local CExpressComfirmView = class("CExpressComfirmView", CViewBase)

function CExpressComfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressComfirmView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressComfirmView.OnCreateView(self)
	self.m_OkBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_CountDownLabel = self:NewUI(4, CCountDownLabel)
	self:InitContent()
end

function CExpressComfirmView.InitContent(self)
	self.m_DescLabel:SetText(string.format("【%s】", g_MarryCtrl.m_ComfirmName))
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
	self.m_CountDownLabel:SetTickFunc(callback(self, "OnCount"))
	self.m_CountDownLabel:SetTimeUPCallBack(callback(self, "OnTimeUp"))
	local iTime = g_MarryCtrl.m_WaitResponseTime - g_TimeCtrl:GetTimeS()
	if iTime < 0 then
		iTime = 0
	end
	self.m_CountDownLabel:BeginCountDown(iTime)
end

function CExpressComfirmView.OnClickOk(self)
	nethuodong.C2GSExpressResponse(1)
	self:OnClose()
end

function CExpressComfirmView.OnClickCancel(self)
	nethuodong.C2GSExpressResponse(2)
	self:OnClose()
end

function CExpressComfirmView.OnCount(self, iValue)
	self.m_CountDownLabel:SetText(string.format("%ss自动拒绝", iValue))
end

function CExpressComfirmView.OnTimeUp(self)
	self.m_CountDownLabel:SetText("0s自动拒绝")
	self:OnClickCancel()
end

return CExpressComfirmView