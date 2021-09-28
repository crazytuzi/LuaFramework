ActivityData = ActivityData or BaseClass()
ActivityData.SCROLL_CLICK_EFF = {}
ActivityData.Act_Type = {
	normal = 1,
	boss = 2,
	boss_remindind = 3,
	battle_field = 4,
	kuafu_battle_field = 5,
	shushan = 6,
	custom_preview = 7,
}

ActivityData.TitleType = {
	[1] = 3,    --仙
	[2] = 1,    --人
	[3] = 2,    --魔
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

ActivityData.ActState = {
	OPEN = 0,										-- 活动进行中
	WAIT = 1,										-- 活动未开启
	CLOSE = 2,										-- 活动已结束
}

--在左侧显示标题列表
ActivityData.ShowLeftTitle = {
	[ACTIVITY_TYPE.KF_MINING] = 1,
	[ACTIVITY_TYPE.KF_FISHING] = 1,
}


-- 活动卷轴里面的功能
FunInActHallView = {
	{fun_name = ViewName.LongXingView, icon = "Icon_Longxing", icon_name = "LongXing", open_name = ViewName.LongXingView,type = 100001},
	-- {fun_name = ViewName.DuihuanView, icon = "DuihuanView", icon_name = "DuihuanView", open_name = ViewName.DuihuanView, is_teshu = true, name = 11111,},
}

-- 活动卷轴里面的图标显示位置(活动开启显示在最前列)
local FunInActHallViewFirst = {
	[2188] = ViewName.HuanZhuangShopView,
}

local ACTIVITY_PREVIEW_OPEN_LEVEL = 150
local MAX_NUM = 3

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
	self.cross_activity_list = {}

	self.act_change_callback = {}

	self.lucky_log = {}
	self.activity_type = 0

	self.activity_info_list = {} 							-- 存储全部下发的活动信息,用于玩家升级之后重新给活动信息表赋值
	self.cross_activity_info_list = {}						-- 存储全部下发的活动信息,用于玩家升级之后重新给活动信息表赋值

	local activity_cfg = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto")
	self.show_cfg = ListToMap(activity_cfg.show_cfg, "act_id")
	self.show_type_list_cfg = ListToMapList(activity_cfg.show_cfg, "act_type")

	self.huangchenghuizhancfg_cfg = ConfigManager.Instance:GetAutoConfig("huangchenghuizhancfg_auto")
	self.hz_pos_cfg = ListToMapList(self.huangchenghuizhancfg_cfg.pos, "monsterid")

    -- 卷轴红点
	self.red_point_states = {}
	self.act_list_cfg = ConfigManager.Instance:GetAutoConfig("daily_activity_auto").daily

	self.rand_act_open_list_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").open_cfg

	self.next_monster_invade_time = 0
	-- self:SetActivityStatus(ACTIVITY_TYPE.ACTIVITY_HALL, ACTIVITY_STATUS.OPEN, 4000000000)
	-- self:DailyInit()

	self.activity_config = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto")
	self.show_cfg = ListToMap(self.activity_config.show_cfg, "act_id")
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.worldboss_auto = ConfigManager.Instance:GetAutoConfig("worldboss_auto")
	self.all_boss_list = self.worldboss_auto.worldboss_list
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

	self.wchz_info = {
		boss_num = 0,
		next_refresh_time = 0,
		monster_list = {},
	}
	self.wchz_role_info = {
		add_exp = 0,
		drop_list = {},
	}
    self.first_rank = {}
	self.is_send_zhuagui_invite = false 			--是否等待发出秘境降魔邀请
	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChangeCallBack, self))
	RemindManager.Instance:Register(RemindName.ACTIVITY_JUAN_ZHOU, BindTool.Bind(self.IsShowRedPointJuan, self))
	self.remind_handle = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, function ()
		RemindManager.Instance:Fire(RemindName.ACTIVITY_JUAN_ZHOU)
	end)
