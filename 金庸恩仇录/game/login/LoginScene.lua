require("utility.Func")
require("network.NetworkHelper")
require("game.game")
require("data.data_url")
require("utility.richtext.richText")

local MANAGE_STATUS_1 = 1 -- 爆满
local MANAGE_STATUS_2 = 2 -- 忙碌
local MANAGE_STATUS_3 = 3 -- 正常
local MANAGE_STATUS_4 = 4 -- 维护

local resetData = function ()
	require("game.Bag.BagCtrl").setRequest(false)
	require("game.Spirit.SpiritCtrl").clear()
end

local LoginScene = class("LoginScene", function (...)
	return display.newScene("LoginScene")
end)

function LoginScene:ctor(param)
	
	if device.platform == "windows" or device.platform == "mac" then
		param = param or {}
		cc.FileUtils:getInstance():setPopupNotify(true)
	end
	
	cc.Director:getInstance():purgeCachedData()
	GameAudio = require("utility.GameAudio")
	GameAudio.init()
	game.player.chn_flag = param.chn_flag or ""
	game.player.versionInfo = param.versionInfo or nil
	game.runningScene = self
	self:init()
	GameAudio.preloadMusic(ResMgr.getSFX(SFX_NAME.u_queding))
	GameAudio.playMainmenuMusic(true)
	resetData()
	GameStateManager:resetState()
	PageMemoModel.Reset()
	MapModel:init()
	
	--if device.platform == "ios" then
	--	local layer = require("app.scenes.UserLogin").new({})
	--	self:addChild(layer, 100, 100)
	--end
	
end

--验证登录
function LoginScene:verifyLogin(callback)
	local deviceinfo = CSDKShell.GetDeviceInfo()
	local uac = game.player.m_sdkID
	local acc = game.player.m_sdkID
	local function loadStorge(...)
		uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
		--[[
		local q = string.find(uac, "_")
		if q ~= nil and q > 0 then
			acc = uac
		else
			acc = "simulate__" .. cc.UserDefault:getInstance():getStringForKey("accid")
		end
		]]
		acc = uac
		game.player:setUid(acc)
	end
	--if device.platform == "mac" or device.platform == "windows" then
	loadStorge()
	--end
	local network = require("utility.GameHTTPNetWork").new()
	local msg = {}
	msg.m = "login"
	msg.a = "login"
	msg.platformID = CSDKShell.getChannelID()
	msg.chn_flag = game.player.chn_flag or ""
	msg.deviceinfo = deviceinfo
	--if device.platform == "mac" or device.platform == "windows" then
	msg.SessionId = game.player.m_sessionID
	msg.acc = acc
	msg.uac = uac
	msg.loginName = game.player.m_loginName
	--else
	--	msg.a = "loginYouai"
	--	msg.channelId = CSDKShell.getYAChannelID()
	--	msg.token = game.player.m_sessionID
	--	msg.version = CSDKShell.getVersion()
	--end
	msg.packetTag = PacketTag
	local function cb(data)
		--[[
		if data.errorCode == 101 then
			device.showAlert(common:getLanguageString("@Hint"), common:getLanguageString("@HintSDKError"), common:getLanguageString("@OK"), function (...)
				GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
			end)
		end
		dump(data)
		]]
		self._serverlist = {}
		self._lastserverlist = {}
		if data.errCode ~= 0 then
			dump(data)
			show_tip_label(data_error_error[data.errCode].prompt)
			return
		end
		game.player.m_acc = data.rtnObj.user.acc
		game.player.m_loginName = data.rtnObj.user.lac
		--[[
		if device.platform == "ios" or device.platform == "android" then
			game.player:setUid(data.rtnObj.user.acc)
			if data.rtnObj.user.extend ~= nil then
				game.player:setExtendData(data.rtnObj.user.extend)
				dump(data.rtnObj.user.extend)
			end
		end
		]]
		self._serverlist = data.rtnObj.servers
		if data.rtnObj.serverList then
			self._lastserverlist = data.rtnObj.serverList
		end
		
		print("服务器列表:")
		dump(self._serverlist)
		
		--[[
		if device.platform == "windows" or device.platform == "mac" then
			self._serverlist = data.rtnObj.servers
			if data.rtnObj.serverList then
				self._lastserverlist = data.rtnObj.serverList
			end
			dump(self._serverlist)
		else
			local debugID = 1
			self._serverlist = {}
			self._lastserverlist = {}
			for k, v in ipairs(data.rtnObj.servers) do
				if v.debug == debugID then
					table.insert(self._serverlist, v)
				end
			end
			if data.rtnObj.serverList then
				for k, v in ipairs(data.rtnObj.serverList) do
					if v.debug == debugID then
						table.insert(self._lastserverlist, v)
					end
				end
			end
			dump(self._serverlist)
		end
		]]
		game.player.m_defaultServer = cc.UserDefault:getInstance():getIntegerForKey("dfs", 1)
		if game.player.m_defaultServer == nil or game.player.m_defaultServer == 0 then
			game.player.m_defaultServer = 1
		else
			local len = cc.UserDefault:getInstance():getIntegerForKey("serlen", 0)
			local currentLen = #self._serverlist
			if len > 0 and len < currentLen then
				game.player.m_defaultServer = game.player.m_defaultServer + (currentLen - len)
			end
		end
		device.hideActivityIndicator()
		self:onSelectedServer(2, game.player.m_defaultServer)
		if callback then
			callback()
		end
	end
	
	device.showActivityIndicator()
	network:SendRequest(1, msg, cb, nil, NewServerInfo.CHECK_LOGIN_URL)
	--[[
	device.showActivityIndicator()
	local function request()
		NetworkHelper.request(
		NewServerInfo.CHECK_LOGIN_URL,
		msg,
		function(data)
			if data.errCode ~= 0 then
				if data.errmsg ~= nil then
					show_tip_label(data.errmsg)
				else
					show_tip_label(data_error_error[data.errCode].prompt)
				end
			else
				cb(data)
			end
		end,
		"POST")
	end
	request()
	]]
