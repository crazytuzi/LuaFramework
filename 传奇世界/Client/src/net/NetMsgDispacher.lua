UNCONNECT = 1
CONNECTING = 2
CONNECTED = 3
RECONNECTFAILED = 4
KICKOUT = 5

LOGIN = 1
ENTER = 2
REGISTER = 3
RECONNECT = 4
CHANGE_GROUP = 5

local function NetErrorToMsgBox(isGotoLogin,text)
	cclog("NetErrorToMsgBox")
	local callback = nil
	if isGotoLogin then
		removeNetLoading()
		callback = function()
			globalInit()
			game.ToLoginScene()
		end
	end
	if not text then
		text = game.getStrByKey("server_stop")
	end
	MessageBox(text,game.getStrByKey("sure"),callback)
end

-- function NetMsgDispacher(msgId,msgBuf,params)
-- 	--print("NetMsgDispacher，msgId："..msgId)
-- 	userInfo.noNetTransforTime = 0
-- 	local luaBuffer = tolua.cast(msgBuf, "LuaMsgBuffer")
-- 	if msgId == LOGIN_SC_TICKOUT then
-- 		cclog("kick_out")
-- 		userInfo.connStatus = KICKOUT
-- 		local kickType = luaBuffer:popInt()
-- 		local str = game.getStrByKey("kick_out")
-- 		if kickType == 2 then
-- 			str = game.getStrByKey("server_stop")
-- 		elseif kickType == 3 then
-- 			str = game.getStrByKey("GM_kick")
-- 		end
-- 		NetErrorToMsgBox(true,str)
-- 	end
-- 	if userInfo.connStatus ~= KICKOUT then
-- 		local netSim = require("src/net/NetSimulation")
-- 		local index = -1
-- 		if netSim.isRecvMsg then
-- 			index = netSim:recvMsgInfo(msgId, 0)
-- 			luaBuffer:beginRemData(0)
-- 		end

-- 		if g_msgHandlerInst and g_msgHandlerInst.handlerTable and g_msgHandlerInst.handlerTable[msgId] then 
-- 			g_msgHandlerInst.handlerTable[msgId](luaBuffer,msgId,params)
-- 			if netSim.isRecvMsg then
-- 				netSim:recvMsgInfo(msgId, 0, luaBuffer:getRemData(), index)
-- 			end
-- 		else 
-- 			log("has not NetMsgHandler，msgId："..msgId)
-- 		end
		
-- 		--LOGIN_SC_WORLDUPDATE==msgId 排队走另外协议
-- 		if userInfo.removeNetMsg and userInfo.removeNetMsg==msgId or FRAME_SC_MESSAGE==msgId or LITTERFUN_SC_NOTIFY_MONEYTREE==msgId or LOGIN_SC_WORLDUPDATE==msgId then
-- 			cclog("remove loading")
-- 			removeNetLoading()
-- 		end
-- 	end

-- end

function g_NetMsgDispacher(...)
	print("num",msg_num)
	local msgBuf = {...}
	--if G_MAINSCENE then
		userInfo.noNetTransforTime = 0
		for i=1,#msgBuf do
			if msgBuf[i] then
				local luaBuffer = tolua.cast(msgBuf[i], "LuaMsgBuffer")
				if luaBuffer then
					local msgId = luaBuffer:getMsgId()
                    setCrashLog("curMsgID", tostring(msgId))
					--print("NetMsgDispacher，msgId："..msgId)
					if msgId == FRAME_SC_ENTITY_ENTER then
						game.onEnterMapScene(luaBuffer)
						-- local params = {luaBuffer:readByFmt("bissscs")}
						-- G_MAINSCENE:onEnterMapScene(luaBuffer,params)
					elseif msgId == FRAME_SC_ENTITY_EXIT then
						if G_MAINSCENE and G_MAINSCENE.map_layer then
							G_MAINSCENE.map_layer:onRoleExit(luaBuffer)
						end
					elseif msgId == FRAME_SC_PROP_UPDATE then
						if G_MAINSCENE then
							G_MAINSCENE:onPropUpdate(luaBuffer)
						end
                    else
						if msgId == LOGIN_SC_TICKOUT then
							userInfo.connStatus = KICKOUT
							local retTable = g_msgHandlerInst:convertBufferToTable("LoginTickoutRet", luaBuffer)
							local kickType = retTable.reason
							local str = game.getStrByKey("kick_out")
							if kickType == 2 then
								str = game.getStrByKey("server_error")
							elseif kickType == 3 then
								str = game.getStrByKey("GM_kick")
							end
							NetErrorToMsgBox(true,str)
						end
						if userInfo.connStatus ~= KICKOUT then

							local netSim = require("src/net/NetSimulation")
							if netSim.isRecvMsg then
								netSim:logSendMsgInfo(msgId, 0)
							end

							if g_msgHandlerInst and g_msgHandlerInst.handlerTable and g_msgHandlerInst.handlerTable[msgId] then 
								local msgHanderFunc = function()
									return g_msgHandlerInst.handlerTable[msgId](luaBuffer,msgId,params)
								end
                                
								xpcall(msgHanderFunc,__G__TRACKBACK__)				
							else 
								log("has not NetMsgHandler，msgId："..msgId)
							end

							--LOGIN_SC_WORLDUPDATE==msgId 排队走另外协议
						end
					end
					
					if userInfo.removeNetMsg and userInfo.removeNetMsg==msgId or FRAME_SC_MESSAGE==msgId or LITTERFUN_SC_NOTIFY_MONEYTREE==msgId or LOGIN_SC_WORLDUPDATE==msgId then
						removeNetLoading()
					end
				end
			else
				if G_MAINSCENE and G_MAINSCENE.map_layer then
					Mapview_onMsgHandler(i-1)
					--MapView:onMsgHandler(i-1)
				end
			end
		end
	--end
