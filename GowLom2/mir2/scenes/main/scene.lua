local current = ...
local ui = import(".ui")
local ground = import(".ground")
local itemInfo = import(".common.itemInfo")
local common = import(".common.common")
local operate = import(".pc.operate")
local baseScene = import("..baseScene", current)
local scene = class("main", baseScene)
local netLgoic = import(".common.reconnectLogic")
local netLoadingSpr = nil

table.merge(scene, {})

scene.ctor = function (self)
	g_data.login:setLoginState(GameStateType.game)

	main_scene = self
	self.ground = ground.new():addto(self)
	self.ui = ui.new():addto(self):hide()

	self.processTouchForMutil(self)

	local rsb = DefaultClientMessage(CM_TaskAll)
	rsb.FBoFinished = 0
	rsb.FShowUIFlag = 1

	MirTcpClient:getInstance():postRsb(rsb)

	rsb.FBoFinished = 1
	rsb.FShowUIFlag = 2

	MirTcpClient:getInstance():postRsb(rsb)

	local rsb = DefaultClientMessage(CM_RechargeList)

	MirTcpClient:getInstance():postRsb(rsb)
	self.addNodeEventListener(self, cc.NODE_ENTER_FRAME_EVENT, function (...)
		self.ground:update(...)
		self.ui:update(...)
		self:update(...)

		return 
	end)
	self.scheduleUpdate(ground)

	if 0 < DEBUG then
		g_data.client:setLastTime("ping", true)
	end

	if WIN32_OPERATE then
		operate.init()
		self.initHotKey(self)
	end

	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ChrList, self, self.onSM_CharacterInfo)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_OUTOFCONNECTION_KICKOUT, self, self.onSM_OUTOFCONNECTION_KICKOUT)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_PING, self, self.onSM_PING)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RechargeList, self, self.onSM_RechargeList)
	g_data.eventDispatcher:addListener("NET_RECONNECTED", self, self.hideNetLoadingAni)
	g_data.eventDispatcher:addListener("NET_DISCONNECTED", self, self.showNetLoadingAni)
	g_data.eventDispatcher:addListener("NET_RECONNECT_TIME_OUT", self, self.netReconnetTimeOut)
	g_data.eventDispatcher:addListener("BIG_EXIT", self, self.bigExit)

	self.lastPingTick_ = 0
	self.lastPingTimePoint_ = 0
	self.lastServerTimePoint = 0
	g_data.netTimeOut = false
	g_data.isSkillBegan = false
	reConnectLogic = netLgoic.new()
	self._watchdogCount = 0

	watchdog:setListener(function (speed)
		if 1.1 <= speed then
			print("检测到使用了加速外挂,加速倍速", speed)

			self._watchdogCount = self._watchdogCount + 1

			if 3 <= self._watchdogCount then
				local rsb = DefaultClientMessage(CM_IamGuilt)
				rsb.FSpeed = math.floor(speed*100)

				MirTcpClient:getInstance():postRsb(rsb)

				self._watchdogCount = 0
			end
		else
			self._watchdogCount = 0
		end

		return 
	end)

	return 
end
scene.setNormalFPS = function (self)
	local enable = g_data.setting.base.highFrame

	if enable then
		cc.Director:getInstance():setAnimationInterval(0.016666666666666666)
	else
		cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
	end

	self.lowFPS = false

	return 
end
scene.setLowFPS = function (self)
	cc.Director:getInstance():setAnimationInterval(0.1)

	self.lowFPS = true

	return 
end
local lowFPSTime = 30
scene.checkLowFPS = function (self, isTouch)
	if not g_data.setting.base.operateCheck then
		return 
	end

	self.touchStamp = self.touchStamp or socket.gettime()

	if not self.lowFPS then
		local touchTime = socket.gettime() - self.touchStamp

		if lowFPSTime < touchTime then
			self.setLowFPS(self)
		end
	elseif isTouch then
		self.touchStamp = socket.gettime()

		self.setNormalFPS(self)
	end

	return 
