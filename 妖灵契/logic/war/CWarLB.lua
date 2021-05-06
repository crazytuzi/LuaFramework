local CWarLB = class("CWarLB", CBox)

function CWarLB.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ReplaceMenu = self:NewUI(1, CWarReplaceMenu)
	self.m_ChatBox = self:NewUI(3, CWarMenuChatBox)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:CheckShow()
end

function CWarLB.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.Replace then
		self:CheckShow()
	end
end

function CWarLB.CheckShow(self)
	if not g_ShowWarCtrl:IsCanOperate() then
		return
	end
	local bActive = g_WarCtrl:IsPrepare() or g_WarCtrl:IsReplace()
	self.m_ReplaceMenu:SetActive(bActive)
	self.m_ReplaceMenu:UpdateMenu()
	self.m_ChatBox:SetActive(not bActive and not g_WarCtrl:IsWarStart())
end

return CWarLB