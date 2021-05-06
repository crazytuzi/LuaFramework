local CServerCtrl = class("CServerCtrl", CCtrlBase)
CServerCtrl.g_DevServer = {
	servers ={
		--[1001]={name="开发服",	ip="119.130.207.253", new=0, group=1, state = 2},
		--[1002]={name="林晓龙", ip="192.168.8.78", new=0, group=1, state= 1},
		--[1003]={name="黄成",	ip="192.168.8.104", new=0, group=1, state= 1},
		--[1004]={name="谢桂添", ip="192.168.8.107", new=0, group=1, state= 1},
		--[1005]={name="刘威",	ip="119.130.207.239", new=0, group=2},
		--[1006]={name="顾永豪",	ip="192.168.8.116", new=0, group=1},
		--[1008]={name="湛力健", ip="192.168.8.123", new=0, group=1},
		--[1009]={name="压测服", ip="192.168.8.157", new=0, group=1},
		--[1010]={name="压测服2", ip="businessn1.cilugame.com", new=0, group=1},
		--[1011]={name="分支测试服", ip="192.168.8.138", new=0, group=1},


		[1101]={name="风花雪月", ip="43.226.158.47", new=1, group=2},
		-- [1102]={name="月见岛", ip="47.100.107.145", new=0, group=2},
		--[1102]={name="商务服", ip="businessn1.cilugame.com", new=0, group=2},
		--[1103]={name="安卓审核服", ip="shenhen1.cilugame.com", new=1, group=2},
		--[1104]={name="IOS审核服", ip="119.130.207.253", new=1, group=2},
	},
	groups = {
		[1] = {name="ST"}
	},
	common_port = {7011,7012,27011,27012,27013},
}

CServerCtrl.g_LocalServer = {
	servers ={
		["dev_server_1"]={name="外网测试服", ip="119.130.207.253", new=1, group=3, cs_url="119.130.207.253"},
	},
	groups = {
		[3] = {name="测试"},
	},
	common_port = {7011,7012,27011,27012,27013},
}

function CServerCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_IsInit = false
	self.m_ServerData = {}
	self.m_GroupServers = {}
	self.m_RoleInfos = {} --未登录有游戏服务器之前的角色信息
	self.m_RoleList = {}
	self.m_RecommendList = {} --推荐列表
	-- self:Test()
end

function CServerCtrl.InitServer(self)
	if not g_LoginCtrl.IsSdkLogin() then
		if main.g_AppType  == "dev" then
			self:SetServerData(CServerCtrl.g_DevServer)
		else
			self:SetServerData(CServerCtrl.g_LocalServer)
		end
	end
end

function CServerCtrl.Test(self)
	if Utils.IsEditor() then
		local lRoles = {{server=1001, pid=1, icon=130, name="测试角色", school=1, grade=1}}
		self:SetRoleList(lRoles)
		self.m_RecommendList = {1001}
	end
end

function CServerCtrl.SetRecommendList(self, list)
	self.m_RecommendList = list
end

function CServerCtrl.GetRecommendList(self)
	return self.m_RecommendList
end

function CServerCtrl.SetRoleList(self, lRoles)
	self.m_RoleInfos = {}
	for i, dRole in ipairs(lRoles) do
		if not self.m_RoleInfos[dRole.server] then
			self.m_RoleInfos[dRole.server] = {}
		end
		table.insert(self.m_RoleInfos[dRole.server], dRole)
	end
	self.m_RoleList = lRoles
end

function CServerCtrl.GetRoleList(self)
	return self.m_RoleList
end

function CServerCtrl.GetServerRoles(self, iServer)
	return self.m_RoleInfos[iServer] or {}
end

function CServerCtrl.SetServerData(self, dServer)
	self.m_IsInit = true
	self.m_ServerData = dServer
	self:CheckTestServer()
	self.m_GroupServers = self:ProccessGroupsData(self.m_ServerData)
	table.print(self.m_GroupServers, "CServerCtrl.SetServerData:")
end

function CServerCtrl.ClearServerData(self)
	if g_LoginCtrl:IsSdkLogin() then
		self.m_IsInit = false
		self.m_ServerData = {}
		self.m_GroupServers = {}
	end
