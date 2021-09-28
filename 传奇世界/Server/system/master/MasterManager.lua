--MasterManager.lua
--/*-----------------------------------------------------------------
--* Module:  MasterManager.lua
--* Author:  Andy
--* Modified: 2016年02月16日
--* Purpose: 师徒系统管理类
-------------------------------------------------------------------*/

require ("system.master.MasterConstant")
require ("system.master.MasterPlayer")
require ("system.master.MasterOffLine")
require ("system.master.MasterServlet")

MasterManager = class(nil, Singleton, Timer)

function MasterManager:__init()
	self._taskConfig = {}		--师徒任务配置
	self._UserInfoBySID = {}	--玩家数据静态ID索引
	self._UserOffLine = {}		--玩家离线数据
	self._UserMaster = {}		--满足师傅条件的玩家
	self._UserDoubleXP = {}		--标记玩家打怪是否有双倍经验

	self._UserDelete = {}		--删除角色的用户
	self._nowTaskID = 1			--当天的师徒任务ID
	self._tick = os.time()
	self._timeTick = time.toedition("day")

	self:loadTaskConfig()
	gTimerMgr:regTimer(self, 1000, 3000)
	print("MasterManager TimeID:",self._timerID_)
	g_listHandler:addListener(self)
end

function MasterManager:loadTaskConfig()
	for _, data in pairs(require "data.MasterTaskDB" or {}) do
		local config = {}
		config.id = data.q_id
		config.type = data.q_type
		config.percent = data.q_percent
		config.finish = data.q_finish
		config.level = data.q_level
		config.exp = data.q_rewards_exp
		config.money = data.q_rewards_money
		config.bindIngot = data.q_rewards_bindIngot
		self._taskConfig[config.id] = config
	end
end

--玩家上线
function MasterManager:onPlayerLoaded(player)
	local roleSID = player:getSerialID()
	local playerInfo = self:getPlayerInfoBySID(roleSID)
	if playerInfo and not playerInfo:getLoadDB() then
		playerInfo:setLoadDB(true)
	end
	if not self:getOffLineInfo(roleSID) then
		self:addOffLineInfo(roleSID)
	end
end

function MasterManager:onLevelChanged(player)
	local roleSID, level = player:getSerialID(), player:getLevel()
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo then
		offLineInfo:setLevel(level)
		offLineInfo:setOffLineUpdateDB(true)
	end
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	if not playerInfo then return end
	playerInfo:setLevel(level)
	if level >= MASTER_MIN_LEVEL then
		if playerInfo:getNowProfession() == MASTER_PROFESSION.NOTHING then
			for masterSID, _ in pairs(playerInfo:getApplyMasterList() or {}) do
				g_masterSer:apprenticeDeleteApply(roleSID, masterSID)
			end
			playerInfo:setNowProfession(MASTER_PROFESSION.MASTER)
			playerInfo:cast2DB()
		elseif playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
			playerInfo:setFinishTime(os.time())
			playerInfo:setNowProfession(MASTER_PROFESSION.CAN_MASTER)
			playerInfo:cast2DB()
			self:setDoubleXP(roleSID, 0)
			--推送可出师信息
			fireProtoMessage(player:getID(), APPRENTICE_SC_FINISH, "ApprenticePushFinish", {who = 1, roleSID = roleSID})
			local masterSID = playerInfo:getMasterSID()
			if #masterSID > 0 then
				local master = g_entityMgr:getPlayerBySID(masterSID)
				if master then
					fireProtoMessage(master:getID(), APPRENTICE_SC_FINISH, "ApprenticePushFinish", {who = 2, roleSID = roleSID})
				end
				local masterInfo = self:getPlayerInfoBySID2(masterSID)
				if masterInfo then
					self:pushExperience(masterSID, 6, os.time(), playerInfo:getName())
				else
					local masterOffLine = self:getOffLineInfo(masterSID)
					if masterOffLine then
						masterOffLine:addExperience(6, os.time(), playerInfo:getName())
					end
				end
			end
		end
	end
