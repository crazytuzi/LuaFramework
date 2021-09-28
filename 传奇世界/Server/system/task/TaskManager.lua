--TaskManager.lua
--/*-----------------------------------------------------------------
 --* Module:  TaskManager.lua
 --* Author:  seezon
 --* Modified: 2014年4月8日
 --* Purpose: 任务管理器
 -------------------------------------------------------------------*/
require ("system.task.TaskServlet")
require ("system.task.RoleTaskInfo")
require ("system.task.LuaTaskDAO")
require ("system.task.TaskBase")
require ("system.task.TaskEventHandler")
require ("system.task.TaskConstant")
require ("system.task.TaskEventParse")
	
TaskManager = class(nil, Singleton)
--全局对象定义
g_LuaTaskDAO = LuaTaskDAO.getInstance()
g_taskServlet = TaskServlet.getInstance()


function TaskManager:__init()
	self._roleTaskInfos = {} --运行时ID
	self._roleTaskInfoBySID = {} --数据库ID
	self._roleMonsterInfo = {}	--单人杀怪任务, 野怪动态ID信息
	self._rolePersonalEscortInfo = {}	--个人护送任务, 护送任务ID信息
	g_listHandler:addListener(self)
end

function TaskManager:getMainTaskState(roleID, taskID)
	if taskID <= 0 then
		return TaskStatus.Accept
	end

	local roleInfo = self:getRoleTaskInfo(roleID) 
	
	local mainTaskId = roleInfo:getCurMainTaskId()

	--增加主线任务任务，通知客户端
	if mainTaskId then
		if mainTaskId < taskID then
			return TaskStatus.Finished
		else
			return TaskStatus.Accept
		end
	else
		local task = roleInfo:getMainTask()
		if task then
			if task:getID() == taskID then
				return task:getStatus()
			elseif task:getID() > taskID then
				return TaskStatus.Finished
			else
				return TaskStatus.Accept
			end
		end
	end

	return TaskStatus.Accept
end

--发送任务数据给客户端
function TaskManager:notifyTaskData2Client(player)
	local roleInfo = self:getRoleTaskInfoBySID(player:getSerialID()) 
	if not roleInfo then
		return
	end
	local mainTaskId = roleInfo:getCurMainTaskId()

	--增加主线任务任务，通知客户端
	if mainTaskId then
		local taskP = g_LuaTaskDAO:getPrototype(mainTaskId)
		local chapter = 5
		if not (mainTaskId == 0) then
			local nextTaskP = g_LuaTaskDAO:getPrototype(mainTaskId)
			if nextTaskP then
				chapter = nextTaskP.q_chapter
			end
		end

		local ret = {}
		ret.taskID = mainTaskId
		ret.chapter = chapter
		fireProtoMessage(player:getID(), TASK_SC_CUR_MAIN_TASK, 'CurMainTaskProtocol', ret)
	else
		local task = roleInfo:getMainTask()
		if task then
			local taskState = task:getStatus()
			local targetState = task:getTargetStates()
			local taskP = g_LuaTaskDAO:getPrototype(task:getID())
			local chapter = taskP.q_chapter
			local ret = {}
			ret.taskID = task:getID()
			ret.isNew = 0
			ret.chapter = chapter
			ret.targetState = targetState
			fireProtoMessage(player:getID(), TASK_SC_ADD_TASK, 'AddTaskProtocol', ret)

			task:setStatus(nil)
			task:validate()
		end
	end

	--加载日常任务
	local dailyTask = roleInfo:getDailyTask()
	if dailyTask then
		local needFinishIngot,needAllIngot = self:CalFinishTaskByIngot(roleInfo)
		local ret = {}
		ret.taskID = dailyTask:getID()
		ret.isNew = 0
		ret.curloop = dailyTask:getCurrentLoop()
		ret.rewardId = dailyTask:getRewardID()
		ret.targetState = dailyTask:getTargetStates()
		ret.needFinishIngot = needFinishIngot
		ret.needAllIngot = needAllIngot
		ret.etrXp = TASK_DAILY_FINISH_BY_INGOT_EXP
		fireProtoMessage(player:getID(), TASK_SC_ADD_DAILY_TASK, 'AddDailyTaskProtocol', ret)

		dailyTask:validate()
	else
		local lastTaskInfo = roleInfo:getLastTaskInfo(TaskType.Daily)
		if lastTaskInfo then
			local ret = {}
			ret.taskType = TaskType.Daily
			ret.taskID = lastTaskInfo.id
			ret.rewardID = lastTaskInfo.rId
			fireProtoMessage(player:getID(), TASK_SC_SEND_LASTTASK_INFO, 'SendLastTaskInfoProtocol', ret)
		end
	end

	--加载支线任务
	local branchTask = roleInfo:getAllBranchTask()
	for _,task in ipairs(branchTask) do
		local targetState = task:getTargetStates()
		local ret = {}
		ret.taskID = task:getID()
		ret.targetState = targetState
		fireProtoMessage(player:getID(), TASK_SC_ADD_BRANCH_TASK, 'AddBranchProtocol', ret)
		task:setStatus(nil)
		task:validate()
	end

