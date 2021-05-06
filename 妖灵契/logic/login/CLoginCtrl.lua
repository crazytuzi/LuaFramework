local CLoginCtrl = class("CLoginCtrl")

function CLoginCtrl.ctor(self)
	self:InitValue()
	-- self:SetNoticeList({
	-- 	{id=1, content="111111111", title="1"},
	-- 	{id=2, content="222222222", title="2"}
	-- })
	self.m_Notices = {}
	self.m_NoticeMd5 = nil
end

function CLoginCtrl.InitValue(self)
	self.m_LoginInfo = {account=nil, pid=nil, role_token=nil,role_list={}} --登录成功数据
	self.m_ReconnectInfo = {account = nil,token = nil,pid = nil,role_token = nil} --重登数据
	self.m_VerifyInfo = {account = nil,token = nil} --验证数据
	self.m_LoginAccountCb = nil
	self.m_ConnectServer = nil
	self.m_CreateRoleLogin = false
end

function CLoginCtrl.Logout(self)
	if g_LoginCtrl.IsSdkLogin() then
		g_SdkCtrl:Logout()
	else
		self:ChangeAccount()
		local oView = CLoginView:GetView()
		if oView then
			oView:CheckShowPage()
		else
			CLoginView:ShowView()
		end
	end
end

function CLoginCtrl.ChangeAccount(self)
	self:LogoutProcess()
	g_NetCtrl:Disconnect()
end

function CLoginCtrl.LogoutProcess(self)
	g_ServerCtrl:ClearServerData()
	if g_LoginCtrl:HasLoginInfo() then
		netlogin.C2GSChangeAccount()
	end
	if self:HasLoginRole() then
		netlogin.C2GSLogoutByOneKey()
	end
	self:InitValue()
	g_NetCtrl:Disconnect()
	local oView = CLoginView:GetView()
	if oView then
		oView:CheckShowPage()
	end
	main.ResetGame({"CLoginView"})
end

function CLoginCtrl.IsSdkLogin(self)
	return (main.g_AppType  ~= "dev") and (main.g_SdkLogin == 1)
end

function CLoginCtrl.LoginRoleHide(self)
	if CLoginView:GetView() then
		CLoginView:CloseView()
		g_ResCtrl:GC()
	end
	CSelectServerView:CloseView()
end

function CLoginCtrl.SetLoginAccountCb(self, cb)
	self.m_LoginAccountCb = cb
end

function CLoginCtrl.GetAccount(self)
	if self.m_LoginInfo["account"] then
		return self.m_LoginInfo["account"]
	else
		return self.m_VerifyInfo["account"]
	end
end

function CLoginCtrl.GetNoticeMd5(self)
	return self.m_NoticeMd5
end

function CLoginCtrl.ReadNotices(self)
	if self.m_NoticeMd5  then
		IOTools.SetClientData("notice_info", {md5=self.m_NoticeMd5, time=os.time()})
		return self.m_Notices
	end
end

--{[{title:"",content:"json",hot:3},]}
function CLoginCtrl.SetNoticeList(self, lNotices)
	lNotices = lNotices or {}
	if next(lNotices) then
		for i, dNotice in ipairs(lNotices) do
			dNotice.content = decodejson(dNotice.content)
		end
		self.m_Notices = lNotices
		self.m_NoticeMd5 = Utils.MD5HashString(cjson.encode(lNotices))
		table.print(self.m_Notices, "设置公告:")
	end
end

function CLoginCtrl.IsForceShowNotice(self)
	if self.m_NoticeMd5  then
		local info = IOTools.GetClientData("notice_info") or {}
		if info.md5 then
			if info.time then
				if os.date("%j", info.time) ~= os.date("%j") then
					return true
				end
			else
				return true
			end
		else
			return true
		end
	end
	return false 
end

function CLoginCtrl.UpdateVerifyInfo(self, dInfo)
	table.update(self.m_VerifyInfo, dInfo)
end

function CLoginCtrl.UpdateLoginInfo(self, dInfo)
	table.update(self.m_LoginInfo, dInfo)
end

