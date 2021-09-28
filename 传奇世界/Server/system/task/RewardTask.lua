--RewardTask.lua
--/*-----------------------------------------------------------------
 --* Module:  RewardTask.lua
 --* Author:  gongyingqi
 --* Modified: 2016Äê1ÔÂ5ÈÕ
 --* Purpose: ÐüÉÍÈÎÎñ
 -------------------------------------------------------------------*/
--]]

ANNREWARDTASKMAXNUM = 5 --发布普通悬赏任务
ANN_SUPER_REWARDTASK_MAXNUM = 1 	--发布至尊悬赏任务
ACCREWARDTASKMAXNUM = 5 --接受普通悬赏任务
ACC_SUPER_REWARDTASK_MAXNUM = 1 	--接取至尊悬赏任务

ANNREWARDTASK_LEVEL_MIN = 28 --发布最小等级
ACCREWARDTASK_LEVEL_MIN = 28 --接取最小等级

SELECTPAGENUM = 50			--没类任务最多接取数量
SELECT_CD_TIME = 30 		--任务查询时间

REWARDTASK_RANK_BLUE = 1		--普通悬赏任务
REWARDTASK_RANK_PURPLE = 2	--高级悬赏任务
REWARDTASK_RANK_SUPER = 3 	--至尊悬赏任务

CREATEREWARDTASKITEM = {}
CREATEREWARDTASKITEM[REWARDTASK_RANK_PURPLE] = 9008
CREATEREWARDTASKITEM[REWARDTASK_RANK_SUPER] = 9009

REWARDTASK_RANK_BLUE_COST_MONEY = 10000 	--普通任务发布消耗金币数量
--message id
CREATE_REWARDTASK_NOT_ENOUGH = {}
CREATE_REWARDTASK_NOT_ENOUGH[REWARDTASK_RANK_BLUE] = -62
CREATE_REWARDTASK_NOT_ENOUGH[REWARDTASK_RANK_PURPLE] = -63
CREATE_REWARDTASK_NOT_ENOUGH[REWARDTASK_RANK_SUPER] = -91

EXPIREREWARDPERCENT = 200 --过期倍率
DELETEREWARDPERCENT = 200	--完成倍率

REWARD_NPC_OPT_DISTANCE = 100

REWARDTASK_GUARD_TIME = 600	--任务接取保护时间

--系统发布任务相关
REWARDTASK_SYSTEM_CREATE_BLUE_NUM = 20
REWARDTASK_SYSTEM_CREATE_PURPLE_NUM = 10
REWARDTASK_SYSTEM_CREATE_SUPER_NUM = 1

REWARDTASK_SYSTEM_TIME = {12,18}	--任务发布时间点
REWARDTASK_SYSTEM_BROADCAST_TIME = 5 --前五分钟预告
REWARDTASK_SYSTEM_BROADCAST_COUNT = 3
REWARDTASK_SYSTEM_DISPLAYE_NAME = "系统"

--引导悬赏相关
REWARDTASK_CREATE_EVENTID = 34
REWARDTASK_RECEIVE_EVENTID = 35
REWARDTASK_FINISH_EVENTID = 36
REWARDTASK_DELETE_EVENTID = 60

REWARDTASK_RECEIVE_ID = 31009	--接取指定悬赏任务


--一个发布悬赏任务
AnnRewardTaskInfo = class()
local prop = Property(AnnRewardTaskInfo)
prop:accessor("TaskGUID")
prop:accessor("ExpireTime")
prop:accessor("Status")
prop:accessor("TaskRank")
prop:accessor("TaskID")
prop:accessor('ReceiveNum')

function AnnRewardTaskInfo:__init(taskGUID, expireTime, status, taskRank, taskID, receiveNum)
	prop(self, "TaskGUID", tonumber(taskGUID))
	prop(self, "ExpireTime", tonumber(expireTime))
	prop(self, "Status", tonumber(status))
	prop(self, "TaskRank", tonumber(taskRank))
	prop(self, "TaskID", tonumber(taskID))
	prop(self, "ReceiveNum", tonumber(receiveNum))
end

--发布悬赏任务
AnnRewardTaskInfos = class()

local prop = Property(AnnRewardTaskInfos)
prop:accessor("roleID")

function AnnRewardTaskInfos:__init()
	self.Tasks = {} 
end

