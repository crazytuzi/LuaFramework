TaskSwitchModelGuide =BaseClass(TaskBehavior)

function TaskSwitchModelGuide:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.SwitchModelGuide)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenPKModelSwitchUI()
		end
	end
end

function TaskSwitchModelGuide:OpenPKModelSwitchUI()
	local mainCityUI = MainUIController:GetInstance():GetPanel()
	if mainCityUI then
		mainCityUI:ShowModelSelect()

	end
end

function TaskSwitchModelGuide:__init(taskData)
	
	self:InitEvent()
end

function TaskSwitchModelGuide:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskSwitchModelGuide:__delete()
	
end
