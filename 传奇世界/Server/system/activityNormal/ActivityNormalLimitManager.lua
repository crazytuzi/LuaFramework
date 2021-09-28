--ActivityNormalLimitManager.lua
--/*-----------------------------------------------------------------
--* Module:  ActivityNormalLimitManager.lua 
--* Author:  Andy 
--* Modified: 2016年06月07日
--* Purpose: 定时活动
-------------------------------------------------------------------*/

ActivityNormalLimitManager = class(nil, Singleton, Timer)

function ActivityNormalLimitManager:__init()
	self._activityConfig = {}	--定时活动配置数值
	self._allUser = {}			--所有在线玩家{[roleID] = level}
	self._closeActivity = {}	--当前关闭的活动
	self._GMTime = {}			--GM命令开启时间{[activityID] = os.time()}
	self._GMIndex = {}

	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 0, 3000)
	print("ActivityNormalLimitManager TimeID:", self._timerID_)
end

function ActivityNormalLimitManager:setNormalLimitConfig(data)
	self._activityConfig = {}
	local now, nowWeek = os.date("*t", os.time()), self:nowWeek()
	for _, config in pairs(data or {}) do
		local tmp = {}
		tmp.active = false					--当前是否开启
		tmp.activityID = config.activityID	--定时活动ID
		tmp.name = config.name
		tmp.level = config.level
		tmp.startTime = os.time{year = now.year, month = now.month, day = now.day, hour = config.time[1], min = config.time[2], sec = config.time[3]}
		tmp.endTime = os.time{year = now.year, month = now.month, day = now.day, hour = config.time[4], min = config.time[5], sec = config.time[6]}
		tmp.weeks = config.week or {}
		if tmp.startTime > tmp.endTime then
			if os.time() >= tmp.startTime then
				tmp.endTime = tmp.endTime + DAY_SECENDS
			else
				tmp.startTime = tmp.startTime - DAY_SECENDS
			end
		end
		if not g_ActivityMgr:isEmpty(tmp.weeks) and not table.contains(tmp.weeks, nowWeek) then
			tmp.startTime, tmp.endTime = self:setNextTime2(tmp.startTime, tmp.endTime, tmp.weeks)
		end
		tmp.startTime, tmp.endTime = self:setNextTime(tmp.startTime, tmp.endTime, tmp.weeks, tmp.activityID)
		table.insert(self._activityConfig, tmp)
		if tmp.activityID == ACTIVITY_NORMAL_ID.MON_ATTACK then
			g_MonAttackMgr:preEndNotice(tmp.endTime)
		elseif tmp.activityID == ACTIVITY_NORMAL_ID.INVADE then
			g_InvadeMgr:setEndTime(tmp.endTime)
		elseif tmp.activityID == ACTIVITY_NORMAL_ID.LUOXIA then
			g_LuoxiaMgr:setOverTime(tmp.endTime)
		end
	end
	for index, activity in pairs(self._activityConfig) do
		self._GMIndex[activity.activityID] = index
	end
end

function ActivityNormalLimitManager:getActivityStartTime(activityID)
	local timeTick = 0
	if activityID == ACTIVITY_NORMAL_ID.MANOR_WAR then
		local isOpen, timeStr, lateDay = g_manorWarMgr:getManorOpenTime()
		timeTick = self:dealTimeStr(isOpen, timeStr, lateDay)
	elseif activityID == ACTIVITY_NORMAL_ID.CENTER_WAR then
		local isOpen, timeStr, lateDay = g_manorWarMgr:getZhongzhouOpenTime()
		timeTick = self:dealTimeStr(isOpen, timeStr, lateDay)
	elseif activityID == ACTIVITY_NORMAL_ID.SHA_WAR then
		local isOpen, timeStr, lateDay = g_shaWarMgr:getOpenTime()
		timeTick = self:dealTimeStr(isOpen, timeStr, lateDay)
	else
		local activitys, times, isOpen = self:getActivityConfig(activityID), {}, false
		if #activitys > 0 then
			for _, activity in pairs(activitys) do
				if activityID == ACTIVITY_NORMAL_ID.WORLD_BOSS then
					isOpen = true
					table.insert(times, activity.startTime)
				else
					if activity.active then
						isOpen = true
						break
					else
						table.insert(times, activity.startTime)
					end
				end
			end
			if not isOpen then
				timeTick = math.min(unpack(times))
			end
			if activityID == ACTIVITY_NORMAL_ID.WORLD_BOSS and #times > 1 and g_WorldBossMgr:isBossAllKill() then
				table.sort(times)
				if times[1] and times[2] and time.toedition("day", times[1]) ~= time.toedition("day", times[2]) then
					timeTick = times[2]
				end
			end
		end
	end
	return timeTick
