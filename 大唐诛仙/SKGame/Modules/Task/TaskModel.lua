--任务系统数据层
TaskModel =BaseClass(LuaModel)

function TaskModel:__init()
	-- 
	--self.taskCfg = GetCfgData("task")
	self.taskDataList = {}

	self:InitData()
	self:InitEvent()
end

function TaskModel:InitData()

	self.lastSubmitTaskId = -1

	--环任务
	self.curCycleTaskNum = 0 --当前环任务的环数

	--日常任务
	self.curDailyTaskNum = 0 --当前日常任务的环数 (悬赏任务)

	--标识任务行为是否触发交任务对话（只有自动寻路到目标点才可以触发，期间被打断是不触发的）
	self.isCanShowSubmitDialog = false

	--最近的（当前的）任务交任务信息（点击任务面板产生）
	self.lastSubmitTaskNPCInfo = {}

	--为了解决网络延迟造成的前后端任务数据不同步的情况，加个网络提交任务锁
	--发送提交任务请求时，加锁，状态值置为true
	--收到提交任务回包时，解锁，状态值置为false
	self.submitTaskLock = false 
end

function TaskModel:InitEvent()
	self.handler1  = GlobalDispatcher:AddEventListener(EventName.JOYSTICK_MOVE, function (data) self:HandleJoyStickMove(data) end)
end

function TaskModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function TaskModel:InitTaskList(taskList)
	self.taskDataList = {}
	for index = 1, #taskList do
		local data = taskList[index]
		if data and GetCfgData("task"):Get(data.taskId) then
			table.insert(self.taskDataList, TaskData.New(data))
		else
			print("=====ERROR：任务表没有ID为" , data.taskId , "数据")
		end
	end
	self:SortAllTaskData()
	self:GetAccordionData()
end


--	内容显示优先级排序：主线>支线 (主线为1，支线为2)
--	支线任务按照任务id排序。
--	任务追踪最多显示10个任务。
function TaskModel:SortAllTaskData()
	table.sort(self.taskDataList, function (taskDataObjA, taskDataObjB)
		local typeA = taskDataObjA:GetTaskType()
		local typeB = taskDataObjB:GetTaskType()
		return typeA < typeB
	end
	)

	local branchLineTaskList = {}
	for index = 1, #self.taskDataList do
		local v = self.taskDataList[index]
		if v:GetTaskType() == TaskConst.TaskType.BranchLine then
			table.insert(branchLineTaskList, v)
		end
	end

	for index = 1, #branchLineTaskList do
		local dataIndex = self:GetTaskIndexById(branchLineTaskList[index].taskData.id)
		table.remove(self.taskDataList, dataIndex)
	end

	table.sort(branchLineTaskList, function (a, b)
		return (a.taskData.id < b.taskData.id)
	end)

	for index = 1, #branchLineTaskList do
		table.insert(self.taskDataList, branchLineTaskList[index])
	end

end



function TaskModel:GetAllTaskData()
	return self.taskDataList or {}
end


function TaskModel:InitCfgData()
	
end

function TaskModel:GetTaskDataByID(id)
	if id ~= nil then
		for index = 1, #self.taskDataList do
			local v = self.taskDataList[index]
			if v.taskData.id == id then
				return v
			end
		end
	end
	return {}
end

function TaskModel:GetTaskDataByIndex(index)
	if index ~= nil and index > 0 and index <= #self.taskDataList then
		local v = self.taskDataList[index]
		if v then
			return v
		end
	end
	return {}
end

--通过任务ID获取任务Index
function TaskModel:GetTaskIndexById(id)
	if id ~= nil then
		for index = 1, #self.taskDataList do
			if self.taskDataList[index].taskData.id == id then
				return index
			end
		end
	end
	return 0
end

