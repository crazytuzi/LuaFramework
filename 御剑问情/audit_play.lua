
GlobalEventSystem = GlobalEventSystem or nil
GlobalTimerQuest = GlobalTimerQuest or nil

Play = Play or {
	ctrl_state = CTRL_STATE.START,
	is_start_init_module = false,
	module_list = {},
}

function Play:Start()
	table.insert(self.module_list, Runner.New())			-- 循环

	GlobalEventSystem = EventSystem.New()					-- 全局事件系统
	Runner.Instance:AddRunObj(GlobalEventSystem, 3)
	table.insert(self.module_list, GlobalEventSystem)

	GlobalTimerQuest = TimerQuest.New()						-- 定时器
	table.insert(self.module_list, GlobalTimerQuest)

	table.insert(self.module_list, CountDown.New())
	table.insert(self.module_list, GameNet.New())			-- 网络
	table.insert(self.module_list, ConfigManager.New())		-- 配置管理器
	table.insert(self.module_list, StepPool.New())			-- 分步池
	table.insert(self.module_list, GameMapHelper.New())		-- 地图
	table.insert(self.module_list, PreloadManager.New())	-- 预加载
	table.insert(self.module_list, EffectManager.New())		-- 特效

	self.modules_controller = ModulesController.New()		-- 游戏模块

	if self.complete_callback then
		self.complete_callback()
		self.complete_callback = nil
	end
end

function Play:Update(now_time, elapse_time)
	if self.ctrl_state == CTRL_STATE.UPDATE then
		if Runner then
			Runner.Instance:Update(now_time, elapse_time)
		end
	elseif self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.NONE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.NONE then
		self:CheckLoginView()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
end

function Play:SetComplete(complete_callback)
	self.complete_callback = complete_callback
end

function Play:Stop()
	-- 注册通知事件
	self:RefreshStopNotification()

	-- 析构各个模块
	local count = #self.module_list
	for i = count, 1, -1 do
		self.module_list[i]:DeleteMe()
	end
	self.module_list = {}
	self.complete_callback = nil
end

function Play:CheckLoginView()
	local login_view = ViewManager.Instance:GetView(ViewName.Login)
	if self.is_start_init_module or not login_view or not login_view:IsLoaded() then
		return
	end
	self.is_start_init_module = true
	self.modules_controller:Start(function (percent)
		if percent >= 1 then
			table.insert(self.module_list, self.modules_controller)
			table.insert(self.module_list, TipsSystemManager.New())	-- 系统提示
			table.insert(self.module_list, TipsFloatingManager.New())	-- 右下角上漂文字
			table.insert(self.module_list, TipsFloatingName.New())		-- 右下角上漂文字(好友名字用)
			table.insert(self.module_list, TipsActivityNoticeManager.New())	-- 活动公告
			table.insert(self.module_list, TipsEventNoticeManager.New())	-- 事件公告

			-- 注册通知事件
			self:RefreshNotification()

			if self.truly_complete_callback then
				self.truly_complete_callback()
			end

			self.ctrl_state = CTRL_STATE.UPDATE
		end
	end)
end

function Play:SetTrulyCompleteCallBack(truly_complete_callback)
	self.truly_complete_callback = truly_complete_callback
end

function Play:RefreshNotification()
	LocalNotification.CancelAllNotifications(50)

	local now = os.time()
	local date_t = Split(os.date("%w-%H-%M-%S", now), "-")
	local week_pass = date_t[1] * 24 * 3600 + date_t[2] * 3600 + date_t[3] * 60 + date_t[4]
	local week_start = now - week_pass

	local cfg = ConfigManager.Instance:GetAutoConfig("notification_config_auto").notification
	for k,v in pairs(cfg) do
		local notify_time = v.weekday * 24 * 3600 + v.hour * 3600 + v.minute * 60 + v.second
		local next_time = nil
		if notify_time > week_pass then
			next_time = week_start + notify_time
		else
			next_time = week_start + notify_time + 7 * 24 * 60 * 60
		end

		LocalNotification.SendRepeatingNotification(
			k, next_time * 1000, CalendarUnit.Week, v.title, v.content)
	end
end

function Play:RefreshStopNotification()
	if GameVoManager.Instance == nil or GuaJiTaData.Instance == nil then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local info = GuaJiTaData.Instance:GetRuneTowerInfo()
	if main_role_vo == nil or
		info == nil or
		info.offline_time == nil or
		info.offline_time <= 0 then
		return
	end

	local hours = math.floor(info.offline_time / 3600)
	local minutes = math.floor(info.offline_time / 60 - 60 * hours)
	local message = string.format(
		"【%s】已开始进入经验塔挂机；剩余时间：%d小时%d分钟",
		main_role_vo.name,
		hours,
		minutes)
	local now = os.time()
	LocalNotification.SendNotification(49, (now + 60) * 1000, "", message)
end

return Play
