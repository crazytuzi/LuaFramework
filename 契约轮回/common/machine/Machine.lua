--
-- Author: LaoY
-- Date: 2018-06-30 15:34:52
--

Machine = Machine or class("Machine")

Machine.DefaultGroove = "main"
function Machine:ctor()
	self.machine_list = {}
	self.groove_run_list = {}
	self.is_exit = false
	self.default_state_name = false
	-- 状态机默认状态锁
	self.lock_default_state = false
	MachineManager:GetInstance():CreateMachine(self)
	-- 创建默认的槽
	self:CreateGroove(Machine.DefaultGroove)
end

function Machine:dctor()
	MachineManager:GetInstance():RemoveMachine(self)
end

function Machine:CreateGroove(groove)
	if self.machine_list[groove] then
		logWarn(string.format("the groove is existence , the name is %s",groove))
		return
	end
	self.machine_list[groove] = {}
end

function Machine:CreateState(state_name,groove)
	groove = groove or Machine.DefaultGroove
	if not self.machine_list[groove] then
		-- logError(string.format("the groove is Non-existent , the name is %s",groove))
		return
	end
	local machine_state = self.machine_list[groove][state_name]
	-- 重复创建的话给个提示就好了
	if machine_state then
		logWarn(string.format("the state_name is existence , the name is %s",state_name))
	end
	if not machine_state then
		machine_state = MachineState(state_name,groove)
		self.machine_list[groove][state_name] = machine_state
	end
	return machine_state
end

function Machine:SetDefaultState(state_name)
	self.default_state_name = state_name
end

function Machine:GetCurStateName(groove)
	groove = groove or Machine.DefaultGroove
	local cur_machine_state = self.groove_run_list[groove]
	if cur_machine_state then
		return cur_machine_state:GetStateName()
	end
	return nil
end

function Machine:ChangeState(state_name,groove)
	self.lock_default_state = state_name == nil
	local is_use_defalut = state_name == nil
	state_name = state_name or self.default_state_name
	groove = groove or Machine.DefaultGroove
	if not self.machine_list[groove] then
		-- logError(string.format("the groove is Non-existent , the name is %s",groove))
		return
	end
	local machine_state = self.machine_list[groove][state_name]
	if not machine_state then
		-- logError(string.format("the state_name is Non-existent , the groove is %s, the name is %s",groove,state_name))
		traceback()
		return
	end

	local cur_machine_state = self.groove_run_list[groove]
	if cur_machine_state and state_name == cur_machine_state:GetStateName() then
		return
	end

	if self.change_start_call_back then
		self.change_start_call_back(state_name,groove)
	end

	if cur_machine_state then
		cur_machine_state:OnExit(state_name)
	end

	if is_use_defalut and not self.lock_default_state then
		return
	end

	-- 有可能退出状态机的时候又加载了新的状态机
	while(self.groove_run_list[groove] and self.groove_run_list[groove].is_playing and self.groove_run_list[groove] ~= machine_state) do
		self.groove_run_list[groove]:OnExit(state_name)
	end

	machine_state:onEnter()
	self.groove_run_list[groove] = machine_state

	if self.change_finish_call_back then
		self.change_finish_call_back(state_name,groove)
	end
	self.is_exit = false
	self.lock_default_state = false
end

--[[
	@param change_start_call_back 	改变状态回调，开始改变
	@param change_finish_call_back 	改变状态回调，完成改变
]]
function Machine:SetCallBack(change_start_call_back,change_finish_call_back)
	self.change_start_call_back  = change_start_call_back
	self.change_finish_call_back = change_finish_call_back
end

--外部一般不调用 用ChangeState管理控制
function Machine:OnEnter()
	for groove,cur_machine_state in pairs(self.groove_run_list) do
		cur_machine_state:onEnter()
	end
end

function Machine:Update(delta_time)
	if self.is_exit then
		return
	end
	for groove,cur_machine_state in pairs(self.groove_run_list) do
		cur_machine_state:Update(delta_time)
	end
end

function Machine:OnExit()
	self.is_exit = true
	for groove,cur_machine_state in pairs(self.groove_run_list) do
		cur_machine_state:OnExit()
	end
	if self.is_exit then
		self.groove_run_list = {}
	end
	self.is_exit = false
end