end

function NetError(num)
	print("...[NetError called] .........." .. tostring(num) )
	--选择服务器后会断开前一个连接，新开socket
	if not _G_IS_LOGINSCENE and not __G_ON_CREATE_ROLE then
		cclog("NetError,userInfo.connStatus"..userInfo.connStatus)
		g_reconnect_auto_status = game.getAutoStatus()
		game.setAutoStatus(0)
		if G_MAINSCENE and (Director:getRunningScene() == G_MAINSCENE) then 
			if G_MAINSCENE.pingNode and G_MAINSCENE.pingNode.clearHeartSpeedBad then
				G_MAINSCENE.pingNode:clearHeartSpeedBad()
			end
		end

		if userInfo.connStatus == KICKOUT then
			--LuaSocket:getInstance():closeSocket()
			CommonSocketClose()
			return
		end
		if userInfo.connStatus == CONNECTED then
			print("CONNECTED")
			--新手剧情不允许重连 直接跳转回登录界面
			if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isStory == true then
				NetErrorToMsgBox(true, game.getStrByKey("bad_heart_speed_tip"))
			else
				local NetLoading = require("src/base/NetLoading")
				NetLoading.curTime = 1
				addNetLoading(nil,nil,true)
				CommonSocketClose()
				--LuaSocket:getInstance():closeSocket()
				if GameSocketLunXun then
		    		LuaSocket:getInstance():openSocket(2,0,userInfo.gatewayPort, userInfo.gatewayAddr, "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194")
		    	else
		    		LuaSocket:getInstance():openSocket(0,0,userInfo.gatewayPort, userInfo.gatewayAddr)
		    	end
		    	userInfo.connStatus = CONNECTING
		    	userInfo.connType = ENTER
		    	userInfo.isReconn = 1
		    	userInfo.reconnRequest = 1
		    	userInfo.reconnResponse = 0
		    end
		end	
	elseif __G_ON_CREATE_ROLE then
		NetErrorToMsgBox(true, game.getStrByKey("bad_heart_speed_tip") )
	end
end

function sendLoadPlayerMsg(userId, dbid, worldId, realId, startTick, mapId, sessionID, username)
    local platId = 1
    if isIOS() then platId = 0 end

    local openId = sdkGetOpenId()
    local clientVersion = cc.UserDefault:getInstance():getStringForKey("current-version-code")
    local osVersion = getOSVersion()
    local deviceType = getDeviceType()
    local telecomOper = ""
    if getTelephonyProviderType then
        telecomOper = getTelephonyProviderType()
    end
    
    local network = getNetworkType()

    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local dpi = cc.Device:getDPI()

    local loginChannel = getLoginChannel()
    local cpuType = getCPUType()
    local memSize = getRamSize()

    local appStartType = 0
    if LoginUtils.isLaunchFromWXGameCenter() then
    	appStartType = 1
    elseif LoginUtils.isLaunchFromQQGameCenter() then
    	appStartType = 2
    end


    print("sendLoadPlayerMsg", platId, osVersion, clientVersion, appStartType)


	local ret = { userID = userId, dbID = dbid, worldID = worldId, realID = realId, startTick = startTick, mapID = mapId, sessionID = sessionID,
				  platID = platId, openid = openId, clientVersion = clientVersion, systemSoftware= osVersion, systemHardware = deviceType, telecomOper = telecomOper,
				  network = network, screenWidth = frameSize.width, screenHight = frameSize.height, density = dpi, loginChannel = loginChannel, 
				  cpuHardware = cpuType, memory = memSize,
				  -- gLRender = "", gLVersion = "", deviceId = "",
				  pay_token = sdkGetPayToken(), pf = sdkGetPf(), pfkey = sdkGetPfKey(),sessionToken = userInfo.sessionToken,roleName = username,
				  appStartType = appStartType,
				}

	g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CG_LOAD_PLAYER, "LoginLoadPlayerInfoReq", ret)
