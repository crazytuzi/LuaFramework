--ActivityManager.lua
--/*-----------------------------------------------------------------
--* Module:  ActivityManager.lua
--* Author:  Andy
--* Modified: 2015年9月22日
--* Purpose: Implementation of the class ActivityManager
-------------------------------------------------------------------*/

require ("system.activity.ActivityConstants")
require ("system.activity.DataManager")
require ("system.activity.ActivityServlet")
require ("system.activity.SignIn")
require ("system.activity.SevenFestival")
require ("system.activity.Online")
require ("system.activity.Level")
require ("system.activity.MonthCard")
require ("system.activity.operater.Model1")
require ("system.activity.operater.Model2")
require ("system.activity.operater.Model3")
require ("system.activity.operater.Model4")
require ("system.activity.operater.Model5")
require ("system.activity.operater.Model6")
require ("system.activity.operater.Model8")

ActivityManager = class(nil, Singleton, Timer)

function ActivityManager:__init()
	self._startTime = g_frame:getStartTick()	-- 开服时间
	self._UserLoadFlag = {}			--玩家登录或掉线登录延时推活动数据标记
	self._ActivityTable = {}		--正在进行的运营活动列表,用于活动关闭推送活动数据给玩家
	self._ActivityTable2 = {}		--即将进行的运营活动列表,用于活动开启推送活动数据给玩家
	self._item = {}					--道具数据
	self._allOnlineUser = {}		--所有在线的玩家
	self._nowMaxActivityID = ACTIVITY_MIN_ID	--当前最大的运营活动ID
	self._signNowDay = time.toedition("day")	--当前签到的日期

	self._UserSignIn = {}			--签到
	self._UserOnline = {}			--在线礼包
	self._UserLevel = {}			--等级礼包
	self._UserMonthCard = {}		--月卡
	self._UserSevenFestival = {}	--七日盛典数据
	self._UserActivity = {}			--运营活动数据
	
	self._lastTick = 0
	self._lastTick1 = 0
	self._nowDay = time.toedition("day")
	self:checkHasSevenFestival("init")
	self:loadItemConfig()
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 1000)
	print("ActivityManager TimeID:",self._timerID_)
end

function ActivityManager.setStartTime(timeTick)
	g_ActivityMgr._startTime = timeTick
	g_ActivityMgr:checkHasSevenFestival("setStartTime")
end

function ActivityManager:checkHasSevenFestival(source)
	print("=====\tStartTime:" .. time.tostring(self._startTime) .. "\t=====", source)
	self._hasSeventFestival = false	--是否有七日盛典活动
	self._hasSeventFestival2 = false--是否有十四日盛典活动
	local nowOpenDay = self:getNowOpenDay()
	if nowOpenDay > 0 and nowOpenDay <= ACTIVITY_SEVEN_FESTIVAL_DAY + 1 then
		self._hasSeventFestival = true
	end
	if nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY and nowOpenDay <= ACTIVITY_SEVEN_FESTIVAL_DAY2 + 1 then
		self._hasSeventFestival2 = true
	end
	if source == "setStartTime" or source == "GMsetStartTime" then
		self:sendAllActivityList()
	end
end

function ActivityManager:update()
	local now = os.time()
	--每秒触发
	for roleID, t in pairs(self._UserLoadFlag or {}) do
		if now > t then
			self:getActivityList(roleID)
			self._UserLoadFlag[roleID] = nil
		end
	end
	--三秒触发
	if now - self._lastTick >= 3 then
		self:checkActivityTable()
		self._lastTick = now
	end
	--五秒触发
	if now - self._lastTick1 >= 5 then
		self:checkSevenFestival()
		self._lastTick1 = now
		local timeTick = time.toedition("day")
		if timeTick ~= self._nowDay then
			self._nowDay = timeTick
			for _, User in pairs(self._UserMonthCard or {}) do
				User[ACTIVITY_MONTHCARD_ID]:check()
			end
			--检查运营活动是否需要重置状态
			for _, activitys in pairs(self._UserActivity or {}) do
				for _, activity in pairs(activitys or {}) do
					activity:resetStatus()
				end
			end
			self:checkSingin()
		end
		self:checkOnlineActivity(timeTick)
	end
end

--活动事件触发检测模板执行回调
function ActivityManager:action(modelID, callback)
	local models = g_DataMgr:getActivityConfigByModelID(modelID)
	if not self:isEmpty(models) then
		for activityID, model in pairs(models) do
			callback(model, modelID, activityID)
		end
	end
end

function ActivityManager:actionAll(callback)
	for modelID, models in pairs(g_DataMgr:getAllActivityConfig()) do
		for activityID, model in pairs(models) do
			callback(model, modelID, activityID)
		end
	end
end

