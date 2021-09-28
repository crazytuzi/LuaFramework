TaskDecompose =BaseClass(TaskBehavior)

function TaskDecompose:__init(taskData)
	
	self:InitEvent()
end

function TaskDecompose:__delete()
	
end

function TaskDecompose:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskDecompose:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.Decompose)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
	
		self:OpenDecomposePanel()
	end
end

function TaskDecompose:OpenDecomposePanel()
	--暂无分解界面
	PkgCtrl:GetInstance():OpenByType(PkgConst.PanelType.decomposition)
end

