local CCreateRoleView = class("CCreateRoleView", CViewBase)

function CCreateRoleView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/CreateRoleView.prefab", cb)
	self.m_GroupName = "main"
	self.m_DepthType = "Menu"
end

function CCreateRoleView.OnCreateView(self)
	self.m_MainPage = self:NewPage(1, CCreateRoleMainPage)
	self.m_BranchPage = self:NewPage(2, CCreateRoleBranchPage)
	self.m_Container = self:NewUI(3, CWidget)
	self:InitContent()
end

function CCreateRoleView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self:ShowMainPage()
end

function CCreateRoleView.ShowMainPage(self)
	g_CreateRoleCtrl:SetCreateData("mode", "school")
	g_CreateRoleCtrl:SetCreateData("branch", 1)
	self:ShowSubPage(self.m_MainPage)
	self.m_MainPage:Refresh()
end

function CCreateRoleView.ShowBranchPage(self)
	self:ShowSubPage(self.m_BranchPage)
	self.m_BranchPage:SetSchool(g_CreateRoleCtrl:GetCreateData("school"))
end

return CCreateRoleView