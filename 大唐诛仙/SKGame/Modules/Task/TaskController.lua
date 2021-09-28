--任务系统协议处理
TaskController =BaseClass(LuaController)

RegistModules("Task/TaskModel")
RegistModules("Task/TaskView")

RegistModules("Task/View/TaskPanel")

RegistModules("Task/View/AwardItem")
RegistModules("Task/View/AwardList")

RegistModules("Task/View/TaskEffect")
RegistModules("Task/TaskData")
RegistModules("Task/TaskConst")

RegistModules("Task/TaskBehaviorFactory")
RegistModules("Task/TaskBehavior")
RegistModules("Task/TaskBehaviorStrategy")

RegistModules("Task/TaskNPCInteraction")
RegistModules("Task/TaskNPCInteractionFactory")
RegistModules("Task/TaskNPCInteractionStrategy")
RegistModules("Task/TaskObjectMgr")



function TaskController:__init()
	self.model = TaskModel:GetInstance()
	self.view = TaskView.New()
	self.taskObjMgr = TaskObjectMgr:GetInstance()
	
	self:InitEvent()
	self:RegistProto()
end

function TaskController:InitEvent()
	self.handler0 =  GlobalDispatcher:AddEventListener(EventName.SyncPlayerAttr, function(data)
		self:HandleSyncPlayerAttr(data)
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.ROLE_INITED, function()
		self:InitCycleTaskNum()
		self:InitDailyTaskNum()
		GlobalDispatcher:DispatchEvent(EventName.UpdateTaskList)
		GlobalDispatcher:RemoveEventListener(self.handler1)
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED , function ()
		self:InitTaskList()
		self:InitDailyTaskNum()
	end)

	--一进入游戏，就执行带有引导编号的引导类型任务
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH , function ()
		self:AutoExecTask()
		GlobalDispatcher:RemoveEventListener(self.handler3)
	end)
	
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then self.model:Reset() end
	end)
end

function TaskController:InitTaskList()
	local listPlayerTask = LoginModel:GetInstance():GetListPlayerTasks()
	self.model:InitTaskList(listPlayerTask or {})
	GlobalDispatcher:DispatchEvent(EventName.InitTaskList)
end

function TaskController:InitCycleTaskNum()
	self.model:InitCycleTaskNum()
end

function TaskController:InitDailyTaskNum()
	self.model:InitDailyTaskNum()
end

function TaskController:RegistProto()
	self:RegistProtocal("S_SubmitTask")
	self:RegistProtocal("S_SynTaskTrack")
	self:RegistProtocal("S_AbandonTask")
end

--[[
	某个任务已经完成
	删除旧taskId任务数据及其表现
	新增任务playerTask
	具体看协议S_SubmitTask
]]
function TaskController:S_SubmitTask(msgParam)
	local msg = self:ParseMsg(task_pb.S_SubmitTask(), msgParam)
	
	local lastSubmitTaskId = -1
	if msg.taskId ~= 0 then
		lastSubmitTaskId = msg.taskId
	else
		lastSubmitTaskId = self.model:GetLastSubmitTaskId()
	end

	--完成了某个日常任务
	local taskDataObj = self.model:GetTaskDataByID(lastSubmitTaskId)
	local noEmpty = not TableIsEmpty(taskDataObj)
	--添加完成任务时播放音效
	if noEmpty then
		local audioId = taskDataObj:GetFinishAudio()
		if audioId ~= 0 then
			EffectMgr.PlaySound(tostring(audioId))
		end
		if (taskDataObj:IsAutoSumbit() == false) then
			self:ShowTaskCompleteEffect()
		end
		if taskDataObj:IsDailyTask() == true then
			--每次提交“悬赏任务”时，如果还有剩余次数，自动帮玩家打开“悬赏任务”接取面板，否则给出次数已满的提示。
			if taskDataObj:GetTaskLogicalStage() == TaskConst.LogicalStage.Submit then
				local dailyModel = DailyTaskModel:GetInstance()
				if dailyModel:IsMaxHasGetCnt() then
					UIMgr.Win_FloatTip("悬赏任务可接取次数已满")
				else
					local dailyCtrl = DailyTaskController:GetInstance()
					dailyCtrl:OpenDailyTaskPanel()
					if dailyModel:GetDailyListFlag() == false then
						dailyCtrl:GetDailyTaskList()
						dailyModel:SetGetDailyListFlag(true)
					end
				end
			end
			GlobalDispatcher:DispatchEvent(EventName.SubmitDailyTask)
		end
	end
	
	self.taskObjMgr:DestroyTaskObjectById(lastSubmitTaskId)
	self.model:DestroyTaskData(lastSubmitTaskId)
	self.model:SetSubmitTaskLock(false)

	if msg.playerTask then
		self.model:UpgradeTaskList(msg.playerTask)
	end
	
	if lastSubmitTaskId ~= -1 then
		local lastSumitNPCInfo = self.model:GetLastSubmitTaskNPCInfo()
		if not TableIsEmpty(lastSumitNPCInfo) and lastSumitNPCInfo.taskId == lastSubmitTaskId then
			--print("清除提交信息", lastSubmitTaskId)
			self.model:CleanLastSubmitTaskNPCInfo()
		end
		
		GlobalDispatcher:DispatchEvent(EventName.FinishTask , lastSubmitTaskId)
	end
	GlobalDispatcher:DispatchEvent(EventName.UpdateTaskList)
	GlobalDispatcher:DispatchEvent(EventName.UpdateNPCHeadState)
	self:AutoExecTask() --如何接到可执行的引导的任务就直接强制执行
	-- self.model:AutoDoNext()
end

--[[
	同步某个TaskId任务状态
	具体看协议S_SynTaskTrack
]]