function ActivityManager:getActivityList(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end
	local activityList = {}
	local roleSID, level = player:getSerialID(), player:getLevel()

	local activity = {}
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID)
	if User then
		activity = {ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID, ACTIVITY_NAME_SIGNIN, User:redDot(), false}
		self:insertActivity(activityList, ACTIVITY_TAB_WELFARE, activity)
	end
	if self._hasSeventFestival then
		local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SEVEN_FESTIVAL, ACTIVITY_SEVEN_FESTIVAL_ID)
		if User then
			activity = {ACTIVITY_MODEL.SEVEN_FESTIVAL, ACTIVITY_SEVEN_FESTIVAL_ID, ACTIVITY_NAME_SEVEN_FESTIVAL, User:redDot(), false}
			self:insertActivity(activityList, ACTIVITY_TAB_FESTIVAL, activity)
		end
	end
	if self._hasSeventFestival2 then
		local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SEVEN_FESTIVAL2, ACTIVITY_SEVEN_FESTIVAL_ID2)
		if User then
			activity = {ACTIVITY_MODEL.SEVEN_FESTIVAL2, ACTIVITY_SEVEN_FESTIVAL_ID2, ACTIVITY_NAME_SEVEN_FESTIVAL2, User:redDot(), false}
			self:insertActivity(activityList, ACTIVITY_TAB_FESTIVAL, activity)
		end
	end
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.ONLINE, ACTIVITY_ONLIINE_ID)
	if User then
		activity = {ACTIVITY_MODEL.ONLINE, ACTIVITY_ONLIINE_ID, ACTIVITY_NAME_ONLINE, User:redDot(), false}
		self:insertActivity(activityList, ACTIVITY_TAB_WELFARE, activity)
	end
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.LEVEL, ACTIVITY_LEVEL_ID)
	if User then
		activity = {ACTIVITY_MODEL.LEVEL, ACTIVITY_LEVEL_ID, ACTIVITY_NAME_LEVEL, User:redDot(), false}
		self:insertActivity(activityList, ACTIVITY_TAB_WELFARE, activity)
	end
	--月卡
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_ID)
	if User then -- and User:calcSurplus() > 0 then
		activity = {ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_ID, ACTIVITY_NAME_MONTHCARD, User:redDot(), false}
		self:insertActivity(activityList, ACTIVITY_TAB_WELFARE, activity)
	end
	--豪华月卡
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_LUXURY_ID)
	if User then -- and User:calcSurplus() > 0 then
		activity = {ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_LUXURY_ID, ACTIVITY_NAME_MONTHCARD_LUXURY, User:redDot(), false}
		self:insertActivity(activityList, ACTIVITY_TAB_WELFARE, activity)
	end
	--运营活动
	self:actionAll(function(model, modelID, activityID)
		if model.levelDown and model.levelUp and model.levelDown <= level and level <= model.levelUp and self:timeValid(model.startTime, model.endTime, model.week) then
			local User = self:getUserActivity(roleID, modelID, activityID)
			if not User then
				User = self:initActivityUserData(modelID, activityID, roleSID, roleID)
			end
			if modelID ~= ACTIVITY_MODEL.FIRSTCHARGE or (modelID == ACTIVITY_MODEL.FIRSTCHARGE and not User:finishFirstCharge()) then
				activity = {modelID, activityID, model.name, User:redDot(), model.index, model.order, model.lableType, model.leftLabel, model.link, model.activityPic}
				self:insertActivity(activityList, ACTIVITY_TAB_OPERATER, activity)
			end
		end
	end)
	self:sendActivityList(roleID, activityList)
end

function ActivityManager:insertActivity(activityList, tab, activity)
	if not activityList[tab] then activityList[tab] = {} end
	table.insert(activityList[tab], activity)
end

function ActivityManager:sendActivityList(roleID, activityList)
	local tabs = {}
	for tab, _ in pairs(activityList) do
		tabs[tab] = true
	end
	if #tabs > 0 then
		local lists = {}
		for tab, _ in pairs(tabs or {}) do
			local list, data = {}, {}
			for _, activity in pairs(activityList[tab]) do
				local tmp = {}
				tmp.modelID = activity[1]		--模板ID
				tmp.activityID = activity[2]	--活动ID
				tmp.activityName = activity[3]	--活动名称
				tmp.redDot = activity[4]		--小红点提示
				tmp.index = activity[5]			--活动是否设置锚点
				tmp.order = activity[6]			--显示顺序
				tmp.lableType = activity[7]		--活动标签页类型：推荐活动（0），超值特权（1），游戏公告（2）
				tmp.leftLabel = activity[8]		--活动左上角标签：1:限时（黄色）、2:火爆（红色）、3:最新（绿色）、4:免费（紫色）
				tmp.link = activity[9]			--立即前往的链接
				tmp.pic = activity[10]			--活动图标
				table.insert(data, tmp)
			end
			list.tab = tab						--活动入口ID
			list.data = data
			table.insert(lists, list)
		end
		fireProtoMessage(roleID, ACTIVITY_SC_LIST_RET, "ActivityListRet", {list = lists})
	end
end

