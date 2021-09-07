WelfareData = WelfareData or BaseClass()

function WelfareData:__init()
	if WelfareData.Instance then
		print_error("[WelfareData] 尝试创建第二个单例模式")
		return
	end
	WelfareData.Instance = self

	self.welfare_cfg = ConfigManager.Instance:GetAutoConfig("welfare_auto")

	self.welfare_award_cfg = ListToMap(self.welfare_cfg.open_server_sign_in_reward_config, "day")
	self.cur_month_cfg =ListToMap(self.welfare_cfg.sign_in, "month", "day") 

	self.addtime_callback = BindTool.Bind(self.AddTime, self)
	self.time_change_callback = {}
	self.online_time = 0

	self.sign_in_days = 0
	self.change_sign_flag = 0
	self.daily_find_list = {}
	self.happy_tree_growth_val_list = {}
	self.happy_tree_reward = 0
	self.total_happy_tree_growth_val = 0
	self.accmulation_signin_days = 0
	self.total_sign_count = 0
	self.is_open_server_sign_in = 0
	self.chongzhi_count = 0

	self.chongjihaoli_reward_flag_list = {}
	self.chongjihaoji_record_list = {}
	self.open_server_sign_in_reward_mark = {}
	
	GlobalTimerQuest:AddDelayTimer(function()
		self.add_time_quest = GlobalTimerQuest:AddRunQuest(self.addtime_callback, 1)
	end, 0)

	self.red_point_list = {
		["Sign"] = false,
		-- ["OnlineReward"] = false,
		["FindReward"] = false,
		["HappyTree"] = false,
		["LevelReward"] = false,
	}

	--引用二进制
	self.luabit = require"bit"
	self.tree_exchange_had_click = false

	self.callback = BindTool.Bind(self.SetLevelExchangeRedPoint, self)

	GlobalTimerQuest:AddDelayTimer(function()
		ActivityData.Instance:NotifyActChangeCallback(self.callback)
	end, 0)
	self.level_change_callback = BindTool.Bind(self.LevelRewardRedPoint, self)
	PlayerData.Instance:ListenerAttrChange(self.level_change_callback)

	RemindManager.Instance:Register(RemindName.WelfareSign, BindTool.Bind(self.GetSignRemind, self))
	RemindManager.Instance:Register(RemindName.WelfareFind, BindTool.Bind(self.GetFindRemind, self))
	RemindManager.Instance:Register(RemindName.WelfareLevelReward, BindTool.Bind(self.GetLevelRewardRemind, self))
end

function WelfareData:SetHappyTreeExchangeRedPoint()
	self:CheckHappyTreeRedPoint()
end

function WelfareData:SetLevelExchangeRedPoint(attr_name, value)
	if attr_name == "level" then
		self:LevelRewardRedPoint()	
	end
end

function WelfareData:__delete()
	RemindManager.Instance:UnRegister(RemindName.WelfareSign)
	RemindManager.Instance:UnRegister(RemindName.WelfareFind)
	RemindManager.Instance:UnRegister(RemindName.WelfareLevelReward)

	if ActivityData.Instance ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.callback)
	end
	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.level_change_callback)
	end
	if self.add_time_quest then
		GlobalTimerQuest:CancelQuest(self.add_time_quest)
		self.add_time_quest = nil
	end
	WelfareData.Instance = nil
end

function WelfareData:GetLevelRewardCfg()
	return self.welfare_cfg.chong_level_gift
end

function WelfareData:GetLevelRewardList()
	local list = {}
	local cfg = self:GetLevelRewardCfg()
	
	for i = #cfg, 1, -1 do
		local flag = self.chongjihaoli_reward_flag_list[32 - i + 1]
		local vo = TableCopy(cfg[i])
		vo.flag = flag
		table.insert(list, vo)
	end
	table.sort(list, SortTools.KeyLowerSorter("flag", "level"))
	return list
end