end

function ActivityNormalLimitManager:dealTimeStr(isOpen, timeStr, lateDay)
	local timeTick = 0
	if not isOpen then
		-- timeStr = "*,*,*,6,19:00:00-20:00:00,25"
		local data = StrSplit(timeStr, ",")
		data = data[5]
		data = StrSplit(data, ":")
		local now = os.date("*t", os.time() + lateDay * DAY_SECENDS)
		timeTick = os.time{year = now.year, month = now.month, day = now.day, hour = data[1], min = data[2], sec = 0}
	end
	return timeTick
end

function ActivityNormalLimitManager:nowWeek(time)
	time = time or os.time()
	local t = os.date("*t", time)
	local week = t.wday
	week = week - 1
	if week == 0 then
		week = 7
	end
	return week
end

--获取当前进行的指定活动的开始时间
function ActivityNormalLimitManager:getNowWorldBossStartTime(activityID)
	local activitys = self:getActivityConfig(activityID)
	for _, activity in pairs(activitys) do
		if activity.active then
			return activity.startTime
		end
	end
	return 0
end

--设置下一次活动时间
function ActivityNormalLimitManager:setNextTime(startTime, endTime, weeks, activityID)
	local now = os.time()
	if endTime < now then
		if not g_ActivityMgr:isEmpty(weeks) then
			startTime, endTime = self:setNextTime2(startTime, endTime, weeks)
		else
			startTime = startTime + DAY_SECENDS
			endTime = endTime + DAY_SECENDS
		end
		if activityID then
			if activityID == ACTIVITY_NORMAL_ID.MON_ATTACK then
				g_MonAttackMgr:preEndNotice(endTime)
			elseif activityID == ACTIVITY_NORMAL_ID.INVADE then
				g_InvadeMgr:setEndTime(endTime)
			elseif activityID == ACTIVITY_NORMAL_ID.LUOXIA then
				g_LuoxiaMgr:setOverTime(endTime)
			end
		end
	end
	return startTime, endTime
end

function ActivityNormalLimitManager:setNextTime2(startTime, endTime, weeks)
	local week = self:nowWeek(endTime)
	local nextDay = 8
	for _, v in pairs(weeks) do
		if v > week and v < nextDay then
			nextDay = v
		end
	end
	if nextDay == 8 then
		nextDay = math.min(unpack(weeks)) + 7
	end
	startTime = startTime + (nextDay - week) * DAY_SECENDS
	endTime = endTime + (nextDay - week) * DAY_SECENDS
	return startTime, endTime
end

function ActivityNormalLimitManager:getActivityConfig(activityID)
	local result = {}
	for _, activity in pairs(self._activityConfig) do
		if activity.activityID == activityID then
			table.insert(result, activity)
		end
	end
	return result
end

function ActivityNormalLimitManager:getActivityConfigByIndex(index)
	return self._activityConfig[index]
end

function ActivityNormalLimitManager:getAllActivityConfig()
	return self._activityConfig
end

function ActivityNormalLimitManager:getJoinLevel(activityID)
	local activitys = self:getActivityConfig(activityID)
	if #activitys > 0 then
		return activitys[1].level
	end
	return 1
end

function ActivityNormalLimitManager:getActivityName(activityID)
	local activitys = self:getActivityConfig(activityID)
	if #activitys > 0 then
		return activitys[1].name
	end
	return "null"
end

function ActivityNormalLimitManager:setActiveState(activityID, isActive)
	if isActive and table.contains(self._closeActivity, activityID) then
		table.removeValue(self._closeActivity, activityID)
	end
	if not isActive and not table.contains(self._closeActivity, activityID) then
		table.insert(self._closeActivity, activityID)
	end
