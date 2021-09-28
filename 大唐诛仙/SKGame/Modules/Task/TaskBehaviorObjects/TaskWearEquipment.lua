TaskWearEquipment =BaseClass(TaskBehavior)

function TaskWearEquipment:__init(taskData)
	
	self:InitEvent()
end

function TaskWearEquipment:InitEvent()
	
	TaskBehavior.InitEvent(self)
	

end

function TaskWearEquipment:__delete()
	
end

function TaskWearEquipment:Behavior()
	
	self:SetTaskTargetType(TaskConst.TaskTargetType.WearEquipment)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenBagPanel()
		end
	end
end

function TaskWearEquipment:OpenBagPanel()
	--PkgCtrl:GetInstance():Open()
	PlayerInfoController:GetInstance():Open()
end