--玩家上线
function ActivityManager:onPlayerLoaded(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	self:initUserData(roleSID, roleID)
	self:pushChargeData(roleID)
	self:sevenFestivalChange(roleID, ACTIVITY_ACT.LOGIN, time.toedition("day"))
	self:action(ACTIVITY_MODEL.LOGIN, function(model, modelID, activityID)
		self:login(self:getUserActivity(roleID, modelID, activityID))
	end)
	self:action(ACTIVITY_MODEL.TOTAL_LOGIN, function(model, modelID, activityID)
		self:login(self:getUserActivity(roleID, modelID, activityID))
	end)
	self:action(ACTIVITY_MODEL.CONTINUOUS_LOGIN, function(model, modelID, activityID)
		self:login(self:getUserActivity(roleID, modelID, activityID))
	end)
	self._UserLoadFlag[roleID] = os.time()player:getLevel()
end

function ActivityManager:login(User)
	if User then
		User:login()
	end
end

function ActivityManager:initUserData(roleSID, roleID)
	if self._allOnlineUser[roleID] then
		return
	end
	self._allOnlineUser[roleID] = true
	g_entityDao:loadActivity(roleSID)
	if not self._UserSignIn[roleID] then
		self._UserSignIn[roleID] = {}
		self._UserSignIn[roleID][ACTIVITY_SIGNIN_ID] = SignIn(roleID, roleSID)
	end
	if not self._UserSevenFestival[roleID] then
		self._UserSevenFestival[roleID] = {}
		self._UserSevenFestival[roleID][ACTIVITY_SEVEN_FESTIVAL_ID] = SevenFestival(roleID, roleSID, ACTIVITY_MODEL.SEVEN_FESTIVAL, ACTIVITY_SEVEN_FESTIVAL_ID)
		self._UserSevenFestival[roleID][ACTIVITY_SEVEN_FESTIVAL_ID2] = SevenFestival(roleID, roleSID, ACTIVITY_MODEL.SEVEN_FESTIVAL2, ACTIVITY_SEVEN_FESTIVAL_ID2)
	end
	if not self._UserOnline[roleID] then
		self._UserOnline[roleID] = {}
		self._UserOnline[roleID][ACTIVITY_ONLIINE_ID] = Online(roleID, roleSID)
	end
	if not self._UserLevel[roleID] then
		self._UserLevel[roleID] = {}
		self._UserLevel[roleID][ACTIVITY_LEVEL_ID] = Level(roleID, roleSID)
	end
	if not self._UserMonthCard[roleID] then
		self._UserMonthCard[roleID] = {}
		self._UserMonthCard[roleID][ACTIVITY_MONTHCARD_ID] = MonthCard(roleID, roleSID,ACTIVITY_MONTHCARD_ID)
		self._UserMonthCard[roleID][ACTIVITY_MONTHCARD_LUXURY_ID] = MonthCard(roleID, roleSID,ACTIVITY_MONTHCARD_LUXURY_ID)
	end
	self:actionAll(function(model, modelID, activityID)
		if self:timeValid(model.startTime, model.endTime, model.week) then
			self:initActivityUserData(modelID, activityID, roleSID, roleID)
		end
	end)
end

--初始化运营活动玩家数据
function ActivityManager:initActivityUserData(modelID, activityID, roleSID, roleID)
	if not self._UserActivity[roleID] then
		self._UserActivity[roleID] = {}
	end
	local User = self._UserActivity[roleID][activityID]
	if User then
		return User
	end
	if modelID == ACTIVITY_MODEL.LOGIN or modelID == ACTIVITY_MODEL.TOTAL_LOGIN or modelID == ACTIVITY_MODEL.CONTINUOUS_LOGIN or modelID == ACTIVITY_MODEL.SPECIFIC_ONLINE then
		User = Model1(modelID, activityID, roleID, roleSID)
	elseif modelID == ACTIVITY_MODEL.DISCOUNT then
		User = Model2(modelID, activityID, roleID, roleSID)
	elseif modelID == ACTIVITY_MODEL.COPY_REWARD or modelID == ACTIVITY_MODEL.TASK_REWARD or modelID == ACTIVITY_MODEL.MONSTER_REWARD then
		User = Model3(modelID, activityID, roleID, roleSID)
	elseif modelID == ACTIVITY_MODEL.JOIN_WORLD_BOSS or modelID == ACTIVITY_MODEL.TOTAL_JOIN_COPY or modelID == ACTIVITY_MODEL.SMELT or modelID == ACTIVITY_MODEL.SMELT_SPECIAL
		or modelID == ACTIVITY_MODEL.STRENGTHEN or modelID == ACTIVITY_MODEL.STRENGTHEN_SPECIAL or modelID == ACTIVITY_MODEL.TASK or modelID == ACTIVITY_MODEL.BAPTIZE
		or modelID == ACTIVITY_MODEL.BAPTIZE_SPECIAL then
		User = Model4(modelID, activityID, roleID, roleSID)
	elseif modelID == ACTIVITY_MODEL.SPECIFIC_ITEM then
		User = Model5(modelID, activityID, roleID, roleSID)
	elseif modelID == ACTIVITY_MODEL.FIRSTCHARGE or modelID == ACTIVITY_MODEL.PAY or modelID == ACTIVITY_MODEL.TOTALCHARGE then
		User = Model6(modelID, activityID, roleID, roleSID)
	elseif modelID == ACTIVITY_MODEL.LEVEL_ACTIVITY or modelID == ACTIVITY_MODEL.TOTALCHARGE2 or modelID == ACTIVITY_MODEL.ONLINE_ACTIVITY or modelID == ACTIVITY_MODEL.TOTAL_KILL_MONSTER then
		User = Model8(modelID, activityID, roleID, roleSID)
	end
	if User then
		self._UserActivity[roleID][activityID] = User
	end
	return User
end

-- 加载玩家活动数据返回
function ActivityManager.onLoadActivity(roleSID, dbData)
	if #dbData <= 0 then
		return
	end
	local data = protobuf.decode("ActivityProtocol", dbData)
	if type(data) ~= "table" then
		return
	end
	local modelID, activityID, datas, realModelID = data.modelID, data.activityID, data.datas, false
	for _, id in pairs(ACTIVITY_MODEL) do
		if modelID == id then
			realModelID = true
			break
		end
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not realModelID or #datas <= 0 or not player then
		return
	end
	local roleID = player:getID()
	g_ActivityMgr:initUserData(roleSID, roleID)
	if modelID ~= ACTIVITY_MODEL.SEVEN_FESTIVAL and modelID ~= ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		datas = unserialize(datas)
	end
	local User = g_ActivityMgr:getUserActivity(roleID, modelID, activityID)
	if User then
		User:loadDBdata(datas)
	end
end

-- 存缓存
function ActivityManager:cast2Cache(roleSID, modelID, activityID, datas)
	if modelID ~= ACTIVITY_MODEL.SEVEN_FESTIVAL and modelID ~= ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		datas = serialize(datas)
	end
	local dbData = {modelID = modelID, activityID = activityID,	datas = datas}
	local cache_buff = protobuf.encode("ActivityProtocol", dbData)
	g_engine:savePlayerCache(roleSID, activityID * 1000 + modelID, cache_buff, #cache_buff)
end

-- 根据模板ID跟活动ID获取玩家活动数据
function ActivityManager:getUserActivity(roleID, modelID, activityID)
	if modelID == ACTIVITY_MODEL.MONTHCARD then
		if self._UserMonthCard[roleID] then
			return self._UserMonthCard[roleID][activityID]
		end
	elseif modelID == ACTIVITY_MODEL.SIGNIN then
		if self._UserSignIn[roleID] then
			return self._UserSignIn[roleID][activityID]
		end
	elseif modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL or modelID == ACTIVITY_MODEL.SEVEN_FESTIVAL2 then
		if self._UserSevenFestival[roleID] then
			return self._UserSevenFestival[roleID][activityID]
		end
	elseif modelID == ACTIVITY_MODEL.ONLINE then
		if self._UserOnline[roleID] then
			return self._UserOnline[roleID][activityID]
		end
	elseif modelID == ACTIVITY_MODEL.LEVEL then
		if self._UserLevel[roleID] then
			return self._UserLevel[roleID][activityID]
		end
	else
		if not self._UserActivity[roleID] then
			self._UserActivity[roleID] = {}
		end
		if self._UserActivity[roleID][activityID] then
			return self._UserActivity[roleID][activityID]
		end
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			return self:initActivityUserData(modelID, activityID, player:getSerialID(), roleID)
		end
	end
end

--掉线登录
function ActivityManager:onActivePlayer(player)
	local roleID = player:getID()
	self._UserLoadFlag[roleID] = os.time()
end

--玩家注销
function ActivityManager:onPlayerOffLine(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	self:playerLogout(self:getUserActivity(roleID, ACTIVITY_MODEL.ONLINE, ACTIVITY_ONLIINE_ID))
	self:playerLogout(self:getUserActivity(roleID, ACTIVITY_MODEL.SEVEN_FESTIVAL, ACTIVITY_SEVEN_FESTIVAL_ID))
	self:playerLogout(self:getUserActivity(roleID, ACTIVITY_MODEL.SEVEN_FESTIVAL2, ACTIVITY_SEVEN_FESTIVAL_ID2))
	self:action(ACTIVITY_MODEL.ONLINE_ACTIVITY, function(model, modelID, activityID)
		self:playerLogout(self:getUserActivity(roleID, modelID, activityID))
	end)
	
	self._allOnlineUser[roleID] = nil
	if self._UserSignIn[roleID] then
		self._UserSignIn[roleID] = nil
	end
	if self._UserSevenFestival[roleID] then
		self._UserSevenFestival[roleID] = nil
	end
	if self._UserMonthCard[roleID] then
		self._UserMonthCard[roleID] = nil
	end
	if self._UserOnline[roleID] then
		self._UserOnline[roleID] = nil
	end
	if self._UserLevel[roleID] then
		self._UserLevel[roleID] = nil
	end
	if self._UserActivity[roleID] then
		self._UserActivity[roleID] = nil
	end
end

function ActivityManager:playerLogout(User)
	if User then
		User:playerLogout()
	end
end

--玩家充值
function ActivityManager:onPlayerCharge(player, ingot, czType)
	local roleID = player:getID()
	-- ingot = math.floor(ingot / 10)
	if not ingot or ingot <= 0 then
		return
	end
	self:charge(self:getUserActivity(roleID, ACTIVITY_NAME_MONTHCARD, ACTIVITY_MONTHCARD_ID), ingot, czType)
	self:action(ACTIVITY_MODEL.FIRSTCHARGE, function(model, modelID, activityID)
		self:charge(self:getUserActivity(roleID, modelID, activityID), ingot)
	end)
	self:action(ACTIVITY_MODEL.TOTALCHARGE, function(model, modelID, activityID)
		self:charge(self:getUserActivity(roleID, modelID, activityID), ingot)
	end)
	self:action(ACTIVITY_MODEL.TOTALCHARGE2, function(model, modelID, activityID)
		self:charge(self:getUserActivity(roleID, modelID, activityID), ingot)
	end)
end

function ActivityManager:charge(User, ingot, czType)
	if User then
		User:charge(ingot, czType)
	end
end

--消耗元宝
function ActivityManager:onPlayerConsume(player, ingot)
	local roleID = player:getID()
	self:action(ACTIVITY_MODEL.PAY, function(model, modelID, activityID)
		self:consume(self:getUserActivity(roleID, modelID, activityID), ingot)
	end)
end

function ActivityManager:consume(User, ingot)
	if User then
		User:consume(ingot)
	end
end

-- 判断是否在活动时间范围内
function ActivityManager:timeValid(startTime, endTime, weeks)
	if not startTime or not endTime then
		return false
	end
	local now = os.time()
	if startTime <= now and now <= endTime then
		if weeks and type(weeks) == "table" and #weeks > 0 then
			local t = os.date("*t", os.time())
			local week = t.wday
			week = week - 1
			if week == 0 then
				week = 7
			end
			if table.contains(weeks, week) then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		return false
	end
end

--当天为开服第几天
function ActivityManager:getNowOpenDay()
	local tab = os.date("*t", self._startTime)
	local openTick = self._startTime - tab.hour * 3600 - tab.min * 60 - tab.sec
	return math.max(math.ceil((os.time() - openTick) / DAY_SECENDS), 0)
end

--玩家升级
function ActivityManager:onLevelChanged(player)
	local roleID, level = player:getID(), player:getLevel()
	self:sevenFestivalChange(roleID, ACTIVITY_ACT.LEVELUP, level)
	self:levelUp(self:getUserActivity(roleID, ACTIVITY_MODEL.LEVEL, ACTIVITY_LEVEL_ID), level)
	self:action(ACTIVITY_MODEL.LEVEL_ACTIVITY, function(model, modelID, activityID)
		self:levelUp(self:getUserActivity(roleID, modelID, activityID), level)
	end)
	if not self:isEmpty(g_DataMgr:getAllActivityConfig()) then
		self:getActivityList(roleID)
	end
end

function ActivityManager:levelUp(User, level)
	if User then
		User:levelUp(level)
	end
end

function ActivityManager:battleChanged(player, battle)
	self:sevenFestivalChange(player:getID(), ACTIVITY_ACT.BATTLEUP, battle)
end

--装备强化(穿戴装备)
function ActivityManager:equipmentUp(roleSID)
	if self._hasSeventFestival or self._hasSeventFestival2 then
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then
			return
		end
		local itemMgr = player:getItemMgr()
		if not itemMgr then
			return
		end
		local minLeve = -1		--身上穿的所有装备中强化最低的等级
		local allEquip = true	--是否所有装备都穿上身
		local quality = {}		--身上装备对应品质物品个数
		for i = 1, Item_EquipPosition_Foot do
			local equipStrengthLevel = -1
			local item = itemMgr:findItem(i, Item_BagIndex_EquipmentBar)
			if item then
				local equipProto = item:getEquipProp()
				if equipProto then
					equipStrengthLevel = equipProto:getStrengthLevel()
				end
				local itemProto = g_entityMgr:getConfigMgr():getItemProto(item:getProtoID())
				if itemProto then
					local color = itemProto.defaultColor or 0
					if not quality[color] then
						quality[color] = 0
					end
					quality[color] = quality[color] + 1
				end
			end
			if i ~= Item_EquipPosition_Suit then
				if equipStrengthLevel > -1 then
					if minLeve == -1 or minLeve > equipStrengthLevel then
						minLeve = equipStrengthLevel
					end
				else
					allEquip = false
				end
			end
		end
		local roleID = player:getID()
		if allEquip and minLeve > -1 then
			self:sevenFestivalChange(roleID, ACTIVITY_ACT.EQUIP, minLeve)
		end
		for i = 2, 5 do
			self:qualityEquipCount(roleID, quality, i)
		end
	end
end

--达到指定品质以上的装备数量
function ActivityManager:qualityEquipCount(roleID, quality, color)
	local count = 0
	for k, v in pairs(quality) do
		if k >= color then
			count = count + v
		end
	end
	if count > 0 then
		if color == 2 then
			self:sevenFestivalChange(roleID, ACTIVITY_ACT.QUALITY2, count)
		elseif color == 3 then
			self:sevenFestivalChange(roleID, ACTIVITY_ACT.QUALITY3, count)
		elseif color == 4 then
			self:sevenFestivalChange(roleID, ACTIVITY_ACT.QUALITY4, count)
		elseif color == 5 then
			self:sevenFestivalChange(roleID, ACTIVITY_ACT.QUALITY5, count)
		end
	end
end

--勋章升级
function ActivityManager.medallLevelUp(roleID, level)
	g_ActivityMgr:sevenFestivalChange(roleID, ACTIVITY_ACT.MEDALUP, math.ceil((level + 1) / 10))
end

--远古宝藏改变
function ActivityManager.preciousUp(roleSID, count)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.PRECIOUS, count)
	end
end

--公平竞技场胜利
function ActivityManager.winPvp(roleID)
	g_ActivityMgr:sevenFestivalChange(roleID, ACTIVITY_ACT.PVP, 1)
end

--七日盛典数据改变
function ActivityManager:sevenFestivalChange(roleID, type, value)
	if self._hasSeventFestival or self._hasSeventFestival2 then
		local nowOpenDay = self:getNowOpenDay()
		if nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY2 then
			return
		end
		if nowOpenDay <= ACTIVITY_SEVEN_FESTIVAL_DAY then
			local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SEVEN_FESTIVAL, ACTIVITY_SEVEN_FESTIVAL_ID)
			if User then
				User:changeStatus(type, value)
			end
		end
		if nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY then
			local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SEVEN_FESTIVAL2, ACTIVITY_SEVEN_FESTIVAL_ID2)
			if User then
				User:changeStatus(type, value)
			end
		end
	end
