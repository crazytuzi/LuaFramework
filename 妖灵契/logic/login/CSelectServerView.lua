local CSelectServerView =  class("CSelectServerView", CViewBase)

function CSelectServerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/SelectServerView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CSelectServerView.OnCreateView(self)
	self.m_GroupBtn = self:NewUI(1, CButton, true, false)
	self.m_GroupGrid = self:NewUI(2, CGrid)
	self.m_ServerBox = self:NewUI(3, CServerBox)
	self.m_ServerGrid = self:NewUI(4, CGrid)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_ConfirmBtn = self:NewUI(6, CButton)
	self.m_RolePart = self:NewUI(7, CRolePart)
	self.m_RoleBox = self:NewUI(8, CBox)
	self.m_LastLoginLabel = self:NewUI(9, CLabel)
	self.m_CurServer = nil
	self.m_ConfirmCb = nil
	self:InitContent()
end

function CSelectServerView.SelectCurServer(self, dServer)
	self.m_CurServer = dServer
end

function CSelectServerView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_GroupBtn:SetActive(false)
	self.m_ServerBox:SetActive(false)
	self.m_RolePart:SetActive(false)
	self.m_RoleBox:SetActive(false)

	local dServer = IOTools.GetClientData("login_server")
	if dServer then
		self.m_LastLoginLabel:SetText(dServer.name)
	else
		self.m_LastLoginLabel:SetText("暂无")
	end
	self:RerfeshGroupGrid()
end

function CSelectServerView.SetConfirmCb(self, cb)
	self.m_ConfirmCb = cb
end