end

function MasterManager:battleChanged(player, battle)
	local offLineInfo = self:getOffLineInfo(player:getSerialID())
	if offLineInfo then
		offLineInfo:setBattle(battle)
		offLineInfo:setOffLineUpdateDB(true)
	end
end

--玩家下线
function MasterManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		self:releaseOffLineUser(roleSID, roleSID, true)
		local masterSID = playerInfo:getMasterSID()
		if #masterSID > 0 then
			self:releaseOffLineUser(masterSID, roleSID)
		end
		local apprentices = playerInfo:getApprentice()
		for i = 1, #apprentices do
			local apprenticeSID = apprentices[i]
			self:releaseOffLineUser(apprenticeSID, roleSID)
			self:sendErrMsg2Client(apprenticeSID, MASTER_ERR_MASTER_ONLINE2, 0, {})
			self:setDoubleXP(apprenticeSID, 0)
		end
	end
	self._UserInfoBySID[roleSID] = nil
	self:releaseMasterUser(roleSID)
end

--玩家删除
function MasterManager:onPlayerDelete(roleSID)
	self._UserDelete[roleSID] = os.time()
	g_entityDao:loadMaster(roleSID, true)
end

function MasterManager:update()
	local now = os.time()
	for roleSID, t in pairs(self._UserDelete) do
		if now - t > 3 then
			self:deletePlayer(roleSID)
			self._UserDelete[roleSID] = nil
		end
	end
	if now - self._tick > 60 then
		for roleSID, _ in pairs(self._UserInfoBySID) do
			self:nearbyMaster(roleSID)
		end
		local timeTick = time.toedition("day")
		if timeTick ~= self._timeTick then
			for _, offLineInfo in pairs(self._UserOffLine) do
				offLineInfo:resetTaskState()
			end
			self:randomTask()
			self._timeTick = timeTick
		end
		for _, offLineInfo in pairs(self._UserOffLine) do
			offLineInfo:castOffLine2DB2()
		end
		self._tick = now
	end
end

function MasterManager:deletePlayer(roleSID)
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		if #playerInfo:getMasterSID() > 0 then
			g_masterSer:apprenticeBetray(roleSID, true)
		end
		local apprentices = playerInfo:getApprentice()
		for i = 1, #apprentices do
			g_masterSer:masterExpel(roleSID, apprentices[i], true)
		end
		for masterSID, _ in pairs(playerInfo:getApplyMasterList() or {}) do
			g_masterSer:apprenticeDeleteApply(roleSID, masterSID)
		end
		for apprenticeSID, _ in pairs(playerInfo:getApplyApprenticeList() or {}) do
			g_masterSer:masterDeleteApply(roleSID, apprenticeSID)
		end
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			self:onPlayerOffLine(player)
		end
	end
end

--当关联的师徒玩家都下线后释放相关的玩家离线数据
function MasterManager:releaseOffLineUser(roleSID, relatedSID, mine)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo then
		if mine then
			offLineInfo:setOffLine(os.time())
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player and player:getLevel() >= APPRENTICE_MIN_LEVEL - 1 and offLineInfo:getOffLineUpdateDB() then
				offLineInfo:castOffLine2DB()
			end
		end
		offLineInfo:removeRelatedUser(relatedSID)
		if offLineInfo:getRelatedUserCount() == 0 then
			self._UserOffLine[roleSID] = nil
		end
	end
end

--加载数据
function MasterManager.loadDBData(roleSID, datas, isDelete)
	local playerInfo = g_masterMgr:getPlayerInfoBySID(roleSID)
	if playerInfo then
		playerInfo:loadDBData(datas, isDelete)
	end
end

function MasterManager.loadDBData2(player, datas, roleSID)
	local playerInfo = g_masterMgr:getPlayerInfoBySID(roleSID)
	if playerInfo then
		playerInfo:loadDBData(datas, false)
	end
