--ActivityNormalManager.lua
--/*-----------------------------------------------------------------
--* Module:  ActivityNormalManager.lua
--* Author:  Andy
--* Modified: 2016年06月07日
--* Purpose: 日常活动
-------------------------------------------------------------------*/

require ("system.activityNormal.ActivityNormalConstant")
require ("system.activityNormal.ActivityNormalPlayer")
require ("system.activityNormal.ActivityNormalServlet")
require ("system.activityNormal.ActivityNormalLimitManager")

ActivityNormalManager = class(nil, Singleton, Timer)

function ActivityNormalManager:__init()
	self._normalConfig = {}		--配置数值
	self._normalUser = {}		--玩家数据
	self._activenessReward = {}	--活跃度奖励

	self._nowDay = time.toedition("day", os.time())	--当前统计的日期

	self:initialize()
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 30000, 30000)
	print("ActivityNormalManager TimeID:",self._timerID_)
end

function ActivityNormalManager:initialize()
	for _, config in pairs(require "data.ActivityNormalDB") do
		local tmp = {}
		tmp.id = config.q_id
		tmp.tab = config.q_tab
		tmp.activityID = config.q_activity_id or 0
		tmp.name = config.q_name or ""
		tmp.level = config.q_level or 0
		tmp.time = loadstring("return " .. (config.q_time or '{}'))()
		tmp.type = config.q_type
		tmp.times = config.q_times
		tmp.integral = config.q_integral
		tmp.findTimes = config.q_find_times or 0
		tmp.findMoney = config.q_find_money or 0
		tmp.findMoneyDropID = config.q_find_money_dropid or 0
		tmp.findIngot = config.q_find_ingot or 0
		tmp.findIngotDropID = config.q_find_ingot_dropid or 0
		if tmp.id and tmp.type then
			self._normalConfig[tmp.id] = tmp
		end
	end
	local normalLimitConfig = {}
	for i_, config in pairs(self._normalConfig) do
		if config.activityID > 0 and config.activityID ~= ACTIVITY_NORMAL_ID.MANOR_WAR and config.activityID ~= ACTIVITY_NORMAL_ID.CENTER_WAR and config.activityID ~= ACTIVITY_NORMAL_ID.SHA_WAR then
			for _, timeConfig in pairs(config.time) do
				local tmp = {}
				tmp.activityID = config.activityID
				tmp.name = config.name
				tmp.level = config.level
				tmp.time = timeConfig.time
				tmp.week = timeConfig.week
				table.insert(normalLimitConfig, tmp)
			end
		end
	end
	g_normalLimitMgr:setNormalLimitConfig(normalLimitConfig)
	for integral, dropID in pairs(ACTIVENESS_DROPID) do
		local dropItem, reward = dropString(0, 0, dropID), {}
		for _, item in pairs(dropItem) do
			local tmp = {
				itemID = item.itemID,
				count = item.count,
				bind = item.bind,
				strength = item.strength,
			}
			table.insert(reward, tmp)
		end
		self._activenessReward[integral] = reward
	end
end

--达成活跃度
function ActivityNormalManager.activeness2(roleID, type, count)
	local playerInfo = g_normalMgr:getPlayerInfo(roleID)
	if playerInfo then
		playerInfo:finishActiveness(type, count)
	end
end

--达成活跃度
function ActivityNormalManager:activeness(roleID, type, count)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		playerInfo:finishActiveness(type, count)
	end
end

--是否领过活跃度
function ActivityNormalManager:isReward(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		return playerInfo:isReward()
	end
	return false
end

--玩家掉线
function ActivityNormalManager:onPlayerInactive(player)
end

--玩家下线
function ActivityNormalManager:onPlayerOffLine(player)
	local roleID = player:getID()
	self._normalUser[roleID] = nil
end

--加载数据
function ActivityNormalManager.loadDBData(player, cacha_buf, roleSID)
	if #cacha_buf > 0 then
		local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
		if playerInfo then
			playerInfo:loadDBData(cacha_buf)
		end
	end
end

function ActivityNormalManager:update()
	local timeTick = time.toedition("day", os.time())
	local reset = false
	if self._nowDay ~= timeTick then
		reset = true
		self._nowDay = timeTick
	end
	for _, playerInfo in pairs(self._normalUser) do
		if reset then
			playerInfo:initializeActiveness()
			playerInfo:checkFindReward()
		end
		playerInfo:checkCast2DB()
	end
end

--玩家升级
function ActivityNormalManager:onLevelChanged(player)
	fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_STATE_CHANGE, 'ActivityNormalStateChange', {flag = 1, level = player:getLevel()})