-- 悬赏任务20160106
	--加载悬赏任务
	local rewardTask = roleInfo:getRewardTask()
	if rewardTask then
		local ret = {}
		ret.taskID = rewardTask:getID()
		ret.isNew = 0
		ret.taskGUID = roleInfo:getRewardTaskGUID()
		local targertData = rewardTask:getTargetStates()
		local targetNum = table.size(targertData)
		local guardExpiredTime = roleInfo:getRewardTaskGuardTime()
		local expiredTime = guardExpiredTime - os.time()
		if expiredTime > 0 then
			ret.guardExpiredTime = expiredTime
		end	
		ret.targetNum = targetNum
		ret.targetStates = {}
		for i = 1, targetNum  do
			table.insert(ret.targetStates, targertData[i])
		end
		fireProtoMessage(player:getID(), TASK_SC_ADD_REWARD_TASK, 'AddRewardTaskRet', ret)

		-- local retBuffer = SCADDREWARDTASK.writeFun(rewardTask:getID(), 0, roleInfo:getRewardTaskGUID(), rewardTask:getTargetStates())
		-- g_engine:fireLuaEvent(player:getID(), retBuffer)
	end

	local sharedTask = roleInfo:getSharedTask()
	if sharedTask then
		local owner = 0
		if roleInfo:IsTaskOwner() then
			owner = 1
		end
		local retBuffer = SCADDSHAREDTASK.writeFun(sharedTask:getID(), sharedTask:getTargetStates(),owner,roleInfo:getSharedTaskTargetPos())
		fireProtoMessage(player:getID(), TASK_SC_ADD_SHARED_TASK, 'AddSharedTaskProtocol', retBuffer)
	end
end

function TaskManager:checkMainTask(player)
	local roleInfo = self:getRoleTaskInfoBySID(player:getSerialID()) 
	if not roleInfo then
		return false
	end
	local mainTaskId = roleInfo:getCurMainTaskId()

	if not mainTaskId and not roleInfo:getMainTask() then
		return false
	end
	return true
end

--验证所有任务
function TaskManager:checkAllTaskStatus(player)
	local roleInfo = self:getRoleTaskInfoBySID(player:getSerialID()) 
	if not roleInfo then
		return
	end

	local task = roleInfo:getMainTask()
	if task then
		if task:canEnd() then
			task:setStatus(TaskStatus.Done)
		else
			task:setStatus(TaskStatus.Active)
		end
	--[[
		task:setStatus(nil)
		task:validate()
		]]
	end

	--日常任务
	local dailyTask = roleInfo:getDailyTask()
	if dailyTask then
		if dailyTask:canEnd() then
			dailyTask:setStatus(TaskStatus.Done)
		else
			dailyTask:setStatus(TaskStatus.Active)
		end
	--[[
		dailyTask:setStatus(nil)
		dailyTask:validate()
		]]
	end

	--支线任务
	local branchTask = roleInfo:getAllBranchTask()
	for _,task in ipairs(branchTask) do
		if task:canEnd() then
			task:setStatus(TaskStatus.Done)
		else
			task:setStatus(TaskStatus.Active)
		end
	--[[
		task:setStatus(nil)
		task:validate()
		]]
	end

end

--掉线登陆
function TaskManager:onActivePlayer(player)
	self:notifyTaskData2Client(player)
end

--玩家上线
function TaskManager:onPlayerLoaded(player)
	print("玩家ID", player:getID(),player:getSerialID())
	self:notifyTaskData2Client(player)
end

--获取玩家信息
function TaskManager:getPlayerInfo(player)
	local roleID = player:getID()
	--print("玩家上线了，玩家ID是",roleID)
	local roleSID = player:getSerialID()
	local memInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not memInfo then
		memInfo = RoleTaskInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleTaskInfos[roleID] = memInfo
		self._roleTaskInfoBySID[roleSID] = memInfo
		
		--加载任务目标观察器
		local taskEventSet = TaskEventHandler()
		memInfo:setTaskEventSet(taskEventSet)
	end

	return memInfo
end


