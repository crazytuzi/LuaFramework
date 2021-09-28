TaskTeam =BaseClass(LuaUI)
function TaskTeam:__init( ... )
	self.URL = "ui://0042gnithudkb6"
	self:__property(...)
	self:Config()
end

function TaskTeam:SetProperty( ... )
	
end

function TaskTeam:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end
function TaskTeam:InitData()
	self.isInited = false
	self.selectState = TaskTeamConst.TaskTeamState.TaskState
	self.ExtendState = TaskTeamConst.ExtendState.In
	self.model = TaskModel:GetInstance()
	self.taskDataList = self.model:GetAllTaskData()
	self.lastTaskId = -1
	self.lastTaskDataObj = {}

	self.teamItems = {} -- 队伍成员
end
function TaskTeam.Create( ui, ...)
	return TaskTeam.New(ui, "#", {...})
end
function TaskTeam:InitUI()
	self.taskList = self.taskConn:GetChild("list")
	self.taskConn = TaskTraceList.Create(self.taskConn, {})
	self.taskConn:SetUI(self.taskDataList)
	-- 队伍
	self.teamTip = self.ui:GetChild("teamTip")
	self.button_team = self.ui:GetChild("button_team")
	self.teamConn = self.ui:GetChild("teamConn")
	self.btnTeamCreate = UIPackage.CreateObject("Main","BtnTeam")
	self.teamConn:AddChild(self.btnTeamCreate)
	self.btnTeamCreate:SetXY(14, 30)
	self:TeamChangedHandler()
end
function TaskTeam:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","TaskTeam")
	self.c1 = self.ui:GetController("c1")
	self.bg_btn_extend = self.ui:GetChild("bg_btn_extend")
	self.button_task = self.ui:GetChild("button_task")
	self.taskConn = self.ui:GetChild("taskConn")
	self.group_need_move = self.ui:GetChild("group_need_move")
	self.button_extend = self.ui:GetChild("button_extend")
	self.effect_move_out = self.ui:GetTransition("effect_move_out")
	self.effect_rotate_out = self.ui:GetTransition("effect_rotate_out")
	self.effect_move_in = self.ui:GetTransition("effect_move_in")
	self.effect_rotate_in = self.ui:GetTransition("effect_rotate_in")
end

-- 组队信息有变化
function TaskTeam:TeamChangedHandler()
	local mems = ZDModel:GetInstance():GetMember()
	self.btnTeamCreate.visible = next(mems) == nil
	self:UpdateMembers()
end
function TaskTeam:MemHpChangedHandler(playerId)
	local mem = ZDModel:GetInstance():GetMember(playerId)
	if mem then
		for i,v in ipairs(self.teamItems) do
			if v.data and v.data.playerId == playerId then
				v:UpdateHp( v.data.hp, v.data.maxHp )
				break
			end
		end
	end
end
function TaskTeam:UpdateMembers()
	for i,v in ipairs(self.teamItems) do
		v:RemoveFromParent()
	end
	local mems = ZDModel:GetInstance():GetMember()
	local i = 1
	for k,v in pairs(mems) do
		local item = self.teamItems[i]
		if item then
			item:Update(v)
		else
			item = TeamItem.New(v)
		end
		item:SetScale(0.8, 0.8)
		item:SetXY(0, (i-1)*65)
		item:AddTo(self.teamConn)
		self.teamItems[i] = item
		i = i + 1
	end
end
-- 事件
function TaskTeam:InitEvent()
	-- 任务
	self.button_task.onClick:Add(self.OnTaskBtnClick, self)
	self.taskList.onClickItem:Add(self.OnTaskItemClick, self)
	self.button_extend.onClick:Add(self.OnExtendBtnClick, self)

	self.handler1=GlobalDispatcher:AddEventListener(EventName.InitTaskList, function ( data )
		self:InitTaskList(data)
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.UpdateTaskList, function ( data )
		self:UpdateTaskList(data)
	end)
	self.handler3=GlobalDispatcher:AddEventListener(EventName.UpdateTaskState, function ( data )
		self:UpdateTaskState(data)
	end)
	self.syncCycleTaskNumHandle=GlobalDispatcher:AddEventListener(EventName.SyncCycleTaskNum, function(data)
		self:HandleSyncCycleTaskNum(data)
	end)

-- 队伍
	self.button_team.onClick:Add(self.OnTeamBtnClick, self)
	self.btnTeamCreate.onClick:Add(function ()
		self:OnTeamBtnClick()
	end)
	self.teamChangeHandle=GlobalDispatcher:AddEventListener(EventName.TEAM_CHANGED, function ()
		self:TeamChangedHandler()
	end)
	self.memHpChangeHandle=GlobalDispatcher:AddEventListener(EventName.MEMBER_HP_CHANGED, function (playerId)
		self:MemHpChangedHandler(playerId)
	end)
	self.reqTeamHandle= GlobalDispatcher:AddEventListener(EventName.NOTICE_REQ_INTEAM, function ()
		self.teamTip.visible = true
	end)

	self.autoNextHandle= GlobalDispatcher:AddEventListener(EventName.AUTO_DONEXT_TASK, function ()
		if self.taskList and self.taskList.numItems ~= 0 then
			self.taskList.selectedIndex = 0
			self:DoTaskItem(0)
		end
	end)
end