function CLoginCtrl.ConnectServer(self, dServer)
	if g_NetCtrl:IsConnecting() and self.m_ConnectServer and dServer and table.equal(self.m_ConnectServer, dServer) then
		g_NotifyCtrl:FloatMsg("正在连接这个服务器，请稍等")
		print("正在连接这个服务器，请稍等")
		return
	end
	if dServer then
		self.m_ConnectServer = dServer
	end
	if not self.m_ConnectServer then
		g_NotifyCtrl:FloatMsg("服务器信息不存在")
		print("服务器信息不存在")
		self:HideLoginTips()
		return
	end
	IOTools.SetClientData("login_server", self.m_ConnectServer)
	local sIP = self.m_ConnectServer.ip
	local lPort = self.m_ConnectServer.ports or {}
	lPort = table.extend(lPort, g_ServerCtrl:GetCommonPort())
	g_NetCtrl:Connect(sIP, lPort)
end

function CLoginCtrl.GetLoginInfo(self, sKey)
	return self.m_LoginInfo[sKey]
end

function CLoginCtrl.ClearReconnectInfo(self)
	self.m_ReconnectInfo = {account = nil,token = nil,pid = nil,role_token = nil}
end

function CLoginCtrl.ClearLoginInfo(self)
	self.m_LoginInfo = {account=nil, token = nil, pid=nil, role_token=nil, role_list={}} --登录成功数据
end

function CLoginCtrl.HasLoginInfo(self)
	return (self.m_LoginInfo.token ~= nil) or (self.m_LoginInfo.account~=nil)
end

function CLoginCtrl.HasLoginRole(self)
	return self:HasLoginInfo() and (g_AttrCtrl.pid ~= 0)
end

function CLoginCtrl.HasReconnectInfo(self)
	return (self.m_ReconnectInfo.token and self.m_ReconnectInfo.role_token and self.m_ReconnectInfo.pid)
	or self.m_ReconnectInfo.token or self.m_ReconnectInfo.account
end

function CLoginCtrl.IsNeedCreateRole(self)
	return self:HasLoginInfo() and next(self.m_LoginInfo["role_list"]) == nil
end

function CLoginCtrl.IsHello(self)
	return self.m_IsHello
end

function CLoginCtrl.SetConnectServer(self, dServer)
	self.m_ConnectServer = dServer
end

function CLoginCtrl.GetConnectServer(self)
	return self.m_ConnectServer
end

function CLoginCtrl.GetPlatformID(self)
	local platid = 4
	if Utils.IsAndroid() then
		platid = 1
	elseif Utils.IsIOS() then
		platid = 3
	end
	return platid
end

function CLoginCtrl.LoginAccount(self, account, token)
	if not g_NetCtrl:IsValidSession(1001) then
		return 
	end
	local platid = self:GetPlatformID()
	local sVer = table.concat({C_api.Utils.GetResVersion()}, ".")
	local iQrcode = g_QRCodeCtrl:IsQRCodeLogin() and 1 or 0
	netlogin.C2GSLoginAccount(account, token, Utils.GetDeviceModel(), platid, Utils.GetMac(),
	 main.g_ProtoVer, sVer, UnityEngine.SystemInfo.operatingSystem, Utils.GetDeviceUID(), "", iQrcode)
end

function CLoginCtrl.LoginRole(self, account, pid)
	if g_LoginCtrl:HasLoginRole() then
		return
	end
	if g_CreateRoleCtrl:IsInCreateRole() then
		-- if not IOTools.GetClientData("cg_played") then
		-- 	IOTools.SetClientData("cg_played", 1)
		-- end
		-- CLoginView:CloseView()
		-- Utils.PlayCG(function()
		-- 	netlogin.C2GSLoginRole(account, pid)
		-- 	end)
		-- return
	end
	netlogin.C2GSLoginRole(account, pid)
end

function CLoginCtrl.IsShenheServer(self)
	local dServer = g_LoginCtrl:GetConnectServer()
	return dServer.server_id == "iosshenhe_gs10001" or dServer.server_id == "shenhe_gs10001"
end

function CLoginCtrl.CheckCreateRole(self)
	local bCreate = g_LoginCtrl:IsNeedCreateRole()
	if bCreate then
		local dServer = g_LoginCtrl:GetConnectServer()
		if (dServer.server_id == "iosshenhe_gs10001" or dServer.server_id == "shenhe_gs10001") and Utils.IsIOS() and Utils.GetGameType() ~= "ylq" then
			CCreateRoleShenHeView:ShowView()
		else
			g_CreateRoleCtrl:StartCreateRole()
		end
	else
		CLoginView:ShowView(function(v) 
			v:ShowServerPage()
		end)
	end

	return bCreate