end

function CServerCtrl.IsInit(self)
	return self.m_IsInit
end

function CServerCtrl.GetCurServerName(self)
	local oNet = g_NetCtrl:GetNetObj()
	local sName = ""
	if oNet then
		local ip = oNet:GetIP()
		if ip then
			sName = self:GetServerNameByIP(ip)
		end
	end
	return sName
end

function CServerCtrl.GetCommonPort(self)
	return table.copy(self.m_ServerData.common_port) or {}
end

function CServerCtrl.GetServerNameByIP(self, sIP)
	if self.m_ServerData and self.m_ServerData.servers then
		for _, ser in pairs(self.m_ServerData.servers) do
			if ser.ip == sIP then
				return ser.name
			end
		end
	end
	return "未知服务器"
end

function CServerCtrl.GetServerByID(self, id)
	local dServer = self.m_ServerData.servers[id]
	return dServer
end

function CServerCtrl.GetServerByName(self, sServerName)
	for id, dServer in pairs(self.m_ServerData.servers) do
		if dServer.name == sServerName then
			return dServer
		end
	end
end


function CServerCtrl.GetNewestServer(self)
	local dNewServer
	for id, dServer in pairs(self.m_ServerData.servers) do
		if dNewServer then
			if dServer.new > dNewServer.new then
				dNewServer = dServer
			end
		else
			dNewServer = dServer
		end
	end
	return dNewServer
end

function CServerCtrl.GetServerData(self)
	return self.m_ServerData
end

function CServerCtrl.ProccessGroupsData(self, dRawData)
	local dData = table.copy(dRawData)
	local groups = dData.groups
	local max = 0
	for k, v in pairs(groups) do
		v.group_id = k
		v.servers = {}
		if tonumber(k) then
			max = (k > max) and k or max
		end
	end
	local defaultGroup = {name="默认", servers = {}, group_id = max + 1}
	for k, dServer in pairs(dRawData.servers) do
		dServer.server_id = k
		if groups[dServer.group] then
			table.insert(groups[dServer.group].servers, dServer)
		else
			table.insert(defaultGroup.servers, dServer)
		end
	end
	if next(defaultGroup.servers) then
		groups[max] = defaultGroup
	end
	return groups
end

function CServerCtrl.GetGroupServers(self)
	return self.m_GroupServers
end

function CServerCtrl.GetGroupName(self, iSerID)
	local dServer = self:GetServerByID(iSerID)
	local dGroup = self.m_GroupServers[dServer.group]
	if dGroup then
		return dGroup.name
	else
		return "????"
	end
end

function CServerCtrl.CheckTestServer(self)
	if g_LoginCtrl:IsSdkLogin() then
		local dSettingData = g_ApplicationCtrl:GetGameSettingData()
		if dSettingData and (dSettingData.updateMode ~= enum.UpdateMode.Update) and not define.Url.Ori_Release then
			self.m_ServerData.servers = table.merge(self.m_ServerData.servers, CServerCtrl.g_LocalServer.servers)
			self.m_ServerData.groups = table.merge(self.m_ServerData.groups, CServerCtrl.g_LocalServer.groups)
			CLoginServerPage.ConnectServer = function(o)
				if o:IsCanConnect() then
					local bSwitchCS = false
					if o.m_Server.cs_url then
						if not define.Url.Ori_Release then
							define.Url.Ori_Release = define.Url.Release 
						end
						if define.Url.Release ~= o.m_Server.cs_url then
							bSwitchCS = true
							define.Url.Release = o.m_Server.cs_url
						end
					end
					if bSwitchCS then
						print("切换CS地址:"..define.Url.Release)
						g_NotifyCtrl:FloatMsg("切换CS地址:"..define.Url.Release)
						g_LoginCtrl:Logout()
					else
						g_LoginCtrl:ShowLoginTips("正在连接服务器")
						g_LoginCtrl:ConnectServer(o.m_Server)
					end
				end
			end
		end
	end
end

function CServerCtrl.ServerKeyToNumer(self, sKey)
	return tonumber(sKey) or tonumber(string.match(sKey, "%w+_%a+(%d*)")) or 0
end

return CServerCtrl