--更新任务列表
function TaskModel:UpgradeTaskList(newList)
	if newList and #newList > 0 then
		for index = 1, #newList do
			local v = newList[index]
			local rtnIshas , rntIndex = self:IsHasByTaskId(v.taskId)
			if rtnIshas == true and rtnIndex ~= -1 then
				self.taskDataList[rntIndex] = TaskData.New(v)
			else
				table.insert(self.taskDataList, TaskData.New(v))
			end
		end
		self:SortAllTaskData()
	end
end

function TaskModel:SetLastSubmitTaskId(taskId)
	if taskId then self.lastSubmitTaskId = taskId or -1 end
end

function TaskModel:GetLastSubmitTaskId()
	return self.lastSubmitTaskId
end

function TaskModel:IsHasByTaskId(taskId)
	if taskId ~= nil then
		for index, taskDataObj in pairs(self.taskDataList) do
			if taskDataObj:GetTaskId() == taskId then
				return true, index
			end
		end
	end
	return false, -1
end


function TaskModel:PrintAllTaskList()

end

--清除某个TaskData对象
function TaskModel:DestroyTaskData(taskId)
	if taskId then
		for index, taskDataObj in pairs(self.taskDataList) do
			if taskDataObj:GetTaskId() == taskId then
				table.remove(self.taskDataList, index)
				break
			end
		end
	end
end

-- 同步任务状态
function TaskModel:SyncTaskState(playerTask)
	if playerTask ~= nil then
		for index = 1, #self.taskDataList do
			local v = self.taskDataList[index]
			local taskData = v:GetTaskData()
			if taskData.id == playerTask.taskId then
				v:SetTaskProcessState(playerTask.currentNum, playerTask.taskState)
				return
			end
		end
	end
end

function TaskModel:SetAutoFight( auto )
	local beDoNext = self.isAuto
	if self.isAuto ~= auto then
		self.isAuto = auto
	end
	if not auto then return beDoNext==true end
	return false
end
function TaskModel:AutoFight()
	AutoFightMgr.SetAuto(self.isAuto)
end
function TaskModel:AutoDoNext()
	DelayCall(function ()
		GlobalDispatcher:Fire(EventName.AUTO_DONEXT_TASK)
	end, 0.5)
end
function TaskModel:BreakAuto()
	self.isAuto=false
end
function TaskModel:ContinueAuto()
	self:SetAutoFight( true )
	AutoFightMgr.SetAuto(self.isAuto)
end

--在为完成，可交付状态的任务中，找到交付npc为具体某个npc的任务集合
function TaskModel:GetTaskListBySubmitNPC(npcId)
	local rtnTaskDataList = {}
	if npcId then
		for index = 1, #self.taskDataList do
			local v = self.taskDataList[index]
			if v:GetTaskState() == TaskConst.TaskState.Finish then
				if v:GetSubmitNPCId() == npcId then
					table.insert(rtnTaskDataList, v)
				end
			end	
		end
	end
	rtnTaskDataList = self:SortTaskListByTaskId(rtnTaskDataList)
	return rtnTaskDataList
end

--在未完成状态的任务中，找到执行任务的npc未具体某个npc的任务集合（比如和某个npc对话的任务类型）
function TaskModel:GetTaskListByExecNPC(npcId)
	local rtnTaskDataList = {}
	if npcId then
		for index = 1, #self.taskDataList do
			local v = self.taskDataList[index]
			if v:GetTaskState() == TaskConst.TaskState.NotFinish then
				local taskTarget = v:GetTaskTarget()
				if not TableIsEmpty(taskTarget) and self:IsNPCInteractionTask(taskTarget.targetType) then
					if taskTarget.targetParam[1] and taskTarget.targetParam[1] == npcId then
						table.insert(rtnTaskDataList, v)
					end
				end
			end
		end
	end
	rtnTaskDataList =  self:SortTaskListByTaskId(rtnTaskDataList)
	return rtnTaskDataList
end

--判断某个任务是否属于直接于npc交互的任务，比如npc对话任务类型
function TaskModel:IsNPCInteractionTask(taskType)
	return taskType == TaskConst.TaskTargetType.NPCInteraction
end