function WelfareData:GetExchangeLeftTime()
	self.is_today = false
	local time_cfg = ActivityData.Instance:GetClockActivityByID(22)
	local reward_wdays = {}
	reward_wdays[0] = time_cfg.open_day
	local start_time = Split(time_cfg.open_time, ":")
	local end_time = Split(time_cfg.end_time, ":")
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	--本日0点开始已经过了多少秒
	local today_pass_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	--奖励日0点开始到开启活动需多少秒
	local start_interval = start_time[1] * 3600 + start_time[2] * 60
	--奖励日0点开始到结束活动需多少秒
	local end_interval = end_time[1] * 3600 + start_time[2] * 60
	--本日是星期几
	local wday = 0
	if time_table.wday == 1 then
		wday = 7
	else
		wday = time_table.wday - 1
	end

	for k,v in pairs(reward_wdays) do
		if wday == tonumber(v) then
			if today_pass_time > start_interval and today_pass_time < end_interval then
				--在奖励时段
				self.is_today = true
				return end_interval - today_pass_time
			end
		end
	end
	--不在奖励时段
	local reward_wday = 0
	for k,v in pairs(reward_wdays) do
		if tonumber(v) >= wday then
			reward_wday = v
			break
		end
	end

	if reward_wday == 0 then
		local min = 999
		for k,v in pairs(reward_wdays) do
			if tonumber(v) < min then
				min = tonumber(v)
			end
		end
		reward_wday = min
	end

	local left_day = 0
	if tonumber(wday) > tonumber(reward_wday) then
		left_day = 7 - wday + reward_wday - 1
	elseif wday == reward_wday then
		if today_pass_time < start_interval then
			return start_interval - today_pass_time
		else
			left_day = 6
		end
	else
		left_day = reward_wday - wday - 1
	end
	local day_left_time = left_day * 24 * 3600
	local today_end_left_time = 86400 - today_pass_time
	return today_end_left_time + day_left_time + start_interval
end

function WelfareData:SetWelfareData(protocol)
	self.activity_find_flag = protocol.activity_find_flag
	self.online_reward_mark = bit:d2b(protocol.online_reward_mark)
	self.continuous_sign_in_days = protocol.continuous_sign_in_days
	self.sing_in_times = protocol.sign_in_today_times
	self.offline_time = protocol.offline_timestamp
	self.offline_exp = protocol.offline_exp
	self.sign_in_reward_mark = bit:d2b(protocol.sign_in_reward_mark)
	self.sign_in_days = bit:d2b(protocol.sign_in_days)
	self.change_sign_flag = protocol.change_sign_flag
	self.online_time = protocol.today_online_time
	self.daily_find_list = protocol.daily_find_list
	self.chongzhi_flag = protocol.chongzhi_flag
	self.happy_tree_growth_val_list = protocol.happy_tree_growth_val_list
	self.happy_tree_level = protocol.happy_tree_level
	self.happy_tree_reward = protocol.happy_tree_reward
	self.total_happy_tree_growth_val = protocol.total_happy_tree_growth_val
	self.accmulation_signin_days = protocol.accmulation_signin_days
	self.chongzhi_count = protocol.chongzhi_count
	self.total_sign_count = 0 				--总签到天数
	local sign_in_flag_list = self:GetSignFlagList()
	for i = 1, 31 do
		if sign_in_flag_list[32-i] ~= 0 then
			self.total_sign_count = self.total_sign_count + 1
		end
	end

	--冲级豪礼
	self.chongjihaoli_reward_flag_list = bit:d2b(protocol.chongjihaoli_reward_mark)
	self.chongjihaoji_record_list = protocol.chongjihaoji_record_list
	self.open_server_sign_in_reward_mark = bit:d2b(protocol.open_server_sign_in_reward_mark)
	self.is_open_server_sign_in = protocol.is_open_server_sign_in
	
	self:CheckRedPoint()
end

function WelfareData:GetSignInfo()
	if self:GetIsOpenServerSign() then
		return self.open_server_sign_in_reward_mark
	end
	return self.sign_in_days
end


function WelfareData:GetIntradaySignInfo(num)
	if self:GetIsOpenServerSign() then
		return self.open_server_sign_in_reward_mark[32 - num]
	end
	return self.sign_in_days[32 - num]