end

--加载师徒离线数据
function MasterManager:loadOffLineDBData(roleSID, relatedSID, mine)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo then
		offLineInfo:addRelatedUser(relatedSID)
		if mine then
			offLineInfo:dealOffLineData()
		end
	else
		offLineInfo = self:addOffLineInfo(roleSID)
		if relatedSID then
			offLineInfo:addRelatedUser(relatedSID)
		end
	end
end

--加载师徒离线数据返回
function MasterManager.onLoadOffLineDBData(roleSID, datas)
	local offLineInfo = g_masterMgr:getOffLineInfo(roleSID)
	if offLineInfo then
		offLineInfo:loadOffLineDBData(datas)
	end
end

function MasterManager:getPlayerInfoBySID(roleSID)
	local playerInfo = self._UserInfoBySID[roleSID]
	if not playerInfo then
		local player, name, school, level = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			name, school, level = player:getName(), player:getSchool(), player:getLevel()
		end
		playerInfo = MasterPlayer(roleSID, name, school, level)
		self._UserInfoBySID[roleSID] = playerInfo
	end
	return playerInfo
end

function MasterManager:getPlayerInfoBySID2(roleSID)
	return self._UserInfoBySID[roleSID]
end

function MasterManager:addMasterUser(roleSID, master)
	self._UserMaster[roleSID] = master
end

function MasterManager:releaseMasterUser(roleSID)
	self._UserMaster[roleSID] = nil
end

function MasterManager:addOffLineInfo(roleSID)
	local player, school, level, battle = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		name, school, level, battle = player:getName(), player:getSchool(), player:getLevel(), player:getbattle()
	end
	local offLineInfo = MasterOffLine(roleSID, name, school, level, battle)
	offLineInfo:addRelatedUser(roleSID)
	self._UserOffLine[roleSID] = offLineInfo
	g_entityDao:loadOffMaster(roleSID)
	return offLineInfo
end

--添加离线角色关联用户
function MasterManager:addOffLineRelated(roleSID, relatedSID)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo then
		offLineInfo:addRelatedUser(relatedSID)
	end
end

--删除离线角色关联用户
function MasterManager:removeOffLineRelated(roleSID, relatedSID)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo then
		offLineInfo:removeRelatedUser(relatedSID)
	end
end

function MasterManager:getOffLineInfo(roleSID)
	local offLineInfo = self._UserOffLine[roleSID]
	if offLineInfo then
		return offLineInfo
	else
		-- print("getOffLineInfo", debug.traceback())
	end
end

--根据玩家名字获取玩家静态ID
function MasterManager:getPlayerSIDByName(name)
	local player = g_entityMgr:getPlayerByName(name)
	if player then
		return player:getSerialID()
	end
	return 0
end