function TaskManager.loadDBData(player, cache_buf, roleSid)		
	local memInfo = g_taskMgr:getPlayerInfo(player)
	if #cache_buf > 0 then
		memInfo:loadTaskData(cache_buf)
	else
		--print("玩家第一次登入游戏，加载10000号主线任务")
		local timeStamp = tonumber(time.toedition("day"))
		memInfo:setDailyTaskStamp(timeStamp)--设置时间戳
		g_taskServlet:receiveTask(player, TaskType.Main, FIRST_MAIN_TASK_ID)
	end
end

function TaskManager.loadDBData2(player, cache_buf, roleSid)
	local memInfo = g_taskMgr:getPlayerInfo(player)
	if #cache_buf > 0 then
		memInfo:loadTaskData2(cache_buf)
	end
end

--特殊主线任务失败需要丢失这个主线任务重新接取
function TaskManager:mainTaskFail(player, task)
	--现在这种会失败的特殊任务只支持主线
	if task:getType() ~= TaskType.Main then
		return
	end
	
	local nextTaskId = task:getID()
	--删除这个主线任务，让玩家重新接取
	local chapter = 1
	if not (nextTaskId == 0) then
		local nextTaskP = g_LuaTaskDAO:getPrototype(nextTaskId)
		if nextTaskP then
			chapter = nextTaskP.q_chapter
		end
	end

	local ret = {}
	ret.taskID = nextTaskId
	ret.chapter = chapter
	fireProtoMessage(player:getID(), TASK_SC_CUR_MAIN_TASK, 'CurMainTaskProtocol', ret)
	local memInfo = self:getRoleTaskInfoBySID(player:getSerialID())
	memInfo:romoveMainTask(nextTaskId)
end

--玩家下线
function TaskManager:onPlayerOffLine(player)
	
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleTaskInfoBySID(roleSID)
	if not memInfo then
		return
	end
	--下线前要存数据库
	local teamId = player:getTeamID()
	local team = g_TeamPublic:getTeam(teamId)
	if g_sharedTaskMgr:IsTaskOwner(roleSID) and team then
		local onMems = team:getOnLineMems() or {}
		for _,mem in pairs(onMems) do
			local member = g_entityMgr:getPlayerBySID(mem)
			if member then
				g_sharedTaskMgr:deleteSharedTask(member:getID(),false)
			end
		end
	end
	if g_sharedTaskMgr:IsTaskOwner(roleSID) then
		local roleTaskInfo = self:getPlayerInfo(player)
		if roleTaskInfo then
			local task = roleTaskInfo:getSharedTask()
			if task then
				local taskP = g_LuaTaskDAO:getSharedTask(task:getID())
				g_sharedTaskMgr:RemoveTaskFromList(player,taskP.q_rank)
			end
		end
		g_sharedTaskMgr:deleteSharedTask(player:getID(),false)
	else
		g_sharedTaskMgr:deleteSharedTask(player:getID(),true)
	end

	local monInfo = g_taskMgr:getMonsterInfoByRoleId(roleID)
	if monInfo then
		local mon = g_entityMgr:getMonster(monInfo.monId)
		if mon then
			local bindHostile = mon:getBindHostile()
			if bindHostile then
				local roleName = player:getName()
				if bindHostile == roleName then
					g_taskMgr:delMonsterInfoByRoleId(roleID)
					g_entityMgr:destoryEntity(mon:getID())
				end
			end
		end
	end

	if memInfo then
		release(memInfo)
		self._roleTaskInfos[roleID] = nil	
		self._roleTaskInfoBySID[roleSID] = nil
	end
end

function TaskManager:doTalkWithNPC(player, npcId, option)
	local roleTaskInfo = self:getPlayerInfo(player)
	if roleTaskInfo then
		return  roleTaskInfo:talkWithNPC(npcId, option)
	end
end

--切换world的通知
function TaskManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local roleTaskInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if roleTaskInfo then
		roleTaskInfo:switchWorld(peer, dbid, mapID)
	end
end

--切换到本world的通知
function TaskManager:onPlayerSwitch(player, type, buff)
	if type == EVENT_TASK_SETS then
		local memInfo = self:getPlayerInfo(player)
		local cache_buf = buff:popLString()
		local cache_buf2 = buff:popLString()
		memInfo:loadTaskData(cache_buf)
		self:checkAllTaskStatus(player)
		memInfo:loadTaskData2(cache_buf2)
	end	
end

--获取日常任务当前环数
function TaskManager:getDailyTaskLoop(player)
	local roleSID = player:getSerialID()
	local memInfo = self:getRoleTaskInfoBySID(roleSID)
	if not memInfo then
		return
	end
	return memInfo:getDailyTaskLoop()
end