end

---------------是否在开服签到期间----------
function WelfareData:GetIsOpenServerSign()
	return self.is_open_server_sign_in > 0
end

---------------冲级豪礼--------------------------------
function WelfareData:GetLevelRewardFlag(index)
	return self.chongjihaoli_reward_flag_list[32 - index] or 0
end

function WelfareData:GetHasGetCountByIndex(index)
	return self.chongjihaoji_record_list[index + 1] or 0
end

--等级豪礼红点
function WelfareData:LevelRewardRedPoint(attr_name, value)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local can_get = false
	local level_reward_cfg = self:GetLevelRewardCfg()
	for k, v in ipairs(level_reward_cfg) do
		if main_vo.level >= v.level then
			local get_flag = self:GetLevelRewardFlag(v.index)
			if v.is_limit_num == 1 then
				local has_get_count = WelfareData.Instance:GetHasGetCountByIndex(v.index)
				local left_count = v.limit_num - has_get_count
				left_count = left_count < 0 and 0 or left_count
				if left_count > 0 and get_flag == 0 then
					can_get = true
					break
				end
			else
				if get_flag == 0 then
					can_get = true
					break
				end
			end			
		end
	end
	self.red_point_list["LevelReward"] = can_get
end
---------------------------------------------------------

function WelfareData:GetRedPoint(key)
	return self.red_point_list[key]
end

function WelfareData:GetAllRedPoint()
	return self.red_point_list
end

function WelfareData:OnlineTimeRedPoint()
	--在线奖励的红点
	if self.online_reward_mark == nil then
		return
	end
	local online_time_flag = false
	for k,v in pairs(self.welfare_cfg.online_reward) do
		local had_got = self:OnlineRewardMark(v.seq)
		if not had_got then
			local can_get = self:CheckIsCanGetReward(v.minutes)
			if can_get then
				online_time_flag = true
				break
			end
		end
	end
	self.red_point_list["OnlineReward"] = online_time_flag
end

--找回的红点
function WelfareData:CheckFindRedPoint()
	local find_list = self:GetFindData()
	self.red_point_list["FindReward"] = next(find_list) ~= nil
end

--欢乐果树的红点
function WelfareData:CheckHappyTreeRedPoint()
	local apple_list = self:GetHappyTreeRewardCfg()
	if apple_list == nil then
		return
	end
	local tree_flag = false
	for k,v in pairs(apple_list) do
		if not self:GetRewardFetchFlagByType(v.fecth_type) then
			if self.total_happy_tree_growth_val >= v.growth_val then
				tree_flag = true
			end
		end
	end
	if not tree_flag and not self.tree_exchange_had_click then
		tree_flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HAPPYTREE_GROW_EXCHANGE)
	end
	self.red_point_list["HappyTree"] = tree_flag
end

function WelfareData:SetHappyTreeExchangeHadClick()
	self.tree_exchange_had_click = true
	self:SetHappyTreeExchangeRedPoint()
end

function WelfareData:GetHappyTreeExchangeHadClick()
	return self.tree_exchange_had_click
end

function WelfareData:GetTotalSignCount()
	return self.total_sign_count
end

function WelfareData:GetCanGetSignReward()
	local can_get = false
	if self.sing_in_times == 0 then
		can_get = true
	-- elseif self.sing_in_times == 1 then
	-- 	if self.chongzhi_flag == 1 then
	-- 		can_get = true
	-- 	end
	end
	return can_get
end

function WelfareData:CheckRedPoint()
	--签到红点
	self:CheckSignRedPoint()
	--找回的红点
	self:CheckFindRedPoint()
	-- --离线经验的红点
	-- self.red_point_list["OfflineExp"] = self.offline_exp > 0
	--欢乐果树的红点
	self:CheckHappyTreeRedPoint()

	--等级豪礼红点
	self:LevelRewardRedPoint()
end