function AnnRewardTaskInfos:loadTaskData(tb)
	if (#tb) % 6 ~= 0 then
		return
	end

		taskcount = (#tb) / 6

	--ÖðÌõ¶ÁÈ¡
	local taskGUID = 0
	for i=0, taskcount-1 do
		taskGUID = tonumber(tb[i*6+1])
		self.Tasks[taskGUID] = AnnRewardTaskInfo(tb[i*6+1],tb[i*6+2],tb[i*6+3],tb[i*6+4],tb[i*6+5],tb[i*6+6])
		--print(self.Tasks[taskGUID]:getTaskGUID(), self.Tasks[taskGUID]:getExpireTime(), self.Tasks[taskGUID]:getStatus(), self.Tasks[taskGUID]:getTaskRank(), self.Tasks[taskGUID]:getTaskID())
	end
end

function AnnRewardTaskInfos:checkExpireDateOrPrizeStatus()
	local timeNow = os.time()
	for _, task in pairs(self.Tasks or {}) do
		if task:getExpireTime() < timeNow then
			return true 
		elseif task:getStatus() == 1 then
			return true
		end
	end
	return false
end

function AnnRewardTaskInfos:checkDelete(taskGUID)
	local timeNow = os.time()
	
	local task = self.Tasks[taskGUID]
	if task == nil then
		return false, 0
	end
	
	if task:getExpireTime() < timeNow then
		return true, task:getTaskID()
	end
	
	if task:getStatus() == 1 then
		return true, task:getTaskID()
	end
	
	return false, 0
end

function AnnRewardTaskInfos:buildMsg(retBuff)
	local taskNum = table.size(self.Tasks)
	retBuff:pushChar(taskNum)
	
	
	local timeNow = os.time()
	
	for _, task in pairs(self.Tasks or {}) do
		retBuff:pushInt(task:getTaskGUID())
		retBuff:pushInt(task:getExpireTime() - timeNow)
		retBuff:pushInt(task:getStatus())
		retBuff:pushInt(task:getTaskRank())
		retBuff:pushInt(task:getTaskID())
		retBuff:pushInt(task:getReceiveNum())
	end
end

--一个接取悬赏任务
AccRewardTaskInfo = class()
local prop = Property(AccRewardTaskInfo)
prop:accessor("TaskGUID")
prop:accessor("OwnerName")
prop:accessor("ExpireTime")
prop:accessor("TaskRank")
prop:accessor("TaskID")
prop:accessor("ReceiveNum")
prop:accessor("OwnerGUID")
prop:accessor("ReceiveStatus")
prop:accessor("ReceiveTime")

function AccRewardTaskInfo:__init(taskGUID, ownerName, expireTime, taskRank, taskID, receiveNum, ownerGUID, receiveStatus, receiveTime)
	prop(self, "TaskGUID", tonumber(taskGUID))
	prop(self, "OwnerName", ownerName)
	prop(self, "ExpireTime", tonumber(expireTime))
	prop(self, "TaskRank",tonumber( taskRank))
	prop(self, "TaskID", tonumber(taskID))
	prop(self, "ReceiveNum", tonumber(receiveNum))
	prop(self, "OwnerGUID", tostring(ownerGUID))
	prop(self, "ReceiveStatus", tonumber(receiveStatus))
	prop(self, "ReceiveTime", tonumber(receiveTime))	--保护到期时间（接取的10分钟后）
end

--接取悬赏任务
AccRewardTaskInfos = class()

local prop = Property(AccRewardTaskInfos)

function AccRewardTaskInfos:__init()
	self.Tasks = {} 
	self:initTask()
end

function AccRewardTaskInfos:initTask()
	self.Tasks[REWARDTASK_RANK_BLUE] = {}
	self.Tasks[REWARDTASK_RANK_PURPLE] = {}
	self.Tasks[REWARDTASK_RANK_SUPER] = {}
end

function AccRewardTaskInfos:loadTaskData(luaBuf, isInit)	--isInit：是否为初始化内存reward task data
	local buff = tolua.cast(luaBuf, "LuaMsgBuffer")
	num = buff:popInt()
	print('get task num: '..num)

	local blueIdx = 1
	local purpleIdx = 1
	local superIdx = 1
	local now = os.time()
	for i = 1, num do
		taskguid = buff:popInt()
		ownername = buff:popString()
		expiretime = buff:popInt()
		taskrank = buff:popInt()
		taskid = buff:popInt()
		receiveNum = buff:popInt()
		ownerGUID = buff:popString()
		receiveStatus = buff:popInt()
		receiveTime = buff:popInt()
		if not isInit then
			if receiveNum > 0 and receiveTime > now then
				--do nothing
			else
				local idx = 0
				if taskrank == REWARDTASK_RANK_BLUE then
					idx = blueIdx
					blueIdx = blueIdx + 1
				elseif taskrank == REWARDTASK_RANK_PURPLE then
					idx = purpleIdx
					purpleIdx = purpleIdx + 1
				else
					idx = superIdx
					superIdx = superIdx + 1
				end
				self.Tasks[taskrank][idx] = AccRewardTaskInfo(taskguid,ownername,expiretime,taskrank,taskid,receiveNum, ownerGUID, receiveStatus, receiveTime)
				--print("ACC loadtask", i, taskguid, ownername, expiretime, taskrank, taskid)
			end
		else
			if receiveNum > 0 and receiveTime > now then
				--do nothing
			else
				local temp = AccRewardTaskInfo(taskguid,ownername,expiretime,taskrank,taskid,receiveNum, ownerGUID, receiveStatus, receiveTime)
				table.insert(self.Tasks[taskrank], temp)
			end
		end
	end
end

--筛选任务
function AccRewardTaskInfos:getRandomTasks(tasks, num)
	if table.size(tasks) <= num then
		return tasks
	end

	local randomTasks = {}
	local weights = {}		
	local nowTime = os.time()
	local preWeight = 0
	local size = table.size(tasks)
	--print('task num: '..size)
	for i = 1, size do
		local weight = math.floor(math.pow(1800/((tasks[i]:getExpireTime() - nowTime)/60), 2))
		-- print(' task weight: '..weight)
		weights[i] = {[1]=i, [2]=weight + preWeight}
		preWeight = weights[i][2]
	end

	for i = 1, num do
		local weightsSize = table.size(weights)
		-- print('-----------------------------weights...')
		-- for j = 1, weightsSize do
		-- 	print('j:'..j..' taskindex:'..weights[j][1]..' weight:'..weights[j][2])
		-- end
		-- print('print weights end~~~~~~~~~~~~~~~~~~~~~~~~~')

		-- print('random in '..weights[weightsSize][2])
		local random = math.random(weights[weightsSize][2])
		-- print('random: '..random)
		local taskIndx = 0
		local taskWeight = 0
		--取得一个任务索引值
		local pre = 0
		local isfind = false
		local findIndx = 0
		for j = 1, weightsSize do
			if not isfind and random > pre and random <= weights[j][2] then
				findIndx = j
				taskIndx = weights[j][1];
				taskWeight = weights[j][2]-pre
				table.insert(randomTasks, tasks[taskIndx])
				weights[j]=nil
				isfind = true	
			end
			if not isfind then
				pre = weights[j][2]
			else
				--随机到一个任务后，后面的权值表向前移，如：w[1],w[2],w[3]若找到w[2],则w[3]变成w[2]后面依次类推
				if findIndx > 0 and findIndx < j then
					weights[j][2] = weights[j][2] - taskWeight
					weights[j - 1] = weights[j]
				end
			end
		end
		weights[weightsSize] = nil
	end

	-- print('return tasks...........................')
	-- for i, v in pairs(randomTasks) do
	-- 	print('taskId:'..v:getTaskID()..' taskOwnerName:'..v:getOwnerName())
	-- end
	return randomTasks
end

function AccRewardTaskInfos:buildMsg(retBuff)
	local taskNum = table.size(self.Tasks)
	retBuff:pushChar(taskNum)
	
		local timeNow = os.time()
	
	for _, task in pairs(self.Tasks or {}) do
		retBuff:pushInt(task:getTaskGUID())
		retBuff:pushString(task:getOwnerName())
		retBuff:pushInt(task:getExpireTime() - timeNow)
		retBuff:pushInt(task:getTaskRank())
		retBuff:pushInt(task:getTaskID())
		retBuff:pushInt(task:getReceiveNum())
	end
end

require ("system.task.TaskManager")

RewardTaskManager = class(nil, Singleton, Timer)

function RewardTaskManager:__init()
	self._roleAnnRewardTaskInfos = {} 
	self._roleSelectRewardTaskTime = {}	
	self._initRewardTaskList = nil
	self._bBroadcastFlag = false
	self._bPublishFlag = false
	self._mainTaskInfo = {}
	g_listHandler:addListener(self)
	self.maxTaskId = g_worldID*1000000 --×î´óµÄÐÐ»á±àºÅ
	g_entityDao:loadMaxTaskGUID()
	g_entityDao:loadInitRewardTask()
	gTimerMgr:regTimer(self, 0, 1000)
	self:initMainTaskInfo()
end

function RewardTaskManager:initMainTaskInfo()
	print('RewardTaskManager:initMainTaskInfo()')
	self._mainTaskInfo.create = g_LuaTaskDAO:getTaskTDByEventID(REWARDTASK_CREATE_EVENTID)
	self._mainTaskInfo.receive = g_LuaTaskDAO:getTaskTDByEventID(REWARDTASK_RECEIVE_EVENTID)
	self._mainTaskInfo.finish = g_LuaTaskDAO:getTaskTDByEventID(REWARDTASK_FINISH_EVENTID)
	self._mainTaskInfo.delete = g_LuaTaskDAO:getTaskTDByEventID(REWARDTASK_DELETE_EVENTID)			
end

function RewardTaskManager.onInitReardTaskList(luaBuf)
	print('RewardTaskManager.onInitReardTaskList')
	local memInfo = AccRewardTaskInfos()
	memInfo:loadTaskData(luaBuf, true)

	g_RewardTaskMgr._initRewardTaskList = memInfo

	-- for k,v in pairs(g_RewardTaskMgr._initRewardTaskList.Tasks[1]) do
	-- 	print(v:getOwnerName(), v:getOwnerGUID())
	-- end
	-- for k,v in pairs(g_RewardTaskMgr._initRewardTaskList.Tasks[2]) do
	-- 	print(v:getOwnerName(), v:getOwnerGUID())
	-- end
	-- for k,v in pairs(g_RewardTaskMgr._initRewardTaskList.Tasks[3]) do
	-- 	print(v:getOwnerName(), v:getOwnerGUID())
	-- end
end

function RewardTaskManager:doRewardTaskReq(event)
	print("RewardTaskManager:doRewardTaskReq")
	local params = event:getParams()
	local buffer, dbid, hGate = params[1], params[2], params[3]
	local roleSID = tostring(dbid)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	local req, err = protobuf.decode('RewardTaskReq' , buffer)
	if not req then
		print('RewardTaskManager:doRewardTaskReq '..tostring(err))
		return
	end

	local actionType = req.actionType
	local param1 = req.param1
	local param2 = req.param2
	print("doRewardTaskReq actionType, param1 , param2", actionType, param1, param2)
	
	local roleSid = player:getSerialID()
	
	if actionType == 0 then --发布悬赏任务
		self:create(roleSid, param1, false)
	elseif actionType == 1 then --查询悬赏任务
		g_RewardTaskMgr:select(roleSid, param1, param2)
	elseif actionType == 2 then --领取悬赏任务
		g_RewardTaskMgr:receive(roleSid, param1, param2)
	elseif actionType == 3 then --完成悬赏任务
		g_RewardTaskMgr:finish(false, roleSid, param1)
	elseif actionType == 4 then --删除悬赏任务
		g_RewardTaskMgr:delete(roleSid, param1)
	elseif actionType == 5 then --获取自己发布的悬赏任务
		g_RewardTaskMgr:selectmine(roleSid)
	elseif actionType == 6 then --放弃自己领取的悬赏任务
		g_RewardTaskMgr:giveup(roleSid)
	else
		--print("悬赏任务非法操作类型")
	end
	
end

--读取角色发布的悬赏任务
function RewardTaskManager:selectmine(roleSID)
	print("RewardTaskManager:selectmine()", roleSID)
	g_entityDao:selectOwnerRewardTask(roleSID)
end

--读取角色发布的悬赏任务
function RewardTaskManager.onSelectOwnerRewardTask(roleID, luaBuf)	
	g_RewardTaskMgr:updateAnnRewardtaskInfo(roleID, luaBuf, false, 0)
end

function RewardTaskManager:updateAnnRewardtaskInfo(roleSID, luaBuf, bCreate, taskGUID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		warning('cannot find player by sid('..roleSID..')')
		return 
	end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
	if not roleTaskInfo then
		warning('cannot find player taskInfo by sid('..roleSID..')')
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	local memInfo = AnnRewardTaskInfos()
	memInfo:setRoleID(roleSID)
	self._roleAnnRewardTaskInfos[roleSID] = memInfo
		
	local tb = {}
	for w in string.gmatch(luaBuf, "[% ]-([^% ]+)") do
		table.insert(tb, w)
	end
	
	if table.size(tb) > 0 then
		memInfo:loadTaskData(tb)
	end

	--发送数据给玩家
	local ret = {}
	ret.remainAnnRewardTaskNum = ANNREWARDTASKMAXNUM - roleTaskInfo:getRemainAnnRewardTaskNum()
	ret.remainAnnSuperRewardTaskNum = ANN_SUPER_REWARDTASK_MAXNUM - roleTaskInfo:getRemainAnnSuperRewardTaskNum()
	ret.taskNum = table.size(memInfo.Tasks)
	ret.tasks = {}
	local nowTime = os.time()
	for _, task in pairs(memInfo.Tasks or {}) do
		local taskRank = task:getTaskRank()
		local taskguid = task:getTaskGUID()
		local expireTime = task:getExpireTime()
		local taskID = task:getTaskID()
		local receiveNum = task:getReceiveNum()
		local taskStatus = task:getStatus()

    	--create new task add to list
		if bCreate and task:getTaskGUID() == taskGUID and taskStatus == 0 then
			local newTask = AccRewardTaskInfo(taskGUID, player:getName(), expireTime, taskRank, taskID, receiveNum, roleSID, 0, 0)
			table.insert(self._initRewardTaskList.Tasks[taskRank], newTask)			
		end

		local tempTask = {}
		tempTask.taskGUID = taskguid
		tempTask.expireTime = expireTime - nowTime
		tempTask.taskStatus = taskStatus
		tempTask.taskRank = taskRank
		tempTask.taskID = taskID
		tempTask.receiveNum = receiveNum
		--print(tempTask.taskGUID, tempTask.expireTime, tempTask.taskStatus, tempTask.taskRank, tempTask.taskID, tempTask.receiveNum)
		table.insert(ret.tasks, tempTask)
	end
	print('send owner rewardtask info')
	fireProtoMessage(player:getID(), TASK_SC_SELECT_OWNER_REWARDTASK, 'OwnerRewardTaskRet', ret)
end

--获取角色发布的悬赏任务
function RewardTaskManager:getRoleTaskInfo(roleID)
	return self._roleAnnRewardTaskInfos[roleID]
end

--发布悬赏任务
function RewardTaskManager:create(roleID, rank, bGm, taskid)
	print(string.format('RewardTaskManager:create(%d, %d)', roleID, rank))
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	
	if player:getLevel() < ANNREWARDTASK_LEVEL_MIN then
		print('player level too low', player:getLevel())
		g_taskServlet:sendErrMsg2Client(player:getID(), -60, 0)
		return
	end
	
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end

	local taskRank = rank
	if bGm then
		local taskInfo = g_LuaTaskDAO:getRewardTask(taskid)
		if not taskInfo then
			print('GM taskid not find')
			return
		end
		taskRank = taskInfo.q_rank
	end
	
	--当前主线任务为发布悬赏任务这不判断次数限制
	local curMainTaskId = 0
	local mainTask = roleTaskInfo:getMainTask()
	if mainTask then
		curMainTaskId = mainTask:getID()
	end
	local publishTaskId = self._mainTaskInfo.create
	--print('curMainTaskId:',curMainTaskId, 'publishTaskId:', publishTaskId)
	if curMainTaskId ~= publishTaskId then
		if  taskRank == REWARDTASK_RANK_BLUE or taskRank == REWARDTASK_RANK_PURPLE then
			if ANNREWARDTASKMAXNUM <= roleTaskInfo:getRemainAnnRewardTaskNum() then
				print('ann rewardtask num > '..ANNREWARDTASKMAXNUM)
				g_taskServlet:sendErrMsg2Client(player:getID(), -52, 0)
				return
			end
		elseif taskRank == REWARDTASK_RANK_SUPER then
			if ANN_SUPER_REWARDTASK_MAXNUM <= roleTaskInfo:getAnnSuperRewardTaskNum() then
				print('ann super rewardtask num > '.. ANN_SUPER_REWARDTASK_MAXNUM)
				g_taskServlet:sendErrMsg2Client(player:getID(), -92, 0)
				return
			end
		else
			print('no exist cur taskRank '..taskRank)
			return
		end
	end

	--查看当前发布的悬赏任务列表中是否有已经过期的
	local annRewardTaskInfos = self:getRoleTaskInfo(roleID)
	if not annRewardTaskInfos then
		print('get owner reward task failed')
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	if annRewardTaskInfos:checkExpireDateOrPrizeStatus() then
		g_taskServlet:sendErrMsg2Client(player:getID(), -53, 0)
		return
	end
		
	--扣物品
	if taskRank == REWARDTASK_RANK_BLUE then
		if not costMoney(player, REWARDTASK_RANK_BLUE_COST_MONEY, 10) then
			return
		end
	else 
		local eCode = 0
		local itemID = CREATEREWARDTASKITEM[taskRank]
		local result = isMatEnough(player, itemID, 1)
		if not result then
			g_taskServlet:sendErrMsg2Client(player:getID(), CREATE_REWARDTASK_NOT_ENOUGH[taskRank], 0)
			return
		else
			costMat(player, itemID, 1, 9)
		end
	end
	
	--增加每日发布悬赏任务次数
	if curMainTaskId ~= publishTaskId then 
		if taskRank == REWARDTASK_RANK_BLUE or taskRank == REWARDTASK_RANK_PURPLE then
			roleTaskInfo:setAnnRewardTaskNum(roleTaskInfo:getAnnRewardTaskNum() + 1)
		elseif taskRank == REWARDTASK_RANK_SUPER then
			roleTaskInfo:setAnnSuperRewardTaskNum(roleTaskInfo:getAnnSuperRewardTaskNum() + 1)
		end
		roleTaskInfo:cast2db()
	end	
	
	local taskId = taskid

	if not bGm then
		taskId = g_LuaTaskDAO:filtrateRewardTask(taskRank)
	end

	local worldID = g_frame:getWorldId()

	local tGuid = self:getNewTaskGUID()
	local bMainTask = curMainTaskId == publishTaskId
	g_entityDao:createRewardTask(roleID, taskRank, tGuid, worldID, player:getName(), taskId, bMainTask)

	g_logManager:writePropChange(player:getSerialID(), 2 ,9, itemID, 0, 1, 0)
end

--发布悬赏任务
function RewardTaskManager.onCreateRewardTask(roleID, taskRank, res, taskGuid, luaBuf)
	print('RewardTaskManager.onCreateRewardTask()')
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	
	if res < 0 then
		return
	end
	
	g_RewardTaskMgr:updateAnnRewardtaskInfo(roleID, luaBuf, true, taskGuid)
	
	if taskRank == REWARDTASK_RANK_SUPER then
		local ret = {}
		ret.eventId = EVENT_PUSH_MESSAGE
		ret.eCode = 94
		ret.mesId = 0
		ret.param = {}
		table.insert(ret.param, player:getName())
		boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
		g_ChatSystem:SystemMsgIntoChat(0, 2, "", EVENT_PUSH_MESSAGE, 94, 1, {player:getName()})
	end
	
	--发消息
	g_taskServlet:sendErrMsg2Client(player:getID(), 10, 0)
	
	g_taskMgr:NotifyListener(player, "onPubliseReward")	

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.publishReward, 1, taskRank)

	g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.XUANSHUANG_SEND)

	--Tlog悬赏任务流水
	g_tlogMgr:TlogRewardTaskFlow(player , 1, taskRank, 0)
end

function RewardTaskManager:systemCreateRewardTask(taskRank, num)
	print('RewardTaskManager:systemCreateRewardTask(taskRank, num)')
	local worldID = g_frame:getWorldId()
	local now = os.time()
	local expiretime = now + 30*60
	for i = 1, num do
		local taskId = g_LuaTaskDAO:filtrateRewardTask(taskRank)
		local tGuid = self:getNewTaskGUID()
		local sysName = tostring(REWARDTASK_SYSTEM_DISPLAYE_NAME)
		g_entityDao:createRewardTaskBySys(taskRank, tGuid,worldID, sysName,taskId)

		local temp = AccRewardTaskInfo(tGuid,sysName,expiretime,taskRank,taskId,0, 0, 0, 0)
		table.insert(self._initRewardTaskList.Tasks[taskRank], temp)
	end
end

--领取悬赏任务
function RewardTaskManager:receive(roleID, taskGUID, taskID)
	print('RewardTaskManager:receive()')
	local player = g_entityMgr:getPlayerBySID(roleID)

	if not self:isVaildDisToNpc(player) then
		return
	end
	
	if player:getLevel() < ACCREWARDTASK_LEVEL_MIN then
		g_taskServlet:sendErrMsg2Client(player:getID(), -60, 0)
		return
	end
	
	--查看当日发布任务数量
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	--查看现有任务
	if roleTaskInfo:getRewardTask() then
		g_taskServlet:sendErrMsg2Client(player:getID(), -61, 0)
		return
	end
	
	--主线任务接取悬赏任务
	local mainTask = roleTaskInfo:getMainTask()
	local curMainTaskId = 0
	if mainTask then
		curMainTaskId = mainTask:getID()
	end
	print('taskGUID:',taskGUID, 'taskid:', taskID, 'curMainTaskId:', curMainTaskId)
	if taskGUID == 0 and taskID == REWARDTASK_RECEIVE_ID  and curMainTaskId == self._mainTaskInfo.receive then
		--print('get a temp rewardtask task')
		roleTaskInfo:setRewardTaskGUID(0)
		roleTaskInfo:cast2db()
		g_taskServlet:receiveTask(player, TaskType.Reward, taskID)
		g_taskMgr:NotifyListener(player, "onAcceptReward")
		return
	end

	--查看任务完成数量
	local taskDesc = g_LuaTaskDAO:getRewardTask(taskID)	
	if not taskDesc then
		return
	end
	
	local remainNum = 0
	if taskDesc.q_rank == REWARDTASK_RANK_BLUE then
		remainNum = roleTaskInfo:getRemainAccBlueRewardTaskNum()
	elseif taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
		remainNum = roleTaskInfo:getRemainAccPurpleRewardTaskNum()
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		remainNum = roleTaskInfo:getRemainAccSuperRewardTaskNum()
	end
	
	if taskDesc.q_rank == REWARDTASK_RANK_BLUE or taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
		if ACCREWARDTASKMAXNUM <= remainNum then
			g_taskServlet:sendErrMsg2Client(player:getID(), -56, 0)
			return
		end
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		if ACC_SUPER_REWARDTASK_MAXNUM <= remainNum then
			g_taskServlet:sendErrMsg2Client(player:getID(), -56, 0)
			return
		end
	end

	g_entityDao:receiveRewardTask(roleID, taskGUID, taskID)
end

--接收悬赏任务回调
function RewardTaskManager.onReceiveRewardTask(roleID, res, taskGUID, taskID, guardTime)
	print('RewardTaskManager.onReceiveRewardTask()', res)
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	--查看当日发布任务数量
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	--查看现有任务
	if roleTaskInfo:getRewardTask() then
		g_taskServlet:sendErrMsg2Client(player:getID(), -61, 0)
		return
	end

	local taskDesc = g_LuaTaskDAO:getRewardTask(taskID)	
	if not taskDesc then
		print('find cur task failed from DB, taskid='..taskID)
		return
	end
	--[[res: 0:已经被完成，1:第一个接取的玩家，2:任务保护中不能接取，3:任务已过过保护时间]]
	if res == 0 or res == 2 then
		--清除该玩家查询CD时间
		g_RewardTaskMgr._roleSelectRewardTaskTime[roleID] = 0
		local  task = g_LuaTaskDAO:getRewardTask(taskID)
		if res == 0 then
			g_taskServlet:sendErrMsg2Client(player:getID(), -90, 0)
		elseif res == 2 then
			g_taskServlet:sendErrMsg2Client(player:getID(), -98,0)
		end	
		if not task then return end
		g_RewardTaskMgr:select(roleID, task.q_rank, 0)
		return
	elseif res == 1 or res == 3 then
		--领取任务
		roleTaskInfo:setRewardTaskGUID(taskGUID)
		roleTaskInfo:setRewardTaskGuardTime(guardTime)
		roleTaskInfo:cast2db()		
		g_taskServlet:receiveTask(player, TaskType.Reward, taskID)

		g_taskMgr:NotifyListener(player, "onAcceptReward")

		--update origin rewardtask
		for _,v in pairs(g_RewardTaskMgr._initRewardTaskList.Tasks[taskDesc.q_rank]) do
			if v:getTaskGUID() == taskGUID then
				if res == 1 then
					--local now = os.time()
					v:setReceiveStatus(1)
					v:setReceiveTime(guardTime)
					--print("guard time:",guardTime - os.time())
				end
				v:setReceiveNum(v:getReceiveNum() + 1)
				break;
			end
		end

		--Tlog悬赏任务流水
		g_tlogMgr:TlogRewardTaskFlow(player , 0, taskDesc.q_rank, 0)
	end
end

--完成悬赏任务
function RewardTaskManager:finish(bForce, roleID)
	print('RewardTaskManager:finish()')
	local player = g_entityMgr:getPlayerBySID(roleID)

	if not self:isVaildDisToNpc(player) then
		return
	end
	
	if player:getLevel() < ACCREWARDTASK_LEVEL_MIN then
		g_taskServlet:sendErrMsg2Client(player:getID(), -60, 0)
		return
	end
	
	--获取当前悬赏任务
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	local task = roleTaskInfo:getRewardTask()
	if not task then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	if not task:canEnd() and not bForce then
		g_taskServlet:sendErrMsg2Client(player:getID(), -55, 0)
		return
	end
	
	local curMainTaskId = 0
	local mainTask = roleTaskInfo:getMainTask()
	if mainTask then
		curMainTaskId = mainTask:getID()
	end
	if roleTaskInfo:getRewardTaskGUID() == 0 and self._mainTaskInfo.finish == curMainTaskId and task:getID() == REWARDTASK_RECEIVE_ID then 
		roleTaskInfo:setRewardTaskGUID(0)
		g_taskServlet:finishTask(player:getID(), task)
		roleTaskInfo:cast2db()	
		g_taskMgr:NotifyListener(player, "onFinishReward")
		return
	end

	local taskDesc = g_LuaTaskDAO:getRewardTask(task:getID())	
	if not taskDesc then
		return
	end
	
	local remainNum = 0
	if taskDesc.q_rank == REWARDTASK_RANK_BLUE then
		remainNum = roleTaskInfo:getRemainAccBlueRewardTaskNum()
	elseif taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
		remainNum = roleTaskInfo:getRemainAccPurpleRewardTaskNum()
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		remainNum = roleTaskInfo:getRemainAccSuperRewardTaskNum()
	end
	
	if taskDesc.q_rank == REWARDTASK_RANK_BLUE or taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
		if ACCREWARDTASKMAXNUM < remainNum then
			g_taskServlet:sendErrMsg2Client(player:getID(), -56, 0)
			return
		end
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		if ACC_SUPER_REWARDTASK_MAXNUM < remainNum then
			g_taskServlet:sendErrMsg2Client(player:getID(), -56, 0)
			return
		end
	end

	g_entityDao:finishRewardTask(roleID, roleTaskInfo:getRewardTaskGUID(),task:getID(), bForce)
end

--完成悬赏任务回调
function RewardTaskManager.onFinishRewardTask(roleID, res, bForce)
	print('RewardTaskManager.onFinishRewardTask()')
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	local task = roleTaskInfo:getRewardTask()
	if not task then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	local taskDesc = g_LuaTaskDAO:getRewardTask(task:getID())	
	if not taskDesc then
		return
	end
	
	if res == 1 then	
		if taskDesc.q_rank == REWARDTASK_RANK_BLUE then
			roleTaskInfo:setAccBlueRewardTaskNum(roleTaskInfo:getAccBlueRewardTaskNum())
		elseif taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
			roleTaskInfo:setAccPurpleRewardTaskNum(roleTaskInfo:getAccPurpleRewardTaskNum())
		elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
			roleTaskInfo:setAccSuperRewardTaskNum(roleTaskInfo:getAccSuperRewardTaskNum())
		end		

		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.failedReward, 1, taskDesc.q_rank)
		
		g_RewardTaskMgr:giveup(player:getSerialID())
		--g_entityMgr:dropItemToEmail(player:getSerialID(), 5, 60, 9,0,false,"")
		addExpToPlayer(player, 2000, 9)
		g_taskServlet:sendErrMsg2Client(player:getID(), -57, 0)
		return
	end
	
	if not task:canEnd() and not bForce then
		g_taskServlet:sendErrMsg2Client(player:getID(), -55, 0)
		return
	end
	
	local remainNum = 0
	if taskDesc.q_rank == REWARDTASK_RANK_BLUE then
		remainNum = roleTaskInfo:getRemainAccBlueRewardTaskNum()
	elseif taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
		remainNum = roleTaskInfo:getRemainAccPurpleRewardTaskNum()
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		remainNum = roleTaskInfo:getRemainAccSuperRewardTaskNum()
	end

	local competitionTaskNum = 1
	competitionTaskNum = competitionTaskNum + roleTaskInfo:getRemainAccBlueRewardTaskNum()
	competitionTaskNum = competitionTaskNum + roleTaskInfo:getRemainAccPurpleRewardTaskNum()
	competitionTaskNum = competitionTaskNum + roleTaskInfo:getRemainAccSuperRewardTaskNum()
	
	if competitionTaskNum%3 == 0 then
		g_competitionMgr:checkCompetitionActive(roleID,3)
	end

	if taskDesc.q_rank == REWARDTASK_RANK_BLUE or taskDesc.q_rank == REWARDTASK_RANK_BLUE then
		if ACCREWARDTASKMAXNUM <= remainNum then
			g_taskServlet:sendErrMsg2Client(player:getID(), -57, 0)
			return
		end
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		if ACC_SUPER_REWARDTASK_MAXNUM <= remainNum then
			g_taskServlet:sendErrMsg2Client(player:getID(), -57, 0)
			return
		end
	end
	
	if taskDesc.q_rank == REWARDTASK_RANK_BLUE then
		roleTaskInfo:setAccBlueRewardTaskNum(roleTaskInfo:getAccBlueRewardTaskNum() + 1)
		
	elseif taskDesc.q_rank == REWARDTASK_RANK_PURPLE then
		roleTaskInfo:setAccPurpleRewardTaskNum(roleTaskInfo:getAccPurpleRewardTaskNum() + 1)
		
	elseif taskDesc.q_rank == REWARDTASK_RANK_SUPER then
		roleTaskInfo:setAccSuperRewardTaskNum(roleTaskInfo:getAccSuperRewardTaskNum() + 1)
	end
	
	--update mem list
	local memTasks = g_RewardTaskMgr._initRewardTaskList.Tasks[taskDesc.q_rank]
	for i,v in pairs(memTasks) do
		if v:getTaskGUID() == roleTaskInfo:getRewardTaskGUID() then
			table.remove(memTasks, i)
			break
		end
	end

	--清除当前任务查看看CD时间
	g_RewardTaskMgr._roleSelectRewardTaskTime[roleID] = 0

	roleTaskInfo:setRewardTaskGUID(0)
	
	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.finishReward, 1, taskDesc.q_rank)

	g_taskServlet:finishTask(player:getID(), task)
	roleTaskInfo:cast2db()
	
	g_taskMgr:NotifyListener(player, "onFinishReward")

	--Tlog悬赏任务流水
	g_tlogMgr:TlogRewardTaskFlow(player , 2, taskDesc.q_rank, taskDesc.q_rewards_exp)
	g_ActivityMgr:OnTask(player:getID(), task:getID(), TaskType.Reward, taskDesc.q_rank, ACTIVITY_TASK_OPERATE.FINISH_GET_REWARD)
	g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.XUANSHUANG, 1)

	--活动记录
	g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.XUANSHUANG)
