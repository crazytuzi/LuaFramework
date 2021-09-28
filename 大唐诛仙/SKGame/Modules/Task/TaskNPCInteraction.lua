TaskNPCInteraction =BaseClass()

function TaskNPCInteraction:__init(taskData)
	
	
	self.taskData = taskData or {}
	self.npcDialogModel = NPCDialogModel:GetInstance()
	self.isHasSubmitDramaDialog = false
	self.isHasSubmitPanelShow = false
	self:InitEvent()
end

function TaskNPCInteraction:__delete()
	
	self:RemoveEvent()
end

function TaskNPCInteraction:InitEvent()
	self.handler=GlobalDispatcher:AddEventListener(EventName.FinishSubmitDramaDialog, function ( data )
		self:CallbackFinishSubmitDramaDialog(data)
	end)
end

function TaskNPCInteraction:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler)
end

function TaskNPCInteraction:Run()

end

--任务剧情对白
function TaskNPCInteraction:AcceptTaskDialog()
	if not self:IsCanDialog() then return end

	if self.taskData ~= nil and (not TableIsEmpty(self.taskData)) then
		local taskTarget =  self.taskData:GetTaskTarget()
		if taskTarget ~= nil and (not TableIsEmpty(taskTarget)) and self.taskData:IsHasDramaDialog() == true then
			
			--寻路至对白npc
			--打开对话面板
			
			self.npcDialogModel:SetData(self.taskData)
			self.npcDialogModel:SetDialogType(TaskConst.NPCTaskDialogType.DramaType)
			NPCDialogController:GetInstance():OpenNPCDialogPanel()
		end
	end
end

--提交任务剧情对白
function TaskNPCInteraction:SubmitTaskDialog()
	
	if not TableIsEmpty(self.taskData) then
		local taskTarget = self.taskData:GetTaskTarget()
		if not TableIsEmpty(taskTarget) and self.taskData:IsHasSubmitDramaDialog() == true then
			
			self.npcDialogModel:SetData(self.taskData)
			self.npcDialogModel:SetDialogType(TaskConst.NPCTaskDialogType.SubmitTaskDramaType)
			self:SetOpenSubmitDramaDialog(true)
			NPCDialogController:GetInstance():OpenNPCDialogPanel()

			
		end
	end
end

function TaskNPCInteraction:SetOpenSubmitDramaDialog(isOpen)
	if isOpen then
		self.isHasSubmitDramaDialog = isOpen
	end
end

function TaskNPCInteraction:SetOpenSubmitPanle(isOpen)
	if isOpen then
		self.isHasSubmitPanelShow = isOpen
	end
end

--提交任务面板
function TaskNPCInteraction:ShowSubmitTaskPanel()
	if self.taskData ~= nil and (not TableIsEmpty(self.taskData)) then
				
		self.npcDialogModel:SetData(self.taskData)
		self.npcDialogModel:SetDialogType(TaskConst.NPCTaskDialogType.SubmitTaskType)
		self:SetOpenSubmitPanle(true)
		NPCDialogController:GetInstance():OpenNPCSubmitTaskPanel()
		
	end
end

--[[
	任务收尾处理:
	提交任务剧情对白 -->提交任务面板
]]
function TaskNPCInteraction:ProcessTaskEnd()
	if not self:IsCanDialog() then return end
	
	if self.taskData:IsHasSubmitDramaDialog() == true  then
		
		self:SubmitTaskDialog()
		return
	end
	
	
	if self.taskData:IsNeedShowSubmitPanel() == true  then
		
		self:ShowSubmitTaskPanel()
		return
	else
		
		if self.taskData ~= nil and (not TableIsEmpty(self.taskData)) then
			
			TaskController:GetInstance():SubmitTask(self.taskData:GetTaskId())
		end
		return
	end
end

function TaskNPCInteraction:CallbackFinishSubmitDramaDialog(rtnTaskId)
	if not TableIsEmpty(self.taskData) then
		local curTaskId = self.taskData:GetTaskId()
		if rtnTaskId ~= -1 and rtnTaskId == curTaskId then
			
			if self.taskData:IsNeedShowSubmitPanel() == true then
				
				self:ShowSubmitTaskPanel()
			else
			
				TaskController:GetInstance():SubmitTask(curTaskId)
			end
		end
	end
end

function TaskNPCInteraction:SetTaskState(state)
	if not TableIsEmpty(self.taskData) then
		self.taskData:SetTaskState(state)
	end
end

function TaskNPCInteraction:GetTaskData()
	return self.taskData
end

function TaskNPCInteraction:IsCanDialog()
	local rtnIsCan = false
	local lastSubmitTaskInfo = TaskModel:GetInstance():GetLastSubmitTaskNPCInfo()
	if not TableIsEmpty(lastSubmitTaskInfo) then
		local lastTaskId = lastSubmitTaskInfo.taskId
		local lastSubmitNPCId = lastSubmitTaskInfo.submitNPCId
		if TaskModel:GetInstance():IsHasByTaskId(lastTaskId) and self.taskData:GetTaskId() == lastTaskId and self.taskData:GetSubmitNPCId() == lastSubmitNPCId then
			--print("可以进行对话啦" , self.taskData:GetTaskId())
			rtnIsCan = true
		else
			--print("不可以进行对话啦" , self.taskData:GetTaskId())
		end
	end
	return rtnIsCan
end