--获取某个npc的对应的功能ID，比如每日任务npc，点击它，打开每日任务界面
function TaskModel:GetFunIdByNPCId(npcId)
	if npcId then
		local npcCfg = GetCfgData("npc"):Get(npcId)
		if npcCfg then
			return npcCfg.functionId
		end
	end
	return -1
end

--按照TaskId的大小进行升序
function TaskModel:SortTaskListByTaskId(taskList)
	local rtnSortedList = taskList
	if not TableIsEmpty(rtnSortedList) then
		table.sort(rtnSortedList, function(a, b)
			return a:GetTaskId() < b:GetTaskId()
		end)
	end
	return rtnSortedList
end

--是否有环任务
function TaskModel:IsHasCycleTask()
	for index = 1, #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			if curTaskDataObj:GetTaskType() == TaskConst.TaskType.CycleTask then
				return true
			end
		end
	end
	return false
end

function TaskModel:InitCycleTaskNum()
	local mainPlayerVo = LoginModel:GetInstance():GetLoginRole()
	if not TableIsEmpty(mainPlayerVo) then
		self.curCycleTaskNum = mainPlayerVo.weekTaskNum or 0
	end
end

--设置环任务环数
function TaskModel:SetCycleTaskNum(num)
	if num then
		self.curCycleTaskNum = num
	end
end

function TaskModel:GetCycleTaskNum()
	return self.curCycleTaskNum or 0
end

function TaskModel:GetCycleTaskSum()
	return TaskConst.CycleTaskSum or 0
end

--清除环任务环数
function TaskModel:CleanCycleTaskNum()
	self.curCycleTaskNum = 0
end

function TaskModel:InitDailyTaskNum()
	local mainPlayerVo = LoginModel:GetInstance():GetLoginRole()
	if not TableIsEmpty(mainPlayerVo) then
		self.curDailyTaskNum = mainPlayerVo.dailyTaskNum or 0
	end
end

--[[是否有每日任务]]
function TaskModel:IsHasDailyTask()
	for index = 1, #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			if curTaskDataObj:GetTaskType() == TaskConst.TaskType.DailyTask then
				return true
			end
		end
	end
	return false
end

--设置每日任务当前领取任务次数
function TaskModel:SetDailyTaskNum(num)
	if num then
		self.curDailyTaskNum = num
	end
end

--获取每日任务当前领取任务次数
function TaskModel:GetDailyTaskNum()
	return self.curDailyTaskNum or 0 
end

--清除每日任务当前领取任务次数
function TaskModel:CleanDailyTaskNum()
	self.curDailyTaskNum = 0
end

--是否拥有猎妖任务
function TaskModel:IsHasHuntingMonsterTask()
	for index = 1, #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			if curTaskDataObj:GetTaskType() == TaskConst.TaskType.HuntingMonster then
				return true
			end
		end
	end
	return false
end

--获取当前的主线任务
function TaskModel:GetMainTask()
	for index = 1 , #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			if curTaskDataObj:GetTaskType() == TaskConst.TaskType.MainLine then
				return curTaskDataObj
			end
		end
	end
	return {}
end

function TaskModel:IsCycleTask(taskId)
	if taskId then
		local taskCfg = GetCfgData("task"):Get(taskId)
		if taskCfg then
			if taskCfg.type == TaskConst.TaskType.CycleTask then
				return true
			end
		end
	end
	return false
end

--获取环任务的奖励经验
function TaskModel:GetCycleTaskAwardExp(taskId , expCnt)
	if taskId and expCnt then
		if self:IsCycleTask(taskId) then
			return expCnt * self:GetCycleTaskAwardCoefficient()
		end
	end
	return 0
end

--获取环任务的金币数量
function TaskModel:GetCycleTaskAwardCoin(taskId , coinCnt)
	if taskId and coinCnt then
		if self:IsCycleTask(taskId) then
			return coinCnt * self:GetCycleTaskAwardCoefficient()
		end
	end
	return 0
end

