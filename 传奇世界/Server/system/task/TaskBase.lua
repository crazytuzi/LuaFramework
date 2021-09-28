--TaskBase.lua
--/*-----------------------------------------------------------------
 --* Module:  TaskBase.lua
 --* Author:  seezon
 --* Modified: 2014年4月9日
 --* Purpose: 任务基础类
 -------------------------------------------------------------------*/
require "system.task.target.TargetBase"
require "system.task.target.TargetHelper"
TaskBase = class()

local prop = Property(TaskBase)
prop:accessor("roleID")
prop:accessor("ID")			--任务ID
prop:accessor("status")			--任务状态
prop:accessor("type")			--任务类型
prop:accessor("statesInDB")		--目标在数据库中的值

--讨伐任务相关
prop:accessor("q_rewards_exp", 0)	--讨伐奖励经验
prop:accessor("q_rewards_coin", 0)	--讨伐奖励游戏币

--日常任务相关
prop:accessor("currentLoop",0)		--日常任务当前环数
prop:accessor("taskStar",1)		--日常任务星级
prop:accessor("rewardID")		--日常任务的奖励ID

--行会任务相关
prop:accessor("factionID")		--行会ID

function TaskBase:__init(taskID, roleId, taskType)
	self._targets = {}
	prop(self, "ID", taskID)
	prop(self, "roleID", roleId)
	prop(self, "type", taskType)
end

--获取持有该任务的玩家
function TaskBase:getPlayer()
	return g_entityMgr:getPlayer(self:getRoleID())
end

--初始化任务目标
function TaskBase:initTargets(loadDB)
	local states
	--statesInDB保存着数据库的任务目标状态标志，比如有2个任务目标可能就是{[1]=1,[2]=4}	
	--local statesInDB = self:getStatesInDB()
	--local statesInDB = unserialize(self:getStatesInDB())
	--print("TaskBase:initTargets2:",toString(statesInDB))
	local statesInDB = self:getStatesInDB()
	if statesInDB and statesInDB ~= "" then
		local b, s = pcall(loadstring("return "..statesInDB))
		if b and type(s) == "table" then 
			states = s 
		end
	end

	local targets = self:getTarget()
	if targets then	
		for idx, config in ipairs(targets) do
			local context = table.deepCopy(config.param) 
			local target = TargetHelper.createTarget(config.type, self, context, states and states[idx], loadDB)
			self._targets[idx] = target
		end
	end	
end

--构造目标数据
function TaskBase:getTarget()
	local targets = {}

	local killMonster
	local ownMat
	local doneEvent
	local taskP = g_LuaTaskDAO:getPrototype(self:getID())
	if self:getType() == TaskType.Daily then
		taskP = g_LuaTaskDAO:getDailyTask(self:getID())
	elseif self:getType() == TaskType.Branch then
		taskP = g_LuaTaskDAO:getBranchTaskByID(self:getID())
-- 悬赏任务20160106
	elseif self:getType() == TaskType.Reward then
		taskP = g_LuaTaskDAO:getRewardTask(self:getID())
--行会公共任务
	elseif self:getType() == TaskType.Faction then
		taskP = g_LuaTaskDAO:getFactionTask(self:getID())
	elseif self:getType() == TaskType.Shared then
		taskP = g_LuaTaskDAO:getSharedTask(self:getID())
	end

	if taskP then
		killMonster = taskP.q_end_need_killmonster
		ownMat = taskP.q_end_need_goods
		doneEvent = taskP.q_done_event
	end

	--如果有杀怪的任务目标
	if killMonster then
		local killMonsterTargets = self:parseTaskTarget(killMonster)
		for _,v in pairs(killMonsterTargets) do
			local target = {}
			target.type = "TKillMonster"
			target.param = v
			table.insert(targets, target)
		end
	end

	--如果有收集物品的任务目标
	if ownMat then
		local ownMatTargets = self:parseTaskTarget2(ownMat)
		for _,v in pairs(ownMatTargets) do
			local target = {}
			target.type = "TOwnMat"
			target.param = v
			table.insert(targets, target)
		end
	end

	--所以任务目标都整合到这里吧，杀怪和收集就排开了
	if doneEvent and not (doneEvent == "0") then
		local doneEventTargets = self:parseCommonTarget(doneEvent)
		for _,v in pairs(doneEventTargets) do
			local target = {}
			target.type = TaskTargetTypeMap[v.targetType]
			target.param = v
			table.insert(targets, target)
		end
	end

	return targets