end
scene.processTouchForMutil = function (self)
	local function handler(event)
		self:checkLowFPS(true)

		return 
	end

	local touchNode = display.newNode().size(slot2, display.width, display.height):add2(self, 1)

	touchNode.setTouchSwallowEnabled(touchNode, false)
	touchNode.setTouchEnabled(touchNode, true)
	touchNode.setTouchMode(touchNode, cc.TOUCH_MODE_ALL_AT_ONCE)
	touchNode.addNodeEventListener(touchNode, cc.NODE_TOUCH_EVENT, handler)

	return 
end
scene.update = function (self, dt)
	if g_data.netReconnect or g_data.inPhoneCall then
		return 
	end

	self.lastPingTick_ = self.lastPingTick_ + dt

	if 4 < self.lastPingTick_ then
		self.lastPingTick_ = 0

		if self.lastPingTimePoint_ == 0 then
			self.lastPingTimePoint_ = ycFunction.getClock()
			local rsb = DefaultClientMessage(CM_PING)

			MirTcpClient:getInstance():postRsb(rsb)
		else
			local delta = ycFunction.getClock() - self.lastPingTimePoint_

			if 8000000 < delta then
				if 0 < DEBUG then
					p2("error", "PING 过期与服务器断开连接")
				end

				self.lastPingTimePoint_ = 0

				self.onLoseConnect(self)
			end
		end
	end

	self.checkLowFPS(self)

	return 
end
scene.onSM_RechargeList = function (self, result, proIc)
	if result then
		print("拉取充值配置！")
		print_r(result)
		main_scene.ui.waiting:close("CM_RechargeList")

		g_data.chargeList = result.FProductList
		local shopPanel = main_scene.ui.panels.shop

		if shopPanel and shopPanel.panel_type == 2 then
			shopPanel.getRecharOpenLoadRecharge(shopPanel)
		end
	end

	return 
end
scene.onSM_PING = function (self, result, proIc)
	if result then
		self.lastPingTimePoint_ = 0
	end

	return 
end
scene.showNetLoadingAni = function (self)
	if self.ui then
		self.ui.waiting:show(-1, "NET_RECONNECT", 1, 1)
	end

	return 
end
scene.hideNetLoadingAni = function (self)
	if g_data.netReconnect and self.ui then
		self.ui.waiting:close("NET_RECONNECT")
		p2("res", "main.scene:hideNetLoadingAni")
		self.clearGameData(self)
	end

	return 
end
scene.netReconnetTimeOut = function (self)
	if g_data.netReconnect and self.ui then
		self.ui.waiting:close("NET_RECONNECT")
		an.newMsgbox("连接超时，请重新登陆", function (idx)
			if idx == 1 then
				self:bigExit()
			end

			return 
		end, {
			center = true
		})
	end

	return 
end
scene.onSM_OUTOFCONNECTION_KICKOUT = function (self, result, proIc)
	if result then
		g_data.isKickOut = true

		an.newMsgbox("已经被其他用户踢下线", function (idx)
			if idx == 1 then
				self:bigExit()
			end

			return 
		end, {
			center = true
		})
	end

	return 
end
scene.onSM_CharacterInfo = function (self, result, proIc)
	if result then
		self.isLoginQueue = false

		if not self.smallExitState then
			g_data.login.roleInfo = result.FChrList
		else
			self.smallExitState = false

			if WIN32_OPERATE then
				operate.unRegisterEvent()
			end
		end

		self.clearGameData(self)
		g_data.select:receiveRoles(result)
		game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
	end

	return 
end
scene.onEnter = function (self)
	print("main.scene:onEnter")
	self.super.onEnter(self)

	return 
end
scene.onExit = function (self)
	print("main.scene:onExit")
	itemInfo.close()
	self.super.onExit(self)

	if MirMiniResDownMgr then
		MirMiniResDownMgr:getInstance():reset()

		if self.downPercent then
			cache.saveDebug("downloadPercent", self.downPercent)
		end
	end

	self.unscheduleUpdate(self)

	return 
