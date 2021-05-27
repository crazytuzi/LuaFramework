RemindManager = RemindManager or BaseClass()

function RemindManager:__init()
	if nil ~= RemindManager.Instance then
		ErrorLog("[RemindManager]:Attempt to create singleton twice!")
	end

	RemindManager.Instance = self

	self.remind_list = {}
	self.remindgroup_list = {}
	self.check_fun_remind_t = {}
	self.next_time_remind_t = {}
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function RemindManager:__delete()
	RemindManager.Instance = nil
end

function RemindManager:OnRecvMainRoleInfo()
	GlobalTimerQuest:AddDelayTimer(function ()
		Runner.Instance:AddRunObj(self, 4)
	end, 1)
end

-- 提醒的条件成立时主动进行一次提醒计算
function RemindManager:OnGameCondChange(cond_def, is_ok)
	if is_ok and RemindLimitCondKey[cond_def] then
		for remind_name, v in pairs(RemindLimitCondKey[cond_def]) do
			self:DoRemindDelayTime(remind_name)
		end
	end
end

function RemindManager:Update(now_time, elapse_time)
	for k, v in pairs(self.next_time_remind_t) do
		if v[1] <= 0 then
			self.next_time_remind_t[k] = nil
			self:DoRemind(k)
		else
			v[1] = v[1] - elapse_time
		end
	end

	if self.auo_remind_time and now_time - self.auo_remind_time < 1 then
		return 
	end
	for k,v in pairs(self.check_fun_remind_t) do
		if v.auto and (v.do_time <= 0 or self.auo_remind_time == nil) then
			v.do_time = v.time
			self:DoRemind(k)
		elseif v.auto then
			v.do_time = v.do_time - 1
		end
	end
	self.auo_remind_time = now_time
end

--获取提醒数量
function RemindManager:GetRemind(remind_name)
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= RemindLimitAll then
		return 0
	end

	return self.remind_list[remind_name] or 0
end

--获取提醒数量
function RemindManager:GetRemindGroup(group_name)
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= RemindLimitAll then
		return 0
	end
	
	return self.remindgroup_list[group_name] or 0
end

--尝试在(time)秒后计算提醒
function RemindManager:DoRemindDelayTime(remind_name, time)
	if self.next_time_remind_t[remind_name] then
		return
	end

	self.next_time_remind_t[remind_name] = {time or (0.2 + math.random() * 0.5)}
end

--刷新某提醒
function RemindManager:DoRemind(remind_name)
	if remind_name == nil then
		if PLATFORM == cc.PLATFORM_OS_WINDOWS then
			print("没有这个名字remind_name, 请查找原因") 
			DebugLog()
		end
		return
	end
	local start_time = os.clock()

	if self.check_fun_remind_t[remind_name] then
		local num = 0
		local remind_limit = RemindLimit[remind_name]
		if remind_limit == nil or GameCondMgr.Instance:GetValue(remind_limit.cond_def) then
			num = self.check_fun_remind_t[remind_name].func(remind_name)
		end
		if self.remind_list[remind_name] ~= num then
			-- 单条提醒
			self.remind_list[remind_name] = num
			GlobalEventSystem:Fire(OtherEventType.REMIND_CAHANGE, remind_name, self.remind_list[remind_name])

			-- 单条提醒对应的组
			if nil ~= RemindOneToGroup[remind_name] then
				for _, group_name in pairs(RemindOneToGroup[remind_name]) do
					if group_name then
						local remind_g = RemindGroup[group_name]
						remind_g[remind_name] = remind_g[remind_name] or 0
						self.remind_list[remind_name] = self.remind_list[remind_name] or 0
						self.remindgroup_list[group_name] = self.remindgroup_list[group_name] or 0
						self.remindgroup_list[group_name] = self.remindgroup_list[group_name] - remind_g[remind_name] + self.remind_list[remind_name]
						remind_g[remind_name] = self.remind_list[remind_name]
						GlobalEventSystem:Fire(OtherEventType.REMINDGROUP_CAHANGE, group_name, self.remindgroup_list[group_name])
					end
				end
			end
		end
	end


	-- 卡顿调试
	if os.clock() - start_time >= 0.1 then
		if PLATFORM == cc.PLATFORM_OS_WINDOWS then
			print("提醒计算时间过长，调用时间:  ", os.clock() - start_time, " remind_name: " , remind_name) 
		end
	end
end

-- 注册提醒数量计算函数
-- auto_do 是否自动每间隔一段时间进行计算
-- time 自动计算的时间间隔
function RemindManager:RegisterCheckRemind(func, remind_name, auto_do, time)
	self.check_fun_remind_t[remind_name] = {}
	self.check_fun_remind_t[remind_name].func = func
	self.check_fun_remind_t[remind_name].auto = auto_do
	self.check_fun_remind_t[remind_name].time = time or 5
	self.check_fun_remind_t[remind_name].do_time = time or 5
end