end

--删除悬赏任务
function RewardTaskManager:delete(roleID, taskGUID)
	print('RewardTaskManager:delete()',roleID, taskGUID)
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end

	--查看当前发布的悬赏任务列表中是否有已经过期的
	local annRewardTaskInfos = self:getRoleTaskInfo(roleID)
	if not annRewardTaskInfos then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	local checkResult = false
	local taskID = 0
	checkResult, taskID = annRewardTaskInfos:checkDelete(taskGUID)
	print('delete taskID:', taskID)
	if not checkResult then
		g_taskServlet:sendErrMsg2Client(player:getID(), -58, 0)
		return
	end
	
	g_entityDao:deleteRewardTask(roleID, taskID, taskGUID)
end

--数据库回调,删除悬赏任务
function RewardTaskManager.onDeleteRewardTask(roleID, taskID, res, luaBuf)
	print('roleID',roleID, 'taskID: ',taskID, 'res: ',res)
		
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	
	if res == 0 then
		g_taskServlet:sendErrMsg2Client(player:getID(), -59, 0)
		return
	end
	
	--刷新自己的发布悬赏任务的列表
	g_RewardTaskMgr:selectmine(roleID)
	
	--获得任务奖励
	local rewardData = g_LuaTaskDAO:getRewardTask(taskID)
	local exp = 0
	if res == 1 then --获取完整任务奖励		
		g_taskServlet:doReward(player, rewardData, TaskType.Reward, DELETEREWARDPERCENT, false, taskID, rewardData.q_rank)
		exp = rewardData.q_rewards_exp * DELETEREWARDPERCENT / 100
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.beFinishReward, 1, rewardData.q_rank)
		g_taskMgr:NotifyListener(player, "onTPickReward")
	elseif res == 2 then --获取过期任务奖励
		g_taskServlet:doReward(player, rewardData, TaskType.Reward, EXPIREREWARDPERCENT, false, taskID, rewardData.q_rank)
		exp = rewardData.q_rewards_exp * EXPIREREWARDPERCENT / 100
	end
	
	g_taskServlet:sendErrMsg2Client(player:getID(), 11, 0)

	--Tlog悬赏任务流水
	g_tlogMgr:TlogRewardTaskFlow(player , 3, rewardData.q_rank, exp)
	g_ActivityMgr:OnTask(player:getID(), taskID, TaskType.Reward, rewardData.q_rank, ACTIVITY_TASK_OPERATE.PUBLISH_GET_REWARD)