end

--解析目标配置
function TaskBase:parseTaskTarget(str)
	local targets = {}
	local targetStr = StrSplit(str, ";")
	for _, v in pairs(targetStr) do
		local target = {}
		target.isAutoFight = false
		if string.charAt(v, 1) == "@" then
			target.isAutoFight = true
			v = string.sub(v, 2, #v)
		end
		
		local tgStr = StrSplit(v, "_")

		target.ID = StrSplit(tgStr[1], ",")
		target.count = tonumber(tgStr[2])

		table.insert(targets, target)
	end

	return targets
end

--解析目标配置
function TaskBase:parseTaskTarget2(str)
	local targets = {}
	local targetStr = StrSplit(str, ";")
	for _, v in pairs(targetStr) do
		local target = {}
		target.isAutoFight = false
		if string.charAt(v, 1) == "@" then
			target.isAutoFight = true
			v = string.sub(v, 2, #v)
		end
		
		local tgStr = StrSplit(v, "_")

		target.ID = tonumber(tgStr[1])
		target.count = tonumber(tgStr[2])
		target.mapID = tonumber(tgStr[3])
		target.posX = tonumber(tgStr[4])
		target.posY = tonumber(tgStr[5])

		table.insert(targets, target)
	end

	return targets
end

--解析通用目标配置
function TaskBase:parseCommonTarget(str)
	local targets = {}
	local targetStr = StrSplit(str, ";")
	for _, v in pairs(targetStr) do
		local target = {}
		local tgStr = StrSplit(v, "_")

		target.targetType = tonumber(tgStr[1])
		target.param1 = tonumber(tgStr[2])
		target.param2 = tonumber(tgStr[3])
		target.param3 = tonumber(tgStr[4])
		target.param4 = tonumber(tgStr[5])
		target.param5 = tonumber(tgStr[6])
		target.param6 = tonumber(tgStr[7])
		table.insert(targets, target)
	end

	return targets
end

--获取目标状态
function TaskBase:getTargetStates()
	local states = {}
	for idx, target in pairs(self._targets or table.empty) do
		states[idx] = target:getState()
	end
	
	return states
end

--设置目标状态
function TaskBase:setTargetStates(state)
	for idx, target in pairs(self._targets or table.empty) do
		target:setState(state)
	end
end

--通知客户端任务状态改变
function TaskBase:castStates()
	local player = self:getPlayer()
	local targetState = self:getTargetStates()
	if self:getType() == TaskType.Main then
		local taskP = g_LuaTaskDAO:getPrototype(self:getID())
		local chapter = taskP.q_chapter
		local ret = {}
		ret.taskID = self:getID()
		ret.chapter = chapter
		ret.targetState = targetState
		fireProtoMessage(player:getID(), TASK_SC_TARGET_STATE_CHANGE, 'TargetSatusChangeProtocol', ret)

	elseif self:getType() == TaskType.Daily then
		local ret = {}
		ret.taskID = self:getID()
		ret.targetState = targetState
		fireProtoMessage(player:getID(), TASK_SC_DAILY_TARGET_STATE_CHANGE, 'DailyTargetStateChangeProtocol', ret)
	elseif self:getType() == TaskType.Branch then
		local ret = {}
		ret.taskID = self:getID()
		ret.targetState = targetState
		fireProtoMessage(player:getID(), TASK_SC_BRANCH_TARGET_STATE_CHANGE, 'BranchTargetStateChangeProtocol', ret)
-- 悬赏任务20160106
	elseif self:getType() == TaskType.Reward then
		local ret = {}
		ret.taskID = self:getID()
		local stateNum = table.size(targetState)
		ret.targetNum = stateNum
		ret.targetStateDatas = {}
		for i=1,stateNum do
			table.insert(ret.targetStateDatas, targetState[i])
		end
		fireProtoMessage(player:getID(), TASK_SC_REWARD_TARGET_STATE_CHANGE, 'RewardTaskStateChange', ret)

		-- local retBuffer = SCREWARDTASKTARRGETSTATECHANGE.writeFun(self:getID(),targetState)
		-- g_engine:fireLuaEvent(player:getID(), retBuffer)
--行会公共任务
	elseif self:getType() == TaskType.Faction then
		local factionTaskInfo = g_factionMgr:getFactionTaskInfo(self:getFactionID())
		if factionTaskInfo then
			factionTaskInfo:onTaskCastStates(self:getID(),targetState)
		end
	elseif self:getType() == TaskType.Shared then
		local retBuffer = SCSHAREDTASKTARRGETSTATECHANGE.writeFun(self:getID(),targetState)
		fireProtoMessage(player:getID(), TASK_SC_SHARED_TARGET_STATE_CHANGE, 'SharedTargetStateChangeProtocol', retBuffer)
		local taskP = g_LuaTaskDAO:getSharedTask(self:getID())
		local all = 0

		for i=1,4 do
			all = all+targetState[i]
		end

		local teamId = player:getTeamID()
		local team = g_TeamPublic:getTeam(teamId)
		--[[if team then
			local members = team:getOnLineMems()
			g_tlogMgr:TlogYGBZFlow(player,taskP.q_rank,all,#members)
		else
			g_tlogMgr:TlogYGBZFlow(player,taskP.q_rank,all,1)
		end]]
		g_tlogMgr:TlogYGBZFlow(player,taskP.q_rank,all,1)
		if all==4 then
			local teamId = player:getTeamID()
			local team = g_TeamPublic:getTeam(teamId)
			if team then
				local teamMember = team:getOnLineMems()
				-- g_masterMgr:finishMasterTask(MASTER_TASK_ID.TREASURE, player:getSerialID(),teamMember)
			end
		end
		
		g_sharedTaskMgr:AddTaskToList(player,taskP.q_rank,serialize(targetState))
	end
end


--更新任务
function TaskBase:validate()
	if self:canEnd() then
		self:statusChanged(TaskStatus.Done)
	else
		self:statusChanged(TaskStatus.Active)
	end
end

function TaskBase:__release()
	for idx, target in pairs(self._targets) do
		if target then
			target:release()
		end
	end
end

--任务是否目标完成
function TaskBase:targetsCompleted()
	for idx, target in pairs(self._targets) do
		if target then
			local done = target:completed()
			if not done then
				return false
			end
		end
	end
	return true
end

--判断任务是不是可以完成了
function TaskBase:canEnd()
	return self:targetsCompleted()
end

--改变任务状态
function TaskBase:statusChanged(state)
	if not TASK_OPEN_FALG then
		return
	end
	
	local old = self:getStatus()
	if old == state then 
		return 
	end	--不允许同一状态改变两次
	self:setStatus(state)
	if state == nil then 
		return 
	end
	--print(string.format("任务%s的状态由%s变换为%s\n",self:getID(), old or "", state or ""))
	
	--行会公共任务
	if self:getType() == TaskType.Faction then
		if state == TaskStatus.Done then
			local factionTaskInfo = g_factionMgr:getFactionTaskInfo(self:getFactionID())
			if factionTaskInfo then
				factionTaskInfo:onTaskDone(self:getID())
			end
		end
		return
	end

	local player = self:getPlayer()
	if not player then return end
	--任务状态改变改变需要刷新数据库
	local roleId = player:getID()
	local roleInfo = g_taskMgr:getRoleTaskInfo(roleId)
	if not roleInfo then
		return
	end
	roleInfo:cast2db()
	local taskP = g_LuaTaskDAO:getPrototype(self:getID())

	if self:getType() == TaskType.Daily then
		taskP = g_LuaTaskDAO:getDailyTask(self:getID())
	elseif self:getType() == TaskType.Branch then
		taskP = g_LuaTaskDAO:getBranchTaskByID(self:getID())
-- 悬赏任务20160106
	elseif self:getType() == TaskType.Reward then
		taskP = g_LuaTaskDAO:getRewardTask(self:getID())

	elseif self:getType() == TaskType.Shared then
		taskP = g_LuaTaskDAO:getSharedTask(self:getID())
	end
	if not taskP then
		print("数据错误,",self:getType(), self:getID())
		return
	end

	if state == TaskStatus.Active then
		--激活时的处理
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.acceptTask, self)
	elseif state == TaskStatus.Done then		--任务完成
		for idx, target in pairs(self._targets or table.empty) do
			target:onTaskDone()
		end

		--如果是自动提交的任务就在这里完成
		local bAutoFinishTask = taskP.q_finsh_type

		if bAutoFinishTask and bAutoFinishTask == TaskFinishType.AutoFinish then
			g_taskServlet:finishTask(self:getRoleID(), self)
			return
		end
	elseif state == TaskStatus.Finished then
		for idx, target in pairs(self._targets or table.empty) do
			target:onTaskFinished()
		end
	end
	
	----通知客户端
	--print("TASK_SC_STATUS_CHANGE后端写消息", player:getSerialID(),self:getType(), self:getID(), self:getStatus())
	local chapter = taskP.q_chapter or 0
	local ret = {}
	ret.taskType = self:getType()
	ret.taskID = self:getID()
	ret.chapter = chapter
	ret.taskState = self:getStatus()
	fireProtoMessage(player:getID(), TASK_SC_STATUS_CHANGE, 'SatusChangeProtocol', ret)

	if state == TaskStatus.Finished then
		if self:getType() == TaskType.Main then
			--完成主线任务触发特殊行为
			self:finishMainTaskGet(self:getID())
			
			
			local nextTaskId = taskP.q_next_task
			local nextTaskP = g_LuaTaskDAO:getPrototype(nextTaskId)
			local acceptType = tonumber(nextTaskP.q_start_type) or 1
			if acceptType == 1 then		--任务完成的时候自动接新任务
				if not (nextTaskId == 0) and g_taskServlet:canReceive(player, TaskType.Main, nextTaskId)then
					roleInfo:romoveMainTask(nextTaskId)
					g_taskServlet:receiveTask(self:getPlayer(), TaskType.Main, nextTaskId)
					return
				end
			end

			--通知客户端这个任务因为等级接不到
			--print("TASK_SC_CUR_MAIN_TASK后端写消息", nextTaskId)
			local chapter = 5
			if not (nextTaskId == 0) then
				local nextTaskP = g_LuaTaskDAO:getPrototype(nextTaskId)
				if chapter then
					chapter = nextTaskP.q_chapter
				end
			end

			local ret = {}
			ret.taskID = nextTaskId
			ret.chapter = chapter
			print("2223333333333333333333",nextTaskId )
			fireProtoMessage(player:getID(), TASK_SC_CUR_MAIN_TASK, 'CurMainTaskProtocol', ret)
			roleInfo:romoveMainTask(nextTaskId)
		elseif self:getType() == TaskType.Daily then	
			g_taskMgr:NotifyListener(player, "onDoneDailyTask")
			local curLoop = self:getCurrentLoop()
			--print("TASK_SC_FINISH_DAILY_TASK后端写消息", curLoop)
			local ret = {}
			ret.taskID = self:getID()
			ret.curloop = curLoop
			fireProtoMessage(player:getID(), TASK_SC_FINISH_DAILY_TASK, 'FinishDailyTaskProtocol', ret)
			roleInfo:romoveDailyTask()
			if curLoop < roleInfo:getMaxDailyLoop() then
				--local dailyTaskId = g_LuaTaskDAO:getDailyTaskByLevel(self:getPlayer():getLevel())
				local dailyTaskId = g_LuaTaskDAO:getNextDailyTask(self:getPlayer():getLevel(),ret.taskID)
				print("<>>>>>>>>",dailyTaskId)
				g_taskServlet:receiveTask(self:getPlayer(), TaskType.Daily, dailyTaskId, curLoop + 1)
				g_taskServlet:sendErrMsg2Client(roleId, TASK_ERR_FINISH_DAIY, 2, {curLoop,curLoop + 1})
			else
				g_taskServlet:sendErrMsg2Client(roleId, TASK_ERR_FINISH_ALL_DAIY, 1, {roleInfo:getMaxDailyLoop()})
			end
			
--			g_ActivityMgr:OnTask(player:getID(), self:getID(), TaskType.Daily, g_LuaTaskDAO:getDailyRewardStar(self:getRewardID()))
			--触发拼战
			if table.contains(CompetitionLoop, curLoop) then
				g_competitionMgr:checkCompetitionActive(player:getSerialID(),2)
			end
		elseif self:getType() == TaskType.Branch then
			roleInfo:addFinishBrachID(self:getID())
			local ret = {}
			ret.taskID = self:getID()
			fireProtoMessage(player:getID(), TASK_SC_FINISH_BRANCH_TASK, 'FinishBranchProtocol', ret)
			--完成特定支线任务,开启光翼
			if self:getID() == TASK_OPEN_WING_ID then
				g_wingMgr:firstActiveWing(player)
			end

			if self:getID() == TASK_OPEN_MOUNT_ID then
				g_MountManager:OnTaskComplete(player)
			end	

			roleInfo:romoveBranchTask(self:getID())
			--检查是不是新的支线任务
			g_taskMgr:receiveNewBranch(player)

			
-- 悬赏任务20160106	
		elseif self:getType() == TaskType.Reward then
			roleInfo:romoveRewardTask()
			local ret = {}
			ret.actionType = 0
			fireProtoMessage(player:getID(), TASK_SC_FINISH_REWARD_TASK, 'FinishRewardTaskRet', ret)

			-- local retBuff = SCFINISHREWARDTASK.writeFun(0)
			-- g_engine:fireLuaEvent(player:getID(), retBuff)
		elseif self:getType() == TaskType.Shared then
			roleInfo:removeSharedTask()
			local retBuff = SCFINISHSHAREDTASK.writeFun(0)
			fireProtoMessage(player:getID(), TASK_SC_FINISH_SHARED_TASK, 'FinishSharedTaskProtocol', retBuff)
		end

		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.finishTask, self)
	end
end

--完成主线任务触发行为
function TaskBase:finishMainTaskGet(taskID)
	local player = self:getPlayer()
	if not player then return end

	--给坐骑
	if taskID == TASK_OPEN_RIDE_ID then
		g_rideMgr:firstActiveRide(player)
	end

	--给勋章
	if taskID == TASK_OPEN_MEDAL_ID then
		local itemID = 30004
		if player:getSchool() == 2 then
			itemID = 30005
		elseif player:getSchool() == 3 then
			itemID = 30006
		end

		local itemMgr = player:getItemMgr()
		local freeSlotNum = itemMgr:getEmptySize()		----如果物品格子数不够就发邮件
		local offlineMgr = g_entityMgr:getOfflineMgr()
		if freeSlotNum < 1 then
			local email = offlineMgr:createEamil()
			email:setDescId(42)
			email:insertProto(itemID, 1, true)
			offlineMgr:recvEamil(player:getSerialID(), email, 95, 0)
		else
			Operation = itemMgr:addItem(1, itemID, 1, 1, 0, 0, 0, 0)
		end	
	end
end