end

function ActivityManager:checkSevenFestival()
	if self._hasSeventFestival or self._hasSeventFestival2 then
		local nowOpenDay = self:getNowOpenDay()
		if self._hasSeventFestival and not self._hasSeventFestival2 and nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY then
			self._hasSeventFestival2 = true
			self:sendAllActivityList()
		end
		if self._hasSeventFestival and nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY + 1 then
			self._hasSeventFestival = false
			self:sendAllActivityList()
		end
		if self._hasSeventFestival2 and nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY2 + 1 then
			self._hasSeventFestival2 = false
			self:sendAllActivityList()
		end
		if nowOpenDay <= ACTIVITY_SEVEN_FESTIVAL_DAY then
			for _, activitys in pairs(self._UserSevenFestival) do
				for activityID, activity in pairs(activitys) do
					if activityID == ACTIVITY_SEVEN_FESTIVAL_ID then
						activity:update()
						break
					end
				end
			end
		end
		if nowOpenDay > ACTIVITY_SEVEN_FESTIVAL_DAY and nowOpenDay <= ACTIVITY_SEVEN_FESTIVAL_DAY2 then
			for _, activitys in pairs(self._UserSevenFestival) do
				for activityID, activity in pairs(activitys) do
					if activityID == ACTIVITY_SEVEN_FESTIVAL_ID2 then
						activity:update()
						break
					end
				end
			end
		end
	end