end

--1.连通服务器
function CLoginCtrl.OnServerHello(self)
	--检查导表数据更新
	local lFilePaths = IOTools.GetFilterFiles(IOTools.GetPersistentDataPath("/data"), function(s) return not string.find(s, "%.meta") end, false)
	local lFileVersiosns = {}
	for i, path in ipairs(lFilePaths) do
		local dFielVersion = {}
		dFielVersion.file_name = IOTools.GetFileName(path, true)
		local iVer = 0
		local sData = IOTools.LoadStringByLua(path, "rb", 4)
		if sData then
			iVer = IOTools.ReadNumber(sData, 4)
		end
		dFielVersion.version = iVer
		table.insert(lFileVersiosns, dFielVersion)
	end
	netlogin.C2GSQueryLogin(lFileVersiosns)
	self:ShowLoginTips("验证数据中")
end

--1.1 导表数据更新完成
function CLoginCtrl.OnDataUpdateFinished(self)
	--sdk登录用角色token重连
	if self.m_ReconnectInfo.token and 
			self.m_ReconnectInfo.role_token and 
				self.m_ReconnectInfo.pid then
		netlogin.C2GSReLoginRole(self.m_ReconnectInfo.pid, self.m_ReconnectInfo.role_token)
	elseif self.m_ReconnectInfo.token then
		self:LoginAccount(nil, self.m_ReconnectInfo.token)
	elseif self.m_ReconnectInfo.account then
		self:LoginAccount(self.m_ReconnectInfo.account)
	elseif self.m_VerifyInfo.token then
		self:LoginAccount(nil, self.m_VerifyInfo.token)
	else
		self:LoginAccount(self.m_VerifyInfo.account)
	end
	self:ShowLoginTips("正在登录帐号")
end

--2.帐号密码验证成功
function CLoginCtrl.LoginAccountSuccess(self, account, lSimpleRole)
	self.m_LoginInfo["account"] = account
	self.m_LoginInfo["token"] = self.m_VerifyInfo["token"]
	if self.m_ReconnectInfo.pid then
		print("2.重连角色")
		self:LoginRole(account, self.m_ReconnectInfo.pid)
		return
	end
	if self.m_LoginAccountCb then
		print("2.执行帐号密码回调")
		self.m_LoginAccountCb()
	else
		if next(lSimpleRole) then
			local iLastPid = IOTools.GetClientData("last_login_pid")
			local iMaxGrade = 0
			local iPid
			for i, dRole in pairs(lSimpleRole) do
				if iLastPid and dRole.pid == iLastPid then
					iPid = dRole.pid
					break
				elseif dRole.grade >= iMaxGrade then
					iPid = dRole.pid
				end
			end
			self.m_LoginInfo["role_list"] = lSimpleRole
			self:LoginRole(account, iPid)
		else
			self.m_LoginInfo["role_list"] = {}
			self:CheckCreateRole()
		end
	end
	-- UnityEngine.Shader.WarmupAllShaders()
	g_SysSettingCtrl:ReadLocalSettings()
end
--2.1 验证是否需要邀请码
function CLoginCtrl.CheckInviteCodeResult(self, iResult, sMsg)
	--iResult:0为没有有效邀请码，1为有
	if not iResult or iResult == 0 then
		if sMsg and sMsg ~= "" then
			g_NotifyCtrl:FloatMsg(sMsg)
		end
		local oView = CLoginView:GetView()
		if oView then
			oView:ShowInvitationCodePage()
		end
	end
end

--2.2 验证邀请码是否正确
function CLoginCtrl.SetInviteCodeResult(self, iResult, sMsg)
	--iResult:0为没有有效邀请码，1为有
	if iResult == 1 then
		print("2.2进入创角界面")
		self:ConnectServer()
	else
		sMsg = sMsg or "登录失败，错误码:2.2"
		g_NotifyCtrl:FloatMsg(sMsg)
	end
end

