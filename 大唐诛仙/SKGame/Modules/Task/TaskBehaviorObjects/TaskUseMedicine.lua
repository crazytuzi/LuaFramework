TaskUseMedicine =BaseClass(TaskBehavior)

function TaskUseMedicine:__init(taskData)
	self:InitEvent()
end

function TaskUseMedicine:__delete()
	
end

function TaskUseMedicine:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskUseMedicine:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.UseMedicine)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenBagPanel()
		end
	end
end


function TaskUseMedicine:OpenBagPanel()
	PkgCtrl:GetInstance():OpenByType(PkgConst.PanelType.medicine)

end