--FactionTaskInfo.lua
FactionTaskInfo = class()

local prop = Property(FactionTaskInfo)
prop:accessor("faction")
prop:accessor("taskEventSet")

--行会任务今日刷新时间
function FactionTaskInfo:getTodayReFreshTime()
	local now = os.time()
	local now_date = os.date("*t", now)
 	local sectime = os.time({year=now_date.year, month=now_date.month, day=now_date.day, hour=FACTIONTASK_DAILYREFRESH_HOUR})
	return sectime
end

--行会任务今日发奖时间
function FactionTaskInfo:getTodayRewardTime()
	local now = os.time()
	local now_date = os.date("*t", now)
 	local sectime = os.time({year=now_date.year, month=now_date.month, day=now_date.day, hour=FACTIONTASK_DAILYREWARD_HOUR})
	return sectime
end

--行会任务下一次刷新时间
function FactionTaskInfo:getNextReFreshTime()
	local now = os.time()
 	local sectime = self:getTodayReFreshTime()
	if sectime <= now then
		sectime = sectime + FACTIONTASK_DAILYREFRESH_NEXTDAY
	end
	return sectime
end

--行会任务下一次发奖时间
function FactionTaskInfo:getNextRewardTime()
	local now = os.time()
 	local sectime = self:getTodayRewardTime()
	if sectime <= now then
		sectime = sectime + FACTIONTASK_DAILYREFRESH_NEXTDAY
	end
	return sectime
end

function FactionTaskInfo:__init(faction)
	self.dailyReFreshTime = 0				--日常任务刷新时间
	self.dailyRewardTime = self:getTodayRewardTime()	--日常任务发奖时间
	self.dailyTasks = {}					--日常任务 {[taskID] = task}
	self.syncFlag = false					--数据同步
	self.nextReFreshTime = self:getNextReFreshTime()	--下一次任务刷新时间
	self.joinMems = {}
	self.rewardInfos = {}					--行会任务发奖信息
	self.joinCount = 0					--行会任务参与人数
	
	prop(self, "faction", faction)
	local taskEventSet = TaskEventHandler()
	prop(self, "taskEventSet", taskEventSet)
end

function FactionTaskInfo:__release()
	--清空任务列表
	for taskId, task in pairs(self.dailyTasks) do
		release(task)
		self.dailyTasks[taskId] = nil
	end  
	self.dailyTasks = {}
	self.joinMems = {}
	self.rewardInfos = {}
end

function FactionTaskInfo:getFactionID()
	local faction = self:getFaction()
	if faction then
		return faction:getFactionID()
	end
	return 0
end

function FactionTaskInfo:addJoinMem(rolesid)
	print("FactionTaskInfo:addJoinMem ", self.joinCount)

	--过了今日发奖时间的不记录
	--if os.time() > self:getTodayRewardTime() then
	--	return
	--end
	
	if not self.joinMems[rolesid] then
		self.joinMems[rolesid] = true
		self.joinCount = self.joinCount + 1
		print("FactionTaskInfo:relAddJoinMem ", self.joinCount)
		self.syncFlag = true
	end
end

--加载行会任务
function FactionTaskInfo:loadFactionTask(taskId, state, taskTargetState)
	if table.size(self.dailyTasks) > 0 then
		print("FactionTaskInfo:loadFactionTask task num > 1",self:getFactionID(),table.size(self.dailyTasks))
		--return
	end

	local task = TaskBase(taskId, 0, TaskType.Faction)
	task:setFactionID(self:getFactionID())
	task:setStatus(state)
	task:setStatesInDB(taskTargetState)
	task:initTargets()
	--table.insert(self.dailyTasks,task)
	self.dailyTasks[taskId] = task
	self.rewardInfos[taskId] = {completed = 0, rewarded = 0}
	task:validate()
end

--行会任务刷新
function FactionTaskInfo:reFreshTask()
	self.dailyReFreshTime = os.time()
	self.dailyRewardTime = self:getTodayRewardTime()
	self.nextReFreshTime = self:getNextReFreshTime()
	
	--清空任务列表
	for taskId, task in pairs(self.dailyTasks) do
		release(task)
		self.dailyTasks[taskId] = nil
	end  
	self.dailyTasks = {}
	self.joinMems = {}
	self.rewardInfos = {}
	self.joinCount = 0

	--载入新的行会任务
	local faction = self:getFaction()
	local taskId = g_LuaTaskDAO:getFactionTaskByLevel(faction:getLevel())
	self:loadFactionTask(taskId,1,"")

	self.syncFlag = true