--根据玩家静态ID获取玩家名字
function MasterManager:getPlayerNameBySID(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		return player:getName()
	end
	return ""
end

--根据SID判断玩家是否在线
function MasterManager:isOnline(roleSID)
	if g_entityMgr:getPlayerBySID(roleSID) then
		return true
	else
		return false
	end
end

--推送经历数据
function MasterManager:pushExperience(roleSID, flag, time, name)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local ret = {}
		ret.flag = flag
		ret.time = time
		ret.name = name
		fireProtoMessage(player:getID(), MASTER_SC_ADD_EXPERIENCE, "MasterAddExperience", ret)
	end
end

--随机推荐师傅,随机的时候剔除已申请的玩家
function MasterManager:randomMaster(applyList)
	local result = {}
	local size = table.size(self._UserMaster)
	local applyCount = table.size(applyList)
	local num = math.min(10 - applyCount, size)	--随机师傅的个数
	local random = math.random(1, size)
	local index = 0
	for _, master in pairs(self._UserMaster) do
		index = index + 1
		if index >= random then
			local isApply = false
			for _, applyUser in pairs(applyList) do
				if applyUser.roleSID == master.roleSID then
					isApply = true
					break
				end
			end
			if not isApply then
				table.insert(result, master)
			end
			if table.size(result) >= num then
				return result
			end
		end
	end
	if table.size(result) < num then
		index = 0
		for _, master in pairs(self._UserMaster) do
			index = index + 1
			if index >= random then
				break
			end
			local isApply = false
			for _, applyUser in pairs(applyList) do
				if applyUser.roleSID == master.roleSID then
					isApply = true
					break
				end
			end
			if not isApply then
				table.insert(result, master)
			end
			if table.size(result) >= num then
				break
			end
		end
	end
	return result
end

--设置角色是否有双倍奖励
function MasterManager:setDoubleXP(roleSID, masterSID)
	self._UserDoubleXP[roleSID] = masterSID
end

--判定角色是否有双倍奖励
function MasterManager:hasDoubleXP(roleID)
	local double = 0
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		local masterSID = self._UserDoubleXP[player:getSerialID()] or 0
		if masterSID ~= 0 and self:isOnline(masterSID) then
			double = 1
		end
	end
	return double
end

--玩家送花(roleSID:送花的玩家静态ID  masterSID:收花的玩家静态ID)
function MasterManager:giveFlower(roleSID, masterSID, num)
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		local profession = playerInfo:getNowProfession()
		local id = playerInfo:getMasterSID()
		if profession == MASTER_PROFESSION.APPRENTICE and masterSID == id then
			local masterInfo = self:getPlayerInfoBySID2(masterSID)
			if masterInfo then
				masterInfo:setTotalFlower(masterInfo:getTotalFlower() + (num or 1))
				masterInfo:cast2DB()
			else
				local offLineInfo = self:getOffLineInfo(masterSID)
				if offLineInfo then
					offLineInfo:setFlower(num or 1)
					offLineInfo:castOffLine2DB()
				end
			end
		end
	end
end

--获取任务完成配置的总值
function MasterManager:getTaskFinish(taskID)
	for id, config in pairs(self._taskConfig) do
		if id == taskID then
			return config.finish
		end
	end
	return 1
end

--获取任务奖励(return:经验数量,金币数量,绑定元宝数量)
function MasterManager:getTaskReward(taskID)
	for id, config in pairs(self._taskConfig) do
		if id == taskID then
			return config.exp, config.money, config.bindIngot
		end
	end
	return 0, 0, 0
end

--获取自己的任务ID
function MasterManager:getSelfTaskID(roleSID)
	if roleSID then
		for taskID, config in pairs(self._taskConfig) do
			if taskID == self._nowTaskID then
				local player = g_entityMgr:getPlayerBySID(roleSID)
				if player and config.level > player:getLevel() then
					return MASTER_TASK_DEFAULT_ID
				end
				break
			end
		end
	end
	return self._nowTaskID
end

--随机当天任务
function MasterManager:randomTask()
	local percent, task = 0, {}
	for _, config in pairs(self._taskConfig) do
		percent = percent + config.percent
		task[config.id] = percent
	end
	local random = math.random(1, percent)
	local taskID, point = 1, percent
	for id, totalPrecent in pairs(task) do
		if random <= totalPrecent and totalPrecent <= point then
			taskID = id
			point = totalPrecent
		end
	end
	self._nowTaskID = taskID
	updateCommonData(COMMON_DATA_ID_MASTER_TASK, {taskID = taskID, timeTick = time.toedition("day")})
end

function MasterManager:loadNowTaskID(datas)
	local data = unserialize(datas)
	self._nowTaskID = data.taskID
	self._timeTick = data.timeTick
end

--是否跟师傅同屏
function MasterManager:nearbyMaster(roleSID)
	local taskID = self:getSelfTaskID(roleSID)
	if taskID ~= MASTER_TASK_ID.NEARBY then
		return
	end
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if playerInfo and playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE and offLineInfo and offLineInfo:haveTask() then
		local masterSID = playerInfo:getMasterSID()
		local master = g_entityMgr:getPlayerBySID(masterSID)
		if not master then
			return
		end
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then
			return
		end
		if player:getMapID() ~= master:getMapID() then
			return
		end
		local position1 = master:getPosition()
		local position2 = player:getPosition()
		local x, y = math.abs(position1.x - position2.x), math.abs(position1.y - position2.y)
		if x * x + y * y <= MASTER_DISTANCE_SQUARE then
			local timeTick = time.toedition("day")
			offLineInfo:setTaskFinishTime(timeTick)
			offLineInfo:setTaskProgress(offLineInfo:getTaskProgress() + 1)
			addExpToPlayer(player, APPRENTICE_TASK_REWARD_EXP, 202)
			local finish = self:getTaskFinish(MASTER_TASK_ID.NEARBY)
			if offLineInfo:getTaskProgress() >= finish then
				offLineInfo:setTaskID(MASTER_TASK_ID.NEARBY)
				offLineInfo:setTaskFinish(true)
				self:sendTaskFinishReward(MASTER_TASK_ID.NEARBY, roleSID)
			end
			offLineInfo:setUpdateDB(true)
		end
	end
end

function MasterManager:onMonsterKill(monSID, roleID, monID, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end
	if self:getSelfTaskID(player:getSerialID()) ~= MASTER_TASK_ID.KILLMONSTER then
		return
	end
	local roleSID = player:getSerialID()
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo and offLineInfo:haveTask() then
		local timeTick = time.toedition("day")
		offLineInfo:setTaskFinishTime(timeTick)
		offLineInfo:setTaskProgress(offLineInfo:getTaskProgress() + 1)
		local finish = self:getTaskFinish(MASTER_TASK_ID.KILLMONSTER)
		if offLineInfo:getTaskProgress() >= finish then
			offLineInfo:setTaskFinish(true)
			self:sendTaskFinishReward(MASTER_TASK_ID.KILLMONSTER, roleSID)
		end
		offLineInfo:setTaskID(MASTER_TASK_ID.KILLMONSTER)
		offLineInfo:setUpdateDB(true)
	end
end

--完成任务(joinUsre:参与任务的所有玩家的静态ID)
function MasterManager:finishMasterTask(taskID, roleSID, joinUsre)
	if taskID ~= self:getSelfTaskID(roleSID) then
		return
	end
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if playerInfo and offLineInfo and offLineInfo:haveTask() then
		local masterSID = playerInfo:getMasterSID()
		if table.contains(joinUsre, masterSID) then
			local timeTick = time.toedition("day")
			offLineInfo:setTaskFinishTime(timeTick)
			offLineInfo:setTaskProgress(1)
			offLineInfo:setTaskFinish(true)
			offLineInfo:setTaskID(taskID)
			offLineInfo:setUpdateDB(true)
			self:sendTaskFinishReward(taskID, roleSID)
		end
	end
end

--发放师徒任务奖励
function MasterManager:sendTaskFinishReward(taskID, roleSID)
	local playerInfo = self:getPlayerInfoBySID2(roleSID)
	if playerInfo and playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
		local offLineInfo = self:getOffLineInfo(roleSID)
		local timeTick = time.toedition("day")
		if offLineInfo then
			if timeTick == offLineInfo:getTaskRewardTime() then
				self:sendErrMsg2Client(roleSID, MASTER_ERR_REWARD_FINISH, 0, {})
			else
				local player = g_entityMgr:getPlayerBySID(roleSID)
				local exp, money, bindIngot = self:getTaskReward(offLineInfo:getTaskID())
				if exp > 0 then
					addExpToPlayer(player, exp, 202)
				end
				if money > 0 then
					player:setMoney(player:getMoney() + money)
					g_logManager:writeMoneyChange(roleSID, "", 1, 202, player:getMoney(), money, 1)
				end
				if bindIngot > 0 then
					player:setBindIngot(player:getBindIngot() + bindIngot)
					g_logManager:writeMoneyChange(roleSID, "", 4, 202, player:getBindIngot(), bindIngot, 1)
				end
				self:sendErrMsg2Client(roleSID, MASTER_ERR_REWARD_SUCCESS, 0, {})
				offLineInfo:setTaskID(0)
				offLineInfo:setTaskRewardTime(timeTick)
				offLineInfo:castOffLine2DB()
				g_masterSer:pushApprenticeInformation(roleSID)
			end
		end
		local masterSID = playerInfo:getMasterSID()
		local masterOffLine = self:getOffLineInfo(masterSID)
		if not masterOffLine or #masterSID <= 0 then
			return
		end
		if timeTick ~= masterOffLine:getTaskRewardTime() then
			masterOffLine:setTaskRewardCount(0)
			masterOffLine:setTaskRewardTime(timeTick)
		end
		if masterOffLine:getTaskRewardCount() >= MASTER_MAX_REWARD_COUNT then
			return
		end
		masterOffLine:setTaskRewardCount(masterOffLine:getTaskRewardCount() + 1)
		masterOffLine:castOffLine2DB()
		local master = g_entityMgr:getPlayerBySID(masterSID)
		if master then
			master:setVital(master:getVital() + MASTER_TASK_REWARD_VITAL)
			g_logManager:writeMoneyChange(masterSID, "", 5, 202, master:getVital(), MASTER_TASK_REWARD_VITAL, 1)
		else
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			email:setDescId(MASTER_EMAIL_ID)
			email:insertProto(ITEM_VITAL_ID, MASTER_TASK_REWARD_VITAL, true)
			offlineMgr:recvEamil(masterSID, email, 202, 0)
		end
		self:sendErrMsg2Client(masterSID, MASTER_ERR_TASK_MASTER_REWARD, 0, {})
		-- fireProtoMessageBySid(masterSID, MASTER_SC_TASK_FINISH, "MasterTaskFinish", {taskID = taskID})
	end
end

--GM命令设置师徒任务ID
function MasterManager:gmSetTaskID(taskID)
	self._nowTaskID = taskID
	for _, offLineInfo in pairs(self._UserOffLine) do
		local timeTick = time.toedition("day", os.time() - 24 * 3600)
		offLineInfo:setTaskIssue(false)
		offLineInfo:setTaskIssueTime(timeTick)
		offLineInfo:setTaskProgress(0)
		offLineInfo:setTaskFinish(false)
		offLineInfo:setTaskFinishTime(timeTick)
		offLineInfo:setTaskRewardTime(timeTick)
		offLineInfo:setTaskRewardCount(0)
	end
	updateCommonData(COMMON_DATA_ID_MASTER_TASK, {taskID = taskID, timeTick = time.toedition("day")})
end

--GM命令完成师徒任务
function MasterManager:gmFinishTask(roleSID)
	local taskID = self:getSelfTaskID(roleSID)
	local offLineInfo = self:getOffLineInfo(roleSID)
	if offLineInfo and offLineInfo:haveTask() then
		offLineInfo:setTaskFinishTime(time.toedition("day"))
		offLineInfo:setTaskProgress(self:getTaskFinish(taskID))
		offLineInfo:setTaskFinish(true)
		offLineInfo:setTaskID(taskID)
		offLineInfo:setUpdateDB(true)
		self:sendTaskFinishReward(taskID, roleSID)
	end
end

function MasterManager:sendErrMsg2Client(roleSID, errId, paramCount, params)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		fireProtoSysMessageBySid(MasterServlet.getInstance():getCurEventID(), roleSID, EVENT_MASTER_SETS, errId, paramCount, params)
	end
end

function MasterManager.getInstance()
	return MasterManager()
end

g_masterMgr = MasterManager.getInstance()