end

function ActivityManager:hasSeventFestival2()
	return self._hasSeventFestival2
end

function ActivityManager:checkSingin()
	local timeTick = time.toedition("day", os.time() - ACTIVITY_REFRESH * 3600)
	if timeTick ~= self._signNowDay then
		self:sendAllActivityList()
		self._signNowDay = timeTick
	end
end

function ActivityManager:checkOnlineActivity(timeTick)
	for _, User in pairs(self._UserOnline) do
		User[ACTIVITY_ONLIINE_ID]:check(false, timeTick)
	end
	self:action(ACTIVITY_MODEL.SPECIFIC_ONLINE, function(model, modelID, activityID)
		for roleID, _ in pairs(self._allOnlineUser) do
			if self:canJoinActivity(roleID, model) then
				self:checkOnline(self:getUserActivity(roleID, modelID, activityID))
			end
		end
	end
	)
	self:action(ACTIVITY_MODEL.ONLINE_ACTIVITY, function(model, modelID, activityID)
		for roleID, _ in pairs(self._allOnlineUser) do
			if self:canJoinActivity(roleID, model) then
				self:checkOnline(self:getUserActivity(roleID, modelID, activityID))
			end
		end
	end
	)
end

function ActivityManager:checkOnline(User)
	if User then
		User:checkOnline()
	end
end