--3.角色创建成功
function CLoginCtrl.CreateRoleSuccess(self, account, tSimpleRole)
	if account == self.m_LoginInfo["account"] then
		table.insert(self.m_LoginInfo["role_list"], tSimpleRole)
	else
		self.m_LoginInfo["account"] = account
		self.m_LoginInfo["role_list"] = {tSimpleRole}
	end
	self:LoginRole(account, tSimpleRole.pid)
	self.m_CreateRoleLogin = true
	--登录缓协议,暂时注释
	--g_NetCtrl:SetCacheProto("loginend", true)
end

--4.角色登录成功
function CLoginCtrl.LoginRoleSuccess(self, iRole)
	IOTools.SetClientData("last_login_pid", iRole)
	self:SaveLoginTime()
	self:ClearReconnectInfo()
	-- TODO:频繁点击请求登陆有可能导致loginSuccess返回后仍请求登陆，此时账号已清空，引bug，暂时屏蔽，以后加loadingview再恢复
	-- self.m_VerifyInfo = {}
	if self.m_CreateRoleLogin then
		self.m_CreateRoleLogin = false
		g_SdkCtrl:UploadData(enum.Sdk.UploadType.create_role)
	end
	Utils.AddTimer(function() 
			g_SdkCtrl:UploadData(enum.Sdk.UploadType.start_game)
		end, 0, 1)
end

--处理cs服务器发来的信息(sdk登录， 扫码登录才有)
function CLoginCtrl.ProcessCSLoginInfo(self, dInfo)
	g_NotifyCtrl:HideConnect()
	--刷新token
	self:UpdateVerifyInfo({token=dInfo.token})
	--刷新服务器信息
	local tServer = {
		common_port = dInfo.server_info.ports,
		servers = {},
		groups = {},
	}
	if dInfo.server_info.groups then
		for i, v in ipairs(dInfo.server_info.groups) do
			tServer.groups[v.id] = v
		end
	end
	if dInfo.server_info.servers then
		for i, v in ipairs(dInfo.server_info.servers) do
			tServer.servers[v.id] = v
		end
	end
	xxpcall(CServerCtrl.SetServerData, g_ServerCtrl, tServer)
	if dInfo.RecommendServerList then
		xxpcall(CServerCtrl.SetRecommendList, g_ServerCtrl, dInfo.RecommendServerList)
	end
	
	--刷新角色列表 role_list
	--{server, pid, icon, name, school, grade}
	xxpcall(CServerCtrl.SetRoleList, g_ServerCtrl, dInfo.role_list)
	--刷新公告  infoList
	xxpcall(CLoginCtrl.SetNoticeList, self,  dInfo.server_info.infoList)
	
	CLoginView:ShowView(function(oView)
		oView:ShowServerPage()
	end)
end

--断线重连
function CLoginCtrl.Reconnect(self)
	main.ResetGame()
	if self:HasLoginInfo() then
		self.m_ReconnectInfo = {
			account = self.m_LoginInfo.account,
			token = self.m_LoginInfo.token,
			pid = self.m_LoginInfo.pid,
			role_token = self.m_LoginInfo.role_token,
		}
		self:ClearLoginInfo()
	end
	g_NotifyCtrl:ShowConnect("正在重连...")
	self:ConnectServer()
	table.print(self.m_ReconnectInfo, "CLoginCtrl.Reconnect:")
end

function CLoginCtrl.ShowLoginTips(self, tips)
	local oView = CLoginView:GetView()
	if oView then
		oView:ShowTipsPage(tips)
	else
		g_NotifyCtrl:ShowConnect(tips)
	end
end

function CLoginCtrl.HideLoginTips(self)
	local oView = CLoginView:GetView()
	if oView  then
		oView:HideTipsPage()
	end
	g_NotifyCtrl:HideConnect()
end

function CLoginCtrl.SaveLoginTime(self)
	local sTime = tonumber(IOTools.GetRoleData("last_login_time"))
	if sTime and g_TimeCtrl:IsToday(sTime) then
		self.m_IsFirstLoginToday = false
	else
		self.m_IsFirstLoginToday = true
	end
	IOTools.SetRoleData("last_login_time", g_TimeCtrl:GetTimeS())
end

function CLoginCtrl.IsFirstLoginToday(self)
	return self.m_IsFirstLoginToday
end

return CLoginCtrl