function TaskManager:CalFinishTaskByIngot(roleInfo)
	
	local remainLoop = roleInfo:getMaxDailyLoop() - roleInfo:getDailyTaskLoop() + 1
	--local finishAllNeedMoney = remainLoop * TASK_FINISH_DAILY_NEED_INGOT
	local useIngotFinishTime = roleInfo:getFinishByIngot()
	local needIngotThisTime = 20+useIngotFinishTime*10
	local finishAllNeedMoney = 0

	local tmpUseIngotFinishTime = useIngotFinishTime
	if useIngotFinishTime<TASK_DAILY_MAX_TIME then
		for i = remainLoop,1,-1 do
			if tmpUseIngotFinishTime<TASK_DAILY_MAX_TIME then
				finishAllNeedMoney = finishAllNeedMoney + (20+tmpUseIngotFinishTime*10)
			else
				break
			end
			tmpUseIngotFinishTime = tmpUseIngotFinishTime+1
		end
	end
	return needIngotThisTime,finishAllNeedMoney
end


function TaskManager.doYuanbaoFinishTask(roleSID, payRet, money, itemId, itemCount, callBackContext)
	if payRet == 0 then
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then return end
		local roleInfo = g_taskMgr:getRoleTaskInfo(player:getID())
		local useIngotFinishTime = roleInfo:getFinishByIngot()
		roleInfo:setFinishByIngot(useIngotFinishTime+1)
		local task = roleInfo:getDailyTask()
		if not task then
			--print("没有日常任务了")
			return TPAY_FAILED
		end
		g_taskServlet:finishTask(player:getID(), task,1)
		g_achieveSer:costIngot(roleSID, money)
		--消费记录
		g_PayRecord:Record(player:getID(), -money, CURRENCY_INGOT, 28)
		addExpToPlayer(player,TASK_DAILY_FINISH_BY_INGOT_EXP,25)
		g_taskServlet:writeTaskRecord(player:getID(), task, 2)
		--g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.ZHAOLIN, 1)
		roleInfo:cast2db()
		return TPAY_SUCESS
	else
		return TPAY_FAILED
	end
end

--玩家花元宝直接完成日常任务
function TaskManager:finishDailyTask(roleID, finshType)
	local player = g_entityMgr:getPlayer(roleID)
	local roleInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if not roleInfo then
		return
	end
	local task = roleInfo:getDailyTask()
	if not task then
		--print("没有日常任务了")
		return
	end

	local remainLoop = roleInfo:getMaxDailyLoop() - roleInfo:getDailyTaskLoop() + 1
	local needIngotThisTime,finishAllNeedMoney = self:CalFinishTaskByIngot(roleInfo)
	local useIngotFinishTime = roleInfo:getFinishByIngot()
	if (player:getIngot() < needIngotThisTime and finshType == FinishDailyTaskType.finishCur) 
		or (player:getIngot() < finishAllNeedMoney and finshType == FinishDailyTaskType.finishAll) then
		matNotEnough(player, 2, 0)
		g_taskServlet:sendErrMsg2Client(roleID, COPY_ERR_NOT_ENOUGH_INGOT, 0)
		return
	end
	

	local newRewardID = g_LuaTaskDAO:getDailyTaskMaxReward(task:getRewardID())
	task:setRewardID(newRewardID)
	if finshType == FinishDailyTaskType.finishCur then
		if isIngotEnough(player, needIngotThisTime) then
			--请求扣元宝
			local ret = g_tPayMgr:TPayScriptUseMoney(player, needIngotThisTime, 25, "", 0, 0, "TaskManager.doYuanbaoFinishTask") 
			if ret ~= 0 then
				g_copySystem:fireMessage(0, roleID, EVENT_COPY_SETS, COPY_SYSTEM_BUSY, 0)
				return 
			else
				g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.finishDailyTask1, 1)
				return
			end
		else
			g_copySystem:fireMessage(COPY_CS_ENTERCOPY, player:getID(), EVENT_COPY_SETS, COPY_ERR_NOT_ENOUGH_INGOT, 0)
		end
		--[[
	elseif finshType == FinishDailyTaskType.finishAll then
		--给剩余环的全部最高奖励
		roleInfo:setFinishByIngot(TASK_DAILY_MAX_TIME)
		local rewardProto = g_LuaTaskDAO:getDailyReward(newRewardID)
		local allMoney = 0
		local allXp = 0
		for i=1, remainLoop do
			ret,money,xp = g_taskServlet:doReward(player, rewardProto, TaskType.Daily)
			allMoney = allMoney+money
			allXp = allXp+xp
			g_taskMgr:NotifyListener(player, "onDoneDailyTask")
			--通知成就
			g_achieveSer:notify(player:getSerialID(), AchieveType.Task, AchieveEventType.FinishTask, 1)

		end

		--给满环奖励
		local totalRewardProto = g_LuaTaskDAO:getDailyTotalRewardByLevel(player:getLevel())
		g_taskServlet:doReward(player, totalRewardProto, TaskType.Daily)
		costIngot(player, finishAllNeedMoney, 27)
		g_achieveSer:costIngot(player:getSerialID(), finishAllNeedMoney)
		--消费记录
		g_PayRecord:Record(player:getID(), -finishAllNeedMoney, CURRENCY_INGOT, 28)

		roleInfo:romoveDailyTask()
		
		--player:setXP(player:getXP()+TASK_DAILY_FINISH_BY_INGOT_EXP*remainLoop)
		--Tlog[PlayerExpFlow]
		addExpToPlayer(player,TASK_DAILY_FINISH_BY_INGOT_EXP*remainLoop,27)
		g_taskServlet:sendErrMsg2Client(roleID, -87, 3,{allMoney,allXp,TASK_DAILY_FINISH_BY_INGOT_EXP})
		g_taskServlet:writeTaskRecord(roleID, task, 3)
		local ret = {}
		ret.taskID = task:getID()
		ret.curloop = tonumber(roleInfo:getMaxDailyLoop())
		fireProtoMessage(player:getID(), TASK_SC_FINISH_DAILY_TASK, 'FinishDailyTaskProtocol', ret)

		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.finishDailyTask2, 1)
		]]
	end

	roleInfo:cast2db()
