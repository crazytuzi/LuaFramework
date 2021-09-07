RemindManager = RemindManager or BaseClass()

function RemindManager:__init()
	if nil ~= RemindManager.Instance then
		print_error("[RemindManager]:Attempt to create singleton twice!")
	end
	RemindManager.Instance = self

	self.record_num_t = {}
	self.record_num_cache_t = {}
	self.check_callback_t = {}
	self.execute_callback_t = {}

	self.wait_check_t = {}
	self.wait_check_queue = {}

	self.wait_execute_t = {}
	self.wait_execute_queue = {}

	self.remind_own_group_t = {}
	for group_name, list in pairs(RemindGroud) do
		for _, remind_name in pairs(list) do
			if group_name ~= remind_name then
				self.remind_own_group_t[remind_name] = self.remind_own_group_t[remind_name] or {}
				table.insert(self.remind_own_group_t[remind_name], group_name)
			end
		end
	end

	Runner.Instance:AddRunObj(self, 8)
	-- GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self.cross_server_connected_handle = GlobalEventSystem:Bind(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
end

function RemindManager:__delete()
	RemindManager.Instance = nil
	GlobalEventSystem:UnBind(self.cross_server_connected_handle)
	Runner.Instance:RemoveRunObj(self)
	for k,v in pairs(DelayRemindList) do
		if v.delay_timer then
			GlobalTimerQuest:CancelQuest(v.delay_timer)
			v.delay_timer = nil
		end
	end
	for k,v in pairs(IntervalRemindList) do
		if v.delay_timer then
			GlobalTimerQuest:CancelQuest(v.delay_timer)
			v.delay_timer = nil
		end
	end
end

function RemindManager:Update(now_time, elapse_time)
	self:StepCheckRemind()
	self:StepExecuteRemind()
end

function RemindManager:Fire(remind_name)
	if RemindFunName[remind_name] and not OpenFunData.Instance:CheckIsHide(RemindFunName[remind_name]) then
		return
	end

	if self:IsDelayRemind(remind_name) then
		return
	end

	if nil == self.wait_check_t[remind_name] then
		self.wait_check_t[remind_name] = true
		table.insert(self.wait_check_queue, remind_name)
	end
end

function RemindManager:StepCheckRemind()
	if #self.wait_check_queue <= 0 then
		return
	end

	local remind_name = table.remove(self.wait_check_queue, 1)
	self.wait_check_t[remind_name] = nil

	local num = self.record_num_t[remind_name] or 0

	if IS_ON_CROSSSERVER then
		num = 0
	elseif nil ~= self.check_callback_t[remind_name] then
		num = self.check_callback_t[remind_name]()
	elseif nil ~= self.record_num_cache_t[remind_name] then
		num = self.record_num_cache_t[remind_name]
	end

	if num ~= self.record_num_t[remind_name] then
		self.record_num_t[remind_name] = num
		self:AddToExecuteWaitQueue(remind_name)
		self:RecalcOwnGroup(remind_name)
	end
end

function RemindManager:StepExecuteRemind()
	if #self.wait_execute_queue <= 0 then
		return
	end

	local t = table.remove(self.wait_execute_queue, 1)
	self.wait_execute_t[t.execute] = nil
	t.execute(t.remind_name, self.record_num_t[t.remind_name] or 0)
end

function RemindManager:RecalcOwnGroup(remind_name)
	local group_list = self.remind_own_group_t[remind_name]
	if nil == group_list then
		return
	end

	for _, group_name in ipairs(group_list) do
		local total_num = 0
		local remind_list = RemindGroud[group_name] or {}
		for _, v in pairs(remind_list) do
			total_num = total_num + (self.record_num_t[v] or 0)
		end

		if self:IsDelayRemind(group_name) then
			if self.record_num_cache_t[group_name] ~= total_num then
				self.record_num_cache_t[group_name] = total_num
				self:AddToExecuteWaitQueue(group_name)
			end
		else
			if self.record_num_t[group_name] ~= total_num then
				self.record_num_t[group_name] = total_num
				self:AddToExecuteWaitQueue(group_name)
			end
		end

		if nil ~= self.remind_own_group_t[group_name] then
			self:RecalcOwnGroup(group_name) -- 继续往上层计算
		end
	end
end

function RemindManager:AddToExecuteWaitQueue(remind_name)
	local list = self.execute_callback_t[remind_name] or {}
	for _, execute in pairs(list) do
		if nil == self.wait_execute_t[execute] then
			table.insert(self.wait_execute_queue, {remind_name = remind_name, execute = execute})
		end
	end
end

function RemindManager:GetRegisterNum(t)
	for k, v in pairs(self.check_callback_t) do
		t["register_remind_name : " .. k] = 1
	end
end

function RemindManager:Register(remind_name, callback)
	self.check_callback_t[remind_name] = callback
end

function RemindManager:UnRegister(remind_name)
	self.check_callback_t[remind_name] = nil
end

function RemindManager:GetBindNum(t)
	for k1, v1 in pairs(self.execute_callback_t) do
		local num = 0
		for k2, v2 in pairs(v1) do
			num = num + 1
		end

		t["remind_name : " .. k1] = num
	end
end

function RemindManager:Bind(execute, remind_name)
	if nil == execute then
		return
	end

	self.execute_callback_t[remind_name] = self.execute_callback_t[remind_name] or {}
	self.execute_callback_t[remind_name][execute] = execute

	self:AddToExecuteWaitQueue(remind_name)
end

function RemindManager:UnBind(execute)
	if nil == execute then
		return
	end

	for k, v in pairs(self.execute_callback_t) do
		v[execute] = nil
	end

	for i = #self.wait_execute_queue, 1, -1 do
		if self.wait_execute_queue[i].execute == execute then
			table.remove(self.wait_execute_queue, i)
		end
	end

	self.wait_execute_t[execute] = nil
end

function RemindManager:GetRemind(remind_name)
	if self:IsDelayRemind(remind_name) then
		return 0
	end
	return self.record_num_t[remind_name] or 0
end

function RemindManager:OnConnectLoginServer()
	for k,v in pairs(RemindName) do
		if self.record_num_t[v] and self.record_num_t[v] > 0 then
			self:Fire(v)
		end
	end
end

-- 每30分钟提醒一次的小红点
function RemindManager:IsIntervalRemind(remind_name)
	if IntervalRemindList[remind_name] and IntervalRemindList[remind_name].delay_time then
		if nil ~= IntervalRemindList[remind_name].delay_timer then
			return true
		end
	end

	return false
end

function RemindManager:CreateIntervalRemindTimer(remind_name)
	self:Fire(remind_name)
	if IntervalRemindList[remind_name] and nil == IntervalRemindList[remind_name].delay_timer then
		local function delay_callback()
			IntervalRemindList[remind_name].delay_timer = nil
			if IntervalRemindList[remind_name] and ClickOnceRemindList[remind_name] then
				ClickOnceRemindList[remind_name] = 1
			end
			self:Fire(remind_name)
		end

		local delay_fire_time = IntervalRemindList[remind_name].delay_time
		IntervalRemindList[remind_name].delay_timer = GlobalTimerQuest:AddDelayTimer(delay_callback, delay_fire_time)
	end
end

-- 延迟小红点提醒,返回结果的同时会添加计时器，延时fire（策划需求）
function RemindManager:IsDelayRemind(remind_name)
	if DelayRemindList[remind_name] and DelayRemindList[remind_name].delay_time then
		local cur_login_sceond = TimeCtrl.Instance:GetServerTime() - GameVoManager.Instance:GetUserVo().login_time
		-- -1是为了更精准些
		if cur_login_sceond < DelayRemindList[remind_name].delay_time - 1 then
			if nil == DelayRemindList[remind_name].delay_timer then
				local function delay_callback()
					self:Fire(remind_name)
					DelayRemindList[remind_name].delay_timer = nil
				end

				local delay_fire_time = DelayRemindList[remind_name].delay_time - cur_login_sceond
				DelayRemindList[remind_name].delay_timer = GlobalTimerQuest:AddDelayTimer(delay_callback, delay_fire_time)
			end

			return true
		end
	end

	return false
end