--获取完任务奖励系数
function TaskModel:GetCycleTaskAwardCoefficient()
	local  v = self.curCycleTaskNum % 10;
	if v == 0 then
		v = 10
	end
	return (1 + v * 0.1) * (1 + (math.ceil(self.curCycleTaskNum * 0.1) - 1) * 0.2)
end

function TaskModel:GetTaskListByType(t)
	local rtnList = {}
	if t then
		for index = 1 , #self.taskDataList do
			local curTaskDataObj = self.taskDataList[index]
			if not TableIsEmpty(curTaskDataObj) then
				if curTaskDataObj:GetTaskType() == t then
					table.insert(rtnList , curTaskDataObj)
				end
			end
		end
	end
	return rtnList
end

--构建用于任务面板口风琴组件数据
function TaskModel:GetAccordionData()
	local rtnAccordionData = {}
	local bigTypeData = self:GetBigTypeData()
	for idx = 1 , #bigTypeData do
		local curBigType = bigTypeData[idx]
		local curTaskType = curBigType[1] or -1
		if curTaskType ~= -1 then
			local curTypeTaskList = self:GetTaskListByType(curTaskType)
			curBigType[3] = {}
			if not TableIsEmpty(curTypeTaskList) then
				for taskIdx = 1 , #curTypeTaskList do
					local curTaskObj = curTypeTaskList[taskIdx]
					if not TableIsEmpty(curTaskObj) then
						local taskName = self:SplitNameWithFinish(curTaskObj:GetTaskName())
						table.insert(curBigType[3] , {[1] = curTaskObj:GetTaskId() or 0 , [2] = taskName})
					end
				end
				table.insert(rtnAccordionData , curBigType)
			end
		end
	end
	return rtnAccordionData
end

function TaskModel:SplitNameWithFinish(strTaskName)
	local rtnTaskName = ""
	if strTaskName then
		if string.find(strTaskName , "%(完成%)") ~= nil then
			rtnTaskName = string.sub(strTaskName , 1, -32) --"[COLOR=#00ff00](完成)[/COLOR]" --和策划约定包含ubb字符串的完成共31个字符		
		else
			rtnTaskName = strTaskName
		end
	end
	return rtnTaskName
end

--构建用于任务Task分类列表数据
function TaskModel:GetBigTypeData()
	return TaskConst.TopType
end


function TaskModel:GetInstance()
	if TaskModel.inst == nil then
		TaskModel.inst = TaskModel.New()
	end
	return TaskModel.inst
end

function TaskModel:HandleJoyStickMove(data)
	self.isCanShowSubmitDialog = false
end

function TaskModel:SetShowSubmitDialog(bl)
	if bl ~= nil then
		self.isCanShowSubmitDialog = bl
	end
end

function TaskModel:IsCanShowSubmitDialog()
	return self.isCanShowSubmitDialog
end

--获取引导任务数据（引导ID是否需要）
function TaskModel:GetGuideTaskList(isNeedHasGuideId)
	local rtnTaskDataList = {}
	for index = 1 , #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			if curTaskDataObj:GetTaskType() == TaskConst.TaskType.GuideTask then
				if isNeedHasGuideId then
					if NewbieGuideModel:GetInstance():IsHasGuideInCfg(curTaskDataObj:GetGuideId()) then
						-- self:BreakAuto()
						table.insert(rtnTaskDataList , curTaskDataObj)
					end
				else
					-- self:BreakAuto()
					table.insert(rtnTaskDataList , curTaskDataObj)
				end
			end
		end
	end
	return rtnTaskDataList
end

function TaskModel:GetAutoExecTaskId()
	local rtnTaskId = 0
	local isNeedHasGuideId = true
	local guideTaskList = self:GetGuideTaskList(isNeedHasGuideId)
	local cnt = #guideTaskList
	if  cnt >= 1 then
		rtnTaskId = guideTaskList[cnt]:GetTaskId()
	end
	return rtnTaskId
end

--获取某个任务的引导ID
function TaskModel:GetGuideIDByTaskId(taskId)
	if taskId then
		local taskCfg = GetCfgData("task"):Get(taskId)
		return taskCfg and taskCfg.guildId or 0
	end
	return 0
