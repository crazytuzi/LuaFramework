TaskOperateTeam =BaseClass(TaskBehavior)

function TaskOperateTeam:__init(taskDataObj)
	
	self:InitEvent()
end

function TaskOperateTeam:__delete()
	
end

function TaskOperateTeam:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskOperateTeam:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.OperateTeam)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			ZDCtrl:GetInstance():Open()
		end
	end
end

