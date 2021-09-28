TaskFriendGuide =BaseClass(TaskBehavior)

function TaskFriendGuide:__init(taskData)
	
	self:InitEvent()
end

function TaskFriendGuide:__delete()
	
end

function TaskFriendGuide:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskFriendGuide:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.AddFriend)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenFriendPanel()
		end
	end
end

function TaskFriendGuide:OpenFriendPanel()
	FriendController:GetInstance():Open()
end
