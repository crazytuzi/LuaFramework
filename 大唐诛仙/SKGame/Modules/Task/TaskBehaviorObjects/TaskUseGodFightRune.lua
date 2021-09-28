TaskUseGodFightRune =BaseClass(TaskBehavior)

function TaskUseGodFightRune:__init(taskData)
	self:InitEvent()
end

function TaskUseGodFightRune:__delete()
end

function TaskUseGodFightRune:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskUseGodFightRune:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.UseGodFightRune)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenGodFightRunePanel()
		end
	end
end

function TaskUseGodFightRune:OpenGodFightRunePanel()
	GodFightRuneController:GetInstance():OpenGodFightRunePanel()
end

