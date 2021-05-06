local CTaskSlipMoveView = class("CTaskSlipMoveView", CViewBase)

function CTaskSlipMoveView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskSlipMoveView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_TaskData = nil
	self.m_SessionIdx = nil
end

function CTaskSlipMoveView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TaskSlipCaptruePage = self:NewPage(3, CTaskSlipCaptruePage)
	self.m_TaskSlipGrassPage = self:NewPage(4, CTaskSlipGrassPage)
	UITools.ResizeToRootSize(self.m_Container)
	self:InitContent()
end

function CTaskSlipMoveView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CTaskSlipMoveView.SetData(self, taskId, sessionIdx)
	self.m_TaskData = g_TaskCtrl:GetTaskById(taskId)
	self.m_SessionIdx = sessionIdx
	if true or self.m_TaskData then
		self:ShowSubPage(self.m_TaskSlipCaptruePage)
	else
		self:OnClose()
	end
end

function CTaskSlipMoveView.CompleteCallBack(self)
	if self.m_SessionIdx then
		netother.C2GSCallback(self.m_SessionIdx)
	end
	self:OnClose()
end

function CTaskSlipMoveView.HideCloseBtn(self)
	self.m_CloseBtn:SetActive(false)
end

return CTaskSlipMoveView