end

--查询悬赏任务
function RewardTaskManager:select(roleSID)
	print("RewardTaskManager:select:", roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	
	--判断查询CD时间
	local selectInfo = self._roleSelectRewardTaskTime[roleSID]
	if selectInfo then
		if os.time() - selectInfo < SELECT_CD_TIME then
			--print('select tasks from mem')
			self:fireSelectRewardTaskInfo(self._initRewardTaskList, player, false)
			return
		end
	end

	--直接查询数据库
	g_entityDao:selectRewardTask(roleSID)
end

--数据库回调，查询悬赏任务
function RewardTaskManager.onSelectRewardTask(roleID, luaBuf)
	print("onSelectRewardTask return", roleID, luaBuf)
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end	

	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		print('not find roleTaskInfo')
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	local memInfo = AccRewardTaskInfos()
	memInfo:loadTaskData(luaBuf, false)

	g_RewardTaskMgr:fireSelectRewardTaskInfo(memInfo, player, true)

	--设置CD时间
	g_RewardTaskMgr._roleSelectRewardTaskTime[roleID] = os.time()
end

function RewardTaskManager:fireSelectRewardTaskInfo(memInfo, player, new)
	print('RewardTaskManager:fireSelectRewardTaskInfo()')
	if not player then
		warning('not find player')
		return
	end

	local roleSID = player:getSerialID()
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
	if not roleTaskInfo then
		print('not find roleTaskInfo')
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end

	if not memInfo then
		memInfo = AccRewardTaskInfos()
	end

	local allBlues = {}
	local allPurpes = {}
	local allSupers = {}

	if not new then
		local blueIdx = 1
		local purpleIdx = 1
		local superIdx = 1
		self:removeExpired(memInfo)
		local now = os.time()
		--print('select mem blue size:', table.size(memInfo.Tasks[REWARDTASK_RANK_BLUE]))
		for k,v in pairs(memInfo.Tasks[REWARDTASK_RANK_BLUE]) do
			if v:getOwnerGUID() ~= roleSID then
				if v:getReceiveTime() > now and v:getReceiveNum() > 0 then
					--print('GUID:',v:getTaskGUID(), 'num:',v:getReceiveNum(), 'time:',v:getExpireTime())
				else
					allBlues[blueIdx] = v
					blueIdx = blueIdx + 1
				end
			end
		end
		--print('select mem purple size:', table.size(memInfo.Tasks[REWARDTASK_RANK_PURPLE]))
		for k,v in pairs(memInfo.Tasks[REWARDTASK_RANK_PURPLE]) do
			if v:getOwnerGUID() ~= roleSID then
				if v:getReceiveTime() > now and v:getReceiveNum() > 0 then
					--print('GUID:',v:getTaskGUID(), 'num:',v:getReceiveNum(), 'time:',v:getExpireTime())
				else
					allPurpes[purpleIdx] = v
					purpleIdx = purpleIdx + 1
				end
			end
		end
		--print('select mem super size:', table.size(memInfo.Tasks[REWARDTASK_RANK_SUPER]))
		for k,v in pairs(memInfo.Tasks[REWARDTASK_RANK_SUPER]) do
			if v:getOwnerGUID() ~= roleSID then
				if v:getReceiveTime() > now and v:getReceiveNum() > 0 then
					--print('GUID:',v:getTaskGUID(), 'num:',v:getReceiveNum(), 'time:',v:getExpireTime())
				else
					allSupers[superIdx] = v
					superIdx = superIdx + 1
				end
			end
		end
	else
		allBlues = memInfo.Tasks[REWARDTASK_RANK_BLUE]
		allPurpes = memInfo.Tasks[REWARDTASK_RANK_PURPLE]
		allSupers = memInfo.Tasks[REWARDTASK_RANK_SUPER]
	end

	local ret = {}
	ret.remainAccBlueRewardTaskNum = ACCREWARDTASKMAXNUM - roleTaskInfo:getRemainAccBlueRewardTaskNum()
	ret.RemainAccPurpleRewardTaskNum = ACCREWARDTASKMAXNUM - roleTaskInfo:getRemainAccPurpleRewardTaskNum()
	ret.remainAccSuperRewardTaskNum = ACC_SUPER_REWARDTASK_MAXNUM - roleTaskInfo:getRemainAccSuperRewardTaskNum()
	local blueTasks = memInfo:getRandomTasks(allBlues, SELECTPAGENUM) or {}
	local purpeTasks = memInfo:getRandomTasks(allPurpes, SELECTPAGENUM) or {}
	local superTasks = memInfo:getRandomTasks(allSupers, SELECTPAGENUM) or {}
	ret.taskNum = table.size(blueTasks) + table.size(purpeTasks) + table.size(superTasks)
	ret.taskRank = taskrank

	ret.rewardTasks = {}
	self:filedTaskFromAccObjs(ret.rewardTasks, blueTasks)
	self:filedTaskFromAccObjs(ret.rewardTasks, purpeTasks)
	self:filedTaskFromAccObjs(ret.rewardTasks, superTasks)

	-- for k,v in pairs(ret.rewardTasks) do
	-- 	print(v.taskGUID, v.ownerName, v.newTag)
	-- end
	ret.status = 0

	fireProtoMessage(player:getID(), TASK_SC_SELECT_REWARDTASK, 'SelectRewardTaskRet', ret)
end

function RewardTaskManager:filedTaskFromAccObjs(dest,src)
	print('RewardTaskManager:filedTaskFromAccObjs()')
	local timeNow = os.time()
	for _, task in pairs(src) do
		local receiveStatus = task:getReceiveStatus()
		local receiveTime = task:getReceiveTime()
		local receiveNum = task:getReceiveNum()

		local tempTask = {}
		tempTask.taskGUID = task:getTaskGUID()
		tempTask.ownerName = task:getOwnerName()
		tempTask.expireTime = task:getExpireTime() - timeNow
		tempTask.taskRank = task:getTaskRank()
		tempTask.taskID = task:getTaskID()
		tempTask.receiveNum = task:getReceiveNum()
		if receiveStatus == 0 then
			tempTask.newTag = 1
		else
			tempTask.newTag = 0
		end
		--print(tempTask.taskGUID, tempTask.expireTime, tempTask.ownerName, tempTask.taskRank, tempTask.taskID, tempTask.receiveNum)
		table.insert(dest, tempTask)
	end
end

function RewardTaskManager:removeExpired(memInfo)
	print('RewardTaskManager:removeExpired()')
	if not memInfo then
		return
	end
	local now = os.time()

	for _,v in pairs(memInfo.Tasks) do
		for i,task in pairs(v) do
			if task:getExpireTime() <= now then
				v[i] = nil
			end
		end
	end
end

--放弃自己领取的悬赏任务
function RewardTaskManager:giveup(roleID)
	print(string.format('RewardTaskManager:giveup(%d)', roleID))
	local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	
	--获取当前悬赏任务
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleID)
	if not roleTaskInfo then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	local task = roleTaskInfo:getRewardTask()
	if not task then
		g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end

	--引导任务不能放弃
	local taskGUID = roleTaskInfo:getRewardTaskGUID()
	local mainTask = roleTaskInfo:getMainTask()
	local curMainTaskId = 0
	local taskID = 0
	if mainTask then
		curMainTaskId = mainTask:getID()
	end
	local rewardtask = roleTaskInfo:getRewardTask()
	if rewardtask then
		taskID = rewardtask:getID()
	end
	local nextTask = 0
	local taskInfo = g_LuaTaskDAO:getPrototype(self._mainTaskInfo.receive)
	if taskInfo then
		nextTask = tonumber(taskInfo.q_next_task)
	end

	print('taskGUID:',taskGUID, 'taskid:', taskID, 'curMainTaskId:', curMainTaskId, 'nextTask:', nextTask)
	if taskGUID == 0 and taskID == REWARDTASK_RECEIVE_ID  and curMainTaskId == nextTask then
		g_taskServlet:sendErrMsg2Client(player:getID(), -100, 0)
		return
	end

	--更新数据库
	g_entityDao:giveUpRewardTask(roleID,roleTaskInfo:getRewardTaskGUID(), task:getID())
