local login = {
	servers,
	forces,
	recentServerIds,
	localLastSer,
	serverMsg,
	serverMsg2,
	loginRet1,
	loginRet2,
	isSDKLogin,
	queue,
	zoneId,
	sdk39UserId,
	sdk39UserName,
	showRechargeOnCheckSvr = true,
	type = "",
	checkType = 0,
	ac = "",
	groupIndex = 1,
	curMirver = 180,
	server = 0,
	hasCheckServer = false,
	maxRecentServerNum = 2,
	checkServerType = 0,
	pw = "",
	serverLevel = 0,
	isEnterGame = false,
	ipLine = 1,
	uptUrl = "",
	chk_respath = "public/chk_res/",
	skipDoorAni = false,
	selectIndex = 1,
	mirverServers = {},
	notice = {},
	groups = {},
	loginState = GameStateType.login
}
SvrCheckType = {
	RandomUI = 1,
	NoCheck = 0,
	ChangeSkin = 2
}
login.setServerList = function (self, data)
	self.loadCheckSvrCfg(self)

	self.servers = data
	local lastServerId = self.getLastServerId(self)

	if lastServerId and lastServerId ~= "" then
		local lastServerData = nil

		for i, v in ipairs(data) do
			lastServerData = lastServerId == v.id and v

			if lastServerData then
				break
			end
		end
	end

	self.hasCheckServer = false

	for i, v in ipairs(data) do
		if v.isCheckServer == 1 then
			self.hasCheckServer = true

			if self.checkType == SvrCheckType.ChangeSkin then
				lastServerData = v
			end

			break
		end
	end

	if lastServerData then
		self.setLocalLastServer(self, lastServerData)
	end

	return 
end
login.loadCheckSvrCfg = function (self)
	local file = io.readfile(cc.FileUtils:getInstance():fullPathForFilename(self.chk_respath .. "checkSvrCfg.json"))

	if file then
		local checkSvrCfg = json.decode(file)

		if checkSvrCfg then
			print_r(checkSvrCfg)

			self.showRechargeOnCheckSvr = checkSvrCfg.showRechargeOnCheckSvr
			self.checkType = checkSvrCfg.checkType
		end
	end

	return 
end
login.getChkResPath = function (self)
	return self.chk_respath .. "res/"
end
login.getChkConfigPath = function (self)
	return self.chk_respath .. "config/"
end
login.setVerServers = function (self, ver, data)
	self.curMirver = ver
	self.mirverServers[ver] = data

	self.setServerList(self, data)

	return 
end
login.setSerMaintainInfo = function (self, info)
	self.maintainInfo = info

	return 
end
login.setWhiteList = function (self, whiteList)
	self.isWhiteList = whiteList

	return 
end
login.setUptUrl = function (self, uptUrlString)
	print("login:setUptUrl -- uptUrlString = ", uptUrlString)

	self.uptUrl = uptUrlString

	return 
end
login.setAnnounce = function (self, announce)
	self.announcement = announce

	return 
end
login.getServersByVer = function (self, ver)
	return self.mirverServers[ver]
end
login.setServerTime = function (self, time)
	self.serverTime = time

	return 
end
login.setNotice = function (self, data)
	self.notice = data

	return 
end
login.setForceList = function (self, data)
	self.forces = data

	return 
end
login.getServerId = function (self, data)
	return data.id
end
login.parseServerFullName = function (self, fullName)
	local t = string.split(fullName, "\t")

	return t[1], (t[2] and tonumber(t[2])) or 1
end
login.getLastServerId = function (self)
	if not self.recentServerIds or #self.recentServerIds == 0 then
		self.recentServerIds = cache.getLastServerId()
	end

	if #self.recentServerIds ~= 0 then
		return self.recentServerIds[1]
	end

	return 
end
login.getRecentServerIds = function (self)
	if not self.recentServerIds or #self.recentServerIds == 0 then
		self.recentServerIds = cache.getLastServerId()
	end

	return self.recentServerIds
end
login.setLocalLastServer = function (self, data)
	self.localLastSer = data
	local serverId = self.getServerId(self, data)

	if not self.recentServerIds or #self.recentServerIds == 0 then
		self.recentServerIds = cache.getLastServerId()
	end

	table.removebyvalue(self.recentServerIds, serverId)
	table.insert(self.recentServerIds, 1, serverId)

	local curNum = #self.recentServerIds

	if self.maxRecentServerNum < curNum then
		self.recentServerIds[curNum] = nil
	end

	cache.saveLastServerId(self.recentServerIds)
	print("self.checkType = ", self.checkType)

	if self.checkType ~= SvrCheckType.NoCheck and data.isCheckServer == 1 then
		self.checkServerType = self.checkType
	else
		self.checkServerType = 0
	end

	return 
end
login.setSelectServer = function (self, ip, port, sessionid)
	self.ip = ip
	self.port = port
	self.sessionid = sessionid

	return 
end
login.getSelectGroup = function (self)
	if self.groupIndex <= #self.groups then
		return self.groups[self.groupIndex]
	end

	return {}
end
login.setSDKLogin = function (self, b)
	self.isSDKLogin = b

	return 
end
login.setQueueData = function (self, msg)
	if not msg then
		self.queue = nil
	else
		self.queue = {
			pos = msg.param,
			cnt = msg.tag,
			sec = msg.series
		}
	end

	return 
end
login.isCheckServer = function (self)
	local flag = false

	if self.checkServerType ~= SvrCheckType.NoCheck then
		flag = true
	end

	return flag
end
login.getServerType = function (self)
	return (g_data.login.localLastSer and g_data.login.localLastSer.isCheckServer) or 0
end
login.isChangeSkinCheckServer = function (self)
	local flag = false

	if self.checkServerType == SvrCheckType.ChangeSkin then
		flag = true
	end

	return flag
end
login.showShopAndRechargeBtn = function (self)
	local flag = true

	if self.isCheckServer(self) and self.showRechargeOnCheckSvr == false and device.platform == "ios" then
		flag = false
	end

	return flag
end
login.setEnterGameState = function (self, state)
	self.isEnterGame = state

	return 
end
login.setLoginState = function (self, state)
	print("login.state = ", state)

	self.loginState = state

	return 
end
login.getLoginState = function (self)
	return self.loginState
end
login.getLoginTCP = function (self)
	if not self.loginTCP then
		local loginTcp = MirTcpClient:newInstance()

		loginTcp.setIsFreeOnTerminate(loginTcp, false)
		loginTcp.setIsLoopConnected(loginTcp, false)

		self.loginTCP = loginTcp
	end

	return self.loginTCP
end
login.closeLoginTCP = function (self)
	local tcp = self.getLoginTCP(self)

	if tcp and tcp.isConnected(tcp) then
		tcp.disconnect(tcp, false)
	end

	return 
end

return login
