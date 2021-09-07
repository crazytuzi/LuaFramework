ActivityData = ActivityData or BaseClass()

ActivityData.Act_Type = {
	normal = 1,
	boss = 2,
	boss_remindind = 3,
	battle_field = 4,
	kuafu_battle_field = 5,
	monster_siege = 6,
}

ActivityData.Boss_State = {
	not_start = 0,
	ready = 1,
	death = 2,
	time_over = 3,
}

ActivityData.BossType = {
	WORLD_BOSS = 0,
	BOSS_HOME = 1,
	ELITE_BOSS = 2,
	DABAO_MAP = 3,
}

ACTIVITY_ACT_TYPE_BATTLE = {
	ACT_ID_BATTLE_COUNTRY = 5,
	ACT_ID_BATTLE_FORD = 14,
	ACT_ID_BATTLE_FISH = 6,
	ACT_ID_BATTLE_COUNTRY_BRICK = 21,
}

ACTIVITY_ACT_TYPE_DAILY = {
	ACT_ID_DAILY_YU = 3085,
	ACT_ID_DAILY_MINE = 3082,
	ACT_ID_DAILY_WEAPON = 3,
	ACT_ID_DAILY_FORD = 25,
	ACT_ID_DAILY_BANZHUAN = 28,
}

ACTIVITY_ACT_QIXI_DATA = {
	{act_id = 2193, remind = "QixiCombat"},
	{act_id = 2192},
	{act_id = 4001, remind = "CrossFlowerRank"},
	{act_id = 2194, remind = "SendFlower"},
}

ACTIVITY_ACT_MID_AUTUMN_DATA = {
	{act_id = 2198, remind = "MoonLightLanding"},
	{act_id = 2199, remind = "MidAutumnLottery"},
	{act_id = 2203, remind = "MidAutumnCupMoon"},
	{act_id = 2202, remind = "MidAutumnActExchange"},
	{act_id = 2201, remind ="MidAutumnActTask"},
	{act_id = 2200, remind = "MidAutumnMoonGift"},
}

