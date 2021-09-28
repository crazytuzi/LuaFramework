TaskAddFriend =BaseClass(TaskBehavior)

function TaskAddFriend:__init(taskData)
	
	self:InitEvent()
end

function TaskAddFriend:__delete()
	
end

function TaskAddFriend:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskAddFriend:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.AddFriend)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1)  then
			self:OpenFriendPanel()
		end
	end
end

function TaskAddFriend:OpenFriendPanel()
	FriendController:GetInstance():Open()
end