--扣除元宝回调
function ActivityManager.costIngotCallback(roleSID, ret, money, itemId, itemCount, calbackContext)
	local ret = TPAY_FAILED
	local callbackInfo = unserialize(calbackContext)
	if table.size(callbackInfo) == 0 then
		return ret
	end
	local modelID = callbackInfo.modelID
	local User = g_ActivityMgr:getUserActivity(callbackInfo.roleID, modelID, callbackInfo.activityID)
	if User then
		if (modelID == ACTIVITY_MODEL.DISCOUNT or modelID == ACTIVITY_MODEL.SPECIFIC_ITEM) then
			ret = User:rewardCallBack(callbackInfo.index)
		elseif modelID == ACTIVITY_MODEL.SIGNIN then
			ret = User:reSignCallback(callbackInfo.times)
		end
	end
	return ret
end

--当天是否已签到
function ActivityManager:signInToday(roleID)
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID)
	if User then
		return User:signInToday()
	else
		return false
	end
end

function ActivityManager:gmSingIn(roleID, times)
	local User = self:getUserActivity(roleID, ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID)
	if User then
		return User:gmSingIn(times)
	end
end

function ActivityManager:getStartTime()
	return self._startTime
end

function ActivityManager:GMsetStartTime(day)
	self._startTime = os.time() - (day - 1) * DAY_SECENDS
	self:checkHasSevenFestival("GMsetStartTime")
end

--活动是否到了循环周期(0、无周期 1、按日循环 2、按周循环 3、按月循环 4、按年循环)
function ActivityManager:canLoop(model, finishTime)
	if finishTime <= 0 or not model then
		return false
	end
	if model.modelID == ACTIVITY_MODEL.FIRSTCHARGE then
		return false
	end
	local now, loopType, startTime = os.time(), model.loopType, model.startTime
	if loopType == 1 and time.toedition("day", now) ~= time.toedition("day", finishTime) then
		return true
	elseif loopType == 2 and math.ceil(os.difftime(finishTime, WEEK_START_TIME) / WEEK_SECENDS) ~= math.ceil(os.difftime(now, WEEK_START_TIME) / WEEK_SECENDS) then
		return true
	elseif loopType == 3 and time.toedition("month", now) ~= time.toedition("month", finishTime) then
		return true
	elseif loopType == 4 and time.toedition("year", now) ~= time.toedition("year", finishTime) then
		return true
	end
	return false
end

--能否参加指定的运营活动
function ActivityManager:canJoinActivity(roleID, model)
	local player = g_entityMgr:getPlayer(roleID)
	if not player or not model then
		return false
	end
	local level = player:getLevel()
	if model.joinLevelDown <= level and level <= model.joinLevelUp and self:timeValid(model.startTime, model.endTime, model.week) then
		return true
	else
		return false
	end
end

function ActivityManager:loadItemConfig()
	local itemDatas = require "data.ItemDB"
	for _, record in pairs(itemDatas or {}) do
		local item = {}
		item.itemID = record.q_id or 0
		item.name = record.q_name or ""
		item.bind = true
		if record.q_bind then
			item.bind = record.q_bind == 1
		end
		item.school = record.q_job or 0
		item.sex = record.q_sex or 0
		item.strength = record.q_strength or 0
		item.itemLevel = record.q_level or 0
		item.coolCD =  record.q_cooldown or 0
		self._item[item.itemID] = item
	end
end

function ActivityManager:getItemName(itemID)
	local item = self._item[itemID]
	if item then
		return item.name
	end
	return ""
end

function ActivityManager:getItemInfo(itemID)
	if itemID > 0 then 
		return self._item[itemID]
	end
	return nil
end

--奖励列表中筛选符合玩家的奖励
function ActivityManager:filterReward(player, rewardList)
	local school, sex, rewards = player:getSchool(), player:getSex(), {}
	for _, item in pairs(rewardList or {}) do
		if type(item) == "table" then
			local itemConfig = self._item[item.itemID]
			if itemConfig and (itemConfig.school == 0 or itemConfig.school == school) and (itemConfig.sex == 0 or itemConfig.sex == sex) then
				local reward = {}
				reward.itemID = item.itemID
				reward.count = item.count
				reward.bind = item.bind
				reward.strength = itemConfig.strength
				table.insert(rewards, reward)
			end
		end
	end
	return rewards
end

--是否有效的物品ID
function ActivityManager:validItemID(itemID)
	if not itemID then
		return false
	end
	if itemID == ITEM_INGOT_ID or itemID == ITEM_BIND_INGOT_ID or itemID == ITEM_MONEY_ID then
		return true
	else
		for id, _ in pairs(self._item) do
			if id == itemID then
				return true
			end
		end
		return false
	end
end

function ActivityManager:checkActivityTable()
	for i = #self._ActivityTable, 1, -1 do
		local activity = self._ActivityTable[i]
		if not self:timeValid(activity.startTime, activity.endTime, activity.week) then
			self:sendAllActivityList()
			table.insert(self._ActivityTable2, activity)
			table.remove(self._ActivityTable, i)
		end
	end
	for i = #self._ActivityTable2, 1, -1 do
		local activity = self._ActivityTable2[i]
		if self:timeValid(activity.startTime, activity.endTime, activity.week) then
			self:sendAllActivityList()
			table.insert(self._ActivityTable, activity)
			table.remove(self._ActivityTable2, i)
		end
	end
end

-- 往活动表里边添加活动数据
function ActivityManager:addActivityTable()
	self:actionAll(function(model, modelID, activityID)
		if self:timeValid(model.startTime, model.endTime, model.week) then
			local isActivity = true
			for _, activity in pairs(self._ActivityTable) do
				if activity.modelID == modelID and activity.activityID == activityID then
					isActivity = false
					break
				end
			end
			if isActivity then
				table.insert(self._ActivityTable, {modelID = modelID, activityID = activityID, startTime = model.startTime, endTime = model.endTime, week = model.week})
			end
		else
			local isActivity = true
			for _, activity in pairs(self._ActivityTable2) do
				if activity.modelID == modelID and activity.activityID == activityID then
					isActivity = false
					break
				end
			end
			if isActivity then
				table.insert(self._ActivityTable2, {modelID = modelID, activityID = activityID, startTime = model.startTime, endTime = model.endTime, week = model.week})
			end
		end
	end)