end

--[[刷新服务器]]
function LoginScene:refreshServerList(callback)
	local deviceinfo = CSDKShell.GetDeviceInfo()
	local acc = game.player.m_uid
	local network = require("utility.GameHTTPNetWork").new()
	local msg = {}
	msg.m = "login"
	msg.a = "list"
	msg.platformID = CSDKShell.getChannelID()
	msg.chn_flag = game.player.chn_flag or ""
	msg.SessionId = game.player.m_sessionID
	msg.acc = acc
	msg.packetTag = PacketTag
	local function cb(data)
		--1
		if data.errCode ~= nil and data.errCode ~= 0 then
			dump(data)
			show_tip_label(data_error_error[data.errCode].prompt)
			return
		end
		
		self._serverlist = data.rtnObj.servers
		if data.rtnObj.serverList then
			self._lastserverlist = data.rtnObj.serverList
		end
		dump(self._serverlist)
		--[[
		--2
		if device.platform == "windows" or device.platform == "mac" then
			self._serverlist = data.rtnObj.servers
			if data.rtnObj.serverList then
				self._lastserverlist = data.rtnObj.serverList
			end
			dump(self._serverlist)
		else
			local debugID = 1
			self._serverlist = {}
			self._lastserverlist = {}
			for k, v in ipairs(data.rtnObj.servers) do
				if v.debug == debugID then
					table.insert(self._serverlist, v)
				end
			end
			if data.rtnObj.serverList then
				for k, v in ipairs(data.rtnObj.serverList) do
					if v.debug == debugID then
						table.insert(self._lastserverlist, v)
					end
				end
			end
			dump(self._serverlist)
		end
		]]
		--3
		if callback then
			callback()
		end
	end
	--local _loginUrl = common:getLoginUrl()
	network:SendRequest(1, msg, cb, nil, NewServerInfo.SERVER_LIST_URL)
end

--[[进入界面]]
function LoginScene:onEnter()
	game.runningScene = self
	GameAudio.playMainmenuMusic(false)
	local deviceInfo = CSDKShell.GetDeviceInfo()
	if game.player.m_logout == true then
		game.player.m_logout = false
	end
	local versionUrl = NewServerInfo.VERSION_URL
	if VERSION_CHECK_DEBUG == true then
		versionUrl = NewServerInfo.DEV_VERSION_URL
	end
	--[[local function requestPayWay()
	NetworkHelper.request(
	versionUrl,
	{
	ac = "dwrechargemode",
	package = CSDKShell.GetBoundleID(),
	packetTag = PacketTag
	},
	function (data)
		dump(data)
		self:initPayWay(data)
	end,
	"GET"
	)
end

requestPayWay()]]
end

function LoginScene:initPayWay(data)
	CurrentPayWay = ""
	if data ~= nil and data.rechargemode ~= nil then
		CurrentPayWay = data.rechargemode
	end
	if TargetPlatForm and TargetPlatForm == PLATFORMS.VN and VERSION_CHECK_DEBUG == false and SHEN_BUILD == true then
		CurrentPayWay = "appstore_nv"
	end
	if CurrentPayWay == nil or CurrentPayWay == "" then
		CurrentPayWay = ""
		show_tip_label(common:getLanguageString("@wangluoyc1"))
	end
