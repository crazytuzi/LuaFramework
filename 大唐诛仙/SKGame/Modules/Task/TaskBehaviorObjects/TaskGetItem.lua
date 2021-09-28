TaskGetItem =BaseClass(TaskBehavior)

function TaskGetItem:__init(taskData)
	
	self:InitEvent()
end

function TaskGetItem:__delete()
	
end

function TaskGetItem:InitEvent()
	TaskBehavior.InitEvent(self)

end

function TaskGetItem:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.GetItem)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
	

	end
end