function CSelectServerView.RerfeshGroupGrid(self)
	self.m_GroupGrid:Clear()
	--已有角色按钮
	if next(g_ServerCtrl:GetRoleList()) then
		local oBtn = self.m_GroupBtn:Clone(false)
		oBtn:SetActive(true)
		oBtn:SetText("已有角色")
		oBtn.m_ShowRoles = true
		oBtn:SetGroup(self.m_GroupGrid:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnSelectGroup"))
		self.m_GroupGrid:AddChild(oBtn)
	end

	if next(g_ServerCtrl:GetRecommendList()) then
		local oBtn = self.m_GroupBtn:Clone(false)
		oBtn:SetActive(true)
		oBtn:SetText("推荐服务器")
		oBtn.m_ShowRecommend = true
		oBtn:SetGroup(self.m_GroupGrid:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnSelectGroup"))
		self.m_GroupGrid:AddChild(oBtn)
	end

	--服务器按钮
	local function sortfunc(d1, d2)
		if d1.new ~= d2.new then
			return d1.new > d2.new
		end
		return d1.server_id > d2.server_id
	end
	self.m_GroupServers = g_ServerCtrl:GetGroupServers()
	table.print(self.m_GroupServers, "GroupServers------------------------>")
	local lGroupKeys = table.keys(self.m_GroupServers)
	table.sort(lGroupKeys)
	for i, group_id in ipairs(lGroupKeys) do
		local dGroup = self.m_GroupServers[group_id]
		local oBtn = self.m_GroupBtn:Clone(false)
		oBtn:SetActive(true)
		oBtn:SetGroup(self.m_GroupGrid:GetInstanceID())
		oBtn:SetText(dGroup.name)
		oBtn.m_GroupID = group_id
		table.sort(dGroup.servers, sortfunc)
		oBtn:AddUIEvent("click", callback(self, "OnSelectGroup"))
		self.m_GroupGrid:AddChild(oBtn)
	end
	local oDefaultBtn = self.m_GroupGrid:GetChild(1)
	if oDefaultBtn then
		self:OnSelectGroup(oDefaultBtn)
	end
end


function CSelectServerView.OnSelectGroup(self, oBtn)
	oBtn:SetSelected(true)
	self.m_ServerGrid:Clear()
	if oBtn.m_ShowRecommend then
		local list = g_ServerCtrl:GetRecommendList()
		for i, serid in ipairs(list) do
			local dServer = g_ServerCtrl:GetServerByID(serid)
			if dServer then
				local oBox = self:CreateServerBox(dServer)
				self.m_ServerGrid:AddChild(oBox)
			end
		end
	elseif oBtn.m_ShowRoles then
		local lRoles = g_ServerCtrl:GetRoleList()
		for i, dRole in ipairs(lRoles) do
			local oBox = self:CreateRoleBox(dRole)
			self.m_ServerGrid:AddChild(oBox)
		end
	else
		local lServer = self.m_GroupServers[oBtn.m_GroupID].servers
		for i, dServer in ipairs(lServer) do
			local oBox = self:CreateServerBox(dServer)
			self.m_ServerGrid:AddChild(oBox)
		end
	end
	self.m_ServerGrid:Reposition()
end

function CSelectServerView.CreateServerBox(self, dServer)
	local oBox = self.m_ServerBox:Clone()
	oBox:SetActive(true)
	oBox:SetServer(dServer)
	oBox:SetGroup(self.m_ServerGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnSelectServer"))
	return oBox
end

function CSelectServerView.CreateRoleBox(self, dRole)
	local oBox = self.m_RoleBox:Clone()
	oBox:SetActive(true)
	oBox.m_ServerLabel = oBox:NewUI(1, CLabel)
	oBox.m_AvatarSprite = oBox:NewUI(2, CSprite)
	oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
	local dServer = g_ServerCtrl:GetServerByID(dRole.server)
	if dServer then
		local sServer = g_ServerCtrl:GetGroupName(dServer.server_id).." "..dServer.name
		oBox.m_ServerLabel:SetText(sServer)
	else
		oBox.m_ServerLabel:SetText("????")
	end

	oBox.m_AvatarSprite:SpriteAvatar(dRole.icon)
	oBox.m_GradeLabel:SetText(dRole.name.." lv"..tostring(dRole.grade))
	oBox:SetGroup(self.m_ServerGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnSelectRole"))
	oBox.m_Server = dServer
	return oBox
end

function CSelectServerView.SelectRoleBox(self, oBox)
	oBox:SetSelected(true)
	local dServer= oBox.m_Server
	if not Utils.IsDevUser() then
		self.m_RolePart:SetServer(dServer)
	end
	self.m_CurServer = dServer
end

function CSelectServerView.SelectServerBox(self, oBox)
	oBox:SetSelected(true)
	local dServer= oBox.m_Server
	if not Utils.IsDevUser() then
		self.m_RolePart:SetServer(dServer)
	end
	self.m_CurServer = dServer
end

function CSelectServerView.OnSelectRole(self, oBox)
	self:SelectRoleBox(oBox)
	self:OnConfirm()
end

function CSelectServerView.OnSelectServer(self, oBox)
	self:SelectServerBox(oBox)
	self:OnConfirm()
end

function CSelectServerView.AutoSelect(self)
	if not self.m_CurServer then
		local lGroupKeys = table.keys(self.m_GroupServers)
		table.sort(lGroupKeys)
		local group_id = lGroupKeys[1]
		if group_id then
			self.m_CurServer = g_ServerCtrl:GetNewestServer()
		end
	end
	if not self.m_CurServer then
		return
	end
	local bFindGroup = false
	for i, oBtn in ipairs(self.m_GroupGrid:GetChildList()) do
		if oBtn.m_GroupID == self.m_CurServer.group then
			bFindGroup = true
			self:OnSelectGroup(oBtn)
			break
		end
	end
	if not bFindGroup then
		return
	end
	for i, oBox in ipairs(self.m_ServerGrid:GetChildList()) do
		if oBox.m_Server.server_id == self.m_CurServer.server_id then
			self:OnSelectServer(oBox)
			return
		end
	end
	self.m_CurServer = nil
end

function CSelectServerView.SetServer(self, dServer)
	self.m_CurServer = dServer
	-- self:AutoSelect()
end

function CSelectServerView.OnConfirm(self)
	if self.m_ConfirmCb and self.m_CurServer then
		self.m_ConfirmCb(self.m_CurServer)
	end
	self:CloseView()
end

return CSelectServerView