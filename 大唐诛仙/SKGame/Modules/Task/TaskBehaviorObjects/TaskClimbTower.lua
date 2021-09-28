TaskClimbTower =BaseClass(TaskBehavior)

function TaskClimbTower:__init(taskData)
	
	self:InitEvent()
end

function TaskClimbTower:__delete()
	

end

function TaskClimbTower:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskClimbTower:Behavior()
	
	self:SetTaskTargetType(TaskConst.TaskTargetType.ClimbTower)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		
		self:OpenClimbTowerPanel()
	end
end

function TaskClimbTower:OpenClimbTowerPanel()
	
	ShenJingController:GetInstance():OpenShenJingPanel()
end