function TaskTeam:OnTaskBtnClick()
	if self.selectState == TaskTeamConst.TaskTeamState.TaskState then
		TaskController:GetInstance():OpenTaskPanel()
	end
	self.selectState = TaskTeamConst.TaskTeamState.TaskState
end

function TaskTeam:OnTeamBtnClick()
	self.teamTip.visible=false
	if SceneModel:GetInstance():IsInNewBeeScene() == true then
		UIMgr.Win_FloatTip("通关彼岸村后可使用组队")
		return
	end

	if self.selectState == TaskTeamConst.TaskTeamState.TeamState then
		ZDCtrl:GetInstance():Open()
	end
	self.selectState = TaskTeamConst.TaskTeamState.TeamState

	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

function TaskTeam:OnExtendBtnClick()
	if TaskTeamConst.ExtendState.In == self.ExtendState then
		self.effect_move_out:Play()
		self.effect_rotate_out:Play()
		self.ExtendState = TaskTeamConst.ExtendState.Out
	elseif TaskTeamConst.ExtendState.Out == self.ExtendState then
		self.effect_move_in:Play()
		self.effect_rotate_in:Play()
		self.ExtendState = TaskTeamConst.ExtendState.In
	end
end

function TaskTeam:IsTaskTeamStateOut()
	return self.ExtendState == TaskTeamConst.ExtendState.Out
end

function TaskTeam:OnTaskItemClick(e)
	e:StopPropagation()
	e:PreventDefault()
	e:CaptureTouch()
	self:DoTaskItem(self.taskList.selectedIndex)
end
function TaskTeam:DoTaskItem(idx)
	idx = idx + 1
	local curTaskDataObj = self.model:GetTaskDataByIndex(idx)
	GlobalDispatcher:DispatchEvent(EventName.AUTO_HPMP, false)
	SceneController:GetInstance():GetScene():StopAutoFight(false) --任务寻路停止自动战斗
	if curTaskDataObj ~= nil and (not TableIsEmpty(curTaskDataObj)) then
		if self.lastTaskId ~= curTaskDataObj:GetTaskId() then
			self.lastTaskDataObj= TaskBehaviorFactory:GetInstance():Create(curTaskDataObj)
			self.lastTaskId = curTaskDataObj:GetTaskId()
		end
		if not TableIsEmpty(self.lastTaskDataObj) then
			local taskModel = TaskModel:GetInstance()
			taskModel:SetShowSubmitDialog(true)
			SceneModel:GetInstance():CleanPathingFlag()
			taskModel:SetLastSubmitTaskNPCInfo(curTaskDataObj:GetTaskId() , curTaskDataObj:GetSubmitNPCId())
			self.lastTaskDataObj:Behavior()
		end
	end
	local item = self.taskConn:GetItem( idx )
	if item then item:ManagerAuto() end
end

function TaskTeam:InitTaskList()
	self.taskDataList = self.model:GetAllTaskData() or {}
	self.taskConn:SetUI(self.taskDataList)
	self.isInited = true
end

function TaskTeam:UpdateTaskList()
	self:UpdateTaskListData()
	self:UpdateTaskListUI()
end

function TaskTeam:UpdateTaskListData()
	self.taskDataList = self.model:GetAllTaskData()
end

function TaskTeam:UpdateTaskListUI()
	self.taskConn:SetUI(self.taskDataList)
end

function TaskTeam:UpdateTaskState(playerTaskMsg)
	local taskModel = TaskModel:GetInstance()
	if not TableIsEmpty(playerTaskMsg) then
		self.taskConn:UpdateTaskState(playerTaskMsg)
		local curTaskDataObj = taskModel:GetTaskDataByID(playerTaskMsg.taskId)
		if not TableIsEmpty(curTaskDataObj) and curTaskDataObj:GetTaskState() == TaskConst.TaskState.Finish then
			local taskObj =  TaskBehaviorFactory:GetInstance():Create(curTaskDataObj)
			if not TableIsEmpty(taskObj) then
				if curTaskDataObj:IsNeedAutoComplete() == true then
					taskModel:SetShowSubmitDialog(true)
					SceneModel:GetInstance():CleanPathingFlag()
					taskModel:SetLastSubmitTaskNPCInfo(curTaskDataObj:GetTaskId() , curTaskDataObj:GetSubmitNPCId())
					taskObj:Behavior()
				end
			end
		end
	end
end

function TaskTeam:HandleSyncCycleTaskNum(data)
	self.taskConn:SyncCycleTaskNum()
end

function TaskTeam:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.syncCycleTaskNumHandle)
	
	GlobalDispatcher:RemoveEventListener(self.teamChangeHandle)
	GlobalDispatcher:RemoveEventListener(self.memHpChangeHandle)
	GlobalDispatcher:RemoveEventListener(self.reqTeamHandle)
	GlobalDispatcher:RemoveEventListener(self.autoNextHandle)
end

function TaskTeam:IsInTeamCtrl()
	return self.c1.selectedIndex == MainUIConst.TaskTeamCtrl.Team
end

function TaskTeam:__delete()
	self:RemoveEvent()
	if self.teamItems then
		for i,v in ipairs(self.teamItems) do
			v:Destroy()
		end
		self.teamItems = nil
	end
	if self.taskConn then
		self.taskConn:Destroy()
	end
	self.taskConn = nil
	self.lastTaskId = nil
	self.lastTaskDataObj = nil
end