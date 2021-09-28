TaskCompose =BaseClass(TaskBehavior)

function TaskCompose:__init(taskData)
	
	self:InitEvent()
end

function TaskCompose:__delete()
	
end

function TaskCompose:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskCompose:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.Compose)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenComposePanel()
		end
	end
end

function TaskCompose:OpenComposePanel()
	--暂无通用合成界面
	PkgCtrl:GetInstance():OpenByType()
end