end

function TaskManager:pickDailyReward(roleID, loop)
	local player = g_entityMgr:getPlayer(roleID)
	local roleInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if not roleInfo then
		return
	end
	local task = roleInfo:getDailyTask()
	if not task then
		--print("没有日常任务了")
		return
	end

	if task:getCurrentLoop() ~= loop then
		return
	end

	if task:getStatus() ~= TaskStatus.Done then
		return
	end

	g_taskServlet:finishTask(roleID, task)
end

--0点刷新
function TaskManager:onFreshDay()
	for roleID,info in pairs(self._roleTaskInfos) do
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			info:freshDay()
		end
	end
end

--玩家死亡
function TaskManager:onPlayerDied(player, killerID)
	g_taskMgr:NotifyListener(player, "onChangeModeFail")
end

--日常任务奖励升星级
function TaskManager:upRewardStar(roleID)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local roleInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if not roleInfo then
		return
	end

	local task = roleInfo:getDailyTask()

	if not task then
		return
	end

	local rewardProto = g_LuaTaskDAO:getDailyReward(task:getRewardID())

	if not rewardProto then
		return
	end

	local needBindIngot = rewardProto.q_upStarNeedMoney
	--获取升星级需要的钱
	if (player:getBindIngot() + player:getIngot())< needBindIngot then
		--g_tradeMgr:sendErrMsg2Client(roleID, TRADE_ERR_BIND_INGOT, 0, {})
		matNotEnough(player, 2, 0)
		return
	end

	local newRewardID = g_LuaTaskDAO:getDailyTaskMaxReward(task:getRewardID())

	if task:getRewardID() == newRewardID then
		g_taskServlet:sendErrMsg2Client(roleID, TASK_ERR_ALREADY_MAX_STAR, 0)
		return
	end

	task:setRewardID(newRewardID)
	if player:getBindIngot() >= needBindIngot then
		player:setBindIngot(player:getBindIngot() - needBindIngot)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 4, 26, player:getBindIngot(), needBindIngot, 2)
	else
		local remainIngot = needBindIngot - player:getBindIngot()
		player:setBindIngot(0)
		costIngot(player, remainIngot, 26)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 4, 26, player:getBindIngot(), needBindIngot - remainIngot, 2)
	end
	
	--消费记录
	g_PayRecord:Record(player:getID(), -needBindIngot, CURRENCY_BINDINGOT, 27)
	roleInfo:cast2db()
	--通知升星任务目标
	g_taskMgr:NotifyListener(player, "onUpStarTask")

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.taskUpstar, 1)

	--通知客户端
	local ret = {}
	ret.rewardId = newRewardID
	fireProtoMessage(player:getID(), TASK_SC_UP_REWARD_STAR_RET, 'UpRewardStarRetProtocol', ret)

end

--获取主线任务ID
function TaskManager:getMainTaskId(roleID)
	local roleTaskInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if not roleTaskInfo then
		return 0
	end

	local mainTask = roleTaskInfo:getMainTask()

	if mainTask then
		return mainTask:getID()
	end

	return 0
end


