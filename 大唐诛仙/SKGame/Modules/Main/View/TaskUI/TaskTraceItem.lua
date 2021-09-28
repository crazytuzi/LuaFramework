TaskTraceItem =BaseClass(LuaUI)
function TaskTraceItem:__init( ... )
	self.URL = "ui://0042gnituujrbl"
	self:__property(...)
	self:Config()
end
function TaskTraceItem:SetProperty( ... )
end
function TaskTraceItem:Config()
	self:InitData()
end

function TaskTraceItem:InitData()
	self.isAutoKill = false
	self.taskId = -1
	self.taskData = {}
	self.finishStr = "完成"
end
function TaskTraceItem:SetData(itemData)
	if not TableIsEmpty(itemData) then
		self.taskData = itemData or {}
		self.taskId = itemData:GetTaskId() or -1
	end
end
function TaskTraceItem:GetTaskId()
	return self.taskId
end
function TaskTraceItem:GetData()
	return self.taskData
end
function TaskTraceItem:ManagerAuto()
	TaskModel:GetInstance():SetAutoFight( self.isAutoKill )
end
function TaskTraceItem:SetTaskStateUI()
	local target = self.taskData:GetTaskTarget()
	local tt = target.targetType
	local allCnt = 0
	local hasFinish = false
	local param = target.targetParam
	local TaskTargetType = TaskConst.TaskTargetType
	self.isAutoKill = false
	-- local beDoNext = false
	if tt == TaskTargetType.KillMonster then
		allCnt = param[3] --{mapID，怪物ID，数量}
		self.isAutoKill=self.taskData:GetTaskState()==0 --是否完成
		local beDoNext = TaskModel:GetInstance():SetAutoFight( self.isAutoKill )
		if beDoNext then TaskModel:GetInstance():AutoDoNext() end
	elseif tt == TaskTargetType.CollectItem then
		--allCnt = param[2] --{transferID,数量} --走配置
	elseif tt == TaskTargetType.CopyPass  then
		--allCnt = 1 --- {需要通关的副本id,通关次数}（暂时未定）
	elseif tt == TaskTargetType.GetItem then
		allCnt = param[3] --获取多少个物品
		self.isAutoKill=self.taskData:GetTaskState()==0
		local beDoNext = TaskModel:GetInstance():SetAutoFight( self.isAutoKill )
		if beDoNext then TaskModel:GetInstance():AutoDoNext() end
	elseif tt == TaskTargetType.CycleTaskCounter then
		allCnt = param[1] --完成n次环任务
	elseif tt == TaskTargetType.DailyTaskCounter then
		allCnt = param[1] --完成n次悬赏任务
	elseif tt == TaskTargetType.RankMatchCounter then
		allCnt = param[1] -- 需要完成的天梯匹配次数
	elseif tt == TaskTargetType.HuntingMonsterCounter then
		allCnt = param[1] --需要完成的猎妖次数
	elseif tt == TaskTargetType.Compose then
		allCnt = param[1] --需要完成的合成次数
	else
		allCnt = 0
	end
	local curTaskState = self.taskData:GetTaskState() or -1
	local TaskState = TaskConst.TaskState
	if curTaskState == TaskState.Finish then
		hasFinish = true
	elseif curTaskState == TaskState.NotFinish then
		hasFinish = false
	end
	
	local str = self.taskData:GetTaskContent()
	if allCnt ~= 0 then
		local process = self.taskData:GetTaskProcess()
		if hasFinish == true then
			self.label_task_content_type2.text = string.format(str, process)
		else
			self.label_task_content_type2.text = string.format(str, process)
		end
	else
		if hasFinish == true then
			self.label_task_content_type2.text = str
		else
			self.label_task_content_type2.text = string.format("%s", str)
		end
	end
end

function TaskTraceItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","TaskTraceItem")
	self.image_bg_type1 = self.ui:GetChild("image_bg_type1")
	self.label_task_name_type1 = self.ui:GetChild("label_task_name_type1")
	self.label_task_desc_type1 = self.ui:GetChild("label_task_desc_type1")
	self.group_task_type1 = self.ui:GetChild("group_task_type1")
	self.image_bg_type2 = self.ui:GetChild("image_bg_type2")
	self.loader_icon_type2 = self.ui:GetChild("loader_icon_type2")
	self.label_task_name_type2 = self.ui:GetChild("label_task_name_type2")
	self.label_task_content_type2 = self.ui:GetChild("label_task_content_type2")
	self.group_task_type_2 = self.ui:GetChild("group_task_type_2")
end

function TaskTraceItem:SetUI(itemData)
	self:SetData(itemData)
	self.group_task_type_2.visible = true
	self.group_task_type1.visible = false
	self:SetTaskNameUI()
	self:SetTaskStateUI()
	self:SetTaskTypeUI()
end

function TaskTraceItem:SetTaskTypeUI()
	if not TableIsEmpty(self.taskData) then
		self.loader_icon_type2.url = StringFormat("Icon/Task/{0}", self.taskData:GetTaskType())
	end
end

function TaskTraceItem:SetTaskNameUI()
	if not TableIsEmpty(self.taskData) then
		local strName = ""
		if self.taskData:IsCycleTask() == true then
			local model = TaskModel:GetInstance()
			local strState = StringFormat("{0}/{1}环",model:GetCycleTaskNum(),model:GetCycleTaskSum())
			strName = StringFormat("{0}	{1}",self.taskData:GetTaskData().taskName or "", strState)
		else
			strName = self.taskData:GetTaskData().taskName or ""
		end
		self.label_task_name_type2.text = strName
	end
end

function TaskTraceItem.Create( ui, ...)
	return TaskTraceItem.New(ui, "#", {...})
end

function TaskTraceItem:__delete()
	self.image_bg_type1 = nil
	self.label_task_name_type1 = nil
	self.label_task_desc_type1 = nil
	self.group_task_type1 = nil
	self.image_bg_type2 = nil
	self.loader_icon_type2 = nil
	self.label_task_name_type2 = nil
	self.label_task_content_type2 = nil
	self.group_task_type_2 = nil
end