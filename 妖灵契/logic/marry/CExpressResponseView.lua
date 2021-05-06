local CExpressResponseView = class("CExpressResponseView", CViewBase)

function CExpressResponseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressResponseView.prefab", cb)
end

function CExpressResponseView.OnCreateView(self)
	self.m_CountDownLabel = self:NewUI(1, CCountDownLabel)
	self:InitContent()
end

function CExpressResponseView.InitContent(self)
	self.m_CountDownLabel:SetTickFunc(callback(self, "OnCount"))
	self.m_CountDownLabel:SetTimeUPCallBack(callback(self, "OnTimeUp"))
	g_MarryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnExpressEvent"))
end

function CExpressResponseView.SetData(self, iTime)
	self.m_CountDownLabel:BeginCountDown(iTime)
end

function CExpressResponseView.OnCount(self, iValue)
	self.m_CountDownLabel:SetText(string.format("%s秒后自动结束", iValue))
end

function CExpressResponseView.OnTimeUp(self)
	self.m_CountDownLabel:SetText("0秒后自动结束")
	self:OnClose()
end

function CExpressResponseView.OnExpressEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Marry.Event.OnResponse then
		self:OnClose()
	end
end

return CExpressResponseView