end

-- 删除活动数据
function ActivityManager:deleteActivity(modelID, activityID)
	for roleID, activitys in pairs(self._UserActivity or {}) do
		for id, _ in pairs(activitys or {}) do
			if id == activityID and self._UserActivity[roleID] then
				self._UserActivity[roleID][activityID] = nil
			end
		end
	end
	g_entityDao:deleteActivity(modelID, activityID)
end

--领取奖励背包不足走邮件接口
function ActivityManager:sendRewardByEmail(roleSID, reward, source)
	if not roleSID or not reward then
		return
	end
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setDescId(2)
	for _, item in pairs(reward) do
		if type(item.bind) == "number" and item.bind == 0 then
			item.bind = false
		end
		email:insertProto(item.itemID, item.count, item.bind, item.strength)
	end
	offlineMgr:recvEamil(roleSID, email, source, 0)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_copySystem:fireMessage(0, player:getID(), EVENT_COPY_SETS, 7, 0)
	end
end

function ActivityManager:writeLog(roleSID, option, source, itemID, count, bind, player)
	if itemID == ITEM_MONEY_ID then
		g_logManager:writeMoneyChange(roleSID, "", 1, source, player:getMoney(), count, option)
	elseif itemID == ITEM_INGOT_ID then
		g_logManager:writeMoneyChange(roleSID, "", 3, source, player:getIngot(), count, option)
	elseif itemID == ITEM_BIND_INGOT_ID then
		g_logManager:writeMoneyChange(roleSID, "", 4, source, player:getBindIngot(), count, option)
	elseif itemID == ITEM_VITAL_ID then
		g_logManager:writeMoneyChange(roleSID, "", 5, source, player:getVital(), count, option)
	else
		g_logManager:writePropChange(roleSID, option, source, itemID, 0, count, bind)
	end
end

function ActivityManager:createActivityID()
	if self._nowMaxActivityID < ACTIVITY_MAX_ID  then
		self._nowMaxActivityID = self._nowMaxActivityID + 1
	else
		self._nowMaxActivityID = ACTIVITY_MIN_ID
	end
	updateCommonData(COMMON_DATA_ID_MAX_ACTIVITY_ID, self._nowMaxActivityID)
	return self._nowMaxActivityID
end

function ActivityManager:setMaxActiviytID(activityID)
	activityID = toNumber(activityID, 0)
	if activityID > self._nowMaxActivityID then
		self._nowMaxActivityID = activityID
	end
end

-- 推送月卡剩余天数
function ActivityManager:pushChargeData(roleID)
	local ret = {}
	ret.monthCardSurplus_luxury = 0
	ret.monthCardSurplus = 0

	local tMonthCard = self:getUserActivity(roleID, ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_ID)
	if tMonthCard then
		ret.monthCardSurplus = tMonthCard:calcSurplus()
	end

	--豪华月卡
	local tMonthCardLuxury = self:getUserActivity(roleID, ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_LUXURY_ID)
	if tMonthCardLuxury then
		ret.monthCardSurplus_luxury = tMonthCardLuxury:calcSurplus()
	end

	fireProtoMessage(roleID, ACTIVITY_SC_CHARGE_RET, "ActivityChargeRet", ret)
end

