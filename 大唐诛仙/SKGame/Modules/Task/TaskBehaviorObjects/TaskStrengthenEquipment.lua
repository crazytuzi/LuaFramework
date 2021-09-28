TaskStrengthenEquipment =BaseClass(TaskBehavior)
function TaskStrengthenEquipment:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.StrengthenEquipment)
	
	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenPlayerCommonPanel()
		end
	end
end

function TaskStrengthenEquipment:OpenPlayerCommonPanel()
	--PlayerInfoController:GetInstance():Open()
	SkillController:GetInstance():OpenSkillPanel(SkillConst.TabType.Wakan)
end