function WelfareData:CheckSignRedPoint()
	local sign_flag = false
	if self.is_open_server_sign_in == 0 then
		local sign_flag_list = self:GetSignFlagList()
		local total_sign_flag_list = self:GetTotalSignInReardMark()

		local total_sign_reward_list = self:GetTotalSignCfg()

		local now_day = TimeCtrl.Instance:GetServerDay()
		now_day = tonumber(now_day)
		if sign_flag_list[32-now_day] == 0 then
			--当天还没签到
			sign_flag = true
		end
		for k,v in ipairs(total_sign_reward_list) do
			local got_flag = total_sign_flag_list[32-(k-1)]
			if got_flag == 0 then
				local sign_count = self:GetTotalSignCount()
				local can_get = sign_count >= v.total_sign_in
				if can_get then
					sign_flag = true
					break
				end
			end
		end
	else
		local now_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if self.open_server_sign_in_reward_mark[32-now_day] == 0 then
			--当天还没签到
			sign_flag = true
		end
	end
	self.red_point_list["Sign"] = sign_flag
end

function WelfareData:NotifyWhenTimeChange(callback)
	self.time_change_callback[callback] = callback
end

function WelfareData:UnNotifyWhenTimeChange(callback)
	self.time_change_callback[callback] = nil
end

function WelfareData:GetChongZhiFlag()
	return self.chongzhi_flag
end

--获取福利Cfg
function WelfareData:GetWelfareCfg()
	return self.welfare_cfg
end

function WelfareData:TimeWithZero(num)
	if num < 10 then
		return "0"..num
	else
		return num
	end
end

--把秒转换为00:00:00格式
function WelfareData:TimeFormatWithZero(total_sec)
	local h, m, s = self:TimeFormat(total_sec)
	return self:TimeWithZero(h)..":"..self:TimeWithZero(m)..":"..self:TimeWithZero(s)
end

--把秒转换为时分秒
function WelfareData:TimeFormat(total_sec)
	local time_tab = TimeUtil.Format2TableDHMS(total_sec)
	local hour = time_tab.hour
	local min = time_tab.min
	local sec = time_tab.s
	return hour, min, sec
end

--把秒转换为日时分秒
function WelfareData:TimeFormatWithDay(total_sec)
	local day = math.floor(total_sec/86400)
	total_sec = total_sec - (day * 86400)
	local h,m,s = self:TimeFormat(total_sec)
	return day, h, m, s
end

