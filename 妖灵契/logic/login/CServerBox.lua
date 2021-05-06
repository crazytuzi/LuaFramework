local CServerBox = class("CServerBox", CBox)

function CServerBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_StateSpr = self:NewUI(2, CSprite)
	self.m_LvlLabel = self:NewUI(3, CLabel)
	self.m_NewSpr = self:NewUI(4, CSprite)
	self.m_ServerInfo = nil
end

function CServerBox.SetServer(self, dServer)
	self.m_Server = dServer
	self.m_NameLabel:SetText(dServer.name)
	local iLastPid = IOTools.GetClientData("last_login_pid")
	local lRoles = g_ServerCtrl:GetServerRoles(dServer.server_id)
	local dRoleInfo
	for i, dRole in pairs(lRoles) do
		if iLastPid and dRole.pid == iLastPid then
			dRoleInfo = dRole
			break
		end
	end
	if not dRoleInfo and next(lRoles) then
		dRoleInfo = lRoles[1]
	end
	if dRoleInfo then
		self.m_LvlLabel:SetText(dRoleInfo.name.." lv"..tostring(dRoleInfo.grade))
	else
		self.m_LvlLabel:SetText("")
	end
	
	self.m_NewSpr:SetActive(dServer.new and dServer.new == 1)
	local iState = dServer.state or 1
	local tMap = {
		[0] = "pic_weihu",
		[1] = "pic_kongxian",
		[2] = "pic_yongji",
		[3] = "pic_baoman",
	}
	if tMap[iState] then
		self.m_StateSpr:SetActive(true)
		self.m_StateSpr:SetSpriteName(tMap[iState])
		self.m_StateSpr:MakePixelPerfect()
	else
		self.m_StateSpr:SetActive(false)
	end
end

function CServerBox.GetServer(self)
	return self.m_Server
end

return CServerBox