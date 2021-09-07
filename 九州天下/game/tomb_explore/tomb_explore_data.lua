TombExploreData = TombExploreData or BaseClass()

function TombExploreData:__init()
	if TombExploreData.Instance then
		print_error("[TombExploreData] Attemp to create a singleton twice !")
	end
	TombExploreData.Instance = self
	self.cfg = ConfigManager.Instance:GetAutoConfig("activitywanglingexplore_auto")
	self.time_cfg = ActivityData.Instance:GetClockActivityByID(26)
	self.time_quest = nil

	self.callback = BindTool.Bind(self.ActivityOpenTimeCount, self)
	ActivityData.Instance:NotifyActChangeCallback(self.callback)
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.task_change_callback = nil
	self.monitor_task_id = 0

	self.task_scroller_data = {}

	self.timer_callback = nil
end

function TombExploreData:__delete()
	if ActivityData.Instance ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.callback)
	end

	TombExploreData.Instance = nil
end

function TombExploreData:IsTaskAllDone()
	local all_done = true
	for k,v in pairs(self:GetTombFBTaskInfo()) do
		if not v.is_finish then
			all_done = false
		end
	end
	return all_done
end

function TombExploreData:GetBOSSInfo()
	for k,v in pairs(self.cfg.flush_point) do
		if v.id == self.cfg.boss[1].pos_id_start then
			return v.pos_x, v.pos_y, self.cfg.boss.boss_id
		end
	end
end

function TombExploreData:GetBossName(boss_id)
	local single_cfg = self.monster_cfg[boss_id]
	if single_cfg then
		return single_cfg.name
	end
	return ""
end

function TombExploreData:ActivityOpenTimeCount()
	local state_info = ActivityData.Instance:GetActivityStatuByType(26)
	local is_show = false
	if state_info ~= nil and state_info.status == 2 then
		is_show = true
		if self.time_quest == nil then
			self.first_cont = true
			self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
			self.activity_time = state_info.next_time - TimeCtrl.Instance:GetServerTime()
		end
	end
end

function TombExploreData:GetBossCfg()
	return self.cfg.boss[1]
end

function TombExploreData:GetIsSpawnBOSS()
	if self.activity_time ~= nil then
		return (self.activity_time - self.cfg.boss[1].reflush_time_s) > 0
	else
		return false
	end
end

function TombExploreData:Timer()
	self.activity_time = self.activity_time - 1
	if self.first_cont then
		local left_time = self.activity_time - self.cfg.boss[1].reflush_time_s
		if left_time <= 0 then
			self.first_cont = false
			--进入BOSS不再刷新的时间
			TombExploreCtrl.Instance:NotifyNoBOSS()
		end
	end

	if self.activity_time <= 0 then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TombExploreData:GetContinueTime()
	return self.activity_time
end

function TombExploreData:TaskMonitor()
	if self.task_list ~= nil and self.task_change_callback ~= nil then
		for k,v in pairs(self.fb_data.task_list) do
			if v.task_id == self.monitor_task_id then
				if v.cur_param_value > self.task_list[k].cur_param_value then
					self.task_change_callback()
				end
				break
			end
		end
	end
end

--设置王陵活动副本信息
function TombExploreData:SetTombFBInfo(protocol)
	self.fb_data = protocol
	print(ToColorStr((self.fb_data.limit_task_time - TimeCtrl.Instance:GetServerTime()), TEXT_COLOR.GREEN))
	self:FlushTombFBTaskInfo()
	self:TaskMonitor()
	self.task_list = protocol.task_list
end

--获得王陵活动副本信息
function TombExploreData:GetTombFBInfo()
	return self.fb_data
end

function TombExploreData:NotifyTaskProcessChange(task_id, func)
	self.task_change_callback = func
	self.monitor_task_id = task_id
end
function TombExploreData:UnNotifyTaskProcessChange()
	self.task_change_callback = nil
end

--获得副本任务配置
function TombExploreData:GetTaskCfgByID(task_id)
	for k,v in pairs(self.cfg.task_list) do
		if v.task_id == task_id then
			return v
		end
	end
end

--刷新王陵活动副本信息
function TombExploreData:FlushTombFBTaskInfo()
	self.task_scroller_data = {}
	local finish_task_list = {}
	local un_finish_task_list = {}
	for k,v in pairs(self.fb_data.task_list) do
		local task_cfg = self:GetTaskCfgByID(v.task_id)
		local text = ""
		if task_cfg.task_type == 1 then
			--采集
			local gather_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[task_cfg.param_id]
			text = text..ToColorStr(gather_cfg.name, TEXT_COLOR.GREEN_3)
		else
			--打怪
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[task_cfg.param_id]
			text = text..ToColorStr(monster_cfg.name, TEXT_COLOR.GREEN_3)
		end

		if v.is_finish == 1 then
			--完成
			text = text..ToColorStr(Language.TombExplore.HaveReached, TEXT_COLOR.YELLOW)
		else
			--未完成
			text = text..
			ToColorStr("(", TEXT_COLOR.GRAY_WHITE)..
			ToColorStr(v.cur_param_value, TEXT_COLOR.GRAY_WHITE)..
			ToColorStr(" / "..v.param_count, TEXT_COLOR.GRAY_WHITE)..ToColorStr(")", TEXT_COLOR.GRAY_WHITE)
		end

		local data = {}
		data.cfg = task_cfg
		data.target_text = text
		data.is_double_reward = (v.is_double_reward == 1)
		data.is_finish = (v.is_finish == 1)

		if data.is_finish then
			table.insert(finish_task_list, data)
		elseif data.is_double_reward then
			table.insert(self.task_scroller_data, data)
		else
			table.insert(un_finish_task_list, data)
		end
	end
	for k,v in pairs(un_finish_task_list) do
		table.insert(self.task_scroller_data, v)
	end
	for k,v in pairs(finish_task_list) do
		table.insert(self.task_scroller_data, v)
	end
end

function TombExploreData:GetTombFBTaskInfo()
	return self.task_scroller_data
end

--获取王陵活动等级要求
function TombExploreData:GetTombActivityLevel()
	return self.time_cfg.min_level
end

--获取王陵活动开启时间
function TombExploreData:GetTombActivityOpenTime()
	local day = Split(self.time_cfg.open_day, ":")
	local day_text = ""
	if #day >= 7 then
		day_text = Language.Activity.EveryDay
	else
		day_text = Language.Activity.WeekDay
		for k,v in pairs(day) do
			day_text = day_text..Language.Common.NumToChs[tonumber(v)]
			if k < #day then
				day_text = day_text.."、"
			end
		end
	end
	day_text = day_text.." "..self.time_cfg.open_time.."-"..self.time_cfg.end_time

	return day_text
end

--获取王陵活动奖励
function TombExploreData:GetTombActivityRewards()
	local rewards = {}
	for i=1,10 do
		local reward = self.time_cfg["reward_item"..i]
		if reward ~= nil then
			table.insert(rewards, reward)
		else
			break
		end
	end
	return rewards
end

function TombExploreData:GetTombActivityOtherCfg()
	return self.cfg.other[1]
end

--获取王陵活动奖励
function TombExploreData:GetTombActivityRewards()
	local rewards = {}
	for i=1,10 do
		local reward = self.time_cfg["reward_item"..i]
		if reward ~= nil then
			table.insert(rewards, reward)
		else
			break
		end
	end
	return rewards
end