end

function ActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ActivityHall)
	RemindManager.Instance:UnRegister(RemindName.ACTIVITY_JUAN_ZHOU)
	GlobalEventSystem:UnBind(self.pass_day_handle)
	GlobalEventSystem:UnBind(self.remind_handle)
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
	if self.activity_config then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		for _,v in pairs(self.activity_config.show_cfg) do
			if v.act_type == act_type and main_vo.level < v.max_level then
				local act_t = TableCopy(v)
				act_t.sort_key = 0

				local main_vo = GameVoManager.Instance:GetMainRoleVo()
				if main_vo.level > act_t.min_level then
					act_t.sort_key = act_t.sort_key + 1000000
				end

				if ActivityData.Instance:GetActivityIsOpen(act_t.act_id) then
					act_t.sort_key = act_t.sort_key + 100000
				end

				local server_time = TimeCtrl.Instance:GetServerTime()
				local now_weekday = os.date("%w", server_time)
				if now_weekday == 0 then now_weekday = 7 end
				local server_time_str = os.date("%H:%M", server_time)

				local open_day_list = Split(act_t.open_day, ":")
				local open_time_list = Split(act_t.open_time, "|")
				local open_time_str = open_time_list[1]
				local end_time_list = Split(act_t.end_time, "|")

				local today_open = false
				local though_time = true
				for k, v in ipairs(open_day_list) do
					if v == now_weekday then
						today_open = true
						for k1, v1 in ipairs(end_time_list) do
							if v1 > server_time_str then
								though_time = false
								open_time_str = open_time_list[k1]
								break
							end
						end
						break
					end
				end

				if today_open then
					if though_time then
						act_t.sort_key = act_t.sort_key - 1000000
					else
						act_t.sort_key = act_t.sort_key + 10000
					end
				end

				local open_time_t = Split(open_time_str, ":")
				local open_time_value = tonumber(open_time_t[1]) * 100 + tonumber(open_time_t[2])
				act_t.sort_key = act_t.sort_key + (2400 - open_time_value)

				table.insert(temp_list, act_t)
			end
		end
	end
	table.sort(temp_list, SortTools.KeyUpperSorter("sort_key"))
	if act_type == ActivityData.Act_Type.normal then
		local index = 0
		for i = 1, #temp_list do
			if temp_list[i].act_id == ACTIVITY_TYPE.GONGCHENG_WORSHIP then
				index = i
				break
			end
		end
		if index > 0 then
			table.remove(temp_list, index)
		end
	end
	if act_type == ActivityData.Act_Type.kuafu_battle_field then
		local index = 0
		for i = 1, #temp_list do
			if temp_list[i].act_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
				index = i
				break
			end
		end
		if index > 0 then
			table.remove(temp_list, index)
		end
	end
	return temp_list
end

function ActivityData:GetClockActivityCountByType(act_type)
	local count = 0
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.activity_config then
		for _,v in pairs(self.activity_config.show_cfg) do
			if v.act_type == act_type and v.act_id ~= ACTIVITY_TYPE.GONGCHENG_WORSHIP and main_vo.level < v.max_level
				and v.act_id ~= ACTIVITY_TYPE.KF_GUILDBATTLE then
				count = count + 1
			end
		end
	end
	return count
end

function ActivityData:GetClockActivityByID(id)
	return self.show_cfg[id] or {}
end