end

--放弃悬赏任务回调
function RewardTaskManager.onGiveUpRewardTask(roleSID, res)
	print(string.format('RewardTaskManager:onGiveUpRewardTask(%d, %d)', roleSID, res))
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return
	end
	if res == 0 then
		local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
		if not roleTaskInfo then
			print('not roleTaskInfo data')
			g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
			return
		end

		local task = roleTaskInfo:getRewardTask()
		local taskDesc = g_LuaTaskDAO:getRewardTask(task:getID())
		for i,v in pairs(g_RewardTaskMgr._initRewardTaskList.Tasks[taskDesc.q_rank]) do
			if v:getTaskGUID() == roleTaskInfo:getRewardTaskGUID() then
				v:setReceiveNum(v:getReceiveNum() - 1)
				v:setReceiveTime(0)
				break
			end
		end

		roleTaskInfo:romoveRewardTask()
		roleTaskInfo:setRewardTaskGUID(0)
		roleTaskInfo:cast2db()
		
		local ret = {}	
		ret.actionType = 1
		fireProtoMessage(player:getID(), TASK_SC_FINISH_REWARD_TASK, 'FinishRewardTaskRet', ret)
	end
end


--玩家下线
function RewardTaskManager:onPlayerOffLine(player)
	local roleSid = player:getSerialID()
	self._roleAnnRewardTaskInfos[roleSid] = nil