end

--行会任务载入
--参数 为保存的格式
function FactionTaskInfo:loaddb(cache_buf,fmt)
	if #cache_buf > 0 then
		local datas = ""
		local err = 0
		if fmt == DatasDBFmt.protobuf then
			datas,err = protobuf.decode("FactionTaskProtocol", cache_buf)
		else
			datas = unserialize(cache_buf)
		end
		if type(datas) ~= "table" then
			print("FactionTaskInfo:loaddb encode unserialize error", self:getFactionID(), fmt, err, type(datas))
			return
		end		
		local now = os.time()
		self.dailyReFreshTime = datas.dailyReFreshTime		--日常任务刷新时间
		self.nextReFreshTime = self:getNextReFreshTime()
		self.dailyTasks = {}
		self.joinMems = {}
		self.rewardInfos = {}
		self.joinCount = (datas.joinCount and datas.joinCount) or 0

		local todayReFreshTime = self:getTodayReFreshTime()	--今日刷新时间
		if self.dailyReFreshTime < todayReFreshTime then	--重新刷新
			self:reFreshTask()
		else							--读取旧数据
			--日常任务列表
			for _, task in ipairs(datas.dailyTasks) do
				local taskID = task.taskID
				local state = task.state
				local taskTargetState = task.taskTargetState
				self:loadFactionTask(taskID, state, taskTargetState)

				local rewardInfo = {}
				rewardInfo.completed = (task.completed and task.completed) or 0
				rewardInfo.rewarded = (task.rewarded and task.rewarded) or 0
				self.rewardInfos[taskID] = rewardInfo
				print("FactionTaskInfo:loaddb ", self.joinCount, taskID, rewardInfo.completed, rewardInfo.rewarded)
			end

			self.dailyRewardTime = self:getTodayRewardTime()
		end
	end
end

