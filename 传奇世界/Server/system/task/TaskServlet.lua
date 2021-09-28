--TaskServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  TaskServlet.lua
 --* Author:  seezon
 --* Modified: 2014年4月8日
 --* Purpose: 任务消息接口
 -------------------------------------------------------------------*/

TaskServlet = class(EventSetDoer, Singleton)

function TaskServlet:__init()
	self._doer = {
			[TASK_CS_PICK_UP] =			TaskServlet.doPickUpMat,
			[TASK_CS_YUANBAO_FINISH_DAILY_TASK] =	TaskServlet.doFinishDailyTask,
			[TASK_CS_UP_REWARD_STAR] =		TaskServlet.doUpRewardStar,
			[TASK_CS_FINISHSTORY] =			TaskServlet.doFinishStroy,
			[TASK_CS_GET_FINISH_BRANCH] = TaskServlet.doGetFinishBranch,
			[TASK_CS_DEALLOADING] = TaskServlet.doDealLoading,
			[TASK_CS_PICK_DAILY_REWARD] = TaskServlet.doPickDailyReward,
-- 悬赏任务20160106
			[TASK_CS_REWARDTASK_REQ] = TaskServlet.doRewardTaskReq,	
--单人杀怪任务
			[TASK_CS_REQ_FRESH_MONSTER_TASK] = TaskServlet.doFreshMonsterTaskReq,
			[TASK_CS_REQ_USE_GOT_TASK] = TaskServlet.doUseGotTaskReq,
			[TASK_CS_START_PICK] = TaskServlet.doStartPick,
}	

	self._pickMatCD = {}
end