function ActivityData:GetActivityInfoById(id)
	return self.show_cfg[id] or {}
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
	--如果该活动是开服活动直接获取活动信息
	if status == ACTIVITY_STATUS.OPEN then
		for _,v in pairs(RA_OPEN_SERVER_ACTIVITY_TYPE) do
			if activity_type == v then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
		end
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
	local show_cfg = self.activity_config.show_cfg or {}
	local act_name = ""
	for k, v in ipairs(show_cfg) do
		if act_type == v.act_id then
			act_name = v.act_name
			break
		end
	end
	if act_name == "" then
		for k, v in ipairs(self.rand_act_open_list_cfg) do
			if v.activity_type == act_type then
				act_name = v.name
				break
			end
		end
	end

	--判断版本活动
	if act_name == "" then
		local list = FestivalActivityData.Instance:GetActivityOpenCfgById(act_type)
		if nil ~= list then
			act_name = list.name
		end
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
			local open_day = open_day_list[1] or 1
			for _, v in ipairs(open_day_list) do
				if tonumber(v) > now_weekday then
					open_day = tonumber(v)
					break
				end
			end
			time_str = string.format("%s %s", Language.Common.Week .. Language.Common.DayToChs[tonumber(open_day)], open_time_str)
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
	local act_list =  ConfigManager.Instance:GetAutoConfig("daily_activity_auto").daily
	for k,v in pairs(act_list) do
		if act_type == v.act_type then
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

-- 获取活动开启第几天
function ActivityData.GetActivityDays(act_type)
	local activity = ActivityData.Instance:GetActivityStatuByType(act_type)
	if activity then
		local time_off = TimeCtrl.Instance:GetServerTime() - TimeUtil.NowDayTimeStart(activity.start_time)
		return math.ceil(time_off / 86400)
	end
	return 0
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
	local list = self.activity_config.show_cfg
	for k,v in ipairs(list) do
		if v.act_id == act_type then
			return v
		end
	end
	return nil
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
			local boss_level = self:GetWorldBossInfoById(v.boss_id).boss_level
			if nil ~= boss_cfg and boss_level <= role_level then
				local boss_info = {}
				boss_info.boss_type = boss_cfg.boss_tag
				boss_info.name = boss_cfg.boss_name
				boss_info.scene_id = boss_cfg.scene_id
				boss_info.x = boss_cfg.born_x
				boss_info.y = boss_cfg.born_y
				boss_info.boss_level = boss_level

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
	for k,v in pairs(self.all_boss_list) do
		if boss_id == v.bossID then
			return v
		end
	end
	return nil
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
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[boss_id]
	for k,v in pairs(self.worldboss_list) do
		if boss_id == v.bossID then
			cur_info = v
			break
		end
	end
	if nil == cur_info then return end

	local monster_info = {}
	for k, v in pairs(self.monster_cfg) do
		if cur_info.bossID == v.id then
			monster_info = v
		end
	end

	local boss_info = {}
	boss_info.boss_name = cur_info.boss_name
	boss_info.boss_id = cur_info.bossID
	boss_info.scene_id = cur_info.scene_id
	boss_info.born_x = cur_info.born_x
	boss_info.born_y = cur_info.born_y
	local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
	boss_info.map_name = scene_config.name
	boss_info.refresh_time = cur_info.refresh_time
	boss_info.recommended_power = cur_info.recommended_power
	boss_info.boss_level = monster_cfg and monster_cfg.level or 0

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
	if day > 2 then return end
	local act_type = 0
	if day == 1 then
		act_type = ACTIVITY_TYPE.GUILDBATTLE
	elseif day == 2 then
		act_type = ACTIVITY_TYPE.GONGCHENGZHAN
	--elseif day == 3 then
	--	act_type = ACTIVITY_TYPE.GONGCHENGZHAN
	--elseif day == 4 then
	--	act_type = ACTIVITY_TYPE.CLASH_TERRITORY
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