end

function ActivityNormalLimitManager:isFunSwitchOpen(activityID)
	return table.contains(self._closeActivity, activityID)
end

--玩家上线
function ActivityNormalLimitManager:onPlayerLoaded(player)
	self:playerChange(player)
end

--掉线登录
function ActivityNormalLimitManager:onActivePlayer(player)
	self:playerChange(player)
end

--玩家升级
function ActivityNormalLimitManager:onLevelChanged(player)
	self:playerChange(player)
end

function ActivityNormalLimitManager:playerChange(player)
	local roleID = player:getID()
	for _, activity in pairs(self._activityConfig) do
		if activity.active then
			self:pushMsgOn(roleID, activity.activityID)
		end
	end
	self._allUser[roleID] = player:getLevel()
end

--玩家下线
function ActivityNormalLimitManager:onPlayerOffLine(player)
	self._allUser[player:getID()] = nil
end

--推送玩家活动红点状态
function ActivityNormalLimitManager:pushMsgOn(roleID, activityID)
	local canJoin = false
	local activitys = self:getActivityConfig(activityID)
	local player = g_entityMgr:getPlayer(roleID)
	if player and not self:isFunSwitchOpen(activityID) and #activitys > 0 then
		local level = player:getLevel()
		for _, activity in pairs(activitys) do
			if activity.active and level >= activity.level then
				if activityID == ACTIVITY_NORMAL_ID.ENVOY then
					canJoin = g_EnvoyMgr:canJoin2(player)
				elseif activityID == ACTIVITY_NORMAL_ID.LUOXIA then
					canJoin = g_LuoxiaMgr:canJoin2(player)
				elseif activityID == ACTIVITY_NORMAL_ID.INVADE then
					canJoin = g_InvadeMgr:canJoin(player)
				elseif activityID == ACTIVITY_NORMAL_ID.GIVE_WINE and g_GiveWineMgr:canJoinAndGetWine(player) == 0 then
					canJoin = true
				elseif activityID == ACTIVITY_NORMAL_ID.WORLD_BOSS then
					if level >= 30 and not g_WorldBossMgr:isBossAllKill() then
						canJoin = true
					end
				elseif activityID == ACTIVITY_NORMAL_ID.TREASURE then
					canJoin = g_TreasureManger:canJoin2(player)
				else
					canJoin = true
				end
				break
			end
		end
	end
	if canJoin then
		local ret = {}
		ret.id = activityID
		ret.canJoin = canJoin
		fireProtoMessage(roleID, PUSH_SC_MSG_START, "PushActivityStart", ret)
	end
end

function ActivityNormalLimitManager:canJoin(roleID, activityID)
	local result = false
	local activitys = self:getActivityConfig(activityID)
	local player = g_entityMgr:getPlayer(roleID)
	if player and not self:isFunSwitchOpen(activityID) and #activitys > 0 then
		local level = player:getLevel()
		for _, activity in pairs(activitys) do
			-- if activity.active and level >= activity.level then
			-- 	if activityID == ACTIVITY_NORMAL_ID.ENVOY then
			-- 		result = g_EnvoyMgr:canJoin2(player)
			-- 	elseif activityID == ACTIVITY_NORMAL_ID.LUOXIA then
			-- 		result = g_LuoxiaMgr:canJoin2(player)
			-- 	elseif activityID == ACTIVITY_NORMAL_ID.INVADE then
			-- 		result = g_InvadeMgr:canJoin(player)
			-- 	elseif activityID == ACTIVITY_NORMAL_ID.GIVE_WINE then
			-- 		result = g_GiveWineMgr:canJoinAndGetWine(player)	--result == 2 表示活动时间内已领取过
			-- 	else
			-- 		result = true
			-- 	end
			-- 	break
			-- end
			if activity.active then
				if activityID == ACTIVITY_NORMAL_ID.GIVE_WINE then
					result = g_GiveWineMgr:canJoinAndGetWine(player)	--result == 2 表示活动时间内已领取过
				elseif activityID == ACTIVITY_NORMAL_ID.GIVE_WINE then
					result = g_TreasureManger:canJoin2(player)
				else
					result = true
				end
				break
			end
		end
	end
	if type(result) == "boolean" then
		if result then
			result = 0	--可以参加活动
		else
			result = 1	--不能参加活动
		end
	end
	return result
