
CityPoolFightData = CityPoolFightData or BaseClass()

function CityPoolFightData:__init()
	if CityPoolFightData.Instance then
		ErrorLog("[CityPoolFightData]:Attempt to create singleton twice!")
	end
	CityPoolFightData.Instance = self
end

function CityPoolFightData:__delete()
	CityPoolFightData.Instance = nil
end

function CityPoolFightData.GetCityOwnerId()
	return GuildContendConfig and GuildContendConfig.statusMonster and GuildContendConfig.statusMonster.monsterId or -1
end

-- 设置参战行会列表(包括守城方和攻方)
function CityPoolFightData:SetJoinWarGuildList(protocol)
	self.join_war_guild_list = protocol.sign_up_guild_list
	GlobalEventSystem:Fire(GongchengEventType.CITY_POOL_FIGHT_SIGN_LIST)
end

-- 获取守城行会名
function CityPoolFightData:GetDefenceGuildName()
	local in_list = self.join_war_guild_list or {}
	for _,v in pairs(in_list) do
		if v.is_win == 1 then
			return v.name
		end	
	end	
	return ""
end	

-- 是否已参加攻城
function CityPoolFightData:IsSelfInAct()
	local my_guild_name = GuildData.Instance:GetGuildName()
	if my_guild_name == nil then
		return 0
	end
	for _, v in pairs(self.join_war_guild_list or {}) do
		if v.name == my_guild_name then
			return 1
		end
	end
	return 0
end

-- 获取攻城行会名单表
function CityPoolFightData:GetAtkGuildList()
	local in_list = self.join_war_guild_list or {}
	local out_list = {}
	for _,v in pairs(in_list) do
		if v.is_win == 0 then
			table.insert(out_list,v)
		end	
	end	
	return out_list
end

function CityPoolFightData:GetAllJoinWarGuildList()
	return self.join_war_guild_list or {}
end

function CityPoolFightData:GetAtkGuildNameStrList()
	local data_list = {}
	local atk_name_list = self:GetAtkGuildList()
	local guild_name_content = ""
	local length = #atk_name_list
	for k, v in ipairs(atk_name_list) do
		local row = math.floor((k - 1) / 2) + 1
		local col = math.floor((k - 1) % 2) + 1
		data_list[row] = data_list[row] or {name = ""}
		if k < length then
			data_list[row].name = data_list[row].name .. v.name .. "、"
		else
			data_list[row].name = data_list[row].name .. v.name
		end
	end
	return data_list
end

-- 记录城战的状态
function CityPoolFightData:SetCityPoolWarState(protocol)
	if not protocol or not protocol.state then return end
	self.war_state = protocol.state
end

function CityPoolFightData:GetWarState()
	return self.war_state or 0
end

-- 获胜行会名
function CityPoolFightData:SetCityPoolWinGuildName(protocol)
	self.win_guild_name = protocol.name
end

function CityPoolFightData:GetCityPoolWinGuildName()
	return self.win_guild_name or ""
end

-- 获取下一次攻城开启时间
function CityPoolFightData.GetNextOpenTimeDate(is_ignore_hour)
	local t_open_time = GuildConfig and GuildConfig.ContendOpenTime
	local weeks_t = t_open_time and t_open_time.weeks
	local times_t = t_open_time and t_open_time.times and t_open_time.times[1]
	if not weeks_t or not times_t then return end
	local is_sp_reward = false
	local now_weekday = tonumber(os.date("%w",TimeCtrl.Instance:GetServerTime()))
	if now_weekday == 0 then
		now_weekday = 7
	end
	local now_hour = tonumber(os.date("%H",TimeCtrl.Instance:GetServerTime()))
	local now_min = tonumber(os.date("%M",TimeCtrl.Instance:GetServerTime()))
	local shift_day = 0
	if not now_weekday or not now_hour or not now_min then return end

	local temp_weekday = -1
	for i = 1, #weeks_t do
		if now_weekday < weeks_t[i] then
			temp_weekday = weeks_t[i]
			break
		elseif now_weekday == weeks_t[i] then
			if is_ignore_hour or (times_t[3] and tonumber(times_t[3]) and now_hour < tonumber(times_t[3]) and
			 times_t[4] and tonumber(times_t[4]) and now_min < tonumber(times_t[4])) then
				temp_weekday = now_weekday
				break
			end
		end
	end

	if temp_weekday == -1 then
		shift_day = weeks_t[1] - now_weekday + 7
	else
		shift_day = temp_weekday - now_weekday
	end

	local open_shift_day = OtherData.Instance:GetOpenServerDays() - 5
	local combind_shift_day = OtherData.Instance:GetCombindDays() - 5
	if tonumber(open_shift_day) and open_shift_day <= 0 then
		local is_use = is_ignore_hour or (-open_shift_day ~= 0) or (times_t[3] and tonumber(times_t[3]) and now_hour < tonumber(times_t[3]))
		if is_use then
			shift_day = - open_shift_day
			is_sp_reward = true
		end
	elseif tonumber(combind_shift_day) and combind_shift_day <= 0 and OtherData.Instance:GetCombindDays() > 0 then  
		local is_use = is_ignore_hour or (-combind_shift_day ~= 0) or (times_t[3] and tonumber(times_t[3]) and now_hour < tonumber(times_t[3]))
		if is_use then
			shift_day = - combind_shift_day
			is_sp_reward = true
		end
	end
	local next_s = TimeCtrl.Instance:GetServerTime() + shift_day * 24 * 60 * 60
	local date_t = {}
	date_t.month = os.date("%m",next_s)
	date_t.day = os.date("%d",next_s)
	date_t.weekday = tonumber(os.date("%w",next_s))
	date_t.hour_1 = times_t[1] or 20
	date_t.min_1 = times_t[2] or 0
	date_t.hour_2 = times_t[3] or 21
	date_t.min_2 = times_t[4] or 0
	date_t.is_sp_reward = is_sp_reward
	return date_t, next_s,shift_day
end

-- 获取下次攻城战时间字符串
function CityPoolFightData.GetNextOpenTimeDateStr()
	local date_t = CityPoolFightData.GetNextOpenTimeDate()
	if date_t == nil or not date_t.month or not date_t.day or not date_t.weekday then return "" end
	local weekday = date_t.weekday == 0 and 7 or date_t.weekday
	return string.format(Language.WangChengZhengBa.DateStr, date_t.month, date_t.day,date_t.hour_1 or "20", 
		date_t.min_1 or "00", date_t.hour_2 or "21", date_t.min_2 or "00", Language.Common.CHNWeekDays[weekday])
end

function CityPoolFightData.GetShowAwards()
	local show_awards = {}
	local cfg = GuildContendConfig.winGuildAward[1]
	if cfg then
		table.insert(show_awards, {item_id = cfg.id, num = cfg.count, is_bind = cfg.bind})
	end
	cfg = GuildContendConfig.failGuildAward[1]
	if cfg then
		table.insert(show_awards, {item_id = cfg.id, num = cfg.count, is_bind = cfg.bind})
	end
	return show_awards
end