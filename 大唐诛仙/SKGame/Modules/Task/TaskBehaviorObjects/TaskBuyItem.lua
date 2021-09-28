TaskBuyItem =BaseClass(TaskBehavior)

function TaskBuyItem:__init(taskData)
	self:InitEvent()
end

function TaskBuyItem:__delete()
	
end

function TaskBuyItem:InitEvent()
	TaskBehavior.InitEvent(self)

end

function TaskBuyItem:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.BuyItem)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			self:OpenTradingPanel()
		end
	end
end

function TaskBuyItem:OpenTradingPanel()
	TradingController:GetInstance():Open()
end