end

function ActivityNormalLimitManager:redDot(roleID)
	for _, activityID in pairs(ACTIVITY_NORMAL_ID) do
		if self:canJoin(roleID, activityID) == 0 then
			return true
		end
	end
	return false
end

function ActivityNormalLimitManager:update()
	local now = os.time()
	for activityID, t in pairs(self._GMTime) do
		if now - t > 3600 then
			self:off(self._GMIndex[activityID])
			self._GMTime[activityID] = nil
		end
	end
	for index, activity in pairs(self._activityConfig) do
		if activity.active then
			if now > activity.endTime then
				self:off(index)
			end
		else
			if activity.startTime < now then
				self._GMTime[activity.activityID] = nil
				self:on(index)
			end
			if now > activity.startTime - 300 and now < activity.startTime - 296 then
				self:trailerOn1(index)
			end
			if now > activity.startTime - 60 and now < activity.startTime - 56 then
				self:trailerOn2(index)
			end
		end
		if activity.endTime < now then
			activity.startTime, activity.endTime = self:setNextTime(activity.startTime, activity.endTime, activity.weeks, activity.activityID)
		end
	end
end

--活动开启
function ActivityNormalLimitManager:on(index)
	local activity = self:getActivityConfigByIndex(index)
	if not activity or activity.active or self:isFunSwitchOpen(activity.activityID) then
		return
	end
	local activityID = activity.activityID
	activity.active = true
	if activityID == ACTIVITY_NORMAL_ID.WORLD_BOSS then
		self:sendErrMsg2Client(3, 0, {})
		self:sendBossInfo2SystemChat(67,false)
	elseif activityID == ACTIVITY_NORMAL_ID.ENVOY then
		g_EnvoyMgr:openEnvoy()
		self:sendErrMsg2Client(9, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.LUOXIA then
		g_LuoxiaMgr:openLuoxia(self._GMTime[ACTIVITY_NORMAL_ID.LUOXIA])
		self:sendErrMsg2Client(39, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.MON_ATTACK then
		g_MonAttackMgr:on()
		self:sendErrMsg2Client(5, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.GIVE_WINE then
		g_GiveWineMgr:on()
		self:sendErrMsg2Client(60, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.FACTION_DART then 
		g_factionMgr:onFacDart()
		-- self:sendErrMsg2Client(104, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.GOU_HUO then 
		g_factionAreaManager:on()
	elseif activityID == ACTIVITY_NORMAL_ID.INVADE then
		g_InvadeMgr:on(self._GMTime[ACTIVITY_NORMAL_ID.INVADE])
	elseif activityID == ACTIVITY_NORMAL_ID.TREASURE then
		g_TreasureManger:openTreasure()
		self:sendErrMsg2Client(110, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.PVP then
		g_engine:openActivity(EVENT_3V3PVP_SETS, true)
	end
	for roleID, _ in pairs(self._allUser) do
		self:pushMsgOn(roleID, activityID)
	end
	self:sendMsg2SystemChat(63, 1, {activity.name})
	return
end

--活动关闭
function ActivityNormalLimitManager:off(index)
	local activity = self:getActivityConfigByIndex(index)
	if not activity or not activity.active or self:isFunSwitchOpen(activity.activityID) then
		return
	end
	local activityID = activity.activityID
	activity.active = false
	activity.startTime, activity.endTime = self:setNextTime(activity.startTime, activity.endTime, activity.weeks, activityID)
	
	if activityID == ACTIVITY_NORMAL_ID.ENVOY then
		g_EnvoyMgr:closeEnvoy()
		self:sendErrMsg2Client(10, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.LUOXIA then
		g_LuoxiaMgr:closeLuoxia()
	elseif activityID == ACTIVITY_NORMAL_ID.MON_ATTACK then
		g_MonAttackMgr:off()
		self:sendErrMsg2Client(7, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.GIVE_WINE then
		g_GiveWineMgr:off()
		self:sendErrMsg2Client(61, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.FACTION_DART then 
		g_factionMgr:offFacDart()
	elseif activityID == ACTIVITY_NORMAL_ID.GOU_HUO then 
		g_factionAreaManager:off()
	elseif activityID == ACTIVITY_NORMAL_ID.INVADE then 
		g_InvadeMgr:off()
	elseif activityID == ACTIVITY_NORMAL_ID.TREASURE then
		g_TreasureManger:closeTreasure()
		self:sendErrMsg2Client(112, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.PVP then
		g_engine:openActivity(EVENT_3V3PVP_SETS, false)
	end
	for roleID, _ in pairs(self._allUser) do
		self:pushMsgOn(roleID, activityID)
	end
	if activityID ~= ACTIVITY_NORMAL_ID.WORLD_BOSS then
		self:sendMsg2SystemChat(64, 1, {activity.name})
	end
end

--活动预告跑马灯通知
function ActivityNormalLimitManager:trailerOn1(index)
	local activity = self:getActivityConfigByIndex(index)
	if not activity or self:isFunSwitchOpen(activity.activityID) then
		return
	end
	local activityID = activity.activityID
	if activityID == ACTIVITY_NORMAL_ID.WORLD_BOSS then
		self:sendErrMsg2Client(2, 0, {})
		self:sendBossInfo2SystemChat(68, false)
	elseif activityID == ACTIVITY_NORMAL_ID.ENVOY then
		self:sendErrMsg2Client(8, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.LUOXIA then
		self:sendErrMsg2Client(41, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.MON_ATTACK then
		self:sendErrMsg2Client(4, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.GIVE_WINE then
		self:sendErrMsg2Client(59, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.FACTION_DART then 
		self:sendErrMsg2Client(100, 0, {})
	elseif activityID == ACTIVITY_NORMAL_ID.TREASURE then 
		self:sendErrMsg2Client(109, 0, {})
	end
	self:sendMsg2SystemChat(65, 1, {activity.name})
end

--活动预告通知2
function ActivityNormalLimitManager:trailerOn2(index)
	local activity = self:getActivityConfigByIndex(index)
	if not activity then
		return
	end
	if activity.activityID == ACTIVITY_NORMAL_ID.MON_ATTACK then
		return
	end
	self:sendErrMsg2Client(66, 1, {activity.name})
	self:sendMsg2SystemChat(66, 1, {activity.name})
	if activityID == ACTIVITY_NORMAL_ID.WORLD_BOSS then
		self:sendBossInfo2SystemChat(69, false)
	end
end

--GM命令开启活动
function ActivityNormalLimitManager:gmOn(activityID)
	self._GMTime[activityID] = os.time()
	self:on(self._GMIndex[activityID])
end

--GM命令关闭活动
function ActivityNormalLimitManager:gmOff(activityID)
	self._GMTime[activityID] = nil
	self:off(self._GMIndex[activityID])
end

--发送活动信息到聊天系统频道
function ActivityNormalLimitManager:sendMsg2SystemChat(msgIndex, paramCount, params)
	g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,msgIndex,paramCount,params)
end

function ActivityNormalLimitManager:sendBossInfo2SystemChat(index, onlive)
	for i, v in pairs(g_WorldBossMgr._bossMap or {}) do
		local bossName = v.name or ""
		local bossMapName = v.mapname or ""
		if not onlive then
			self:sendMsg2SystemChat(index,2,{bossName,bossMapName})
		else
			self:sendMsg2SystemChat(index,1,{bossName})
		end
	end
end

function ActivityNormalLimitManager:sendErrMsg2Client(errId, paramCount, params)
	local ret = {}
	ret.eventId = EVENT_PUSH_MESSAGE
	ret.eCode = errId
	ret.mesId = 0
	ret.param = {}
	paramCount = paramCount or 0
	for i = 1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function ActivityNormalLimitManager.getInstance()
	return ActivityNormalLimitManager()
end

g_normalLimitMgr = ActivityNormalLimitManager.getInstance()