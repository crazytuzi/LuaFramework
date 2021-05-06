local CBulletInputView = class("CBulletInputView", CViewBase)
--wuling武灵
--wuhun武魂
function CBulletInputView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/BulletInputView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CBulletInputView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Input = self:NewUI(2, CInput)
	self.m_CancelBtn = self:NewUI(3, CButton)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self:InitContent()
end


function CBulletInputView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CBulletInputView.SetCallBack(self, cb)
	self.m_CallBack = cb
end

function CBulletInputView.OnConfirm(self)
	if self.m_CallBack then
		self.m_CallBack(self.m_Input:GetText())
	end
end

return CBulletInputView