end

--[[选择服务器]]
function LoginScene:onSelectedServer(m_type, index)
	self._rootnode.selectServer:setEnabled(true)
	self._rootnode.bottomNode:setVisible(true)
	if index and index <= #self._serverlist then
		if m_type == 1 then
			if self._lastserverlist[index].status == MANAGE_STATUS_4 then
				show_tip_label(self._lastserverlist[index].msg)
			end
		elseif self._serverlist[index].status == MANAGE_STATUS_4 then
			show_tip_label(self._serverlist[index].msg)
		end
		if m_type == 1 and self._lastserverlist[index] then
			local idx = self._lastserverlist[index].idx
			local serverInfo = common:getServerInfoByIdx(self._serverlist, idx)
			if serverInfo ~= nil then
				if game.player.m_defaultServer ~= serverInfo.index then
					game.player.m_isChangedServer = true
				end
				game.player.m_serverID = serverInfo.idx
				game.player.m_serverName = serverInfo.name
				game.player.m_zoneID = serverInfo.zoneId
				game.player.m_defaultServer = serverInfo.index
				CCUserDefault:sharedUserDefault():setIntegerForKey("dfs", game.player.m_defaultServer)
				CCUserDefault:sharedUserDefault():setIntegerForKey("serlen", #self._serverlist)
				self._rootnode.chooseServerName:setString(serverInfo.name)
				self._rootnode.serverState:setDisplayFrame(display.newSpriteFrame(string.format("login_state_%d.png", serverInfo.status)))
				
				if string.find(serverInfo.ip, ":") ~= nil or serverInfo.usePort == 0 then
					NewServerInfo.SERVER_URL = "http://" ..serverInfo.ip
				else
					NewServerInfo.SERVER_URL = string.format("http://%s:%s/", serverInfo.ip, serverInfo.port)
				end
			end
		end
		
		if m_type == 2 and self._serverlist[index] then
			if game.player.m_defaultServer ~= index then
				game.player.m_isChangedServer = true
			end
			game.player.m_serverID = self._serverlist[index].idx
			game.player.m_serverName = self._serverlist[index].name
			game.player.m_zoneID = self._serverlist[index].zoneId
			game.player.m_defaultServer = index
			game.player.m_accountAdd = self._serverlist[index].accountAdd
			CCUserDefault:sharedUserDefault():setIntegerForKey("dfs", game.player.m_defaultServer)
			CCUserDefault:sharedUserDefault():setIntegerForKey("serlen", #self._serverlist)
			self._rootnode.chooseServerName:setString(self._serverlist[index].name)
			self._rootnode.serverState:setDisplayFrame(display.newSpriteFrame(string.format("login_state_%d.png", self._serverlist[index].status)))
			if string.find(self._serverlist[index].ip, ":") ~= nil or self._serverlist[index].usePort == 0 then
				NewServerInfo.SERVER_URL = "http://" ..self._serverlist[index].ip
			else
				NewServerInfo.SERVER_URL = string.format("http://%s:%s/", self._serverlist[index].ip, self._serverlist[index].port)
			end
		end
	end
end

function LoginScene:isLogoExist()
	local logoImage = "ui/TagLogo.png"
	local path = CCFileUtils:sharedFileUtils():fullPathForFilename(logoImage)
	if io.exists(path) then
		return true, logoImage
	else
		return false
	end
end

function LoginScene:init()
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local contentNode = CCBuilderReaderLoad("login/login_scene.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, display.height))
	self:addChild(contentNode, 1)
	self._rootnode.VersionNumber:setString(common:getLanguageString("@VersionNumber", DISPLAY_VERSION))
	local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")
	local bottomLogoOffY = 0
	if display.widthInPixels / display.heightInPixels == 0.75 then
		bgSprite:setPosition(display.cx, display.height * 0.55)
		bgSprite:setScale(0.9)
	elseif display.widthInPixels == 640 and display.heightInPixels == 960 then
		bgSprite:setPosition(display.cx, display.height * 0.55)
	else
		bgSprite:setPosition(display.cx, display.cy)
		self._rootnode.bottomNode:setPositionY(display.height * 0.065)
	end
	self:addChild(bgSprite)
	local isFileExist, logoName = self:isLogoExist()
	if isFileExist then
		local logoSprite = display.newSprite(logoName)
		logoSprite:setPosition(self._rootnode.tag_logo_pos:getContentSize().width / 2, self._rootnode.tag_logo_pos:getContentSize().height / 2)
		self._rootnode.tag_logo_pos:addChild(logoSprite)
	else
		local logoName_default = "jiemian_biaotidonghua"
		local xunhuanname = "jiemian_biaotidonghua_xunhuan"
		local path = "ccs/ui_effect/" .. logoName_default .. "/" .. logoName_default .. ".ExportJson"
		path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
		if io.exists(path) then
			self.logoAnim = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = logoName_default,
			isRetain = true,
			finishFunc = function (...)
				self.logoAnim:removeSelf()
				local logo2 = ResMgr.createArma({
				resType = ResMgr.UI_EFFECT,
				armaName = xunhuanname,
				isRetain = true
				})
				logo2:setPosition(self._rootnode.tag_logo_pos:getContentSize().width / 2, self._rootnode.tag_logo_pos:getContentSize().height / 2)
				self._rootnode.tag_logo_pos:addChild(logo2)
			end
			})
			self.logoAnim:setPosition(self._rootnode.tag_logo_pos:getContentSize().width / 2, self._rootnode.tag_logo_pos:getContentSize().height / 2)
			self._rootnode.tag_logo_pos:addChild(self.logoAnim)
		end
	end
	
	local heroAnim = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "jiemian_dadoudonghua",
	isRetain = true
	})
	
	heroAnim:setPosition(self._rootnode.tag_anim_pos:getContentSize().width / 2, self._rootnode.tag_anim_pos:getContentSize().height / 2)
	self._rootnode.tag_anim_pos:addChild(heroAnim)
	if display.widthInPixels / display.heightInPixels == 0.75 then
		heroAnim:setScale(0.8)
	end
	self._enterGame = false
	--进入游戏
	self._rootnode["enterGameBtn"]:registerScriptTapHandler(function (...)
		--IOS屏蔽登陆
		if device.platform ~= "ios"and CSDKShell.isLogined() == false then
			self:reLogin()
			return
		end
		if self._serverlist == nil then
			show_tip_label(common:getLanguageString("@Connecting"))
			return
		end
		if DEBUG_MODE == 0 and self._serverlist[game.player.m_defaultServer].status == MANAGE_STATUS_4 then
			show_tip_label(self._serverlist[game.player.m_defaultServer].msg)
			return
		end
		if self._enterGame == false then
			self._enterGame = true
			self:enterGame()
			self:performWithDelay(function (...)
				self._enterGame = false
			end,
			1)
		end
	end)
	
	--[[切换账号]]
	self._rootnode.switchAccBtn:addHandleOfControlEvent(function ()
		GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
		--[[
		if device.platform == "windows" or device.platform == "ios" then
			local layer = require("app.scenes.UserLogin").new({})
			self:addChild(layer, 100, 100)
		else
			CSDKShell.switchAccount()
		end
		]]
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	
	--[[
	if CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS or TargetPlatForm == PLATFORMS.TW or device.platform == "windows" or device.platform == "ios" or CSDKShell.getYAChannelID() == CHANNELID.IOS_YA then
		self._rootnode.switchAccBtn:setVisible(true)
	else
		self._rootnode.switchAccBtn:setVisible(false)
	end
	]]
	self._rootnode.switchAccBtn:setVisible(false)
	
	--[[选择服务器]]
	local function selectServerLayer()
		local function serverLayer(...)
			self._rootnode.selectServer:setEnabled(false)
			self._rootnode.bottomNode:setVisible(false)
			if self:getChildByTag(100) == nil then
				local layer = require("game.login.ServerChooseLayer").new(self._lastserverlist, self._serverlist, handler(self, self.onSelectedServer))
				self:addChild(layer, 100, 100)
			end
		end
		self:refreshServerList(serverLayer)
	end
	
	--服务器选择按钮
	self._rootnode["selectServer"]:addHandleOfControlEvent(function ()
		if game.player.m_defaultServer ~= nil then
			if self._serverlist ~= nil then
				selectServerLayer()
			else
				self:verifyLogin(function ()
					selectServerLayer()
				end)
			end
		end
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end

function LoginScene:onEnterTransitionFinish()
	if CSDKShell.isLogined() == true and device.platform ~= "ios" then
		dump("isLogined")
		CSDKShell.showToolbar()
		local info = CSDKShell.userInfo()
		if info ~= nil then
			game.player:initBaseInfo(info)
		end
		self:verifyLogin()
	else
		self:reLogin()
	end
end

function LoginScene:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	display.removeUnusedSpriteFrames()
	local isFileExist, logoName = self:isLogoExist()
	if isFileExist == false then
		ResMgr.ReleaseUIArmature("jiemian_biaotidonghua")
		ResMgr.ReleaseUIArmature("jiemian_biaotidonghua_xunhuan")
		ResMgr.ReleaseUIArmature("jiemian_dadoudonghua")
	end
end

--进入游戏
function LoginScene:enterGame()
	--[[
	if device.platform == "windows" or device.platform == "mac" then
		if self._editBox ~= nil and self._editBox:getText() ~= "" then
			local text = self._editBox:getText()
			local tbl = string.split(text, " ")
			acc = tbl[1]
			game.player:setUid(acc)
			local result = cc.UserDefault:getInstance():setStringForKey("accid", acc)
			cc.UserDefault:getInstance():flush()
		end
	end
	]]
	
	game.player.m_loginName = cc.UserDefault:getInstance():getStringForKey("playerName", "")
	if NewServerInfo.SERVER_URL then
		if device.platform == "ios" then
			game.player.m_platformID =  CSDKShell.getChannelID()
		end
		game.player:setUid(game.player.m_serverID .."." ..game.player.m_acc)
		RequestHelper.game.loginGame({
		sessionId = game.player.m_sessionID,
		uin = game.player.m_uid,
		platformID = game.player.m_platformID,
		callback = function (data)
			dump(data)
			if data["0"] == "" then
				CSDKShell.setDebug(data.orderDebug or 0)
				game.player:setAppOpenData(data.open)
				DramaMgr.resetTutorial()
				game.isCanSkipGame = data["1"][4] == 1 and true or false
				--game.isCanSkipGame = data["1"].guideState == 1 and true or false
				local isNewUser = data["3"]				
				if isNewUser == 1 then
					DramaMgr.isSkipDrama = false
					DramaMgr.createChoseLayer(data)
				elseif isNewUser == 2 then
					if data["4"] ~= nil and data["4"] ~= "" then
						game.player.m_serverKey = data["4"]
					end
					DramaMgr.request(isNewUser, data)
				end
			else
				local errorCode = data["0"]
				if errorCode == "91_11" or errorCode == "91_5" or errorCode == "91_0" then
					CSDKShell.Login()
				elseif errorCode == "PP_0xE0000101" then
					CSDKShell.Login()
				end
			end
		end
		})
	else
		show_tip_label(common:getLanguageString("@Connecting"))
	end
	
	if SHEN_BUILD == false and NewServerInfo.BI_URL then
		dump("~~~~~~~~~~~~~~~~~~~~~~~~adminchatUrl")
		local versionUrl = NewServerInfo.BI_URL
		if VERSION_CHECK_DEBUG == true then
			versionUrl = NewServerInfo.DEV_BI_URL
		end
		local adminchatUrl = versionUrl .. "/adminchat.php"
		local function request(versions)
			NetworkHelper.request(
			adminchatUrl,
			{
			ac = "coverinterface",
			version = versions
			},
			function (data)
				dump(data)
				if data ~= nil and #data > 0 then
					if versions > 0 then
						request(0)
					else
						local eventListen = function (param)
							local returnValue = {}
							if param.errorCode then
								dump("读取存储文件失败error:" .. param.errorCode)
							elseif param.name == "save" then
								dump("save:")
								returnValue = param.values
							elseif param.name == "load" then
								dump("load:")
								returnValue = param.values
							end
							return returnValue
						end
						GameState.init(eventListen, "chatPingbi.json", SECRETKEY)
						curChatData = {}
						for i, v in ipairs(data) do
							curChatData[#curChatData + 1] = v
						end
						GameState.save(curChatData)
						cc.UserDefault:getInstance():setIntegerForKey("ADMINCHAT_VERSION", data[1].id)
						cc.UserDefault:getInstance():flush()
					end
				end
			end,
			"GET")
		end
		request(cc.UserDefault:getInstance():getIntegerForKey("ADMINCHAT_VERSION", 0))
	end
end

--[[重新登录]]
function LoginScene:reLogin()
	--IOS屏蔽登陆
	if device.platform == "ios" then
		self:verifyLogin()
	else
		CSDKShell.Login()
		local scheduler = require("framework.scheduler")
		local loginSche
		loginSche = scheduler.scheduleGlobal(function ()
			if CSDKShell.isLogined() == true then
				local info = CSDKShell.userInfo()
				if info ~= nil then
					game.player:initBaseInfo(info)
				end
				self:verifyLogin()
				scheduler.unscheduleGlobal(loginSche)
			end
		end,
		0.1)
	end
end

return LoginScene