function ActivityData:GetActivityHallDatalist()
	local data_list = {}
	local scroll_sort_t = {}
	local first_data_list = {}
	local level = PlayerData.Instance.role_vo.level
	local num = 0

	local fun_name = ""
	local is_fun_open = true
	if is_fun_open then
		table.insert(data_list, v)
	end

	for _,v in ipairs(FunInActHallView) do
		if OpenFunData.Instance:CheckIsHide(v.fun_name) then
			table.insert(first_data_list, v)
			num = num + 1
		end
	end

	for k,v in pairs(self.cross_activity_list) do
		local act_cfg = self:GetActivityConfig(v.type)
		if v.status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.min_level <= level and act_cfg.is_inscroll == 1 then
			if FunInActHallViewFirst[v.type] then
				table.insert(first_data_list, num + 1, v)
				num = num + 1
			else
				table.insert(data_list, v)
				scroll_sort_t[v.type] = act_cfg.scroll_sort
				if act_cfg.scroll_sort > 0 and ActivityData.SCROLL_CLICK_EFF[v.type] == nil then
					ActivityData.SCROLL_CLICK_EFF[v.type] = true
				end
			end
		end
	end

	for k,v in pairs(self.activity_list) do
		local act_cfg = self:GetActivityConfig(v.type)
		if v.status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.min_level <= level and act_cfg.is_inscroll == 1 then
			if FunInActHallViewFirst[v.type] then
				table.insert(first_data_list, num + 1, v)
				num = num + 1
			else
				table.insert(data_list, v)
				scroll_sort_t[v.type] = act_cfg.scroll_sort
				if act_cfg.scroll_sort > 0 and ActivityData.SCROLL_CLICK_EFF[v.type] == nil then
					ActivityData.SCROLL_CLICK_EFF[v.type] = true
				end
			end
		end
	end

	-- 根据活动号进行排序
	function sortfun(a, b)
		local a_scroll_sort = a.type and scroll_sort_t[a.type] or 0
		local b_scroll_sort = b.type and scroll_sort_t[b.type] or 0
		if a_scroll_sort ~= b_scroll_sort then
			if a_scroll_sort == 0 then
				return false
			elseif b_scroll_sort == 0 then
				return true
			end
			return a_scroll_sort < b_scroll_sort
		end
		local a_type = a.type or 0
		local b_type = b.type or 0
		return a_type < b_type
    end
    table.sort(data_list, sortfun)

    -- 特殊要求的放最前面
    for i,v in ipairs(data_list) do
    	table.insert(first_data_list, v)
    end

	return first_data_list
end

-- 活动卷轴里面活动的红点特效
function ActivityData:SetActivityRedPointState(act_type,act_flag)
	self.red_point_states[act_type] = act_flag
	MainUICtrl.Instance:FlushActivityRed()
	RemindManager.Instance:Fire(RemindName.ACTIVITY_JUAN_ZHOU)
end

-- 是否显示活动卷轴里面的活动红点
function ActivityData:GetActivityRedPointState(act_type)
	if act_type == ACTIVITY_TYPE.RAND_CHARGE_REPALMENT then
		return KaifuActivityData.Instance:GetLeiJiChargeRewardRedPoint()
	end
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
	local level = PlayerData.Instance.role_vo.level
	if self.red_point_states and next(self.red_point_states) then
		for k,v in pairs(self.red_point_states) do
			local act_cfg = self:GetActivityConfig(k)
			if nil ~= act_cfg and level >= act_cfg.min_level and act_cfg.is_inscroll == 1 and self:GetActivityIsOpen(k) and v then
				return 1
			--在活动显示配置里没有而写死的活动功能
			elseif nil == act_cfg and v then
				for _,v1 in ipairs(FunInActHallView) do
					if k == v1.type and OpenFunData.Instance:CheckIsHide(v1.fun_name) then
						return 1
					end
				end
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
	if cfg == nil then
		return rand_t
	end
	if cfg[0] and (nil == day or cfg[0].opengame_day == day) and (open_day - pass_day) <= cfg[0].opengame_day then
		day = cfg[0].opengame_day
		table.insert(rand_t, cfg[0])
	end

	for k,v in ipairs(cfg) do
		if v and (nil == day or v.opengame_day == day) and (open_day - pass_day) <= v.opengame_day then
			day = v.opengame_day
			table.insert(rand_t, v)
		end
	end
	return rand_t
