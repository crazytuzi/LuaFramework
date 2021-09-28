NPCDialogModel =BaseClass(LuaModel)

function NPCDialogModel:__init()
	self:InitData()
end

function NPCDialogModel:__delete()
	NPCDialogModel.inst = nil
end

function NPCDialogModel:GetInstance()
	if NPCDialogModel.inst == nil then
		NPCDialogModel.inst = NPCDialogModel.New()
	end
	return NPCDialogModel.inst
end

function NPCDialogModel:InitData()
	self.taskData = {}
	self.dramaDialogContent = {} --剧情对白
	self.submitTaskDialogContent = {} --提交任务面板对白
	self.submitTaskDramaDialogContent = {} --提交任务剧情对白
	self.curDialogProcess = 0
	self.curDialogType = TaskConst.NPCTaskDialogType.None
end

function NPCDialogModel:SetData(taskData)
	if taskData ~= nil then
		
		self:SetTaskData(taskData)
		self:SetDramaContent()
		self:SetSubmitTaskContent()
		self:SetSubmitTaskDramaContent()
	end
end

function NPCDialogModel:SetDialogType(dialogType)
	if dialogType ~= nil then
		if dialogType == TaskConst.NPCTaskDialogType.DramaType then
			self.curDialogType = TaskConst.NPCTaskDialogType.DramaType
		elseif dialogType == TaskConst.NPCTaskDialogType.SubmitTaskType then
			self.curDialogType = TaskConst.NPCTaskDialogType.SubmitTaskType
		elseif dialogType == TaskConst.NPCTaskDialogType.SubmitTaskDramaType then
			self.curDialogType = TaskConst.NPCTaskDialogType.SubmitTaskDramaType
		else
			self.curDialogType = TaskConst.NPCTaskDialogType.None
		end
	end
	
end

function NPCDialogModel:SetTaskData(taskData)
	
	
	self.taskData = {}
	self.taskData = taskData or {}
end

function NPCDialogModel:GetTaskData()
	return self.taskData or {}
end

function NPCDialogModel:SetDramaContent()
	self.dramaDialogContent = {}
	self.dramaDialogContent = self.taskData:GetDramaDialog() or {}
end

function NPCDialogModel:SetSubmitTaskContent()
	self.submitTaskDialogContent = {}
	self.submitTaskDialogContent = self.taskData:GetSubmitTaskDialog() or {}
end

function NPCDialogModel:SetSubmitTaskDramaContent()
	self.submitTaskDramaDialogContent = {}
	self.submitTaskDramaDialogContent = self.taskData:GetSubmitTaskDramaDialog() or {}
end


function NPCDialogModel:AddDialogProcess()
	self.curDialogProcess = self.curDialogProcess + 1
end

function NPCDialogModel:GetDialogContentByProcess()
	local rtnCurDialogContent = {}
	if self.curDialogProcess  > 0 then
		
		if self.curDialogType == TaskConst.NPCTaskDialogType.DramaType then
			rtnCurDialogContent = self.dramaDialogContent[self.curDialogProcess] or {}
		elseif self.curDialogType == TaskConst.NPCTaskDialogType.SubmitTaskType then
			rtnCurDialogContent = self.submitTaskDialogContent or {}
		elseif self.curDialogType == TaskConst.NPCTaskDialogType.SubmitTaskDramaType then
			rtnCurDialogContent = self.submitTaskDramaDialogContent[self.curDialogProcess] or {}
		end
	end
	return rtnCurDialogContent
end

function NPCDialogModel:GetDialogType()
	return self.curDialogType
end

function NPCDialogModel:DialogIsEnd()
	local rtnIsEnd = false
	if self.curDialogType == TaskConst.NPCTaskDialogType.DramaType then
		if self.curDialogProcess == #self.dramaDialogContent then
			rtnIsEnd = true
		end
	elseif self.curDialogType == TaskConst.NPCTaskDialogType.SubmitTaskType then
		if self.curDialogProcess == #self.submitTaskDialogContent then
			rtnIsEnd = true
		end
	elseif self.curDialogType == TaskConst.NPCTaskDialogType.SubmitTaskDramaType then
		if self.curDialogProcess == #self.submitTaskDramaDialogContent then
			rtnIsEnd = true
		end
	end
	return rtnIsEnd
end

function NPCDialogModel:EndDialogTask()
	self:CleanData()	
end

function NPCDialogModel:ResetDialogProcess()
	self.curDialogProcess = 0
end


function NPCDialogModel:CleanData()
	self.dramaDialogContent = {}
	self.submitTaskDialogContent = {}
	self.submitTaskDramaDialogContent = {}
	self.curDialogProcess = 0
	self.curDialogType = TaskConst.NPCTaskDialogType.None
end

function NPCDialogModel:Reset()
end