--行会任务数据库保存
--参数 为保存的格式
function FactionTaskInfo:cast2db(fmt)
	--print("FactionTaskInfo:cast2db ", self:getFactionID(), fmt)
	local cache_buf = ""
	local factionTaskDatas = {}
	factionTaskDatas.dailyReFreshTime = self.dailyReFreshTime	--日常任务刷新时间
	factionTaskDatas.joinCount = self.joinCount			--参与人数

	factionTaskDatas.dailyTasks = {}
	for taskId, task in pairs(self.dailyTasks) do
		local factionTask = {}
		factionTask.taskID = task:getID()
		factionTask.state = task:getStatus()
		factionTask.taskTargetState = serialize(task:getTargetStates())
		local rewardInfo = self.rewardInfos[taskId]
		factionTask.completed = (rewardInfo and rewardInfo.completed) or 0
		factionTask.rewarded = (rewardInfo and rewardInfo.rewarded) or 0
		table.insert(factionTaskDatas.dailyTasks, factionTask)
	end

	if fmt == DatasDBFmt.protobuf then
		cache_buf = protobuf.encode("FactionTaskProtocol", factionTaskDatas)
	else
		cache_buf = serialize(factionTaskDatas)
	end

	if type(cache_buf) ~= "string" then
		print("FactionTaskInfo:cast2db getDBdata error", self:getFactionID(), fmt)
		return
	end

	--print("FactionTaskInfo:cast2db ", self:getFactionID(), fmt, #cache_buf, cache_buf)
	g_entityDao:updateFactionTask(self:getFactionID(),cache_buf,#cache_buf)
	self.syncFlag = false
end

--行会任务事件通知
function FactionTaskInfo:NotifyListener(roleSID, eventName, ...)
	local eventHandler = self:getTaskEventSet()
	if eventHandler then
		eventHandler:notifyWatchers(eventName, player, ...)
	end				
end

--行会任务信息
function FactionTaskInfo:buildFactionTaskMsg(taskID,roleSID)
	print("FactionTaskInfo:buildFactionTaskMsg")
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_GETTASKINFO_RET)
	local ret = {}
	ret.factionID = self:getFactionID()
	ret.joinCount = self.joinCount

	local taskIDs = {}
	if taskID ~= FACTIONTASK_ALLTASK_ID then
		if self.dailyTasks[taskID] then
			table.insert(taskIDs,taskID)
		end
	else
		for taskID, task in pairs(self.dailyTasks) do
			table.insert(taskIDs,taskID)
		end
	end
	
	ret.tasks = {}
	--任务的详细信息
	for _, taskID in ipairs(taskIDs) do
		local taskinfo = {}
		local task = self.dailyTasks[taskID]
		local targetState = task:getTargetStates()
		local targetNum = table.size(targetState)
		taskinfo.taskID = taskID
		taskinfo.targets = {}
		for i=1,targetNum do
			table.insert(taskinfo.targets,targetState[i])
		end
		table.insert(ret.tasks,taskinfo)
	end
	
	local pb_str, errorCode = protobuf.encode("GetFactionTaskInfoRet", ret)
	if pb_str then
		retBuff:pushPbc(pb_str, #pb_str)
	else
		print("FactionTaskInfo:buildFactionTaskMsg encode error! context: ", errorCode, roleSID, FACTION_SC_GETTASKINFO_RET, "GetFactionTaskInfoRet", toString(ret))
	end
	return retBuff
end

--行会任务状态改变
function FactionTaskInfo:onTaskCastStates(taskId,targetState)
	self.syncFlag = true
end

function FactionTaskInfo:getRewardInfo(taskId)
	local rewardInfo = self.rewardInfos[taskId]
	if not rewardInfo then
		self.rewardInfos[taskId] = {completed = 0, rewarded = 0}
		rewardInfo = self.rewardInfos[taskId]
	end
	return rewardInfo
end

--[[
--行会任务完成 飘黄
function FactionTaskInfo:onTaskDone(taskId)
	--print("FactionTaskInfo:onTaskDone ", self:getFactionID(), taskId)
	--全服飘黄广播
	--local ret = {}
	--ret.factionName = faction:getName()
	--ret.taskID = taskId
	--g_engine:broadWorldEvent(retBuff)
	--boardProtoMessage(FACTION_SC_TASKDONE_NOTIFY, "FactionTaskDoneNotify", ret)

        local rewardInfo = self:getRewardInfo(taskId)
	rewardInfo.completed = 1
	self.syncFlag = true
end
]]--

function FactionTaskInfo:onTaskDone(taskId)
	print("FactionTaskInfo:onTaskDone ", self:getFactionID(), taskId)
	local faction = self:getFaction()
	
	--增加行会财富
	local taskP = g_LuaTaskDAO:getFactionTask(taskId)
	local addMon = 0
	if taskP then
		addMon = taskP.q_rewards_facMoney or 0
		faction:setMoney(faction:getMoney() + addMon)
		--print('FactionTaskInfo:onTaskDone add money', addMon, faction:getMoney())
		faction:NotifyFactionInfo()
		faction:setFactionSyn(true)
	end
	
	--增加行会成员个人贡献
	if taskP then
		local addCon = taskP.q_rewards_facCon or 0
		local allMems = faction:getAllMembers()
		for roleSID, facMem in pairs(allMems) do
			facMem:setContribution(facMem:getContribution() + addCon)
			faction:addUpdateMem(roleSID)
			
			--增加活跃度
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player then 		
				g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.FACTION_TASK)
			end

			--邮件通知
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			email:setDescId(FactionTaskRewardEmail1)
			email:insertParam(tostring(addMon))
			email:insertParam(tostring(addCon))
			offlineMgr:recvEamil(roleSID, email, 0, 0)
		end
	end

	--全服飘黄广播
	local ret = {}
	ret.factionName = faction:getName()
	ret.taskID = taskId
	--g_engine:broadWorldEvent(retBuff)
	boardProtoMessage(FACTION_SC_TASKDONE_NOTIFY, "FactionTaskDoneNotify", ret)
end

--行会公共任务定时发奖
function FactionTaskInfo:onTimeReward()
	print("FactionTaskInfo:onTimeReward ", self:getFactionID())
	local faction = self:getFaction()
	if faction then
		for taskId, task in pairs(self.dailyTasks) do
			local rewardInfo = self:getRewardInfo(taskId)
			--是否完成
			print("FactionTaskInfo:onTimeReward rewarded", self:getFactionID(), rewardInfo.rewarded, rewardInfo.completed)
			if rewardInfo.rewarded ~= 1 and rewardInfo.completed == 1 then
				--print("FactionTaskInfo:onTimeReward rewarded", self:getFactionID())

				local playerCount = math.min(self.joinCount, 140)

				--增加行会财富
				local taskP = g_LuaTaskDAO:getFactionTask(taskId)                                                                                                                                                                                                                                                                                                                                                                                                                      
				local addMon = 0
				local relAddMon = 0
				if taskP then
					addMon = taskP.q_rewards_facMoney or 0
					relAddMon = math.ceil(0.5 * addMon + 0.5 * addMon * math.sqrt(playerCount / 140))
					faction:setMoney(faction:getMoney() + relAddMon)
					print('FactionTaskInfo:onTaskDone add money', addMon, playerCount, relAddMon, faction:getMoney())
					faction:NotifyFactionInfo()
					faction:setFactionSyn(true)
				end
				
				--增加行会成员个人贡献
				if taskP then
					local addCon = taskP.q_rewards_facCon or 0
					local relAddCon = math.ceil(0.5 * addCon + 0.5 * addCon * math.sqrt(playerCount / 140))
					print('FactionTaskInfo:onTaskDone add con', addCon, playerCount, relAddCon)
					local allMems = faction:getAllMembers()
					for roleSID, facMem in pairs(allMems) do
						facMem:setContribution(facMem:getContribution() + relAddCon)
						faction:addUpdateMem(roleSID)
			
						--增加活跃度
						local player = g_entityMgr:getPlayerBySID(roleSID)
						if player then 		
							g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.FACTION_TASK)
						end

						--邮件通知
						local offlineMgr = g_entityMgr:getOfflineMgr()
						local email = offlineMgr:createEamil()
						email:setDescId(FactionTaskRewardEmail1)
						email:insertParam(tostring(relAddMon))
						email:insertParam(tostring(relAddCon))
						offlineMgr:recvEamil(roleSID, email, 0, 0)
					end
				end
			end

			rewardInfo.rewarded = 1
			self.syncFlag = true
		end
	end
	self.dailyRewardTime = self:getNextRewardTime()
