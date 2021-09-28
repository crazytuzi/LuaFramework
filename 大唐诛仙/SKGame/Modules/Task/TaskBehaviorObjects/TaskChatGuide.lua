TaskChatGuide =BaseClass(TaskBehavior)

function TaskChatGuide:__init(taskData)
	
	self:InitEvent()
end

function TaskChatGuide:__delete()
	
end

function TaskChatGuide:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskChatGuide:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.ChatGuide)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		self:OpenChatPanel()
	end
end


function TaskChatGuide:OpenChatPanel()
	ChatController:GetInstance():OpenView()
end