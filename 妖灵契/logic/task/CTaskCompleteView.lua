local CTaskCompleteView = class("CTaskCompleteView", CViewBase)

CTaskCompleteView.Type =
{
	ShiMen = 1,
}

function CTaskCompleteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskCompleteView.prefab", cb)
	--界面设置
	self.m_DepthType = "Notify"
	self.m_Type = nil
end

function CTaskCompleteView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_ShiMenWidget = self:NewUI(2, CBox)
	self:InitContent()
end

function CTaskCompleteView.InitContent(self)

end

function CTaskCompleteView.SetType(self, iType)
	self.m_Type = iType 
	if iType == CTaskCompleteView.Type.ShiMen then
		self.m_ShiMenWidget:SetActive(true)
		local cb = function ()
			nettask.C2GSFinishShimenTask()
			g_TaskCtrl:DoNextRoundShimenTask()
			self:CloseView()
		end
		Utils.AddTimer(cb, 0, 2)
	end
end

return CTaskCompleteView