end

function ActivityData:GetAllActivityOpenInfo()
	local temp_list = {}
	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.normal]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.battle_field]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.kuafu_battle_field]) do
		table.insert(temp_list, v)
	end

	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.MOSHEN)
	table.insert(temp_list, act_info)

	local cfg_list = {}
	for _,v in pairs(temp_list) do
		local act_t = TableCopy(v)
		act_t.sort_key = 0

		if ActivityData.Instance:GetActivityIsOpen(act_t.act_id) then
			act_t.sort_key = act_t.sort_key + 100000
		end

		local server_time = TimeCtrl.Instance:GetServerTime()
		local now_weekday = tonumber(os.date("%w", server_time))
		if now_weekday == 0 then
			now_weekday = 7
		end

		local server_time_str = os.date("%H:%M", server_time)
		local open_day_list = Split(act_t.open_day, ":")
		local open_time_list = Split(act_t.open_time, "|")
		local open_time_str = open_time_list[1]
		local end_time_list = Split(act_t.end_time, "|")

		local today_open = false
		local though_time = true
		for k, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				today_open = true
				for k1, v1 in ipairs(#end_time_list > 0 and end_time_list or open_time_list) do
					if v1 > server_time_str then
						though_time = false
						open_time_str = open_time_list[k1]
						break
					end
				end
				break
			end
		end

		if today_open then
			if though_time then
				act_t.sort_key = act_t.sort_key - 1000000
			else
				act_t.sort_key = act_t.sort_key + 10000
			end

			local open_time_t = Split(open_time_str, ":")
			local open_time_value = tonumber(open_time_t[1]) * 100 + tonumber(open_time_t[2])
			act_t.sort_key = act_t.sort_key + (2400 - open_time_value)

			table.insert(cfg_list, act_t)
		end
	end

	table.sort(cfg_list, SortTools.KeyUpperSorter("sort_key"))

	return cfg_list
end

function ActivityData:GetTodayActInfo()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
  	local temp_list = {}
  	local result_list = {}
	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.normal]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.battle_field]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.kuafu_battle_field]) do
		table.insert(temp_list, v)
	end

	for k, v in pairs(self.show_type_list_cfg[ActivityData.Act_Type.custom_preview] or {}) do
		table.insert(temp_list, v)
	end

	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.MOSHEN)
	table.insert(temp_list, act_info)

	for _,v in pairs(temp_list) do
		local act_t = TableCopy(v)

		local server_time = TimeCtrl.Instance:GetServerTime()
		local now_weekday = tonumber(os.date("%w", server_time))
		if now_weekday == 0 then
			now_weekday = 7
		end

		local open_day_list = Split(act_t.open_day, ":")
		local open_time_list = Split(act_t.open_time, "|")
		local end_time_list = Split(act_t.end_time, "|")

		local today_open = false
		for k, v in ipairs(open_day_list) do
			if tonumber(v) == now_weekday then
				today_open = true
			end
		end

		if v.opensever_day == open_server_day then 		--强制开启活动
			today_open = true
		elseif v.opensever_day > open_server_day then	--未到该活动的开启天数，禁止开启
			today_open = false
		end

		local level_enough = false
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if role_level >= v.min_level and role_level < v.max_level then
			level_enough = true
		end

		if today_open and level_enough then
			for k,v in pairs(open_time_list) do
				if end_time_list[k] then
					local info = {}
					info.act_id = act_t.act_id
					info.act_name = act_t.act_name
					info.open_time = v
					info.end_time = end_time_list[k]
					info.open_time_stamp = self:ChangeToStamp(v)
					info.end_time_stamp = self:ChangeToStamp(end_time_list[k])
					table.insert(result_list, info)
				end
			end
		end
	end
	table.sort(result_list, SortTools.KeyLowerSorter("open_time_stamp"))
	return result_list
end