function ActivityManager:onMonsterKill(monsterSID, roleID, monsterID, mapID)
	local monster = g_entityMgr:getMonster(monsterID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player or not monster then
		return
	end
	local monsterLevel = monster:getLevel()
	self:action(ACTIVITY_MODEL.TOTAL_KILL_MONSTER, function(model, modelID, activityID)
		local User = self:getUserActivity(roleID, modelID, activityID)
		if User then
			User:killMonster(monsterSID, monsterID, monsterLevel)
		end
	end)
	local _, memList = g_TeamPublic:getTeamAllMemBySID(player:getSerialID())
	for _,id in pairs(memList) do
		local member = g_entityMgr:getPlayerBySID(id)
		if member and mapID == member:getMapID() and member:getID() ~= roleID then	--组队里面自己不能重复添加
			self:action(ACTIVITY_MODEL.TOTAL_KILL_MONSTER, function(model, modelID, activityID)
				local teamMonster = self:getUserActivity(member:getID(), modelID, activityID)
				if teamMonster then
					teamMonster:killMonster(monsterSID, monsterID, monsterLevel)
				end
			end)
		end
	end
end

--参加世界BOSS
function ActivityManager:joinWorldBoss(roleID, monsterSID)
	self:action(ACTIVITY_MODEL.JOIN_WORLD_BOSS, function(model, modelID, activityID)
		local User = self:getUserActivity(roleID, modelID, activityID)
		if User then
			User:joinWorldBoss(monsterSID)
		end
	end)
end

--完成副本
function ActivityManager:finishCopy(roleID, copyID)
	self:action(ACTIVITY_MODEL.TOTAL_JOIN_COPY, function(model, modelID, activityID)
		self:onFinishCopy(self:getUserActivity(roleID, modelID, activityID), copyID)
	end)
	local multiple = 1		--副本收益倍数
	self:action(ACTIVITY_MODEL.COPY_REWARD, function(model, modelID, activityID)
		if self:canJoinActivity(roleID, model) and table.contains(model.args, copyID) then
			multiple = model.yieldRate
		end
	end)
	return multiple
end

function ActivityManager:onFinishCopy(User, copyID)
	if User then
		User:finishCopy(copyID)
	end
end

function ActivityManager.onEquipSmelter(roleID, pos)
	g_ActivityMgr:action(ACTIVITY_MODEL.SMELT, function(model, modelID, activityID)
		local smelt = g_ActivityMgr:getUserActivity(roleID, modelID, activityID)
		if smelt then
			smelt:onEquipSmelter()
		end
	end)
	g_ActivityMgr:action(ACTIVITY_MODEL.SMELT_SPECIAL, function(model, modelID, activityID)
		local smeltSpecial = g_ActivityMgr:getUserActivity(roleID, modelID, activityID)
		if smeltSpecial then
			smeltSpecial:onEquipSmelterSpecial(pos)
		end
	end)
end

function ActivityManager.onEquipBaptize(roleID, pos)
	g_ActivityMgr:action(ACTIVITY_MODEL.BAPTIZE, function(model, modelID, activityID)
		local baptize = g_ActivityMgr:getUserActivity(roleID, model, activityID)
		if baptize then
			baptize:onEquipBaptize()
		end
	end)
	g_ActivityMgr:action(ACTIVITY_MODEL.BAPTIZE_SPECIAL, function(model, modelID, activityID)
		local baptizeSpecial = g_ActivityMgr:getUserActivity(roleID, modelID, activityID)
		if baptizeSpecial then
			baptizeSpecial:onEquipBaptizeSpecial(pos)
		end
	end)
end

function ActivityManager.onEquipStrength(roleID, pos)
	g_ActivityMgr:action(ACTIVITY_MODEL.STRENGTHEN, function(model, modelID, activityID)
		local strength = g_ActivityMgr:getUserActivity(roleID, modelID, activityID)
		if strength then
			strength:onEquipStrength()
		end
	end)
	g_ActivityMgr:action(ACTIVITY_MODEL.STRENGTHEN_SPECIAL, function(model, modelID, activityID)
		local strengthSpecial = g_ActivityMgr:getUserActivity(roleID, modelID, activityID)
		if strengthSpecial then
			strengthSpecial:onEquipStrengthSpecial(pos)
		end
	end)
end

function ActivityManager:OnTask(roleID, taskId, taskType, taskLevel, operateType)
	self:action(ACTIVITY_MODEL.TASK, function(model, modelID, activityID)
		local User = self:getUserActivity(roleID, modelID, activityID)
		if User then
			User:OnTask(taskId, taskType, taskLevel, operateType)
		end
	end)
end

function ActivityManager:GetTaskYieldRate(roleID, taskID, taskType, taskLevel)
	--print("444444444444444444444444444444444444:", taskType, ":", taskID, ":", taskLevel)
	local multiple = 1		--收益倍数
	local models = g_DataMgr:getActivityConfigByModelID(ACTIVITY_MODEL.TASK_REWARD)
	if not self:isEmpty(models) then
		for _, model in pairs(models) do
			--print("55555555555555555555555555555555555555:", taskType, ":", taskID, ":", taskLevel)
			if model and self:canJoinActivity(roleID, model) then
				if TaskType.Daily == taskType then
					if model.arg1 == 11 or (model.arg1 == 12 and table.contains(model.args, taskID)) then
						multiple = model.yieldRate
					end
				elseif TaskType.Reward == taskType then
					--print("666666666666666666666666:", taskType, ":", taskID, ":", taskLevel)
					if (model.arg1 == 21 and taskLevel == REWARDTASK_RANK_BLUE)
						or (model.arg1 == 31 and taskLevel == REWARDTASK_RANK_PURPLE)
						or (model.arg1 == 41 and taskLevel == REWARDTASK_RANK_SUPER)
						or (model.arg1 == 22 and taskLevel == REWARDTASK_RANK_BLUE and table.contains(model.args, taskID)) 
						or (model.arg1 == 32 and taskLevel == REWARDTASK_RANK_PURPLE and table.contains(model.args, taskID))
						or (model.arg1 == 42 and taskLevel == REWARDTASK_RANK_SUPER and table.contains(model.args, taskID)) then
						multiple = model.yieldRate
						--print("777777777777777777777777777777777:", taskType, ":", taskID, ":", taskLevel, ":", model.yieldRate)
					end
				end
			end
		end
	end
	--print("888888888888888888888888888888:", multiple)		
	return multiple
end

function ActivityManager:GetMonsterYieldRate(roleID, monsterSID)
	local yieldRate, mul = 100, 1		--收益加成概率 单个奖励倍数
	local models = g_DataMgr:getActivityConfigByModelID(ACTIVITY_MODEL.MONSTER_REWARD)
	if not self:isEmpty(models) then
		for _, model in pairs(models) do
			if self:canJoinActivity(roleID, model) and table.contains(model.args, monsterSID) then
				yieldRate, mul = model.yieldRate or yieldRate, model.arg1 or mul
			end
		end
	end
	return yieldRate, mul
end

--给在线所有玩家推一遍活动列表
function ActivityManager:sendAllActivityList()
	local now = os.time()
	for roleID, _ in pairs(self._allOnlineUser) do
		self._UserLoadFlag[roleID] = now
	end
end

--是否空表
function ActivityManager:isEmpty(tab)
	if type(tab) == "table" then
		return next(tab) == nil
	end
	return true
end

function ActivityManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(ActivityServlet.getInstance():getCurEventID(), roleId, EVENT_ACTIVITY_SETS, errId, paramCount, params)
end

function ActivityManager.getInstance()
	return ActivityManager()
end


function ActivityManager.isMonthCard(roleID)
	-- body
	local tMonthCard = g_ActivityMgr:getUserActivity(roleID, ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_ID)
	if tMonthCard then
		if tMonthCard:calcSurplus() > 0 then
			return 1
		end
	end

	--豪华月卡
	local tMonthCardLuxury = g_ActivityMgr:getUserActivity(roleID, ACTIVITY_MODEL.MONTHCARD, ACTIVITY_MONTHCARD_LUXURY_ID)
	if tMonthCardLuxury then
		if tMonthCardLuxury:calcSurplus() > 0 then
			return 1
		end
	end

	return 0
end

g_ActivityMgr = ActivityManager.getInstance()