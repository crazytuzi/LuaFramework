TaskJoinFamily =BaseClass(TaskBehavior)

function TaskJoinFamily:__init(taskData)
	
	self:InitEvent()
end

function TaskJoinFamily:__delete()
	
end

function TaskJoinFamily:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskJoinFamily:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.JoinFamily)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
	
		self:OpenFamilyPanel()
	end
end

function TaskJoinFamily:OpenFamilyPanel()
	--暂无

	--FriendController:GetInstance():OpenFriendPanelByTask()
	FriendController:GetInstance():Open()
end