--获得今日开启的活动，并且开启中放前面，已结束放后面
function ActivityData:GetTodayActInfoSort()
  	local server_time = TimeCtrl.Instance:GetServerTime()
  	local today_act_list = self:GetTodayActInfo()
  	for i,v in ipairs(today_act_list) do
  		if server_time >= v.open_time_stamp and server_time <= v.end_time_stamp then --开启中
  			today_act_list[i].state = ActivityData.ActState.OPEN
  		elseif server_time > v.end_time_stamp then 	--已结束
  			today_act_list[i].state = ActivityData.ActState.CLOSE
  		else 										--未开启
  			today_act_list[i].state = ActivityData.ActState.WAIT
  		end
  	end
  	table.sort(today_act_list, SortTools.KeyLowerSorter("state", "open_time_stamp"))
  	return today_act_list
end

function ActivityData:GetNextActivityCountDownStr()
	local cfg = self:GetNextActivityOpenInfo()
	if nil == cfg then
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local server_time_str = os.date("%H:%M", server_time)

	local open_time_tbl = Split(cfg.open_time, "|")
	local open_time_str = open_time_tbl[1]

	for k2, v2 in ipairs(open_time_tbl) do
		if server_time_str < v2 then
			open_time_str = open_time_tbl[k2]
			break
		end
	end

	local time_t = Split(open_time_str, ":")
	local act_start_time = TimeUtil.NowDayTimeStart(server_time) + time_t[1] * 60 * 60 + time_t[2] * 60
	local countdown_time = math.floor(act_start_time - server_time)

	if countdown_time < 0 then
		return nil
	end

	local str = ""
	local hour = math.floor(countdown_time / 3600)
	if hour >= 1 then
		str = string.format(Language.Common.AfterHourOpen, hour)
	else
		str = TimeUtil.FormatSecond2MS(countdown_time)
	end

	return str
end

function ActivityData:GetNextActivityOpenInfo()
	if PlayerData.Instance.role_vo.level < ACTIVITY_PREVIEW_OPEN_LEVEL then
		return
	end

	local cfg = nil
	local act_cfg = self:GetAllActivityOpenInfo()
	for i, v in ipairs(act_cfg) do
		local server_time = TimeCtrl.Instance:GetServerTime()
		local server_time_str = os.date("%H:%M", server_time)
		local open_time_tbl = Split(v.open_time, "|")
		local open_time_str = open_time_tbl[1]

		local though_time = true
		for k2, v2 in ipairs(open_time_tbl) do
			if server_time_str < v2 then
				though_time = false
				open_time_str = open_time_tbl[k2]
				break
			end
		end

		local is_openning = self:GetActivityIsOpen(v.act_id) or v.is_allday == 1
		if not is_openning and not though_time then
			cfg = v
			break
		end
	end
	return cfg
end

function ActivityData:GetCurActivityCountDownStr()
	local cfg = self:GetCurActOpenInfo()
	if nil == cfg then
		return ""
	end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local act_end_time = cfg.end_time_stamp
	local countdown_time = math.floor(act_end_time - server_time)
	if countdown_time < 0 then
		return ""
	end

	local str = ""
	local hour = math.floor(countdown_time / 3600)
	if hour >= 1 then
		str = string.format(Language.Common.AfterHourOpen, hour)
	else
		str = TimeUtil.FormatSecond2MS(countdown_time)
	end

	return str
end