function TaskController:S_SynTaskTrack(msgParam)
	local msg = self:ParseMsg(task_pb.S_SynTaskTrack(), msgParam)
	if msg.playerTask then
		self.model:SyncTaskState(msg.playerTask)
		GlobalDispatcher:DispatchEvent(EventName.UpdateTaskState, msg.playerTask)
		GlobalDispatcher:DispatchEvent(EventName.UpdateNPCHeadState)
		-- self.model:AutoDoNext()
	end
end

function TaskController:SubmitTask(taskId)
	if taskId ~= nil then
		local msg = task_pb.C_SubmitTask()
		msg.taskId = taskId
		self:SendMsg("C_SubmitTask", msg)
		self.model:SetSubmitTaskLock(true)
		self.model:SetLastSubmitTaskId(taskId)
	end
end

function TaskController:CompleteTask(taskId)
	if taskId ~= nil then
		local taskDataObj =  self.model:GetTaskDataByID(taskId)
		if not TableIsEmpty(taskDataObj) then
			if taskDataObj:GetTaskState() == TaskConst.TaskState.NotFinish then
				local msg = task_pb.C_CompleteTask()
				msg.taskId = taskId
				self:SendMsg("C_CompleteTask", msg)
			end			
		end
	end
end



function TaskController:OpenTaskPanel()
	if self.view == nil then return end
	self.view:OpenTaskPanel()
end

function TaskController:ShowTaskCompleteEffect()
	if self.view == nil then return end
	local taskEffect = self.view:OpenTaskEffect()
	if taskEffect then
		taskEffect:ShowCompleteEffect()
	end
end

--接取环任务请求
function TaskController:AcceptCycleTask()
	
	local msg = task_pb.C_AcceptWeekTask()
	self:SendMsg("C_AcceptWeekTask", msg)
end

--放弃任务请求
function TaskController:AbandonTask(taskId)
	if taskId then
		local msg = task_pb.C_AbandonTask()
		msg.taskId = taskId
		self:SendMsg("C_AbandonTask", msg)
	end
end

--放弃任务回包
function TaskController:S_AbandonTask(msgParam)
	local msg = self:ParseMsg( task_pb.S_AbandonTask(), msgParam)
	if msg.taskId ~= 0 then
		--如果放弃的是环任务，重置环任务计数
		local taskDataObj = self.model:GetTaskDataByID(msg.taskId)
		if (not TableIsEmpty(taskDataObj)) and (taskDataObj:IsCycleTask() == true) then
			self.model:CleanCycleTaskNum()
		end
		if (not TableIsEmpty(taskDataObj)) and (taskDataObj:IsDailyTask() == true) then
			--print("放弃的是日常任务", msg.taskId)
			GlobalDispatcher:DispatchEvent(EventName.AbandonDailyTask)
		end
		GlobalDispatcher:DispatchEvent(EventName.AbandonTask, msg.taskId)

		--删除某个任务
		self.taskObjMgr:DestroyTaskObjectById(msg.taskId)
		self.model:DestroyTaskData(msg.taskId)
		self.model:SortAllTaskData()
		GlobalDispatcher:DispatchEvent(EventName.UpdateTaskList)
	end
end

function TaskController:HandleSyncPlayerAttr(data)
	if data.propertyId == 61 then
		self.model:SetCycleTaskNum(data.propertyValue)
		GlobalDispatcher:DispatchEvent(EventName.SyncCycleTaskNum)
	end

	if data.propertyId == 64 then
		self.model:SetDailyTaskNum(data.propertyValue)
		GlobalDispatcher:DispatchEvent(EventName.SyncDailyTaskNum)
	end
end

--自动执行引导任务
--先执行引导任务，后执行当前玩家等级高于升级任务类型任务目标等级的任务
function TaskController:AutoExecTask()
	local isHasGuideTask = false
	local autoExecTaskId = self.model:GetAutoExecTaskId()
	local behavior = TaskBehaviorFactory:GetInstance()
	if autoExecTaskId ~= 0 then
		local taskDataObj = self.model:GetTaskDataByID(autoExecTaskId)
		if (not TableIsEmpty(taskDataObj)) and (taskDataObj:GetTaskState() == TaskConst.TaskState.NotFinish) then
			local taskObj = behavior:Create(taskDataObj)
			if not TableIsEmpty(taskObj) then
				self.model:SetShowSubmitDialog(true)
				SceneModel:GetInstance():CleanPathingFlag()
				self.model:SetLastSubmitTaskNPCInfo(taskDataObj:GetTaskId() , taskDataObj:GetSubmitNPCId())
				taskObj:Behavior()
				GlobalDispatcher:DispatchEvent(EventName.StartNewbieGuide , autoExecTaskId)
				isHasGuideTask = true
			end
		end
	end

	if not isHasGuideTask then
		local taskIdList = self.model:GetAutoExecUpgradeLevelTaskId()
		if not TableIsEmpty(taskIdList) and #taskIdList > 0 then
			local taskDataObj = self.model:GetTaskDataByID(taskIdList[1])
			local taskObj = behavior:Create(taskDataObj)
			if not TableIsEmpty(taskObj) then
				self.model:SetLastSubmitTaskNPCInfo(taskDataObj:GetTaskId() , taskDataObj:GetSubmitNPCId())
				taskObj:Behavior()
			end
		end
	end
end

function TaskController:GetInstance()
	if TaskController.inst == nil then
		TaskController.inst = TaskController.New()
	end
	return TaskController.inst
end	

function TaskController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler4)
end

function TaskController:__delete()
	self:CleanEvent()
	
	TaskController.inst = nil

	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
	if self.taskObjMgr then
		self.taskObjMgr:Destroy()
	end
	self.taskObjMgr = nil
end