end

function connectCallback(connRet)
	print("connRet", connRet)
	if connRet == 0 then
		if userInfo.connStatus == RECONNECTFAILED then
			--LuaSocket:getInstance():closeSocket()
			CommonSocketClose()
			userInfo.reconnResponse = userInfo.reconnResponse+1
			return
		end
		CommonSocketClose()
		--LuaSocket:getInstance():closeSocket()
		if userInfo.connStatus == CONNECTING then
			userInfo.connStatus = UNCONNECT
		end
		if not userInfo.isReconn then
			removeNetLoading()
			-- if userInfo.loginPort ~= nil and userInfo.loginPort < 20014 and userInfo.connType == LOGIN then
			-- 	--userInfo.loginPort = userInfo.loginPort+1
			-- 	cclog("port +1, try again~ port = " .. userInfo.loginPort)
			-- 	LuaSocket:getInstance():openSocket(userInfo.loginIp,userInfo.loginPort)
	  --   		userInfo.connStatus = CONNECTING
			-- else
			NetErrorToMsgBox(true)
		else
			addNetLoading(nil,nil,true)
			userInfo.reconnResponse = userInfo.reconnResponse+1
			if GameSocketLunXun then
	    		LuaSocket:getInstance():openSocket(2,500,userInfo.gatewayPort, userInfo.gatewayAddr, "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194")
	    	else
	    		LuaSocket:getInstance():openSocket(0,500,userInfo.gatewayPort, userInfo.gatewayAddr)
	    	end
	    	userInfo.connStatus = CONNECTING
	    	userInfo.connType = ENTER
	    	userInfo.isReconn = 1
	    	userInfo.reconnRequest = userInfo.reconnRequest+1
		end
	else
		--end
		-- if userInfo.connType == RECONNECT then
		-- 	removeNetLoading()
	 --        g_msgHandlerInst:sendSelectRole(userInfo.currRoleStaticId)
	 	local LoginScene = require("src/login/LoginScene")
	    if userInfo.connType == LOGIN then
	    	if LoginScene.msdk then
				local ret = {flatform = LoginScene.sdkPlatform, openid = LoginScene.user_name, openkey = LoginScene.user_pwd, worldID = userInfo.serversreal,serverID = userInfo.serverId}
	    		g_msgHandlerInst:sendNetDataByTable(LOGIN_CS_CHOOSEWORLD_WITH_MSDK_LOGIN, "MsdkLoginChooseWorldReq", ret)
	    	else
				local ret = {openID = LoginScene.user_name, sessionID = LoginScene.user_pwd, serverID = userInfo.serverId, worldID = userInfo.serversreal}
	    		g_msgHandlerInst:sendNetDataByTable(LOGIN_CS_CHOOSEWORLD, "LoginChooseWorldReq", ret)
	    	end

	    elseif userInfo.connType == REGISTER then

			local ret = { userName= LoginScene.user_name, userPwd = LoginScene.user_pwd, create = userInfo.isCreate}
    		g_msgHandlerInst:sendNetDataByTable(LOGIN_CS_CREATEUSER, "LoginCreateUserReq", ret)
	    elseif userInfo.connType == ENTER then
			local ret = {userID = userInfo.userId, token = userInfo.sessionToken}
	    	g_msgHandlerInst:sendNetDataByTable(LOGIN_CG_VERIFY_SESSIONTOKEN, "LoginVerifySessionTokenReq", ret)	    	

	    	if userInfo.isReconn then
	    		userInfo.reconnResponse = userInfo.reconnResponse+1
	    		local NetLoading = require("src/base/NetLoading")
				NetLoading.curTime = 1

                -- 断线重新连上，队员的共享任务服务器已经删除
                if DATA_Mission then DATA_Mission:ClearShareTask(); end
	    	end
	    	
	    	userInfo.connStatus = CONNECTED
	    	if userInfo.connCb then	
		    	userInfo.connCb()
		    	userInfo.connCb = nil
		    else
		    	if userInfo.currRoleStaticId then
		    		sendLoadPlayerMsg(userInfo.userId,userInfo.currRoleStaticId,userInfo.serverId,userInfo.serversreal,userInfo.startTick,__getMapIDByRoleId(userInfo.currRoleStaticId),userInfo.sessionID)
		    	end
            	removeNetLoading()
		    end
	    end
	    userInfo.isReconn = nil
	end
end