end

--玩家上线
function RewardTaskManager:onPlayerLoaded(player)
	if not player then return end
	local roleSid = player:getSerialID()
	g_RewardTaskMgr:selectmine(roleSid)
end

function RewardTaskManager:onLoadMaxTaskID(taskid)
	self.maxTaskId = taskid
end

function RewardTaskManager:getNewTaskGUID()
	self.maxTaskId = self.maxTaskId + 1
	return self.maxTaskId
end

--查看玩家查询任务CD时间
function RewardTaskManager:getSelectInfoBySID(roleSID)
	return self._roleSelectRewardTaskTime[roleSID]
end

--可操作范围内
function RewardTaskManager:isVaildDisToNpc(player)
	if not player then return false end
	local mapId = player:getMapID()
	local pos = player:getPosition();
	local dis = math.max(math.abs(pos.x - 122), math.abs(pos.y - 127))
	--print("mapID:",mapId, "x: ",pos.x, "y:",pos.y, "dis:", dis);
	--不在NPC附近
	if mapId ~= 2100 or dis > REWARD_NPC_OPT_DISTANCE then
		print("distance > max distance to NPC")
		return false
	end

	return true
end

function RewardTaskManager:update()
	local now = os.time()
	local t = os.date("*t", now)
	local hour = t["hour"]
	local minute = t["min"]

	for _,v in pairs(REWARDTASK_SYSTEM_TIME) do
		if not self._bBoardcastFlag and hour == v - 1 then
			if minute == 60 - REWARDTASK_SYSTEM_BROADCAST_TIME then
				print('RewardTask boardcast')
				for i = 1, REWARDTASK_SYSTEM_BROADCAST_COUNT do
					local ret = {}
					ret.eventId = EVENT_PUSH_MESSAGE
					ret.eCode = 113
					ret.mesId = 0
					ret.param = {}
					boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
				end
				g_ChatSystem:SystemMsgIntoChat(0, 2, "", EVENT_PUSH_MESSAGE, 113, 0, {})
				self._bBoardcastFlag = true
				self._bPublishFlag = false
			end
		elseif not self._bPublishFlag and hour == v then
			if minute == 0 then
				for i = 1, REWARDTASK_SYSTEM_BROADCAST_COUNT do
					local ret = {}
					ret.eventId = EVENT_PUSH_MESSAGE
					ret.eCode = 114
					ret.mesId = 0
					ret.param = {}
					boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
				end
				g_ChatSystem:SystemMsgIntoChat(0, 2, "", EVENT_PUSH_MESSAGE, 114, 0, {})
				self:systemCreateRewardTask(REWARDTASK_RANK_BLUE, REWARDTASK_SYSTEM_CREATE_BLUE_NUM)
				self:systemCreateRewardTask(REWARDTASK_RANK_PURPLE, REWARDTASK_SYSTEM_CREATE_PURPLE_NUM)
				self:systemCreateRewardTask(REWARDTASK_RANK_SUPER, REWARDTASK_SYSTEM_CREATE_SUPER_NUM)
				self._bBoardcastFlag = false
				self._bPublishFlag = true
			end
		end
	end
end

function RewardTaskManager.getInstance()
	return RewardTaskManager()
end

g_RewardTaskMgr = RewardTaskManager.getInstance()