--签到--------------------
--获取总签到进度
function WelfareData:GetSignInProcess(total_sign_in_day)
	local count = -1
	for k,v in pairs(self.welfare_cfg.total_sign_in) do
		if v.total_sign_in <= total_sign_in_day then
			count = count + 1
		else
			break
		end
	end
	if count == -1 then
		return 0
	end
	return count/(#self.welfare_cfg.total_sign_in - 2)
end

--获取开服签到奖励领取信息
-- function WelfareData:GetOpenSignFlagList()
-- 	return self.open_server_sign_in_reward_mark or 0
-- end

--获取开服签到总天数
function WelfareData:GetOpenAllSign()
	local all_sign_day = 0
	for k,v in pairs(self:GetSignInfo()) do
		if v == 1 then
			all_sign_day = all_sign_day + 1
		end
	end

	return all_sign_day
end

--获取签到奖励领取信息
function WelfareData:GetSignFlagList()
	return self.sign_in_days or 0
end

--获取改变的签到奖励领取情况
function WelfareData:GetChangeSignFlagList()
	if self:GetIsOpenServerSign() then
		return self.open_server_sign_in_reward_mark
	end
	return bit:d2b(self.change_sign_flag)
end

-- --获取总签到奖励领取情况
function WelfareData:GetTotalSignInReardMark()
	return self.sign_in_reward_mark or 0
end

--获取某一天的签到奖励
function WelfareData:GetSingleSignReward(month, day)
	month = month - 1
	--local cur_month_cfg = self.welfare_cfg.sign_in

	if self.is_open_server_sign_in and self.is_open_server_sign_in > 0 then
		return self.welfare_award_cfg[day]
	end

		-- for k,v in pairs(self.welfare_cfg.open_server_sign_in_reward_config) do
		-- 	if v.day == day then
		-- 		return v
		-- 	end
		-- end
	-- end

	if self.cur_month_cfg[month] == nil then
		return nil
	end
	return self.cur_month_cfg[month][day]

	-- for k,v in pairs(self.welfare_cfg.sign_in) do
	-- 	if v.month == month and v.day == day then
	-- 		return v
	-- 	end
	-- end
end

--获取某个月的签到奖励列表
function WelfareData:GetSingleSignRewardByMonth(month)
	local reward_list = {}
	month = month - 1
	local cur_month_cfg = self.welfare_cfg.sign_in
	if self.is_open_server_sign_in and self.is_open_server_sign_in > 0 then
		return self.welfare_cfg.open_server_sign_in_reward_config
	end
	for k,v in ipairs(cur_month_cfg) do
		if v.month > month then
			break
		end
		if v.month == month then
			table.insert(reward_list, v)
		end
	end
	return reward_list
end

--获取总签到奖励Cfg
function WelfareData:GetTotalSignCfg()
	local total_sign_list = {}
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	local now_month = tonumber(time_table.month)
	now_month = now_month - 1
	for k, v in ipairs(self.welfare_cfg.total_sign_in) do
		if v.month > now_month then
			break
		end
		if now_month == v.month then
			table.insert(total_sign_list, v)
		end
	end
	return total_sign_list
end

--获取最大累计签到天数
function WelfareData:GetMaxTotalSignDay()
	local max_day = 0
	if self.welfare_cfg then
		local total_sign_list = self.welfare_cfg.total_sign_in or {}
		local last_tbl = total_sign_list[#total_sign_list] or {}
		max_day = last_tbl.total_sign_in
	end
	return max_day
end

--获取充值签到信息
function WelfareData:GetSignInTimes()
	return self.sing_in_times
end

--获取连续签到日
function WelfareData:GetContinuousSignInDays()
	return self.continuous_sign_in_days
end

--获取该月所有补签奖励列表
function WelfareData:GetOpenServerAllRecSign()
	local now_day = tonumber(TimeCtrl.Instance:GetCurOpenServerDay())
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	local sign_flag_list = self:GetSignInfo()
	local sign_reward_list = self:GetSingleSignRewardByMonth(tonumber(time_table.month))
	local rec_sign_reward_list = {}
	for k, v in ipairs(sign_reward_list) do
		if k < now_day then
			local flag = sign_flag_list[32-k]
			if flag == 0 then
				table.insert(rec_sign_reward_list, v)
			end
		else
			break
		end
	end
	return rec_sign_reward_list
end

--获取该月所有补签奖励列表
function WelfareData:GetAllRecSign()
	local now_day = TimeCtrl.Instance:GetServerDay()
	now_day = tonumber(now_day)
	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	local sign_flag_list = self:GetSignFlagList()
	local sign_reward_list = self:GetSingleSignRewardByMonth(tonumber(time_table.month))
	local rec_sign_reward_list = {}
	for k, v in ipairs(sign_reward_list) do
		if k < now_day then
			local flag = sign_flag_list[32-k]
			if flag == 0 then
				table.insert(rec_sign_reward_list, v)
			end
		else
			break
		end
	end
	return rec_sign_reward_list
end

--在线奖励----------------
--获取在线奖励Cfg,领取过的会靠下
function WelfareData:GetOnlineRewardCfg()
	local data = {}
	local data_2 = {}
	for k,v in pairs(self.welfare_cfg.online_reward) do
		local mark = self:OnlineRewardMark(v.seq)
		if mark then
			table.insert(data_2, v)
		else
			table.insert(data, v)
		end
	end
	for k,v in pairs(data_2) do
		table.insert(data, v)
	end
	return data
end

--获取在线时间，时分秒格式
function WelfareData:GetOnlineTime()
	return self:TimeFormat(self.online_time)
end

--获取总在线时间
function WelfareData:GetTotalOnlineTime()
	return self.online_time
end

--计时
function WelfareData:AddTime()
	self.online_time = self.online_time + 1
	-- self:OnlineTimeRedPoint()
	for k,v in pairs(self.time_change_callback) do
		v()
	end
end

--根据seq获取在线奖励领取情况
function WelfareData:OnlineRewardMark(seq)
	if seq == nil then
		return false
	end
	if self.luabit.band(self.online_reward_mark,self.luabit.lshift(1,seq)) ~= 0 then
		return true
	else
		return false
	end
end

--获取在线奖励数据
function WelfareData:GetOnlineReward()
	local reward_data = {}
	local is_all_get = false
	local online_min = math.floor(self.online_time/60)
	if not self.online_reward_mark then
		return reward_data, is_all_get
	end
	local online_reward_flag = self.online_reward_mark
	for k, v in ipairs(self.welfare_cfg.online_reward) do
		local flag = online_reward_flag[32 - (k - 1)]
		if flag == 0 then
			reward_data = v
			break
		end
	end
	if not next(reward_data) then
		reward_data = self.welfare_cfg.online_reward[#self.welfare_cfg.online_reward]
		is_all_get = true
	end
	return reward_data, is_all_get
end

function WelfareData:CheckIsCanGetReward(min)
	local online_min = math.floor(self.online_time/60)
	return online_min >= min
end

--找回--------------------
--更新找回数据
function WelfareData:UpdateFindData(protocol)
	for k,v in pairs(self.daily_find_list) do
		if v.find_type == protocol.dailyfind_type then
			table.remove(self.daily_find_list, k)
		end
	end
	self:CheckFindRedPoint()
end

local CheckList = {
	[1] = "exp",
	[2] = "honor",
	[3] = "bind_coin",
	[4] = "item_count",
}

--获取找回数据 0、日常找回 1、活动找回
function WelfareData:GetFindData()
	local data = {}
	local count = 1
	for k,v in pairs(self.daily_find_list) do
		if self:IsOpen(v.find_type, 0) then
			v.total_type = 0
			data[count] = v
			count = count + 1
		end
		-- local is_empty = true
		-- for k2,v2 in pairs(CheckList) do
		-- 	if v[v2] ~= nil and v[v2] > 0 then
		-- 		is_empty = false
		-- 		break
		-- 	end
		-- end
		-- if not is_empty then
		-- 	v.total_type = 0
		-- 	data[count] = v
		-- 	count = count + 1
		-- end
	end
	for k,v in pairs(self.welfare_cfg.activity_find) do
		if self.luabit.band(self.activity_find_flag, self.luabit.lshift(1,v.find_type)) ~= 0 then
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local match_cfg = nil
			for k2,v2 in pairs(self.welfare_cfg.activity_find_reward) do
				if v2.find_type == v.find_type then
					if v2.level <= vo.level then
						match_cfg = v2
					end
				end
			end
			local tmp_data = {}
			tmp_data.vo = v
			tmp_data.gold_need = match_cfg.cost
			tmp_data.item_list = match_cfg.reward_item
			tmp_data.total_type = 1

			tmp_data.bind_coin = match_cfg.bind_coin
			tmp_data.exp = match_cfg.exp
			tmp_data.yuanli = match_cfg.yuanli
			tmp_data.nvwashi = match_cfg.nvwashi
			tmp_data.honor = match_cfg.honor
			tmp_data.guild_gongxian = match_cfg.guild_gongxian
			if self:IsOpen(v.find_type, 1) then
				data[count] = tmp_data
				count = count + 1
			end
		end
	end
	return data
end

--离线--------------------
--获取离线时间,时分秒格式
function WelfareData:GetOffLineTime()
	return self:TimeFormat(self.offline_time or 0)
end

--获取离线经验
function WelfareData:GetOffLineExp()
	return self.offline_exp or 0
end

--获取离线经验Cfg
function WelfareData:GetOffLineExpCfg()
	return self.welfare_cfg.offline_exp
end

--欢乐果树--------------------
--获取果树等级
function WelfareData:GetHappyTreeLevel()
	return self.happy_tree_level or 0
end

--根据奖励类型获取是否领取奖励
function WelfareData:GetRewardFetchFlagByType(fetch_type)
	if self.luabit.band(self.happy_tree_reward,self.luabit.lshift(1,fetch_type - 1)) ~= 0 then
		return true
	else
		return false
	end
end

--获取果树奖励Cfg
function WelfareData:GetHappyTreeRewardCfg()
	if self.happy_tree_level == nil then
		return
	end
	local count = 1
	local reward_list = {}
	for k,v in pairs(self.welfare_cfg.happy_tree) do
		if v.level == self.happy_tree_level then
			reward_list[count] = v
			count = count + 1
		elseif v.level > self.happy_tree_level then
			break
		end
	end
	return reward_list
end

--根据角色果树成长值
function WelfareData:GetHappyTreeGrowValueByType(fetch_type)
	return self.happy_tree_growth_val_list[fetch_type]
end

--根据成长类型果树成长值Cfg
function WelfareData:GetHappyTreeGrowCfgByType(fetch_type)
	for k,v in pairs(self.welfare_cfg.max_growth_val_per_day) do
		if v.level == self.tree_level and v.fetch_type == fetch_type then
			return v
		end
	end
end

--获取果树总成长值
function WelfareData:GetHappyTreeTotalGrowValue()
	return self.total_happy_tree_growth_val
end

--获取成长值比例
function WelfareData:GetHappyTreeTotalGrowScale()
	return self.welfare_cfg.growth_val_config
end

function WelfareData:GetIsExchangeDay()
	return self.is_today
end

-- 得到累计签到天数
function WelfareData:GetAccmulationSigninDays()
	return self.accmulation_signin_days
end

--获得充值次数
function WelfareData:GetRechargeTimes()
	return self.chongzhi_count
end

-- 是否显示
function WelfareData:IsOpen(_type, big_type)
	local config = self.welfare_cfg.daily_find_list
	-- 活动找回
	if big_type == 1 then
		config = self.welfare_cfg.activity_find
	end
	if not config then
		return false
	end
	for k,v in pairs(config) do
		if v.show == nil or v.show > 0 then
			if big_type == 1 then
				if v.find_type == _type then
					return v.is_open ~= 0
				end
			else
				if v.type == _type then
					return v.is_open ~= 0
				end
			end
		end
	end
	return false
end

function WelfareData:GetSignRemind()
	if not OpenFunData.Instance:CheckIsHide("welfare") then
		return 0
	end
	return self:GetRedPoint("Sign") and 1 or 0
end

function WelfareData:GetFindRemind()
	if not OpenFunData.Instance:CheckIsHide("welfare") then
		return 0
	end
	return self:GetRedPoint("FindReward") and 1 or 0
end

function WelfareData:GetLevelRewardRemind()
	if not OpenFunData.Instance:CheckIsHide("welfare") then
		return 0
	end
	return self:GetRedPoint("LevelReward") and 1 or 0
end

function WelfareData:GetRewardByLevel(level)
	if next(self.chongjihaoli_reward_flag_list) == nil or next(self.chongjihaoji_record_list) == nil then
		return {}
	end

	local chongjihaoli_flag = {}
	local cfg = TableCopy(self:GetLevelRewardCfg())
	table.sort(cfg, SortTools.KeyLowerSorter("level"))
	local index = 0
	for i = 1, #cfg do
		index = cfg[i].index
		if self.chongjihaoli_reward_flag_list[32 - index] < 1 and self.chongjihaoji_record_list[index + 1] < cfg[i].limit_num then
			return cfg[i]
		end
	end
	
	return {}
end

function WelfareData:UpLevelRewardCanGetState()
	if next(self.chongjihaoli_reward_flag_list) == nil then
		return false
	end
	local cfg = self:GetLevelRewardCfg()
	local index = 32
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for i = 1, #cfg do
		if self.chongjihaoli_reward_flag_list[index] < 1 and role_level >= cfg[i].level then
			return true
		end
		index = index - 1
	end

	return false
end

function WelfareData:GetShowLimitLevel()
	local limit_level = 30
	if next(self.welfare_cfg) ~= nil then
		limit_level = self.welfare_cfg.other.show_level or limit_level
	end

	return limit_level
end