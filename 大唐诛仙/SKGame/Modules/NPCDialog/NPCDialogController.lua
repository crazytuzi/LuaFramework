RegistModules("NPCDialog/NPCDialogModel")
RegistModules("NPCDialog/NPCDialogView")
RegistModules("NPCDialog/View/NPCDialogPanel")
RegistModules("NPCDialog/View/NPCHeadUIPanel")
RegistModules("NPCDialog/View/NPCSubmitTaskPanel")
RegistModules("NPCDialog/View/ListNPCTaskReward")
RegistModules("NPCDialog/View/TaskStateSelect")
RegistModules("NPCDialog/NPCDialogConst")
RegistModules("NPCDialog/View/ButtonYellow")

NPCDialogController =BaseClass()

function NPCDialogController:__init()
	self:Config()
	self:InitEvent()
	-- self:RegistProto()
end

function NPCDialogController:__delete()
	self:CleanEvent()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end
	NPCDialogController.inst = nil
end

function NPCDialogController:GetInstance()
	if NPCDialogController.inst == nil then
		NPCDialogController.inst = NPCDialogController.New()
	end
	return NPCDialogController.inst
end

function NPCDialogController:Config()
	self.ctrl = TaskController:GetInstance()
	self.view = NPCDialogView.New()
	self.model = NPCDialogModel:GetInstance()
end

function NPCDialogController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

function NPCDialogController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function NPCDialogController:OpenNPCDialogPanel()
	if self.view then
		self.view:OpenNPCDialogPanel()
	end
end

function NPCDialogController:CloseNPCDialogPanel()
	if self.view then
		self.view:CloseNPCDialogPanel()
	end
end

function NPCDialogController:OpenNPCDialogPanelByNPC(npcId, taskDataList, funId)
	if self.view then
		self.view:OpenNPCDialogPanelByNPC(npcId, taskDataList, funId)
	end
end

function NPCDialogController:OpenNPCSubmitTaskPanel()
	if self.view then
		self.view:OpenNPCSubmitTaskPanel()
	end	
end

function NPCDialogController:OpenNPCHeadUIPanel()
	if self.view then
		self.view:OpenNPCHeadUIPanel()
	end
end

function NPCDialogController:CompleteDialogTask()
	local obj = self.model:GetTaskData()
	if obj ~= nil and (not TableIsEmpty(obj)) then
		if obj:GetTaskState() ~= TaskConst.TaskState.Finish then
			self.ctrl:CompleteTask(obj:GetTaskId())
		end
	end
end

function NPCDialogController:SubmitDialogTask()
	local obj = self.model:GetTaskData()
	if obj ~= nil and (not TableIsEmpty(obj)) then
		self.ctrl:SubmitTask(obj:GetTaskId())
	end
end

function NPCDialogController:NPCDialogPanelIsAlive()
	if self.view then
		return self.view:NPCDialogPanelIsAlive()
	end
end