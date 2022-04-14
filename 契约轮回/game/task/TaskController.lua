-- 
-- @Author: LaoY
-- @Date:   2018-09-05 20:50:26
-- 
require("game.task.RequireTask")

TaskController = TaskController or class("TaskController",BaseController)
local TaskController = TaskController

function TaskController:ctor()
	TaskController.Instance = self
	AutoTaskManager()
	self.model = TaskModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function TaskController:dctor()
end

function TaskController:GetInstance()
	if not TaskController.Instance then
		TaskController.new()
	end
	return TaskController.Instance
end

function TaskController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1103_task_pb"
    self:RegisterProtocal(proto.TASK_LIST, self.HandleTaskList)			--任务列表
    self:RegisterProtocal(proto.TASK_ACCEPT, self.HandleTaskAccept)		--接受任务
    self:RegisterProtocal(proto.TASK_SUBMIT, self.HandleTaskSubmit)		--提交任务
    self:RegisterProtocal(proto.TASK_QUICK, self.HandleTaskQuick)		--快速完成
    self:RegisterProtocal(proto.TASK_UPDATE, self.HandleTaskUpdate)		--更新任务
    self:RegisterProtocal(proto.TASK_REWARD, self.HandleTaskReward)		--章节奖励
end

function TaskController:AddEvents()
	-- --请求基本信息
	local function ON_REQ_TASK_LIST()
		self:RequestTaskList()
	end
	self.model:AddListener(TaskEvent.ReqTaskList, ON_REQ_TASK_LIST)

	-- 接受
	local function ON_REQ_TASK_ACCEPT(task_id)
		self.model:OperateTask(task_id)
		self:RequestTaskAccept(task_id)
	end
	self.model:AddListener(TaskEvent.ReqTaskAccept, ON_REQ_TASK_ACCEPT)

	local function ON_REQ_TASK_SUBMIT(task_id)
		self:RequestTaskSubmit(task_id)
	end
	self.model:AddListener(TaskEvent.ReqTaskSubmit, ON_REQ_TASK_SUBMIT)

	local function ON_REQ_TASK_QUICK(task_id)
		self:RequestTaskQuick(task_id)
	end
	self.model:AddListener(TaskEvent.ReqTaskQuick, ON_REQ_TASK_QUICK)

	local function ON_REQ_TASK_REWARD(chapter)
		self:RequestTaskReward(chapter)
	end
	self.model:AddListener(TaskEvent.ReqTaskReward, ON_REQ_TASK_REWARD)

	local function update_task_func(is_del,chg)
		local function step()
			if table.isempty(chg) then
				self.model:FindNextTask()
			else
				for k,v in pairs(chg) do
					self.model:FindNextTask(v.id)
				end
			end
		end
		if is_del then
			self.model:StopFindNextTaskTime()
			self.model.auto_find_next_time_id = GlobalSchedule:StartOnce(step,0.2)
		else
			if not self.model.auto_find_next_time_id then
				step()
			end
		end
	end
	self.model:AddListener(TaskEvent.AccTaskUpdate,update_task_func)

	local function call_back()
		self.model:EnterDungeon()
	end
	GlobalEvent:AddListener(DungeonEvent.ENTER_DUNGEON_SCENE, call_back)

	local function call_back()
		self.model:LeaveDungeon()
	end
	GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)
end

-- overwrite
function TaskController:GameStart()
	local function step()
		self.model:Brocast(TaskEvent.ReqTaskList)
	end
	GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Super)
end

----请求基本信息
function TaskController:RequestTaskList()
	local pb = self:GetPbObject("m_task_list_tos")
	self:WriteMsg(proto.TASK_LIST,pb)
end

----服务的返回信息
function TaskController:HandleTaskList(  )
	local data = self:ReadMsg("m_task_list_toc")
	-- Yzprint('--LaoY TaskController.lua,line 55--')
	-- Yzdump(data,"data")
	self.model.next_task_id = data.next
	self.model.add_task_id_list = {}
	self.model.task_list = {}
	self.model:AddTaskList(data.tasks)
	self.model:Brocast(TaskEvent.AccTaskList)
end

---- 接受任务
function TaskController:RequestTaskAccept(task_id)
	local pb = self:GetPbObject("m_task_accept_tos")
	pb.task_id = task_id
	self:WriteMsg(proto.TASK_ACCEPT,pb)
end
function TaskController:HandleTaskAccept()
	local data = self:ReadMsg("m_task_accept_toc")
	self.model:AddTask(data.task)
	self.model:Brocast(TaskEvent.AccTaskAccept,data.task.id,data.task)
	if AppConfig.Debug then
		Notify.ShowText("Quest accepted")
	end
end

--- 提交任务
function TaskController:RequestTaskSubmit(task_id)
	local pb = self:GetPbObject("m_task_submit_tos")
	pb.task_id = task_id
	self:WriteMsg(proto.TASK_SUBMIT,pb)
end

function TaskController:HandleTaskSubmit()
	local data = self:ReadMsg("m_task_submit_toc")
	self.model:DeleteTask(data.task_id)
	self.model:Brocast(TaskEvent.AccTaskSubmit,data.task_id)
	self.model:Brocast(TaskEvent.AccTaskUpdate)
	GlobalEvent:Brocast(TaskEvent.FinishTask,data.task_id)
end

--快速完成
function TaskController:RequestTaskQuick(task_id)
	local pb = self:GetPbObject("m_task_quick_tos")
	pb.task_id = task_id
	self:WriteMsg(proto.TASK_QUICK,pb)
end
function TaskController:HandleTaskQuick()
	local data = self:ReadMsg("m_task_quick_toc")
	self.model:Brocast(TaskEvent.AccTaskQuick,data.task_id)
end

--更新任务
function TaskController:HandleTaskUpdate()
	local data = self:ReadMsg("m_task_update_toc")

	self.model.next_task_id = data.next

	if not table.isempty(data.del) then
		self.model:DeleteTaskList(data.del)
	end

	if not table.isempty(data.add) then
		self.model.add_task_id_list = {}
		self.model:AddTaskList(data.add)
		for k,v in pairs(data.add) do
			self.model.add_task_id_list[v.id] = true
		end
		GlobalEvent:Brocast(TaskEvent.GlobalAddTask)
	end

	if not table.isempty(data.chg) then
		self.model:AddTaskList(data.chg)
	end
	self.model:Brocast(TaskEvent.AccTaskUpdate,not table.isempty(data.del),data.chg)
	GlobalEvent:Brocast(TaskEvent.GlobalUpdateTask)
end

-- 章节奖励
function TaskController:RequestTaskReward(chapter)
	local pb = self:GetPbObject("m_task_reward_tos")
	pb.chapter = chapter
	self:WriteMsg(proto.TASK_REWARD,pb)
end
function TaskController:HandleTaskReward()
	local data = self:ReadMsg("m_task_reward_toc")
	self.model:Brocast(TaskEvent.AccTaskReward)
end