end

--行会升级
function ActivityNormalManager:factionLevelChange(roleSID, factionLevel)
	-- local player = g_entityMgr:getPlayerBySID(roleSID)
	-- if player then
	-- 	fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_STATE_CHANGE, 'ActivityNormalStateChange', {flag = 2, level = factionLevel})
	-- end
end

--推送活跃度数据
function ActivityNormalManager:pushActiveness(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		local activeness = {}
		for integral, dropID in pairs(ACTIVENESS_DROPID) do
			local tmp = {}
			tmp.integral = integral
			tmp.status = playerInfo:getActivenessState(integral)
			tmp.reward = self._activenessReward[integral]
			table.insert(activeness, tmp)
		end
		local ret = {}
		ret.nowIntegral = playerInfo:getIntegral()
		ret.activeness = activeness
		ret.redDot1 = g_normalLimitMgr:redDot(roleID)
		ret.redDot2 = false
		ret.redDot3 = false
		ret.redDot4 = false
		fireProtoMessage(roleID, ACTIVITY_NORMAL_SC_ACTIVENESS, 'ActivityNormalActiveness', ret)
	end
end

--获取活跃度积分
function ActivityNormalManager:getActivenessIntegral(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		return playerInfo:getIntegral()
	end
	return 0
end

--使用物品
function ActivityNormalManager:useMat(player, matId, count)
	if matId ~= 7040 then
		return
	end
	local roleID = player:getID()
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		self:activeness(roleID, ACTIVENESS_TYPE.DART_INFO, count)
	end
end

function ActivityNormalManager:onMonsterKill(monsterSID, roleID, monsterID, mapID)
	local monster = g_entityMgr:getMonster(monsterID)
	if not monster then
		return
	end
	local playerInfo = self:getPlayerInfo(roleID)
	if not playerInfo then
		return
	end
	playerInfo:finishActiveness(ACTIVENESS_TYPE.KILL_MONSTER, 1)
	if monster:getMonType() == Monster_Excellent then
		playerInfo:finishActiveness(ACTIVENESS_TYPE.KILL_ELITE, 1)
	end
end

function ActivityNormalManager:getActivenessReward(integral)
	return self._activenessReward[integral]
end

function ActivityNormalManager:getPlayerInfo(roleID)
	if not self._normalUser[roleID] then
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			self._normalUser[roleID] = ActivityNormalPlayer(player:getSerialID(), roleID)
		end
	end
	return self._normalUser[roleID]
end

--玩家升级 
function ActivityNormalManager:onLevelChanged(player, level)
	local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
	if playerInfo then
		playerInfo:playerSetLevel(level)
	end
end

function ActivityNormalManager:getNormalConfig()
	return self._normalConfig or {}
end

function ActivityNormalManager:getNormalConfigByTab(tab)
	local result = {}
	for _, config in pairs(self:getNormalConfig()) do
		if config.tab == tab then
			table.insert(result, config)
		end
	end
	return result
end

function ActivityNormalManager:getNormalConfigById(id)
	for _, config in pairs(self:getNormalConfig()) do
		if config.id == id then
			return config
		end
	end
	return nil
end

function ActivityNormalManager:getNormalConfigByType(type)
	for _, config in pairs(self:getNormalConfig()) do
		if config.type == type then
			return config
		end
	end
	return nil
end

function ActivityNormalManager:getActivityJoinLevel(type)
	local config = self:getNormalConfigByType(type)
	if config then
		return config.type
	end
	return 1
end

function ActivityNormalManager:hotUpdateConfig()
	package.loaded["data.ActivityNormalDB"] = nil
	self:initConfig()
end

function ActivityNormalManager:sendErrMsg2Client(roleID, errId, paramCount, params)
	fireProtoSysMessage(ActivityNormalServlet.getInstance():getCurEventID(), roleID, EVENT_ACTIVITY_NORMAL_SETS, errId, paramCount, params)
end

function ActivityNormalManager.DoYuanBaoFindRewardPray(roleSID, ret, money, itemId, itemCount, callBackContext)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
	if not playerInfo then
		return
	end
	playerInfo:payFindRewardCallback(player, ret, callBackContext)
end

function ActivityNormalManager.getInstance()
	return ActivityNormalManager()
end

g_normalMgr = ActivityNormalManager.getInstance()