end

--行会任务状态设置
function FactionTaskInfo:setFactionTaskTargetStates(state)
	local tasklist = self.dailyTasks
	self.dailyTasks = {}
	local strState = "{[1]="..state..",}"
	for _, task in pairs(tasklist) do
		local taskId = task:getID()
		release(task)
		tasklist[taskId] = nil

		--重新接取一个任务
		self:loadFactionTask(taskId, 1, strState)
	end
	self.syncFlag = true
end

--设置行会任务
function FactionTaskInfo:setFactionTaskId(taskId)
	local taskP = g_LuaTaskDAO:getFactionTask(taskId)
	if not taskP then
		return false
	end

	local tasklist = self.dailyTasks
	self.dailyTasks = {}
	self.joinMems = {}
	self.rewardInfos = {}
	self.joinCount = 0

	--重新接取一个任务
	self:loadFactionTask(taskId,1,"")
	self.syncFlag = true
	return true
end

--行会任务更新
function FactionTaskInfo:update()
	--新的行会
	if self.dailyReFreshTime == 0 then
		--self:reFreshTask()
		print("FactionTaskInfo:update dailyReFreshTime == 0 reFreshTask ",self:getFactionID())
	end

	local now = os.time()
	if now > self.nextReFreshTime then
		--tlog行会任务流水
		local faction = self:getFaction()
		if faction then
			for taskId, task in pairs(self.dailyTasks) do
				local taskTargetState = task:getTargetStates()
				local taskTarget = 0
				local targets = task:getTarget()
				for _,v in pairs(targets) do
					if v.param.count then
						taskTarget = v.param.count
					elseif v.param.param1 then
						taskTarget = v.param.param1
					end
					break
				end

				local percent = 0
				if taskTarget > 0 then
					percent = taskTargetState[1] * 100 / taskTarget
				end
				print("TlogFactionTaskFlow ", taskId, taskTargetState[1], taskTarget, percent)
				g_tlogMgr:TlogFactionTaskFlow(faction:getFactionID(), faction:getName(), taskId, percent, table.size(faction:getAllMembers()), self.joinCount, faction:getLevel())
			end
		end
		self:reFreshTask()
	end
	
	--定时发奖
	--if now > self.dailyRewardTime then
	--	self:onTimeReward()
	--end

	--更新数据库
	if self.syncFlag == true then	
		self:cast2db(FACTIONTASK_DBDATAS_FMT)
	end
end