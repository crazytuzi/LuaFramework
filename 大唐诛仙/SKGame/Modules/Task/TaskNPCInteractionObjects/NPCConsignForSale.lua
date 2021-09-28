NPCConsignForSale =BaseClass(TaskNPCInteraction)

function NPCConsignForSale:Run()
	
	if not TableIsEmpty(self.taskData) then
		local state = self.taskData:GetTaskState()
		if state == TaskConst.TaskState.Finish then
			
			self:ProcessTaskEnd()
		elseif state == TaskConst.TaskState.NotFinish then
			
			self:AcceptTaskDialog()
		end
	end
end