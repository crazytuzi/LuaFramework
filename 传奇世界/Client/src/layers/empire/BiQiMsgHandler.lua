local onRecvBiQiDeadData = function(buff)
	log(".......................onRecvBiQiDeadData..........................")
	local data = {}
	data.killerName = buff:popString() --杀死你的人的名字 
	data.killerFactionName = buff:popString() --类型杀死你的人的帮会名字
	data.killeTime = buff:popInt() --类型，被杀死的时间点，1970年以来的秒数
	data.aliveTimeLeft = buff:popChar() --类型，复活剩余时间
	data.buffNum = buff:popChar() --类型，buff层数
	
	local node = require("src/layers/empire/EmpireDeadInfoNode").new(data)
	--G_MAINSCENE:addChild(node, 150)
	Manimation:transit(
	{
		ref = G_MAINSCENE.base_node,
		node = node,
		curve = "-",
		sp = cc.p(display.cx, 0),
		zOrder = 200,
	})
	G_MAINSCENE.map_layer:resetHangup()
end

local onRecvBattleBannerData = function(buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("BannerPosProtocol", buff)

	local manorID = retTab.manorID
	--dump("onRecvBattleBannerData .. " .. manorID)
	if G_MAINSCENE and G_MAINSCENE:CheckEmpireState(manorID) then 
		G_EMPIRE_INFO.BATTLE_INFO.bannerX = retTab.posX
		G_EMPIRE_INFO.BATTLE_INFO.bannerY = retTab.posy
		G_MAINSCENE:showArrowPointToMonster(true, cc.p(G_EMPIRE_INFO.BATTLE_INFO.bannerX, G_EMPIRE_INFO.BATTLE_INFO.bannerY), true)
	end
end

local onRecvBiQiResultData = function(buff)
	log("onRecvBiQiResultData")
	local data = {}
	data.isWin = buff:popBool()
	data.xp = buff:popInt()
	data.factionMoney = buff:popInt()
	if data.isWin then
		data.xpPlus = buff:popChar()
		data.minePlus = buff:popChar()
	end
	
	local node = require("src/layers/empire/BiQiResultNode").new(data)
	Manimation:transit(
	{
		ref = G_MAINSCENE.base_node,
		node = node,
		curve = "-",
		sp = cc.p(display.cx, 0),
		zOrder = 200,
	})
end

local onRevcBiqiStart = function(buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("ManorNotifyAllProtocol", buff)
	local manorID, isOpen = retTab.manorID, retTab.isOpen

	if G_MAINSCENE and G_MAINSCENE.createBiQiBegainIcon then
		G_MAINSCENE:createBiQiBegainIcon(manorID, isOpen)
	end

	if isOpen then
		if manorID == 1 then
			if checkLocalKeyTime("BiqiStart" ..sdkGetOpenId(), 1) then
				liuAudioPlay("sounds/liuVoice/58.mp3",false)
			end
		elseif manorID == 2 then
			if checkLocalKeyTime("" .. manorID .."EmpireStart" ..sdkGetOpenId(), 1) then
				liuAudioPlay("sounds/liuVoice/56.mp3",false)
			end
		end
	end

	g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_GET_LEADERINFO, "ManorGetLeaderInfoProtocol", {manorID = 1})
end

local onRecvBannerUpdate = function(buff)	  
	local retTab = g_msgHandlerInst:convertBufferToTable("NotifyOccupyFactionProtocol", buff)
	
	local facid,manorID,facName = retTab.factionID,retTab.manorID,retTab.facName
	if G_EMPIRE_INFO.BATTLE_INFO.manorID == manorID and G_MAINSCENE and G_MAINSCENE.map_layer then
		G_EMPIRE_INFO.BATTLE_INFO.facId   = facid 	-- 帮派ID
		G_EMPIRE_INFO.BATTLE_INFO.facName = facName	-- 帮会名字

		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_SIMPLEWARINFO, "SimpleWarInfoProtocol", {manorID = manorID})
	end
end

g_msgHandlerInst:registerMsgHandler(MANORWAR_SC_RELIVEINFO, onRecvBiQiDeadData)
g_msgHandlerInst:registerMsgHandler(MANORWAR_SC_BANNERPOS, onRecvBattleBannerData)
g_msgHandlerInst:registerMsgHandler(MNAORWAR_SC_ENDREWARD, onRecvBiQiResultData)
g_msgHandlerInst:registerMsgHandler(MANORWAR_SC_NOTIFYOCCUPYFACTION, onRecvBannerUpdate)
g_msgHandlerInst:registerMsgHandler(MANORWAR_SC_NOTIFYALL, onRevcBiqiStart)