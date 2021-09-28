RegistModules("DailyTask/DailyTaskModel")
RegistModules("DailyTask/DailyTaskView")

RegistModules("DailyTask/View/DailyTaskPanel")
RegistModules("DailyTask/View/DailyTaskContent")
RegistModules("DailyTask/View/DailyTaskItem")
RegistModules("DailyTask/View/DifficultyItem")
RegistModules("DailyTask/View/StarItem")
RegistModules("DailyTask/DailyTaskConst")

DailyTaskController =BaseClass(LuaController)

function DailyTaskController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end

function DailyTaskController:__delete()
	self:CleanEvent()
	DailyTaskController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end

function DailyTaskController:Config()
	self.model = DailyTaskModel:GetInstance()
	self.view = DailyTaskView.New()
end

function DailyTaskController:GetInstance()
	if DailyTaskController.inst == nil then
		DailyTaskController.inst = DailyTaskController.New()
	end
	return DailyTaskController.inst
end

function DailyTaskController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

function DailyTaskController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function DailyTaskController:RegistProto()
	self:RegistProtocal("S_SynDailyTaskList")
end

function DailyTaskController:S_SynDailyTaskList(bff)
	local msg = self:ParseMsg(task_pb.S_SynDailyTaskList(), bff)
	if msg then
		self.model:SyncDailyTaskList(msg)
		GlobalDispatcher:DispatchEvent(EventName.SynDailyTaskList)
	end
end

--获取每日任务列表
function DailyTaskController:GetDailyTaskList()
	local msg = task_pb.C_GetDailyTaskList()
	self:SendMsg("C_GetDailyTaskList", msg)
end

--刷新每日任务列表
function DailyTaskController:RefrshDailyTask(refershType)
	local msg = task_pb.C_RefrshDailyTask()
	msg.type = refershType or 0
	self:SendMsg("C_RefrshDailyTask", msg)
end

--接受每日任务
function DailyTaskController:AcceptDailyTask(taskId)
	if taskId then
		local msg = task_pb.C_AcceptDailyTask()
		msg.taskId = taskId
		self:SendMsg("C_AcceptDailyTask", msg)
	end
end

function DailyTaskController:OpenDailyTaskPanel()
	if self.view then
		self.view:OpenDailyTaskPanel()
	end
end

function DailyTaskController:CloseDailyTaskPanel()
	if self.view then
		self.view:CloseDailyTaskPanel()
	end
end