--完成新手剧情
function TaskManager:finishStory(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	local bornPos = {{mapid=1100,x=21,y=100},{x=22,y=104},{x=21,y=102},{x=23,y=102},{x=27,y=105},{x=29,y=107},{x=26,y=104},{x=24,y=106},{x=29,y=105},{x=27,y=107},{x=30,y=108},{x=32,y=105},{x=32,y=108},{x=21,y=106},{x=31,y=103},{x=29,y=102},{x=24,y=104},{x=26,y=102},{x=25,y=108},{x=23,y=108}}
	
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
   	local rnd = math.random(20)
   	local pos = bornPos[rnd]
	if player and player:getMapID() == 1000 then
		g_sceneMgr:enterPublicScene(roleID, 1100, pos.x, pos.y)	
		--登入血量为0，临时刷新血量BUG	
		player:setHP(player:getMaxHP() - 1)
	end
end

function TaskManager:getFinishBranch(roleID)
	local roleTaskInfo = g_taskMgr:getRoleTaskInfo(roleID)

	if roleTaskInfo then
		roleTaskInfo:getFinishBranch()
	end
end

--玩家升级回调
function TaskManager:onLevelChanged(player, level, oldLevel)
	local roleInfo = self:getRoleTaskInfo(player:getID())
	
	if not roleInfo then
		return
	end

	--通知升级任务目标
	g_taskMgr:NotifyListener(player, "onLevelUp", level)
	--激活日常任务
	if level >= TASK_DAILY_ACTIVE_LEVEL and oldLevel <= TASK_DAILY_ACTIVE_LEVEL then
		if not roleInfo:getDailyTask() then
			roleInfo:freshDailyStamp()
			local dailyTaskId = g_LuaTaskDAO:getDailyTaskByLevel(level)
			g_taskServlet:receiveTask(player, TaskType.Daily, dailyTaskId, 1)
		end
	end

	--激活主线任务
	local nextTaskId = roleInfo:getCurMainTaskId()
	local taskP = g_LuaTaskDAO:getPrototype(nextTaskId)
	local acceptType = tonumber(taskP.q_start_type) or 1
	if not roleInfo:getMainTask() and acceptType == 1 and not (nextTaskId == 0) and g_taskServlet:canReceive(player, TaskType.Main, nextTaskId)then
		roleInfo:romoveMainTask(nextTaskId)
		g_taskServlet:receiveTask(player, TaskType.Main, nextTaskId)
		print('uplv auto receiveTask :', nextTaskId)
		return
	end

	self:receiveNewBranch(player)
end

--检查有可接取的支线任务就接取
function TaskManager:receiveNewBranch(player)
	--激活支线任务
	local allTaskP = g_LuaTaskDAO:getAllBranchTask()
	for id,taskP in pairs(allTaskP) do
		if g_taskServlet:canReceive(player, TaskType.Branch, id) then
			g_taskServlet:receiveTask(player,TaskType.Branch, id)
		end
	end
end

--开启某个支线链任务
function TaskManager:openBranchList(roleSID, itemID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return false
	end

	local roleInfo = self:getRoleTaskInfo(player:getID())
	
	if not roleInfo then
		return false
	end

	--如果已经开启过密令，就不能再开
	if roleInfo:hasOpenKeytask(itemID) then
		g_taskServlet:sendErrMsg2Client(player:getID(), TASK_ERR_ACCEPT_SECOND, 0)
		return false
	end

	local minLevel, taskId = g_LuaTaskDAO:getFirstBranchTask(itemID)

	if not minLevel then
		return false
	end

	if player:getLevel() < minLevel then
		g_taskServlet:sendErrMsg2Client(player:getID(), TASK_ERR_MAIN_LEVEL_NOT_ENOUGH, 0)
		return false
	end

	g_taskServlet:receiveTask(player,TaskType.Branch, taskId)
	return true
end

function TaskManager:onSwitchScene(player, mapID, lastMapId)
	g_taskMgr:NotifyListener(player, "onSwitchScene", mapID, lastMapId)
end

function TaskManager:onSwitchLine(player, lineId, lastLineID)
	g_taskMgr:NotifyListener(player, "onSwitchScene", lineId, lastLineID)
end

--杀怪通知
function TaskManager:onMonsterKill(monsterId, roleID, monID, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end

	local roleSID = player:getSerialID()
	local mapId = player:getMapID()
	local monsterDB = g_configMgr:getMonster(tonumber(monsterId))

	g_taskMgr:NotifyListener(player, "SingleKilledMonster", monID)
	--如果杀的是世界BOSS，就不走普通杀怪通知流程
	if monsterDB and monsterDB.type == 3 then
		print("boss return")
		return
	end

	if g_sharedTaskMgr:IsTreasureKeeper(monsterId) then 
		g_sharedTaskMgr:SyncTaskStatus(monsterId,monID,mapID)
		return
	end

	local hasMonKillCount = {}	--已经记过数的玩家
	local memInfo = g_TeamPublic:getMemInfoBySID(roleSID)
	if memInfo then
		local teamID = memInfo:getTeamID()
		local team = g_TeamPublic:getTeam(teamID)
		if team then
			--队友杀死的怪物可以共享
			local onMems = team:getAllMember() or {}
			for i,v in pairs(onMems) do
				if v ~= roleSID then
					table.insert(hasMonKillCount, v)
					local playerTmp = g_entityMgr:getPlayerBySID(v)
					if playerTmp and mapId==playerTmp:getMapID() then
						g_taskMgr:NotifyListener(playerTmp, "onMonsterKilled", monsterId)
					end

				end
			end
		end
	end

	--取不到队伍至少让玩家自己走任务进度
	g_taskMgr:NotifyListener(player, "onMonsterKilled", monsterId)
	table.insert(hasMonKillCount, roleSID)

	--摸过主线任务怪的人也需要计数
	local monster = g_entityMgr:getMonster(monID)
	if not monster then
		return
	end

	local touchMonsterPlayer = monster:getAttackers()
	for _, roleSID in pairs(touchMonsterPlayer) do
		if not table.contains(hasMonKillCount, roleSID) then
			local playerTmp = g_entityMgr:getPlayerBySID(roleSID)
			if playerTmp then
				g_taskMgr:NotifyListener(playerTmp, "onMonsterKilled", monsterId, 0, true)
			end
		end
	end
end

function TaskManager:onEquipDevelop(player, opType, equipId, level, param)
	if opType == 1 then
		g_taskMgr:NotifyListener(player, "onEquipStrength", equipId, level)
		local item = g_entityMgr:getConfigMgr():getItemProto(equipId)
		if level == 20 or level == 25 or level == 30 then
			local notifyId = TASK_ERR_EQUIP_STRENGTH_NOTIFY1
			if level == 25 then
				notifyId = TASK_ERR_EQUIP_STRENGTH_NOTIFY2
			elseif level == 30 then
				notifyId = TASK_ERR_EQUIP_STRENGTH_NOTIFY3
			end 

			local ret = {}
			ret.eventId = EVENT_ITEM_SETS
			ret.eCode = notifyId
			ret.mesId = g_taskServlet:getCurEventID()
			ret.param = {tostring(player:getName()),tostring(item.name)}
			boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
		end
	elseif opType == 2 then
		g_taskMgr:NotifyListener(player, "onEquipInherit")
	elseif opType == 3 then
		g_taskMgr:NotifyListener(player, "onEquipBaptize")
	elseif opType == 4 then
		g_taskMgr:NotifyListener(player, "onUpmedal")
	elseif opType == 5 then
		g_taskMgr:NotifyListener(player, "onBlessWeapon")
		if param == 1 or param == 3 then
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.LUCK, level)
		end
		if level == 7 then
			g_normalLimitMgr:sendErrMsg2Client(89, 2, {player:getName(), level})
		end
	elseif 6 == opType then	
		g_taskMgr:NotifyListener(player, "onEquipDecompose")
	elseif opType == 7 then	
		g_taskMgr:NotifyListener(player, "onCompound",equipId)
	end
end

function TaskManager.useMat(roleSID, matId, count)
	local player = g_entityMgr:getPlayerBySID(roleSID)

	if not player then
		return
	end
	g_taskMgr:NotifyListener(player, "onUseMat", matId, count)
	g_achieveSer:useMat(player, matId, count)
	g_normalMgr:useMat(player, matId, count)
end

function TaskManager.matChange(roleSID, matId)
	local player = g_entityMgr:getPlayerBySID(roleSID)

	if not player then
		return
	end
	g_taskMgr:NotifyListener(player, "onMatChange", matId)

	g_listHandler:notifyListener("onAddItem", player, matId)
end

function TaskManager.useSkill(roleSID, skillID, userID, targetID)
	AchieveServlet.useSkill(userID, targetID, skillID)

	local player = g_entityMgr:getPlayerBySID(roleSID)

	if not player then
		return
	end
	g_taskMgr:NotifyListener(player, "onUseSkill", skillID)
end

--获取玩家的目标事件观察器
function TaskManager:GetTaskEventHandler(roleID)
	local roleInfo = self:getRoleTaskInfo(roleID)
	if not roleInfo then
		return
	end
	return roleInfo:getTaskEventSet()
end

--通知观察该事件的任务目标
function TaskManager:NotifyListener(player, eventName, ...)
	if not player then return end
	local eventHandler = self:GetTaskEventHandler(player:getID())
	if eventHandler then
		eventHandler:notifyWatchers(eventName, player, ...)
	end
	
	--行会公共任务
	g_factionMgr:NotifyListener(player, eventName, ...)
end

--获取玩家数据
function TaskManager:getRoleTaskInfo(roleID)
	return self._roleTaskInfos[roleID]
end

--获取玩家数据通过数据库ID
function TaskManager:getRoleTaskInfoBySID(roleSID)
	return self._roleTaskInfoBySID[roleSID]
end

function TaskManager:parseTaskData()
	package.loaded["data.TaskDB"]=nil
	local tmpData = require "data.TaskDB"
	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if g_LuaTaskDAO._staticTasks[data.q_taskid] then
				table.deepCopy1(data, g_LuaTaskDAO._staticTasks[task:getID()])
			else
				g_LuaTaskDAO._staticTasks[data.q_taskid] = data
			end
		end
	end
end


function TaskManager:parseDailyTaskData()
	package.loaded["data.DailyTaskDB"]=nil
	package.loaded["data.DailyTaskRewardDB"]=nil
	package.loaded["data.DailyTotalRewardDB"]=nil

	local tmpData = require "data.DailyTaskDB"
	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if g_LuaTaskDAO._dailyTaskDBs[data.q_taskid] then
				table.deepCopy1(data, g_LuaTaskDAO._dailyTaskDBs[data.q_taskid])
			else
				g_LuaTaskDAO._dailyTaskDBs[data.q_taskid] = data
			end
		end
	end

	tmpData = require "data.DailyTaskRewardDB"
	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if g_LuaTaskDAO._dailyRewardDBs[data.q_id] then
				table.deepCopy1(data, g_LuaTaskDAO._dailyRewardDBs[data.q_id])
			else
				g_LuaTaskDAO._dailyRewardDBs[data.q_id] = data
			end
		end
	end

	tmpData = require "data.DailyTotalRewardDB"
	if tmpData then
		g_LuaTaskDAO._dailyTotalRewardDBs = {}
		for i=1, #tmpData do
			local data = tmpData[i]
			table.insert(g_LuaTaskDAO._dailyTotalRewardDBs, data)
		end
	end
end


-- 悬赏任务20160106
function TaskManager:parseRewardTaskData()
	package.loaded["data.RewardTaskDB"]=nil
	local tmpData = require "data.RewardTaskDB"
	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if g_LuaTaskDAO._rewardTaskDBs[data.q_taskid] then
				table.deepCopy1(data, g_LuaTaskDAO._rewardTaskDBs[data.q_taskid])
			else
				g_LuaTaskDAO._rewardTaskDBs[data.q_taskid] = data
			end
		end
	end
end

--是否开启了系统
function TaskManager:canUseFun(player, fcunId)
	local roleInfo = self:getRoleTaskInfoBySID(player:getSerialID()) 
	if not roleInfo then
		return false
	end
	local mainTaskId = roleInfo:getCurMainTaskId()

	local relationTaskId = 0
	if mainTaskId then
		relationTaskId =  mainTaskId - 1
	else
		local task = roleInfo:getMainTask()
		if task then
			relationTaskId = task:getID()
		end
	end

	if relationTaskId >= g_configMgr:getNewFuncLevel(fcunId) then
		return true
	end
	return false
end

--设置玩家单人杀怪数据通过玩家ID
function TaskManager:setMonsterInfo(roleId, monId)
	self._roleMonsterInfo[roleId] = {}
	self._roleMonsterInfo[roleId].monId = monId
end

--获取玩家单人杀怪数据通过玩家ID
function TaskManager:getMonsterInfoByRoleId(roleId)
	return self._roleMonsterInfo[roleId]
end

--删除玩家单人杀怪数据通过玩家ID
function TaskManager:delMonsterInfoByRoleId(roleId)
	self._roleMonsterInfo[roleId] = nil
end

--设置玩家个人护送数据通过玩家ID
function TaskManager:setPersonalEscortInfo(roleId, id)
	self._rolePersonalEscortInfo[roleId] = {}
	self._rolePersonalEscortInfo[roleId].id = id
end

--获取玩家个人护送数据通过玩家ID
function TaskManager:getPersonalEscortInfoByRoleId(roleId)
	return self._rolePersonalEscortInfo[roleId]
end

--删除玩家个人护送数据通过玩家ID
function TaskManager:delPersonalEscortInfoByRoleId(roleId)
	self._rolePersonalEscortInfo[roleId] = nil
end

function TaskManager.getInstance()
	return TaskManager()
end

g_taskMgr = TaskManager.getInstance()