function ActivityData:__init()
	if ActivityData.Instance then
		print_error("[ActivityData] Attempt to create singleton twice!")
		return
	end
	ActivityData.Instance = self

	self.activity_list = {}									-- 活动信息
	self.room_info_list = {}								-- 房间信息
	self.all_boss_info = {}
	self.worldboss_list = {}

	self.act_change_callback = {}

	-- 卷轴红点
	self.red_point_states = {}

	--self.act_list_cfg = ConfigManager.Instance:GetAutoConfig("daily_activity_auto").daily
	self.act_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("daily_activity_auto").daily, "act_type")

	--self.rand_act_open_list_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg

	self.next_monster_invade_time = 0
	-- self:SetActivityStatus(ACTIVITY_TYPE.ACTIVITY_HALL, ACTIVITY_STATUS.OPEN, 4000000000)
	-- self:DailyInit()

	self.activity_config = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto")
	self.activity_config_show_cfg = ListToMapList(self.activity_config.show_cfg, "act_type")
	self.activity_config_id_cfg = ListToMap(self.activity_config.show_cfg, "act_id")
	self.activity_config_forecast = ListToMap(self.activity_config.forecast, "act_type")
	self.rand_act_open_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg, "activity_type")
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	self.worldboss_auto = ConfigManager.Instance:GetAutoConfig("worldboss_auto")
	self.all_boss_list = self.worldboss_auto.worldboss_list
	self.all_boss_config_id = ListToMapList(self.all_boss_list, "bossID")
	for k,v in pairs(self.all_boss_list) do
		--if v.boss_tag == ActivityData.BossType.WORLD_BOSS then
			table.insert(self.worldboss_list, v)
		--end
	end
	-- table.sort(self.worldboss_list, ActivityData.KeyDownSort("boss_level", "refresh_time"))
	self.worldboss_list[0] = table.remove(self.worldboss_list, 1)

	self.cross_info = {
		cross_activity_type = 0,
		login_server_ip = "",
		login_server_port = 0,
		pname = "",
		login_time = 0,
		login_str = "",
		anti_wallow = 0,
		server = 0,
	}

	self.boss_personal_hurt_info = {
		my_hurt = 0,
		self_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_guild_hurt_info = {
		my_guild_hurt = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_week_rank_info = {
		my_guild_kill_count = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.next_refresh_time = 0

	self.is_send_zhuagui_invite = false 			--是否等待发出秘境降魔邀请
	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChangeCallBack, self))
	RemindManager.Instance:Register(RemindName.ActivityHall, BindTool.Bind(self.ActivityCallBackBattleOrDailyRed, self))
	RemindManager.Instance:Register(RemindName.ACTIVITY_JUAN_ZHOU, BindTool.Bind(self.IsShowRedPointJuan, self))
end

function ActivityData:__delete()
	GlobalEventSystem:UnBind(self.pass_day_handle)
	RemindManager.Instance:UnRegister(RemindName.ActivityHall)
	RemindManager.Instance:UnRegister(RemindName.ACTIVITY_JUAN_ZHOU)
	ActivityData.Instance = nil
end

function ActivityData:ClearCache()
	self.boss_personal_hurt_info = {
		my_hurt = 0,
		self_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_guild_hurt_info = {
		my_guild_hurt = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}
end

--对活动进行排序
local function Sort_Activity(act_a, act_b)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.level >= act_a.min_level and main_vo.level >= act_b.min_level then
		local act_a_is_open = ActivityData.Instance:GetActivityIsOpen(act_a.act_id)
		local act_b_is_open = ActivityData.Instance:GetActivityIsOpen(act_b.act_id)
		if act_a_is_open ~= act_b_is_open then
			return act_a_is_open
		else
			local server_time = TimeCtrl.Instance:GetServerTime()
			local now_weekday = os.date("%w", server_time)
			local server_time_str = os.date("%H:%M", server_time)

			local a_open_day_list = Split(act_a.open_day, ":")
			local a_open_time_list = Split(act_a.open_time, "|")
			local a_open_time_str = a_open_time_list[1]
			local a_end_time_list = Split(act_a.end_time, "|")
			-- local a_end_time_str = a_end_time_list[1]

			local b_open_day_list = Split(act_b.open_day, ":")
			local b_open_time_list = Split(act_b.open_time, "|")
			local b_open_time_str = b_open_time_list[1]
			local b_end_time_list = Split(act_b.end_time, "|")
			-- local b_end_time_str = b_end_time_list[1]

			local a_today_open = false
			for k, v in ipairs(a_open_day_list) do
				if v == now_weekday then
					local though_time = true
					for k1, v1 in ipairs(a_end_time_list) do
						if v1 > server_time_str then
							though_time = false
							a_open_time_str = a_open_time_list[k1]
							break
						end
					end
					if not though_time then
						a_today_open = true
					end
					break
				end
			end
			local b_today_open = false
			for k, v in ipairs(b_open_day_list) do
				if v == now_weekday then
					local though_time = true
					for k1, v1 in ipairs(b_end_time_list) do
						if v1 > server_time_str then
							though_time = false
							b_open_time_str = b_open_time_list[k1]
							break
						end
					end
					if not though_time then
						b_today_open = true
					end
					break
				end
			end
			if (a_today_open and b_today_open) or (not a_today_open and not b_today_open) then
				return a_open_time_str < b_open_time_str
			else
				return a_today_open
			end
		end
	else
		return act_a.min_level < act_b.min_level
	end
end

function ActivityData:GetClockActivityByType(act_type)
	local temp_list = {}
	-- if self.activity_config then
	-- 	for _,v in pairs(self.activity_config.show_cfg) do
	-- 		if v.act_type == act_type then
	-- 			table.insert(temp_list, v)
	-- 		end
	-- 	end
	-- end

	if act_type ~= nil then
		local cfg = self.activity_config_show_cfg[act_type]
		if cfg ~= nil then
			for k,v in pairs(cfg) do
				if v ~= nil then
					table.insert(temp_list, v)
				end
			end
		end
	end

	table.sort(temp_list, Sort_Activity)
	return temp_list
end

function ActivityData:GetClockActivityCountByType(act_type)
	local count = 0
	-- if self.activity_config then
	-- 	for _,v in pairs(self.activity_config.show_cfg) do
	-- 		if v.act_type == act_type then
	-- 			count = count + 1
	-- 		end
	-- 	end
	-- end

	if act_type ~= nil then
		local cfg = self.activity_config_show_cfg[act_type]
		if cfg ~= nil then
			for k,v in pairs(cfg) do
				if v ~= nil then
					count = count + 1
				end
			end
		end
	end

	return count
end

function ActivityData:GetClockActivityByID(id)
	--local act_info = {}
	-- for k,v in ipairs(self.activity_config.show_cfg) do
	-- 	if v.act_id == id then
	-- 		act_info = v
	-- 		break
	-- 	end
	-- end
	if id ~= nil then
		return self.activity_config_id_cfg[id]
	end
	return nil
end

function ActivityData:GetActivityInfoById(id)
	local act_info = {}
	local activity_list = self:GetClockActivityByType(ActivityData.Act_Type.normal)
	for k, v in ipairs(activity_list) do
		if v.act_id == id then
			act_info = v
			break
		end
	end
	if not next(act_info) then
		activity_list = self:GetClockActivityByType(ActivityData.Act_Type.battle_field)
		for k2, v2 in ipairs(activity_list) do
			if v2.act_id == id then
				act_info = v2
				break
			end
		end
	end
	if not next(act_info) then
		activity_list = self:GetClockActivityByType(ActivityData.Act_Type.kuafu_battle_field)
		for k2, v2 in ipairs(activity_list) do
			if v2.act_id == id then
				act_info = v2
				break
			end
		end
	end

	if not next(act_info) then
		activity_list = self:GetClockActivityByType(ActivityData.Act_Type.monster_siege)
		for k2, v2 in ipairs(activity_list) do
			if v2.act_id == id then
				act_info = v2
				break
			end
		end
	end
	return act_info
end

function ActivityData:SetActivityStatus(activity_type, status, next_time, start_time, end_time, open_type)
	self.activity_list[activity_type] = {
		["type"] = activity_type,
		["status"] = status,
		["next_time"] = next_time,
		["start_time"] = start_time,
		["end_time"] = end_time,
		["open_type"] = open_type,
	}
	for k, v in pairs(self.act_change_callback) do
		v(activity_type, status, next_time, open_type)
	end
	if status == ACTIVITY_STATUS.CLOSE then
		self:SetNewServerAct()
	end
end

function ActivityData:GetActivityStatus()
	return self.activity_list
end

function ActivityData:GetActivityStatuByType(activity_type)
	return self.activity_list[activity_type]
end

function ActivityData:ClearAllActivity()
	for k,v in pairs(self.activity_list) do
		if v.status ~= ACTIVITY_STATUS.CLOSE then
			v.status = ACTIVITY_STATUS.CLOSE
			for k1, v1 in pairs(self.act_change_callback) do
				v1(k, ACTIVITY_STATUS.CLOSE, 0, open_type)
			end
		end
	end
end

--获得某个活动是否开启
function ActivityData:GetActivityIsOpen(act_type)
	local activity_info = self:GetActivityStatuByType(act_type)
	if nil ~= activity_info and ACTIVITY_STATUS.OPEN == activity_info.status then
		return true
	end
	-- local cfg = self:GetActivityConfig(act_type)
	-- if cfg then
	-- 	if cfg.is_allday == 1 then
	-- 		return true
	-- 	end
	-- end
	return false
end

function ActivityData:SetNextMonsterInvadeTime(time)
	self.next_monster_invade_time = time
end

function ActivityData:GetNextMonsterInvadeTime()
	return self.next_monster_invade_time
end

--根据类型获得活动配置
function ActivityData:GetActivityNameByType(act_type)
	--local show_cfg = self.activity_config.show_cfg or {}
	local cfg = {}
	local act_name = ""
	if act_type ~= nil then
		cfg = self.activity_config_id_cfg[act_type]
		if cfg ~= nil then
			act_name = cfg.act_name
		end
	end
	-- local act_name = cfg.act_name or ""
	-- for k, v in ipairs(show_cfg) do
	-- 	if act_type == v.act_id then
	-- 		act_name = v.act_name
	-- 		break
	-- 	end
	-- end
	if act_name == "" and act_type ~= nil then
		-- for k, v in ipairs(self.rand_act_open_list_cfg) do
		-- 	if v.activity_type == act_type then
		-- 		act_name = v.name
		-- 		break
		-- 	end
		-- end
		cfg = self.rand_act_open_list_cfg[act_type]
		if cfg ~= nil then
			act_name = cfg.name or ""
		end
		-- act_name = cfg.name or ""
	end
	return act_name
end

function ActivityData:GetBossState(boss_id)
	return ActivityData.Boss_State.ready
end

--获得某个活动是否当天开启
function ActivityData:GetActivityIsInToday(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return false end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local updata_time = math.max(server_time - 6 * 3600, 0) 	-- 6点刷新时间
	local w_day = tonumber(os.date("%w", updata_time))
	if 0 == w_day then w_day = 7 end

	local open_day_list = Split(act_cfg.open_day, ":")
	local is_open_day = false
	for k, v in pairs(open_day_list) do
		if tonumber(v) == w_day then
			is_open_day = true
			break
		end
	end
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay() or -1
	local special_day = self.activity_config.other[1].special_day or 0
	--开服前几天特殊处理
	if open_day > 0 and open_day <= special_day then
		is_open_day = act_cfg.open_day == open_day
	end
	return is_open_day
end

--获得某个活动是否已经进行完
function ActivityData:GetActivityIsOver(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil then
		return false
	end
	if self:GetActivityIsInToday(act_type) then
		if self:GetActivityIsOpen(act_type) then
			return false
		else
			local server_time = TimeCtrl.Instance:GetServerTime()
			local time_zone = TimeUtil.GetTimeZone()
			server_time = server_time + time_zone
			local time_tab = TimeUtil.Format2TableDHM(server_time)
			local now_time = time_tab.hour * 60 + time_tab.min
			local open_time_list = Split(act_cfg.open_time, "|")
			local open_time_table = Split(open_time_list[#open_time_list], ":")
			if open_time_table and open_time_table[1] and open_time_table[2] then
				local open_time = tonumber(open_time_table[1]) * 60 + tonumber(open_time_table[2])
				return now_time > open_time
			else
				return false
			end
		end
	else
		return false
	end
end

-- 通过配置表获得某个活动下次的开启时间
function ActivityData:GetNextOpenTime(act_type)
	local act_cfg = self:GetClockActivityByID(act_type)
	local next_time1 = 0
	local next_time2 = "00:00"
	if act_cfg then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local time_zone = TimeUtil.GetTimeZone()
		server_time = server_time + time_zone
		local time_tab = TimeUtil.Format2TableDHM(server_time)
		local now_time = time_tab.hour * 60 + time_tab.min
		local open_time_list = Split(act_cfg.open_time, "|")
		for i = 1, #open_time_list do
			local open_time_table = Split(open_time_list[i], ":")
			if open_time_table and open_time_table[1] and open_time_table[2] then
				local open_time = tonumber(open_time_table[1]) * 60 + tonumber(open_time_table[2])
				if i == 1 then
					next_time1 = open_time
					next_time2 = open_time_list[1]
				end
				if open_time > now_time then
					next_time1 = open_time
					next_time2 = open_time_list[i]
					break
				end
			end
		end
	end
	return next_time1, next_time2
end

-- 通过配置表获得某个活动下次的开启时间(周X xx:xx)
function ActivityData:GetNextOpenWeekTime(act_type)
	local act_info = self:GetClockActivityByID(act_type)
	local time_str = Language.Activity.YiJieShu
	if not act_info or not next(act_info) then
		return time_str
	end
	local open_day_list = Split(act_info.open_day, ":")
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end

	if ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	elseif act_info.is_allday == 1 then
		time_str = Language.Activity.AllDay
	else
		local flag = false
		local open_time_tbl = Split(act_info.open_time, "|")
		local open_time_str = open_time_tbl[1]
		local open_time_frame = act_info.open_time .."-" .. act_info.end_time
		local end_time_tbl = Split(act_info.end_time, "|")
		for _, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				local though_time = true
				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						break
					end
				end
				if though_time then
					time_str = Language.Activity.YiJieShuDes
				else
					flag = true
					time_str = string.format("%s", open_time_str)
				end
				break
			end
		end
		if not flag then
			--根据当前天数只显示下一次开启时间
			-- local open_day = open_day_list[1] or 1
			-- for _, v in ipairs(open_day_list) do
			-- 	if tonumber(v) > now_weekday then
			-- 		--open_day = tonumber(v)
			-- 		break
			-- 	end
			-- end
			-- --time_str = string.format("%s %s", Language.Common.Week .. Language.Common.DayToChs[tonumber(open_day)], open_time_str)

			local open_day = ""
			for k, v in ipairs(open_day_list) do
				if k == 1 then
					open_day = Language.Common.DayToChs[tonumber(v)]
				else
					open_day = open_day .. "," .. Language.Common.DayToChs[tonumber(v)]
				end
			end

			time_str = string.format("%s %s", Language.Common.Week .. open_day, open_time_frame)
		end
	end
	return time_str
end

-- 注册监听活动状态改变
function ActivityData:NotifyActChangeCallback(callback)
	self.act_change_callback[#self.act_change_callback + 1] = callback
end

-- 取消注册
function ActivityData:UnNotifyActChangeCallback(callback)
	for k,v in pairs(self.act_change_callback) do
		if v == callback then
			self.act_change_callback[k] = nil
		end
	end
end

function ActivityData:SetRoomStatusList(activity_type, room_user_max, room_status_list)
	self.room_info_list[activity_type] = {['activity_type'] = activity_type, ['room_user_max'] = room_user_max, ['room_status_list'] = room_status_list}
end

function ActivityData:GetRoomIndex(activity_type)
	local room_data = self.room_info_list[activity_type]
	local room_index = 0
	if room_data then
		local room_user_max = room_data.room_user_max
		local room_list = room_data.room_status_list
		local n = room_user_max
		for k,v in pairs(room_list) do
			if v.is_open == 1 and v.role_num < n then
				n = v.role_num
				room_index = v.index
			end
		end
	end
	return room_index
end

function ActivityData:GetRoomStatuList()
	return self.room_info_list
end

function ActivityData:GetRoomStatuesByActivityType(activity_type)
	return self.room_info_list[activity_type]
end

function ActivityData.GetActivityName(act_type)
	-- local act_list =  ConfigManager.Instance:GetAutoConfig("daily_activity_auto").daily
	-- for k,v in pairs(act_list) do
	-- 	if act_type == v.act_type then
	-- 		return v.name
	-- 	end
	-- end
	local act_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("daily_activity_auto").daily, "act_type")
	if act_type ~= nil then
		local cfg = act_list_cfg[act_type]
		if cfg ~= nil then
			return v.name
		end
	end
	return tostring(act_type)
end

function ActivityData.GetActivityStatusName(status)
	if status == ACTIVITY_STATUS.CLOSE then 				--活动关闭状态
		return "活动关闭状态"
	elseif status == ACTIVITY_STATUS.STANDY then			--活动准备状态
		return "活动准备状态"
	elseif status == ACTIVITY_STATUS.OPEN then				--活动进行中
		return "活动进行中"
	end
	return tostring(status)
end

-- 获取活动剩余时间,结束时间
function ActivityData:GetActivityResidueTime(act_type)
	local time = 0
	local next_time = 0
	local activity = self:GetActivityStatuByType(act_type)
	if activity then
		next_time = activity.next_time
		time = activity.next_time - TimeCtrl.Instance:GetServerTime()
	end
	return time, next_time
end

--请求进入活动的房间
function ActivityData:OnEnterRoom(activity_type)
	local room_info_list = self:GetRoomStatuesByActivityType(activity_type)
	if nil ~= room_info_list and nil ~= room_info_list.room_status_list then
		-- 选择房间人数最少的进入
		local min_role_num = 9999
		local enter_room_index = 0
		local activity_room_list = room_info_list.room_status_list
		for _, room_status in pairs(activity_room_list) do
			if ACTIVITY_ROOM_STATUS.OPEN == room_status.is_open then
				if room_status.role_num < min_role_num then
					min_role_num = room_status.role_num
					enter_room_index = room_status.index
				end
			end
		end
		Log("请求进入" .. ActivityData.GetActivityName(activity_type), "活动房间号：", enter_room_index)
		Log("当前房间人数：", min_role_num)
		local activity_cfg = DailyData.Instance:GetActivityConfig(activity_type)

		if nil ~= activity_cfg then
			ActivityCtrl.Instance:SendActivityEnterReq(activity_type, enter_room_index)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.MeiYouKaiQiDeFangJian)
	end
end

function ActivityData:GetActivityConfig(act_type)
	-- local list = self.activity_config.show_cfg
	-- for k,v in ipairs(list) do
	-- 	if v.act_id == act_type then
	-- 		return v
	-- 	end
	-- end

	return self.activity_config_id_cfg[act_type]
end

function ActivityData:GetActivityForecast(act_type)
	return self.activity_config_forecast[act_type]
end

function ActivityData:ClearCrossInfo(info)
	if self.cross_info then
		self.cross_info.cross_activity_type = 0
		self.cross_info.login_server_ip = ""
		self.cross_info.login_server_port = 0
		self.cross_info.pname = ""
		self.cross_info.login_time = 0
		self.cross_info.login_str = ""
		self.cross_info.anti_wallow = 0
		self.cross_info.server = 0
	end
	GlobalEventSystem:Fire(CrossType.ExitCross)
end

-----------------------------------世界Boss---------------------------------------------

-- 获取可击杀列表信息
function ActivityData:GetCanKillList()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local can_kill_list = {}
	for k,v in pairs(self.all_boss_info) do
		if 1 == v.status then
			local boss_cfg = self:GetBossCfgById(v.boss_id)
			if nil ~= boss_cfg and boss_cfg.boss_level <= role_level then
				local boss_info = {}
				boss_info.boss_type = boss_cfg.boss_tag
				boss_info.name = boss_cfg.boss_name
				boss_info.scene_id = boss_cfg.scene_id
				boss_info.x = boss_cfg.born_x
				boss_info.y = boss_cfg.born_y
				boss_info.boss_level = boss_cfg.boss_level

				boss_info.status = v.status
				boss_info.boss_id = v.boss_id
				can_kill_list[#can_kill_list + 1] = boss_info
			end
		end
	end

	table.sort(can_kill_list, ActivityData.CanKillKeySort("boss_type", "boss_level"))

	return can_kill_list
end

-- 可击杀排序
function ActivityData.CanKillKeySort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] < b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] > b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a > order_b
	end
end

function ActivityData:GetWorldBossNum()
	if 0 == #self.worldboss_list then
		return nil
	end
	return #self.worldboss_list
end

function ActivityData:GetBossCfg()
	return self.worldboss_list
end

-- 根据boss_id获取cfg信息
function ActivityData:GetBossCfgById(boss_id)
	-- for k,v in pairs(self.all_boss_list) do
	-- 	if boss_id == v.bossID then
	-- 		return v
	-- 	end
	-- end
	return self.all_boss_config_id[boss_id]
end

-- 根据boss_id获取boss状态   1.可击杀   0.未刷新
function ActivityData:GetBossStatusByBossId(boss_id)
	if nil ~= self.all_boss_info[boss_id] then
		return self.all_boss_info[boss_id].status
	end
	return 0
end

function ActivityData:SetBossInfo(protocol)
	self.next_refresh_time = protocol.next_refresh_time
	local boss_list = protocol.boss_list
	self.all_boss_info = {}
	for k,v in pairs(boss_list) do
		self.all_boss_info[v.boss_id] = v
	end

	-- for k,v in pairs(self.notify_boss_info_change_callback_list) do
	-- 	v()
	-- end
end

function ActivityData:BossBorn()
	-- for k,v in pairs(self.notufy_boss_born_callback_list) do
	-- 	v{}
	-- end
end

-- 获取世界boss列表
function ActivityData:GetWorldBossList()
	local boss_list = {}
	for i=0,#self.worldboss_list do
		if nil ~= self.worldboss_list[i] then
			boss_list[i] = {}
			boss_list[i].bossID = self.worldboss_list[i].bossID
			boss_list[i].boss_type = self.worldboss_list[i].boss_tag
			boss_list[i].status = self:GetBossStatusByBossId(self.worldboss_list[i].bossID)
		end
	end
	return boss_list
end

-- 根据索引获取boss信息
function ActivityData:GetWorldBossInfoById(boss_id)
	local cur_info = nil
	for k,v in pairs(self.worldboss_list) do
		if boss_id == v.bossID then
			cur_info = v
			break
		end
	end
	if nil == cur_info then return end

	--local monster_info = {}
	-- for k, v in pairs(self.monster_cfg) do
	-- 	if cur_info.bossID == v.id then
	-- 		monster_info = v
	-- 	end
	-- end
	local monster_info = self.monster_cfg[cur_info.bossID]


	local boss_info = {}
	boss_info.boss_name = cur_info.boss_name
	boss_info.boss_level = cur_info.boss_level
	boss_info.boss_id = cur_info.bossID
	boss_info.scene_id = cur_info.scene_id
	boss_info.born_x = cur_info.born_x
	boss_info.born_y = cur_info.born_y
	local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
	boss_info.map_name = scene_config.name
	boss_info.refresh_time = cur_info.refresh_time
	boss_info.recommended_power = cur_info.recommended_power

	local item_list = {}
	for i = 1, 4 do
		local item_id = cur_info["show_item_id" .. i]
		if item_id then
			table.insert(item_list, item_id)
		end
	end

	boss_info.item_list = item_list
	boss_info.boss_capability = cur_info.boss_capability

	boss_info.resid = monster_info.resid

	if nil ~= self.all_boss_info[cur_info.bossID] then
		boss_info.status = self.all_boss_info[cur_info.bossID].status or 0
		boss_info.last_kill_name = self.all_boss_info[cur_info.bossID].last_killer_name or ""
		boss_info.next_refresh_time = self.all_boss_info[cur_info.bossID].next_refresh_time
	end

	return boss_info
end

function ActivityData:GetBossNextReFreshTime()
	return self.next_refresh_time
end

function ActivityData.KeyDownSort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a < order_b
	end
end

function ActivityData:SetBossPersonalHurtInfo(protocol)
	self.boss_personal_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_personal_hurt_info[k] = v
	end
end

function ActivityData:SetBossGuildHurtInfo(protocol)
	self.boss_guild_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_guild_hurt_info[k] = v
	end
end

function ActivityData:SetBossWeekRankInfo(protocol)
	for k,v in pairs(protocol) do
		self.boss_week_rank_info[k] = v
	end
end

function ActivityData:GetBossPersonalHurtInfo()
	return self.boss_personal_hurt_info
end

function ActivityData:GetBossGuildHurtInfo()
	return self.boss_guild_hurt_info
end

function ActivityData:GetBossWeekRankInfo()
	return self.boss_week_rank_info
end

function ActivityData:GetBossWeekRewardConfig()
	return self.worldboss_auto.week_rank_reward
end

function ActivityData:GetBossOtherConfig()
	return self.worldboss_auto.other[1]
end

function ActivityData:GetWorldBossIdBySceneId(scene_id)
	if not scene_id then return end
	local config = self:GetBossCfg()
	if config then
		for k,v in pairs(config) do
			if v.scene_id == scene_id then
				return v.bossID
			end
		end
	end
end

function ActivityData:IsSendZhuaGuiInvite()
	return self.is_send_zhuagui_invite
end


function ActivityData:SetSendZhuaGuiInvite(state)
	self.is_send_zhuagui_invite = state
end

function ActivityData:OnDayChangeCallBack(cur_day, is_new_day)
	self:SetNewServerAct(cur_day)
end

function ActivityData:SetNewServerAct(day, is_next_day)
	day = day or TimeCtrl.Instance:GetCurOpenServerDay()
	if day > 4 then return end
	local act_type = 0
	if day == 1 then
		act_type = ACTIVITY_TYPE.QUNXIANLUANDOU
	elseif day == 2 then
		act_type = ACTIVITY_TYPE.GUILDBATTLE
	elseif day == 3 then
		act_type = ACTIVITY_TYPE.GONGCHENGZHAN
	elseif day == 4 then
		act_type = ACTIVITY_TYPE.CLASH_TERRITORY
	end
	local act_cfg = self:GetClockActivityByID(act_type)
	if act_cfg == nil or next(act_cfg) == nil then return false end

	local time_table = os.date("*t",TimeCtrl.Instance:GetServerTime())
	local day_time = time_table.hour * 3600 + time_table.min*60 + time_table.sec
	local open_day_list = Split(act_cfg.open_time, "|")
	open_day_list = Split(open_day_list[1], ":")
	local open_time = open_day_list[1] * 3600 + open_day_list[2] * 60
	if open_time > day_time or is_next_day then
		if is_next_day then
			time_table.day = time_table.day + 1
		end
		time_table.hour = open_day_list[1]
		time_table.min = open_day_list[2]
		time_table.sec = 0
		if not self:GetActivityIsOpen(act_type) then
			ActivityData.Instance:SetActivityStatus(act_type, ACTIVITY_STATUS.STANDY, os.time(time_table))
		end
	elseif day < 4 and not self:GetActivityIsOpen(act_type) and not is_next_day then
		self:SetNewServerAct(day + 1, true)
	end
end

function ActivityData.IsOpenServerSpecAct(act_type)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if act_type == ACTIVITY_TYPE.QUNXIANLUANDOU and cur_day == 1 then
		return true
	elseif act_type == ACTIVITY_TYPE.GUILDBATTLE and cur_day == 2 then
		return true
	elseif act_type == ACTIVITY_TYPE.GONGCHENGZHAN and cur_day == 3 then
		return true
	elseif act_type == ACTIVITY_TYPE.CLASH_TERRITORY and cur_day == 4 then
		return true
	end
	return false
end

--得到某个活动目前最临近的开启时间段
function ActivityData:GetActivityTwoTime(act_type)
	local act_info = self:GetClockActivityByID(act_type)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local server_time_str = os.date("%H:%M", server_time)
	
	local open_time_tbl = Split(act_info.open_time, "|")
	local open_time_str = open_time_tbl[1]
	local end_time_tbl = Split(act_info.end_time, "|")
	local end_time_str = end_time_tbl[1]

	for k2, v2 in ipairs(end_time_tbl) do
		if v2 > server_time_str then
			open_time_str = open_time_tbl[k2]
			end_time_str = v2
			break
		end
	end
	return open_time_str, end_time_str
end

function ActivityData:GetActDayPassFromStart(activity_type)
	if nil == activity_type then
		return 0
	end
	local activity_status = self:GetActivityStatuByType(activity_type)
	local activity_day = -1
	if nil ~= activity_status then
		local format_time_start = os.date("*t", activity_status.start_time)
		local end_zero_time_start = os.time{year=format_time_start.year, month=format_time_start.month, day=format_time_start.day, hour=0, min = 0, sec=0}

		local format_time_now = os.date("*t", TimeCtrl.Instance:GetServerTime())
		local end_zero_time_now = os.time{year=format_time_now.year, month=format_time_now.month, day=format_time_now.day, hour=0, min = 0, sec=0}

		local format_start_day = math.floor(end_zero_time_start / (60 * 60 * 24))
		local format_now_day =  math.floor(end_zero_time_now / (60 * 60 * 24))
		activity_day = format_now_day - format_start_day
	end
	return activity_day
end

function ActivityData:GetRandActivityConfig(cfg, type)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local pass_day = self:GetActDayPassFromStart(type)
	local rand_t = {}
	local day = nil
	
	if cfg[0] and (nil == day or cfg[0].opengame_day == day) and (open_day - pass_day) <= cfg[0].opengame_day then
		day = cfg[0].opengame_day
		table.insert(rand_t, cfg[0])
	end

	for k,v in ipairs(cfg) do
		if v and v.opengame_day and (nil == day or v.opengame_day == day) and (open_day - pass_day) <= v.opengame_day then
			day = v.opengame_day
			table.insert(rand_t, v)
		end
	end
	return rand_t
end

function ActivityData:GetActivityHallDatalist()
	local data_list = {}
	local level = PlayerData.Instance.role_vo.level
	for k,v in pairs(self.activity_list) do
		local act_cfg = ActivityData.Instance:GetActivityConfig(v.type)
		if v.status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.min_level <= level and act_cfg.is_inscroll == 1 then
			table.insert(data_list, v)
		end
	end
	return data_list
end

-- 活动卷轴里面活动的红点特效
function ActivityData:SetActivityRedPointState(act_type,act_flag)
	self.red_point_states[act_type] = act_flag
	MainUICtrl.Instance:FlushActivityRed()
	RemindManager.Instance:Fire(RemindName.ACTIVITY_JUAN_ZHOU)
end

-- 是否显示活动卷轴里面的活动红点
function ActivityData:GetActivityRedPointState(act_type)
	if self.red_point_states then
		return self.red_point_states[act_type] or false
	end
	return false
end

-- 获取活动卷轴里面的活动数量
function ActivityData:GetActivityRedPointNum()
	local act_num = 0
	for k,v in pairs(self.red_point_states) do
		act_num = act_num + 1
	end
	return act_num
end

-- 主界面是否显示活动卷轴红点
function ActivityData:IsShowRedPointJuan()
	if self.red_point_states and next(self.red_point_states) then
		for k,v in pairs(self.red_point_states) do
			if v then
				return 1
			end
		end
	end
	local act_num = #self:GetActivityHallDatalist()
	if act_num > 0 then
		if self:GetActivityRedPointNum() == 0 then
			-- 初始化默认显示红点
			return 1
		end
	end
	return 0
end

-- 获取活动开启第几天
function ActivityData.GetActivityDays(act_type)
	local activity = ActivityData.Instance:GetActivityStatuByType(act_type)
	if activity then
		local time_off = TimeCtrl.Instance:GetServerTime() - TimeUtil.NowDayTimeStart(activity.start_time)
		return math.ceil(time_off / 86400)
	end
	return 0
end

function ActivityData:ActivityCallBackBattleOrDailyRed()

	if not OpenFunData.Instance:CheckIsHide("activity") then
		return 0
	end
	if self:ActivityCallBackBattleRed() == 1 or self:ActivityCallDailyRed() == 1 then
		return 1
	end
	return 0
end

function ActivityData:ActivityCallBackBattleRed()
	for k,v in pairs(ACTIVITY_ACT_TYPE_BATTLE) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			 return 1
		end
	end
	return 0
end

function ActivityData:ActivityCallDailyRed()
	for k,v in pairs(ACTIVITY_ACT_TYPE_DAILY) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			if v == ACTIVITY_TYPE.HUSONG then
				local can_husong_num = YunbiaoData.Instance and YunbiaoData.Instance:GetHusongRemainTimes()
				if can_husong_num and can_husong_num > 0 then
					return 1
				end
			else
			 	return 1
		 	end
		end
	end
	return 0
end

function ActivityData:OtherCamp()
	local camp = PlayerData.Instance.role_vo.camp
	local data = CampData.Instance:GetMonsterSiegeInfo() 
	local other_camp = data.monster_siege_camp or 0
	local str = ""
	if data ~= nil then
		if other_camp ~= nil and other_camp ~= camp then
			str = Language.Daily.MonsterReward[other_camp]
		end
	end
	return str, other_camp == camp
end

function ActivityData:OtherContryInfo()
	local camp = PlayerData.Instance.role_vo.camp
	local data = CampData.Instance:GetMonsterSiegeInfo() or {}
	local other_camp = data.monster_siege_camp or 0
	local str = ""
	if other_camp > 0 then
		str = camp == other_camp and Language.Daily.MonsterDes1 or 
		string.format(Language.Daily.MonsterDes2,Language.Convene.Nation[other_camp])
	end
	return str 
end