--玩家开始采集
function TaskServlet:doStartPick(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("TaskStartPickProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doStartPick '..tostring(err))
		return
	end

	local roleID = dbid
	local matID = req.matID


	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then
		return
	end

	local scene = g_sceneMgr:getPublicScene(player:getMapID())
	if scene then
		local ret= {}
		ret.actionRoleID = player:getID()
		ret.matID = matID

		boardSceneProtoMessage(scene:getID(), TASK_SC_NOTIFY_PICK_ACTION, 'TaskNotifyPickActionProtocol', ret)
	end
end

--玩家客户端采集物品通知
function TaskServlet:doPickUpMat(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("PickUpProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doPickUpMat '..tostring(err))
		return
	end

	local roleID = dbid
	local matID = req.matID

	local pickCd = self._pickMatCD[roleID]
	if pickCd then
		if os.time() - pickCd < 2 then
			return
		end
	end


	self._pickMatCD[roleID] = os.time()

	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then
		return
	end
	
	local teamId = player:getTeamID()

	local team = g_TeamPublic:getTeam(teamId)
	--取不到队伍至少让玩家自己走任务进度
	if team then
		local teamMember = team:getOnLineMems()
		local mapId = player:getMapID()
		--队友采集可以共享
		for _,memberId in pairs(teamMember) do
			if not (player:getSerialID() == memberId) then
				local member = g_entityMgr:getPlayerBySID(memberId)
				if member and mapId == member:getMapID() then
					g_taskMgr:NotifyListener(member, "onMatChanged", matID)
				end
			end
		end
	end

	g_taskMgr:NotifyListener(player, "onMatChanged", matID)
end

--完成新手剧情
function TaskServlet:doFinishStroy(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("FinishStoryProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doFinishStroy '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	g_taskMgr:finishStory(player:getID())
end

--获取已经完成的支线任务
function TaskServlet:doGetFinishBranch(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetFinishBranchProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doGetFinishBranch '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	g_taskMgr:getFinishBranch(player:getID())
end

--处理服务器加载任务数据失败的异常情况
function TaskServlet:doDealLoading(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("DealLoadingProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doDealLoading '..tostring(err))
		return
	end

	local roleID = dbid
	local taskID = req.taskID

	local player = g_entityMgr:getPlayerBySID(roleID)
	if player and not g_taskMgr:checkMainTask(player)then
		print("数据库任务丢失，客户端加载任务", player:getSerialID(), taskID)
		self:receiveTask(player,TaskType.Main, taskId)
	end
end

--领取日常任务奖励s
function TaskServlet:doPickDailyReward(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("PickDailyRewardProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doPickDailyReward '..tostring(err))
		return
	end

	local roleID = dbid
	local loop = req.curLoop

	local player = g_entityMgr:getPlayerBySID(roleID)
	g_taskMgr:pickDailyReward(player:getID(), loop)
end

--玩家花元宝直接完成日常任务
function TaskServlet:doFinishDailyTask(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("YuanbaoFinishDailyTaskProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doFinishDailyTask '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	local finishType = req.finishType
	
	g_taskMgr:finishDailyTask(player:getID(), finishType)
end

--日常任务奖励升星级
function TaskServlet:doUpRewardStar(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("UpRewardStarProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doUpRewardStar '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	g_taskMgr:upRewardStar(player:getID())
end

--完成任务逻辑
function TaskServlet:GMfinishTask(role, taskType)
	local roleID = role:getID()
	local roleTaskInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if not roleTaskInfo then
		return
	end
	
	if taskType == 1 then
		local task = roleTaskInfo:getMainTask()
		if task then
			self:finishTask(role:getID(), task)
		end
	elseif taskType == 2 then
		local task = roleTaskInfo:getDailyTask()
		if task then
			self:finishTask(role:getID(), task)
		end
	elseif taskType == 3 then
		local tasks = roleTaskInfo:getAllBranchTask()
		for i, v in pairs(tasks) do
			self:finishTask(role:getID(), v)
		end
	elseif taskType == 4 then
		return
	elseif taskType == 5 then
		g_RewardTaskMgr:finish(true, role:getSerialID())
	end
end

--完成任务逻辑
function TaskServlet:finishTask(roleID, task,byIngot)
	local pushReward = self:rewardTask(roleID, task,byIngot)
	local player = g_entityMgr:getPlayer(roleID)
	if not pushReward then
		--print("奖励失败，任务无法完成~")
		return
	end

	local roleTaskInfo = g_taskMgr:getRoleTaskInfo(roleID)
	if not roleTaskInfo then
		return
	end

	
	--改变状态为finish，做最后的处理
	task:statusChanged(TaskStatus.Finished)
	self:writeTaskRecord(roleID, task, 1)
	if task:getType() == TaskType.Daily then
		g_normalMgr:activeness(player:getID(),ACTIVENESS_TYPE.ZHAOLIN)
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.ZHAOLIN, 1)
		g_ActivityMgr:OnTask(player:getID(), task:getID(), TaskType.Daily, g_LuaTaskDAO:getDailyRewardStar(task:getRewardID()))
	end
end

--解析物品奖励
function TaskServlet:parseMatReward(str)
	local rewards = {}
	local rewardStr = StrSplit(str, ";")
	for _, v in pairs(rewardStr) do
		local reward = {}
		
		local tgStr = StrSplit(v, "_")

		reward.ID = tonumber(tgStr[1])
		reward.count = tonumber(tgStr[2]) or 0
		reward.school = tonumber(tgStr[3]) or 0
		reward.sex = tonumber(tgStr[4]) or 0
		reward.strength = tonumber(tgStr[5]) or 0

		table.insert(rewards, reward)
	end

	return rewards
end



--给玩家任务奖励
function TaskServlet:rewardTask(roleID, task,byIngot)
	local taskId = task:getID()
	local player = g_entityMgr:getPlayer(roleID)

	local rewardData = g_LuaTaskDAO:getPrototype(taskId)
	if task:getType() == TaskType.Daily then
		local rewardId = task:getRewardID()
		rewardData = g_LuaTaskDAO:getDailyReward(rewardId)
	elseif task:getType() == TaskType.Branch then
		rewardData = g_LuaTaskDAO:getBranchTaskByID(taskId)
-- 悬赏任务20160106
	elseif task:getType() == TaskType.Reward then
		rewardData = g_LuaTaskDAO:getRewardTask(taskId)
	elseif task:getType() == TaskType.Shared then
		rewardData = g_LuaTaskDAO:getSharedTask(taskId)
	end

	if not rewardData then
		print("取数据原型失败~", taskId)
		return false
	end

	--先验证奖励是否能给
	local canReward, errId = self:verifyReward(player, rewardData)
	if not canReward then
		self:sendErrMsg2Client(roleID, errId, 0)
		return false
	end
	self:doReward(player, rewardData, task:getType(),100,byIngot, taskId,0,false)

	--额外奖励
	if task:getType() == TaskType.Daily then
		--如果是最后一环需要给额外奖励
		local roleInfo = g_taskMgr:getRoleTaskInfo(roleID)
		if not roleInfo then
			return
		end

		if task:getCurrentLoop() == roleInfo:getMaxDailyLoop() then
			local totalRewardProto = g_LuaTaskDAO:getDailyTotalRewardByLevel(player:getLevel())
			self:doReward(player, totalRewardProto, task:getType(), 100,false, taskId,0,true)
		end
	end

	return true
end

--验证能不能奖励
function TaskServlet:verifyReward(player, rewardData)
	return true
end

function TaskServlet:getRewardAddRate(roleID, taskID, taskType, taskLevel)
	--print("333333333333333333333333:", taskType, ":", taskID, ":", taskLevel)
	local rate = g_ActivityMgr:GetTaskYieldRate(roleID, taskID, taskType, taskLevel)
	if not rate or 0 == rate then
		return 1
	end
	return rate
end

--奖励统一接口
-- 悬赏任务20160106 新增获取奖励百分比，目前不支持物品
function TaskServlet:doReward(player, rewardData, taskType, percent,byIngot, taskID, taskLevel,isExtra)
	if not player then
		return
	end
	--print("111111111111111111111111111111:", taskType, ":", taskID, ":", taskLevel)
	local addRewardRate = 1
	local logMoneyTaskType = 6
	if taskType == TaskType.Daily then
		logMoneyTaskType = 8
		addRewardRate = self:getRewardAddRate(player:getID(), taskID, taskType);
	elseif taskType == TaskType.Branch then
		logMoneyTaskType = 7
	elseif taskType == TaskType.Reward then
		--print("2222222222222222222222222222222:", taskType, ":", taskID, ":", taskLevel)
		logMoneyTaskType = 9
		addRewardRate = self:getRewardAddRate(player:getID(), taskID, taskType, taskLevel);
	elseif taskType == TaskType.Shared then
		logMoneyTaskType = 10
	end

	percent = percent or 100

	--奖励经验
	local xp = rewardData.q_rewards_exp

	if xp then
		xp = xp * percent / 100 * addRewardRate
		if taskType == TaskType.Daily then
			print("configed exp,",xp,addRewardRate)
			local roleTaskInfo = g_taskMgr:getRoleTaskInfo(player:getID())
			if roleTaskInfo then
				if roleTaskInfo:getDailyTaskLoop()<=#TASK_DAILY_PRIZE_RATE and not isExtra then
					xp = xp*TASK_DAILY_PRIZE_RATE[roleTaskInfo:getDailyTaskLoop()]
					print("after rated exp,",xp,TASK_DAILY_PRIZE_RATE[roleTaskInfo:getDailyTaskLoop()])
				else
					xp = xp
				end
			end
		end
		--player:setXP(player:getXP() + xp)
		--Tlog[PlayerExpFlow]
		addExpToPlayer(player,xp,logMoneyTaskType)
		if taskType == TaskType.Reward then
			local ret = {}
			ret.type = 0
			ret.value = xp
			fireProtoMessage(player:getID(), FRAME_SC_PICKUP, 'FramePickUpRetProtocol', ret)
		end
	end
	local logTb = {}
	--奖励铜钱
	local money = rewardData.q_rewards_coin
	if money then
		money = money * percent / 100 * addRewardRate
		player:setMoney(player:getMoney() + money)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 1, logMoneyTaskType, player:getMoney(), money, 1)
		if byIngot==1 and taskType == TaskType.Daily then
			g_taskServlet:sendErrMsg2Client(player:getID(), -87, 3,{money,xp,TASK_DAILY_FINISH_BY_INGOT_EXP})
		else
			g_taskServlet:sendErrMsg2Client(player:getID(), TASK_ERR_REWARD_NOTIFY, 2, {money, xp})
		end
	end

	--任务奖励真气
	local vital = rewardData.q_rewards_zq
	if vital then
		vital = vital * percent / 100 * addRewardRate
		player:setVital(player:getVital() + vital)

		local ret = {}
		ret.type = 3
		ret.value = vital
		fireProtoMessage(player:getID(), FRAME_SC_PICKUP, 'FramePickUpRetProtocol', ret)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 5, logMoneyTaskType, player:getVital(),vital, 1)
	end
	--奖励功勋

	--奖励声望
	
	--奖励绑定元宝
	local bindIngot = rewardData.q_rewards_bindYuanBao
	if bindIngot then
		bindIngot = bindIngot * percent / 100 * addRewardRate
		player:setBindIngot(player:getBindIngot() + bindIngot)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 4, logMoneyTaskType, player:getBindIngot(), bindIngot, 1)
	end

	--奖励物品
    local matStr = rewardData.q_rewards_goods
	local matInfo = self:parseMatReward(matStr)
	local school = player:getSchool()
	local sex = player:getSex()
   	local errId = 0
   	local itemMgr = player:getItemMgr()
   	local offlineMgr = g_entityMgr:getOfflineMgr()
	for _,v in pairs(matInfo or {}) do
		if (v.school == 0 or school == v.school) and (v.sex ==0 or sex == v.sex) then
			local needSolt = itemMgr:putNeedSlot(v.ID, v.count * addRewardRate)
			local freeSlotNum = itemMgr:getEmptySize()
			local itemMgr = player:getItemMgr()
			--如果物品格子数不够就发邮件
			if freeSlotNum < needSolt then
				local email = offlineMgr:createEamil()
				local emailConfigId = 32
	
				email:setDescId(emailConfigId)						
				email:insertProto(v.ID, v.count * addRewardRate, false, v.strength)
				offlineMgr:recvEamil(player:getSerialID(), email, 0)
			else
				itemMgr:addItem(1, v.ID, v.count * addRewardRate, true, errId, 0, v.strength, 0, true)
				g_logManager:writePropChange(player:getSerialID(), 1 ,logMoneyTaskType, v.ID, 0, v.count * addRewardRate, 0)
			end
		end
	end

	--记录王城诏令普通和完美完成流水
	if taskType == TaskType.Daily then
		local roleTaskInfo = g_taskMgr:getRoleTaskInfo(player:getID())
		if roleTaskInfo then
			local dailyTask = roleTaskInfo:getDailyTask()
			local logType = 1
			if byIngot==1 then
				logType = 2
			end

			g_tlogMgr:TlogWCZLFlow(player, dailyTask:getCurrentLoop(), tonumber(rewardData.q_starLevel), logType, xp)
		end
	end

	return true,money,xp
end

--判断是否能接某个任务
function TaskServlet:canReceive(player, taskType, taskID)
	if taskType == TaskType.Main then
		local taskP = g_LuaTaskDAO:getPrototype(taskID)

		if not taskP then
			return false
		end
		--判断玩家是否达到接任务的最低等级
		local acceptTaskLevel = taskP.q_accept_needmingrade
		if acceptTaskLevel and player:getLevel() < acceptTaskLevel then
			return false
		end
	elseif taskType == TaskType.Branch then
		local taskP = g_LuaTaskDAO:getBranchTaskByID(taskID)
		if not taskP then
			return false
		end
	
		--过滤掉正在进行和已经完成过的支线任务
		local roleTaskInfo = g_taskMgr:getRoleTaskInfo(player:getID())
		if roleTaskInfo:getBranchTask(taskID) or roleTaskInfo:isFinishBrachID(taskID) then
			return false
		end

		--判断玩家是否达到接任务的最低等级
		local acceptTaskLevel = tonumber(taskP.q_accept_needmingrade)
		if acceptTaskLevel and player:getLevel() < acceptTaskLevel then
			--print(string.format("玩家%s不能接受ID为 %s的任务，等级不够\n",player:getName(), taskID))
			return false
		end

		local pre_taskId = tonumber(taskP.q_pre_taskId) or 0
		--如果有前置任务
		if pre_taskId > 0 then
			if not roleTaskInfo:isFinishBrachID(pre_taskId) then
				return false
			end
		end

		--如果是密令任务必须要开启过
		if tonumber(taskP.q_type) == 1 and not roleTaskInfo:hasOpenKeytask(tonumber(taskP.q_item)) then
			return false
		end
	end

	return true
end

--接受一个任务
function TaskServlet:receiveTask(player, taskType, taskID, loop,owner)
	if not taskID or not player then
		print("接受任务错误", player, taskType, taskID, loop, debug.traceback())
		return
	end
	local task = g_LuaTaskDAO:loadTask(player, taskID, taskType)
	

	--print(string.format("玩家%s接受一个任务ID为 %s的任务\n", player:getSerialID(), task:getID()))

	local roleInfo = g_taskMgr:getRoleTaskInfo(player:getID())

	if task and roleInfo then
		task:initTargets()
		if task:getType() == TaskType.Main then
			if self:rewardAccept(player, task) then
				roleInfo:setMainTask(task)
				--增加主线任务任务，通知客户端
				local targetState = task:getTargetStates()
				local taskP = g_LuaTaskDAO:getPrototype(taskID)
				local chapter = taskP.q_chapter
				local ret = {}
				ret.taskID = task:getID()
				ret.isNew = 1
				ret.chapter = chapter
				ret.targetState = targetState

				fireProtoMessage(player:getID(), TASK_SC_ADD_TASK, 'AddTaskProtocol', ret)
				--验证下任务
				task:validate()
			end
		elseif task:getType() == TaskType.Daily then
			if roleInfo:getDailyTask() then
				roleInfo:romoveDailyTask()
			end

			--随机一个奖励Id
			local rewardId = g_LuaTaskDAO:getDailyTaskRewardByLevel(player:getLevel(),loop)
			task:setRewardID(rewardId)
			task:setCurrentLoop(loop)
			roleInfo:setDailyTask(task)

			local targetState = task:getTargetStates()
			local needFinishIngot,needAllIngot = g_taskMgr:CalFinishTaskByIngot(roleInfo)
			local ret = {}
			ret.taskID = task:getID()
			ret.isNew = 1
			ret.curloop = loop
			ret.rewardId = task:getRewardID()
			ret.targetState = targetState
			ret.needFinishIngot = needFinishIngot
			ret.needAllIngot = needAllIngot
			ret.etrXp = TASK_DAILY_FINISH_BY_INGOT_EXP
			fireProtoMessage(player:getID(), TASK_SC_ADD_DAILY_TASK, 'AddDailyTaskProtocol', ret)
			--验证下任务
			task:validate()
		elseif task:getType() == TaskType.Branch then
			if roleInfo:getBranchTask(task:getID()) then
				return
			end
			roleInfo:addBranchTask(task)
			local ret = {}
			ret.taskID = task:getID()
			ret.targetState = task:getTargetStates()
			fireProtoMessage(player:getID(), TASK_SC_ADD_BRANCH_TASK, 'AddBranchProtocol', ret)

			task:validate()
-- 悬赏任务20160106
		elseif task:getType() == TaskType.Reward then
			if roleInfo:getRewardTask() then
				roleInfo:romoveRewardTask()
			end
			roleInfo:setRewardTask(task)
			--验证下任务
			task:validate()

			local ret = {}
			ret.taskID = task:getID()
			ret.isNew = 1
			ret.taskGUID = roleInfo:getRewardTaskGUID()
			ret.guardExpiredTime = 0
			local guardExpiredTime = roleInfo:getRewardTaskGuardTime()
			local expiredTime = guardExpiredTime - os.time()
			if expiredTime > 0 then
				ret.guardExpiredTime = expiredTime
			end	
			local targertData = task:getTargetStates()
			local targetNum = table.size(targertData)
			ret.targetNum = targetNum
			ret.targetStates = {}
			for i = 1, targetNum  do
				table.insert(ret.targetStates, targertData[i])
			end
			fireProtoMessage(player:getID(), TASK_SC_ADD_REWARD_TASK, 'AddRewardTaskRet', ret)

			-- local targetState = task:getTargetStates()
			-- local retBuffer = SCADDREWARDTASK.writeFun(task:getID(), 1, roleInfo:getRewardTaskGUID(), targetState)
			-- g_engine:fireLuaEvent(player:getID(), retBuffer)
		elseif task:getType() == TaskType.Shared then
			if roleInfo:getSharedTask() then
				roleInfo:removeSharedTask()
			end
			roleInfo:setSharedTask(task)
			if owner == 1 then
				roleInfo:setTaskOwner()
			end
			--验证下任务
			task:validate()
			local targetState = task:getTargetStates()
			local retBuff = SCADDSHAREDTASK.writeFun(task:getID(),targetState,owner,roleInfo:getSharedTaskTargetPos())
			fireProtoMessage(player:getID(), TASK_SC_ADD_SHARED_TASK, 'AddSharedTaskProtocol', retBuff)
		end
	else
		print("任务构造失败")
		return
	end
	return task
end

function TaskServlet:rewardAccept(player, task)
	local taskP = g_LuaTaskDAO:getPrototype(task:getID())
	--奖励物品
	if not taskP.q_accept_rewards_goods then
		return true
	end
    local matStr = taskP.q_accept_rewards_goods
	local matInfo = self:parseMatReward(matStr)
	local school = player:getSchool()
	local sex = player:getSex()
   	local errId = 0
   	local itemMgr = player:getItemMgr()
   	local offlineMgr = g_entityMgr:getOfflineMgr()
	local freeSlotNum = itemMgr:getEmptySize()
	local totalNeedSolt = 0
	for _,v in pairs(matInfo or {}) do
		if (v.school == 0 or school == v.school) and (v.sex ==0 or sex == v.sex) then
			totalNeedSolt = totalNeedSolt + itemMgr:putNeedSlot(v.ID, v.count)
		end
	end

	if freeSlotNum < totalNeedSolt then
		self:sendErrMsg2Client(player:getID(), TASK_ERR_ACCEPT, 0)
		return false
	end

	for _,v in pairs(matInfo or {}) do
		if (v.school == 0 or school == v.school) and (v.sex ==0 or sex == v.sex) then
			itemMgr:addItem(1, v.ID, v.count, true, errId, 0, v.strength, 0, true)
		end
	end

	return true
end

--写任务状态日志
function TaskServlet:writeTaskRecord(roleID, task, nTaskEndState)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local taskID = task:getID()
	local taskName = "null"
	local taskType = task:getType()
	local star = 0
	local taskP = g_LuaTaskDAO:getPrototype(taskID)
	if taskType == TaskType.Daily then
		taskP = g_LuaTaskDAO:getDailyTask(taskID)
		local rewardP = g_LuaTaskDAO:getDailyReward(task:getRewardID())
		if rewardP then
			star = tonumber(rewardP.q_starLevel)
		end
	elseif taskType == TaskType.Branch then
		taskP = g_LuaTaskDAO:getBranchTaskByID(taskID)
-- 悬赏任务20160106		
	elseif taskType == TaskType.Reward then
		taskP = g_LuaTaskDAO:getRewardTask(taskID)
	elseif taskType == TaskType.Shared then
		taskP = g_LuaTaskDAO:getSharedTask(taskID)
	end
	taskName = taskP.q_name
	g_logManager:writeTaskInfo(player:getSerialID(), taskType, taskID, taskName, 0, nTaskEndState, star)
end

--给客户端发送错误提示的接口
function TaskServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_TASK_SETS, errId, paramCount, params)
end

function TaskServlet:onDoerActive()
	TASK_OPEN_FALG = true
end

function TaskServlet:onDoerClose()
	TASK_OPEN_FALG = false
end

-- 悬赏任务20160106
function TaskServlet:doRewardTaskReq(event)	
	g_RewardTaskMgr:doRewardTaskReq(event)
end

--单人杀怪任务
function TaskServlet:doFreshMonsterTaskReq(event)	
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("RequestFreshMonsterTaskProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doFreshMonsterTaskReq '..tostring(err))
		return
	end
	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then
		return
	end
	g_taskMgr:NotifyListener(player, "SingleKillMonsterFreshBoss")
end

--使用道具任务
function TaskServlet:doUseGotTaskReq(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("RequestUseGotTaskProtocol" , pbc_string)
	if not req then
		print('TaskServlet::doUseGotTaskReq '..tostring(err))
		return
	end
	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then
		return
	end
	local taskType = req.taskType or 0
	if taskType == TARGET_ID_NPCUSEGOT then
		g_taskMgr:NotifyListener(player, "onNPCUseGot")
	elseif taskType == TARGET_ID_MONSTERUSEGOT then
		g_taskMgr:NotifyListener(player, "onMonsterUseGot")
	end
end

function TaskServlet.getInstance()
	return TaskServlet()
end


g_eventMgr:addEventListener(TaskServlet.getInstance())