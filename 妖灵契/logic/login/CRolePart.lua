local CRolePart = class("CRolePart", CBox)

function CRolePart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_RoleBox = self:NewUI(1, CBox)
	self.m_CreateBox = self:NewUI(2, CBox)
	self.m_RoleGrid = self:NewUI(3, CGrid)
	self.m_Server = nil
	self:InitContent()
end

function CRolePart.InitContent(self)
	self.m_RoleBox:SetActive(false)
	self.m_CreateBox:SetActive(false)
end

function CRolePart.SetServer(self, dServer)
	self.m_RoleGrid:Clear()
	if not dServer then
		return
	end
	self.m_Server = dServer
	local lRoles = g_ServerCtrl:GetServerRoles(dServer.server_id)
	local iLastPid = IOTools.GetClientData("last_login_pid")
	for i, dRole in ipairs(lRoles) do
		local oBox = self.m_RoleBox:Clone()
		oBox:SetActive(true)
		oBox.m_AvatarSpr = oBox:NewUI(1, CSprite)
		oBox.m_GradeLabel = oBox:NewUI(2, CLabel)
		oBox.m_NameLabel = oBox:NewUI(3, CLabel)
		oBox.m_TipLabel = oBox:NewUI(4, CLabel)
		oBox.m_AvatarSpr:SpriteAvatar(dRole.icon)
		oBox.m_NameLabel:SetText(dRole.name)
		oBox.m_GradeLabel:SetText(dRole.grade)
		if iLastPid and dRole.pid == iLastPid then
			oBox.m_TipLabel:SetText("#G上次登录#n")
		end
		oBox:AddUIEvent("click", callback(self, "OnSelRole", dRole))
		self.m_RoleGrid:AddChild(oBox)
	end

	local oBox = self.m_CreateBox:Clone()
	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnCreateRole"))
	self.m_RoleGrid:AddChild(oBox)
	self.m_RoleGrid:Reposition()
end

function CRolePart.OnSelRole(self, dRole)
	g_LoginCtrl:SetLoginAccountCb(function()
			g_LoginCtrl:LoginRole(g_LoginCtrl:GetAccount(), dRole.pid)
		end)
	g_LoginCtrl:ConnectServer(self.m_Server)
end

function CRolePart.OnCreateRole(self)
	local oView = CLoginView:GetView()
	if oView then
		g_LoginCtrl:SetConnectServer(self.m_Server)
	end
	g_CreateRoleCtrl:StartCreateRole()
	CSelectServerView:CloseView()
end

return CRolePart