end

--获取当前类型为好友引导(编号为23)的任务ID(当前仅存在一个该类型的任务，策划配表控制)
function TaskModel:GetFriendTypeTaskId()
	for index = 1 , #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			local taskTarget = curTaskDataObj:GetTaskTarget()
			if not TableIsEmpty(taskTarget) and taskTarget.targetType == TaskConst.TaskTargetType.FriendGuide then
				return curTaskDataObj:GetTaskId()
			end
		end
	end
	return 0
end

--获取到当前自动执行的玩家升级任务Id
--满足玩家等级大于玩家升级任务等级
function TaskModel:GetAutoExecUpgradeLevelTaskId()
	local rtnTaskIdList = {}
	local taskDataObjList = self:GetUpgradeLevelTypeTaskDataList()
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then
		local mainPlayerLev = mainPlayerVo.level or 0
		if mainPlayerLev ~= 0 then
			for index = 1 , #taskDataObjList do
				local taskDataObj = taskDataObjList[index]
				if taskDataObj then
					local taskTarget = taskDataObj:GetTaskTarget()
					local taskId = taskDataObj:GetTaskId()
					if not TableIsEmpty(taskTarget) and #taskTarget.targetParam > 0 and taskId ~= -1 then
						if taskTarget.targetType == TaskConst.TaskTargetType.UpgradeLevel and 
							taskTarget.targetParam[1] <= mainPlayerLev  and
							taskTarget.targetParam[1] ~= 1 then --玩家升级任务类型目标参数为1，有特殊含义，具体含义看task配置表
							table.insert(rtnTaskIdList , taskId)
							break
						end
					end
				end
			end
		end
	end
	return rtnTaskIdList
end

--获取当前类型为玩家升级任务的任务列表
function TaskModel:GetUpgradeLevelTypeTaskDataList()
	local rtnTaskDataList = {}
	for index = 1 , #self.taskDataList do
		local curTaskDataObj = self.taskDataList[index]
		if not TableIsEmpty(curTaskDataObj) then
			local taskTarget = curTaskDataObj:GetTaskTarget()
			if not TableIsEmpty(taskTarget) and taskTarget.targetType == TaskConst.TaskTargetType.UpgradeLevel then
				table.insert(rtnTaskDataList , curTaskDataObj)
			end
		end
	end
	return rtnTaskDataList
end

function TaskModel:__delete()
	self.lastSubmitTaskId = -1
	TaskModel.inst = nil
	self:CleanEvent()
end

--重新登录，重置数据
function TaskModel:Reset()
	self:CleanDailyTaskNum()
	self:CleanLastSubmitTaskNPCInfo()
end

--设置当前任务的交任务NPC
function TaskModel:SetLastSubmitTaskNPCInfo(taskId , npcId)
	if taskId and  npcId then
		self.lastSubmitTaskNPCInfo = {}
		self.lastSubmitTaskNPCInfo.taskId = taskId
		self.lastSubmitTaskNPCInfo.submitNPCId = npcId
	end
end

function TaskModel:GetLastSubmitTaskNPCInfo()
	return self.lastSubmitTaskNPCInfo
end

function TaskModel:CleanLastSubmitTaskNPCInfo()
	self.lastSubmitTaskNPCInfo = {}
end

function TaskModel:SetSubmitTaskLock(bl)
	if bl ~= nil and type(bl) == 'boolean' then
		self.submitTaskLock = bl
	end
end

function TaskModel:GetSubmitTaskLock()
	return self.submitTaskLock
end
--获取寄售NPC对应的NPCID
function TaskModel:GetConsignForSaleNPCID()
	local npcCfg = GetCfgData("npc")
	for k , v in pairs(npcCfg) do
		if k and type(v) ~= 'function' then
			for idx , funId in pairs(v.functionId) do
				if funId == FunctionConst.FunEnum.ConsignForSale then
					return v.eid or -1
				end
			end
		end
	end
	return -1
end