end
scene.smallExit = function (self)
	if g_data.login:isChangeSkinCheckServer() then
		self.clearGameData(self)
		common.gotoLogin({
			logout = true
		})

		return 
	end

	self.smallExitState = true
	local rsb = DefaultClientMessage(CM_SOFTCLOSE)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
scene.bigExit = function (self)
	self.clearGameData(self)
	common.gotoLogin({
		logout = true
	})

	return 
end
scene.clearGameData = function (self)
	if IS_PLAYER_DEBUG then
		package.loaded["mir2.scenes.main.scene"] = nil
		package.loaded["mir2.scenes.main.ground"] = nil
		package.loaded["mir2.scenes.main.ui"] = nil
	end

	main_scene.ui.console.controller.autoFindPath:multiMapPathStop()
	main_scene:removeAllNodeEventListeners()
	cc.Director:getInstance():getEventDispatcher():dispatchNodeEvent("LuaNode_removeSelf", main_scene.ui)
	cc.Director:getInstance():getEventDispatcher():dispatchNodeEvent("LuaNode_removeSelf", main_scene.ground)
	main_scene.ui:removeSelf()
	main_scene.ground:removeSelf()

	main_scene = nil
	reConnectLogic = nil

	g_data.cleanup()
	g_data.reset()
	audio.stopAllSounds()
	p2("res", "main.scene:clearGameData: 主场景清理数据")
	res.purgeCachedData()
	watchdog:setListener(nil)

	return 
end
scene.phone_listenner = function (self, state, number)
	local function reConnectOnPhoneCallState(s)
		if not reConnectLogic then
			return 
		end

		if s == 0 then
			g_data.inPhoneCall = false

			reConnectLogic:manualConnect()
			print("mir2:phone_listenner() state: ", state)
		else
			g_data.inPhoneCall = true

			reConnectLogic:forceReConnect()
			print("mir2:phone_listenner() state: ", state)
		end

		return 
	end

	slot3(state)

	return 
end
scene.reconectFuc = function (self, info)
	return an.newMsgbox(info .. "\n确定重连?", function (idx)
		print(idx)

		if idx == 0 then
			self:bigExit()
		elseif idx == 1 then
			self.reconnect = true

			scheduler.performWithDelayGlobal(function ()
				return 
			end, 0)
		end

		self.switchBox = nil

		return 
	end, {
		noclose = true,
		center = true,
		hasCancel = true
	})
end
scene.onLoseConnect = function (self)
	print("mir2.scene.main.scene:onLoseConnect")
	scheduler.performWithDelayGlobal(function ()
		return 
	end, 0)

	return 
end

if device.platform == "android" then
	scene.onNetworkStateChange = function (self, currentState)
		print("mir2.scene.main.scene:onNetworkStateChange android")
		scheduler.performWithDelayGlobal(function ()
			return 
		end, 0)

		return 
	end
else
	scene.onNetworkStateChange = function (self, currentState)
		print("mir2.scene.main.scene:onNetworkStateChange ios", currentState)

		if network.isHostNameReachable("www.baidu.com") then
			scheduler.performWithDelayGlobal(function ()
				return 
			end, 0)
		end

		return 
	end
end

scene.downloadMiniResEnd = function (self, percent)
	if not self.ui or not self.ui.panels then
		MirMiniResDownMgr:getInstance():reset()

		return 
	end

	if self.ui.panels.activity and self.ui.panels.activity.processBar then
		self.ui.panels.activity:downloadMiniResEnd(percent)
	end

	if self.ui.panels.miniResDownload and self.ui.panels.miniResDownload.processBar then
		self.ui.panels.miniResDownload:downloadMiniResEnd(percent)
	end

	self.downPercent = string.format("%.2f", percent)

	if self.downPercent == "100.00" then
		cache.saveDebug("downloadPercent", self.downPercent)
	end

	return 
end
scene.initHotKey = function (self)
	local data = cache.getHotKey(common.getPlayerName())
	data = data or def.operate.hotKey

	g_data.hotKey:setKeyInfos(data)

	return 
end

return scene
