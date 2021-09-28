NPCRankMatchCounter =BaseClass(TaskNPCInteraction)

function NPCRankMatchCounter:Run()
	
	if not TableIsEmpty(self.taskData) then
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			
			self:ProcessTaskEnd()
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			
			self:AcceptTaskDialog()
		end
	end

end