function ActivityData:GetCurActOpenInfo()
	if PlayerData.Instance.role_vo.level < ACTIVITY_PREVIEW_OPEN_LEVEL then
		return
	end
	local act_cfg = self:GetTodayActInfo()
	local openning_cfg_list = {}
	local server_time = TimeCtrl.Instance:GetServerTime()
	local cfg = nil
	if act_cfg then
		for i, v in ipairs(act_cfg) do
			if v.open_time_stamp <= server_time and v.end_time_stamp >= server_time then
				table.insert(openning_cfg_list, v)
			end
		end
	end
	if next(openning_cfg_list) then
		cfg = openning_cfg_list[#openning_cfg_list]
	end
	return cfg
end

function ActivityData:GetNextActOpenInfo()
	if PlayerData.Instance.role_vo.level < ACTIVITY_PREVIEW_OPEN_LEVEL then
		return
	end
	local act_cfg = self:GetTodayActInfo()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if act_cfg then
		for i, v in ipairs(act_cfg) do
			if v.open_time_stamp > server_time then
				return v
			end
		end
	end
	return
end

function ActivityData:ChangeToStamp(time_str)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_tb = Split(time_str, ":")
	local tab = os.date("*t", server_time)
	tab.hour = tonumber(time_tb[1])
	tab.min = tonumber(time_tb[2])
	tab.sec = 0
	local stamp = os.time(tab) or 0
	return stamp
end

function ActivityData:SetQunxianLuandouFirstRankInfo(protocol)
	self.first_rank = protocol.first_rank
end

function ActivityData:GetQunxianLuandouFirstRankInfo(protocol)
	return self.first_rank or {}
end


--============================
--========王城会战=============
--=================================

function ActivityData:SetShuShanData(protocol)
	self.wchz_info.boss_num = protocol.monster_num
	self.wchz_info.next_refresh_time = protocol.next_refrestime
	self.wchz_info.monster_list = protocol.monster_list
end

function ActivityData:SetShuShanRoleInfo(protocol)
	self.wchz_role_info.add_exp = protocol.add_exp
	self.wchz_role_info.drop_list = protocol.drop_list
end

function ActivityData:GetShuShanData()
	return self.wchz_info
end

function ActivityData:GetShuShanRoleData()
	return self.wchz_role_info
end

function ActivityData:ClearShuShanRoleData()
	self.wchz_role_info.add_exp = 0
	self.wchz_role_info.drop_list = {}
end

function ActivityData:IsShuShanScene(scene_id)
	if scene_id == self.huangchenghuizhancfg_cfg.other[1].scene_id then
		return true
	end
	return false
end

function ActivityData:SetHuangChengMonsterInfo()
	local temp = {}
	local world_level = RankData.Instance:GetWordLevel() or 0
	if self:IsInHuangChengAcitvity() then
		--0开始，2结束，3个坐标
		for i=0, MAX_NUM - 1 do
			temp[i + 1] = {x = self.huangchenghuizhancfg_cfg.other[1]["pos"..i.."_x"],y = self.huangchenghuizhancfg_cfg.other[1]["pos"..i.."_y"],level = world_level}
		end
	end

	return temp
end

function ActivityData:GetHuangChengMonsterIcon()
	if self:IsInHuangChengAcitvity() then
		return true,ResPath.GetMiscPreloadImgRes(self.huangchenghuizhancfg_cfg.other[1].equip_icon)
	end

	return false,nil,nil
end

function ActivityData:IsInHuangChengAcitvity()
	local scene_id = Scene.Instance:GetSceneId()

	if self:IsShuShanScene(scene_id) and self:GetActivityIsOpen(ACTIVITY_TYPE.HUANGCHENGHUIZHAN) then
		return true
	end

	return false
end

function ActivityData:GetHzRandMonsterPos(monster_id)
	local pos_list = self.hz_pos_cfg[monster_id]
	if pos_list and #pos_list > 0 then
		return pos_list[math.random(1, #pos_list)]
	end
	return nil
end


--=================================

function ActivityData:SetCrossRandActivityStatus(activity_type, status, start_time, end_time)
	self.cross_activity_list[activity_type] = {
		["type"] = activity_type,
		["status"] = status,
		["start_time"] = start_time,
		["end_time"] = end_time,
		["next_time"] = end_time,
		}

	for k, v in pairs(self.act_change_callback) do
		v(activity_type, status, end_time)
	end
end

function ActivityData:GetCrossRandActivityStatusByType(activity_type)
	return self.cross_activity_list[activity_type]
end

function ActivityData:GetActivityOpenByType(act_type)
	local level = PlayerData.Instance.role_vo.level
	for k,v in pairs(self.activity_list) do
		if act_type == v.type then
			local act_cfg = self:GetActivityConfig(v.type)
			if act_cfg == nil then
				return false
			end
			if v.status == ACTIVITY_STATUS.OPEN and act_cfg and act_cfg.min_level <= level and act_cfg.is_inscroll == 1 then
				return true
			end
		end
	end
	return false
end

function ActivityData:GetZhanShenItemCfg()
	local config = ConfigManager.Instance:GetAutoConfig("yizhandaodiconfig_auto").rank_title
	return config or {}
end

function ActivityData:GetXianMoItemCfg()
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").relive_pos
	return config or {}
end


-----------幸运日志------------------

function ActivityData:SendActivityLogType(activity_type)
	self.activity_type = activity_type or 0
end

function ActivityData:SetActivityLogInfo(protocol)
	self.lucky_log[protocol.activity_type] = protocol
end

function ActivityData:GetActivityLogInfo()
	return self.lucky_log[self.activity_type] or {}
end

-- 根据等级判断活动能否显示
function ActivityData:CanShowActivity(act_id, level)
	local cfg = self:GetActivityInfoById(act_id)
	if nil == cfg or nil == cfg.max_level or nil == cfg.min_level then
		return true
	end

	if not level then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		level = main_vo.level
	end
	if level < cfg.max_level and level >= cfg.min_level then
		return true
	end

	return false
end

-- 根据等级判断活动能否显示(只判断等级下限)
function ActivityData:CanShowActivityByLevelFloor(act_id, level)
	local cfg = self:GetActivityInfoById(act_id)
	if nil == cfg or nil == cfg.min_level then
		return true
	end

	if not level then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		level = main_vo.level
	end
	if level >= cfg.min_level then
		return true
	end

	return false
end

--增加一个活动信息到活动列表中
function ActivityData:AddActivityInfo(protocol)
	local tab = {
		activity_type = protocol.activity_type,
		status = protocol.status,
		is_broadcast = protocol.is_broadcast,
		next_status_switch_time = protocol.next_status_switch_time,
		param_1 = protocol.param_1,						--开始时间
		param_2 = protocol.param_2,						--结束时间
		open_type = protocol.open_type
	}
	if tab.status == ACTIVITY_STATUS.CLOSE then
		self.activity_info_list[tab.activity_type] = nil
	else
		self.activity_info_list[tab.activity_type] = tab
	end
end

function ActivityData:GetActivityInfoList()
	return self.activity_info_list
end

--增加一个活动信息到随机活动列表中
function ActivityData:AddCrossActivityInfo(protocol)
	local tab = {
		activity_type = protocol.activity_type,
		status = protocol.status,
		begin_time = protocol.begin_time,
		end_time = protocol.end_time,
	}
	if tab.status == ACTIVITY_STATUS.CLOSE then
		self.cross_activity_info_list[tab.activity_type] = nil
	else
		self.cross_activity_info_list[tab.activity_type] = tab
	end
end

function ActivityData:GetCrossActivityInfoList()
	return self.cross_activity_info_list
end

function ActivityData:GetActivityHallDatalistTwo()
	local data_list = {}
	local list = ActivityData.Instance:GetActivityHallDatalist()
	for k,v in pairs(list) do
		if v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY then
			local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
			local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum() or 0
			if gold < max_chongzhi_num then
				table.insert(data_list,v)
			end
		elseif v.type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE then
			local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
			if not (today_recharge and today_recharge > 0) then
				table.insert(data_list,v) 														--如果当天没有充值，显示单笔返利活动
			end
		else
			table.insert(data_list,v)
		end
	end
	return data_list
end