RemindManager = RemindManager or BaseClass()
RemindManager.NOR_TIME = 1800
function RemindManager:__init()
	if nil ~= RemindManager.Instance then
		print_error("[RemindManager]:Attempt to create singleton twice!")
	end
	RemindManager.Instance = self

	self.record_num_t = {}
	self.check_callback_t = {}
	self.check_time_t = {}
	self.execute_callback_t = {}

	self.wait_check_t = {}
	self.wait_check_queue = {}

	self.wait_execute_t = {}
	self.wait_execute_queue = {}

	self.not_remind_list = {}					--不再提醒列表
	self.has_remind_list = {}

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
	self.login_server_connected_handle = GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self.cross_server_connected_handle = GlobalEventSystem:Bind(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectCrossServer, self))
end

function RemindManager:__delete()
	RemindManager.Instance = nil
	GlobalEventSystem:UnBind(self.login_server_connected_handle)
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

local last_check_time = 0
function RemindManager:Update(now_time, elapse_time)
	self:StepCheckRemind(now_time)
	self:StepExecuteRemind(now_time)
	if last_check_time < now_time then
		last_check_time = now_time + 5
		for k,v in pairs(self.check_time_t) do
			if v.time < now_time then
				self:Fire(k)
				if v.perent_remind_name then
					self:Fire(v.perent_remind_name)
				end
			end
		end
	end
end

--触发has_remind 是否提醒过了，用于上线提醒一次
function RemindManager:Fire(remind_name, has_remind)
	if RemindFunName[remind_name] and not OpenFunData.Instance:FunIsUnLock(RemindFunName[remind_name]) then
		return
	end

	if self.not_remind_list[remind_name] then
		return
	end

	if has_remind then
		self.has_remind_list[remind_name] = true
	end

	if self:IsDelayRemind(remind_name) then
		return
	end

	if nil == self.wait_check_t[remind_name] then
		self.wait_check_t[remind_name] = true
		table.insert(self.wait_check_queue, remind_name)
	end
end

--异步检查
function RemindManager:StepCheckRemind(now_time)
	if #self.wait_check_queue <= 0 then
		return
	end

	local remind_name = table.remove(self.wait_check_queue, 1)
	self.wait_check_t[remind_name] = nil

	local num = self.record_num_t[remind_name] or 0


	if not self.not_remind_list[remind_name] then
		if (self.has_remind_list[remind_name] and OnceTimeRemindList[remind_name] and num > 0) --在只提醒一次列表中并且已经提醒一次的就加到不提醒列表中
			or (OnceADayRemindList[remind_name] and self:RemindToday(remind_name)) then --每天提醒一次并今日已提醒过
			self.not_remind_list[remind_name] = true
			self.record_num_t[remind_name] = 0
			self:AddToExecuteWaitQueue(remind_name)
			self:RecalcOwnGroup(remind_name)
			return
		end
	end

	-- 跨服中不显示的小红点红点了
	if IS_ON_CROSSSERVER and NotRemindInCrossServer[remind_name] then
		num = 0
	elseif self.check_time_t[remind_name] and self.check_time_t[remind_name].time > now_time then
		num = 0
	elseif nil ~= self.check_callback_t[remind_name] then
		num = self.check_callback_t[remind_name]()
	end
	local develop_mode = require("editor/develop_mode")
	if develop_mode:IsDeveloper() and num ~= nil and type(num) ~= "number" then
		print_error("红点判定返回值有误:" .. remind_name)
		print_error("错误的返回值为:" .. num)
	end
	if num ~= self.record_num_t[remind_name] then
		self.record_num_t[remind_name] = num
		self:AddToExecuteWaitQueue(remind_name)

		self:RecalcOwnGroup(remind_name)
	end
	if self.check_time_t[remind_name] and self.check_time_t[remind_name].time <= now_time then
		self.check_time_t[remind_name] = nil
	end
end

--异步通知
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

		--不提醒红点就直接等于0
		if self.not_remind_list[group_name] and total_num > 0 then
			self.record_num_t[group_name] = 0
			self:AddToExecuteWaitQueue(group_name)

		elseif IS_ON_CROSSSERVER and NotRemindInCrossServer[group_name] then
			--在跨服中不显示的红点直接等于0
			self.record_num_t[group_name] = 0
			self:AddToExecuteWaitQueue(group_name)

		elseif self.record_num_t[group_name] ~= total_num then
			self.record_num_t[group_name] = total_num
			self:AddToExecuteWaitQueue(group_name)
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

--注册一个提醒事件
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

--绑定一个某提醒事件的监听
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
	--回到登录服要把跨服处理过的红点重新处理一下
	local total_num = 0
	local remind_list = nil
	local temp_remind_name = ""
	for k, _ in pairs(NotRemindInCrossServer) do
		temp_remind_name = k
		remind_list = RemindGroud[temp_remind_name]
		if remind_list then
			--属于组红点
			total_num = 0
			for _, remind_name in pairs(remind_list) do
				total_num = total_num + (self.record_num_t[remind_name] or 0)
			end

			if self.record_num_t[temp_remind_name] ~= total_num then
				self.record_num_t[temp_remind_name] = total_num
				self:AddToExecuteWaitQueue(temp_remind_name)
				self:RecalcOwnGroup(temp_remind_name)
			end
		else
			--属于独立红点
			self:Fire(temp_remind_name)
		end
	end
end

function RemindManager:OnConnectCrossServer()
	for k,v in pairs(RemindName) do
		if self.record_num_t[v] and self.record_num_t[v] > 0 then
			self:Fire(v)
		end
	end
end

function RemindManager:AddNextRemindTime(remind_name, time, perent_remind_name)
	time = Status.NowTime + (time or RemindManager.NOR_TIME)
	self.check_time_t[remind_name] = {time = time, perent_remind_name = perent_remind_name}
	self:Fire(remind_name)
	if perent_remind_name then
		self:Fire(perent_remind_name)
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

function RemindManager:GetRegisterCallback(remind_name)
	return self.check_callback_t[remind_name]
end

--设置不再提醒
function RemindManager:SetDotRemind(remind_name)
	self.not_remind_list[remind_name] = true
	RemindManager.Instance:Fire(remind_name)
end

--今日是否提醒过
function RemindManager:RemindToday(remind_name)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id .. remind_name)
	return remind_day == cur_day
end

--今日是否提醒过（一般打开某界面时设置）
function RemindManager:SetRemindToday(remind_name)
	if self.record_num_t[remind_name] == nil or self.record_num_t[remind_name] == 0 then
		return
	end
	self:SetTodayDoFlag(remind_name)
end

--本地保存今天提醒状态（用于remind局部单日提醒）
function RemindManager:SetTodayDoFlag(remind_name)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	UnityEngine.PlayerPrefs.SetInt(main_role_id .. remind_name, cur_day)
	RemindManager.Instance:Fire(remind_name)
end