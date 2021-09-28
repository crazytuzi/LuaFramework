CollectiveGoalsData = CollectiveGoalsData or BaseClass()
function CollectiveGoalsData:__init()
	if CollectiveGoalsData.Instance ~= nil then
		ErrorLog("[CollectiveGoalsData] Attemp to create a singleton twice !")
	end
	CollectiveGoalsData.Instance = self
	self.goals_cfg = ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").battlefield_goal or {}
	self.daily_act_cfg = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto").show_cfg or {}
	self.show_field_type_list = {}
	for k,v in ipairs(self.goals_cfg) do
		table.insert(self.show_field_type_list, v.field_type)
	end
	RemindManager.Instance:Register(RemindName.CollectiveGoals, BindTool.Bind(self.GetAllRedPoint, self))
	self.red_point_list = {}
	self.flag = 0
end

function CollectiveGoalsData:__delete()
	RemindManager.Instance:UnRegister(RemindName.CollectiveGoals)
	
	CollectiveGoalsData.Instance = nil
end

function CollectiveGoalsData:GetActiveCfg()
	return self.goals_cfg
end

function CollectiveGoalsData:GetTitleSingleCfg(act_sep)
	local all_cfg = KaifuActivityData.Instance:GetBattleTitleCfg()
	if not all_cfg then return end
	for k,v in pairs(all_cfg) do
		if act_sep == v.act_sep then
			return v
		end
	end
end

function CollectiveGoalsData:GetGoalsSingleCfg(act_sep)
	for k,v in pairs(self.goals_cfg) do
		if act_sep == v.act_sep then
			return v
		end
	end
end

function CollectiveGoalsData:IsGoalsAct(act)
	for k,v in ipairs(self.show_field_type_list) do
		if v == act then
			return true
		end
	end
	return false
end

function CollectiveGoalsData:GetActType(server_day)
	local show_time_list = {}
	for k,v in ipairs(self.show_field_type_list) do
		if k == server_day then
			return v
		end
	end
	return 0
end


function CollectiveGoalsData:GetActTimeList()
	local show_time_list = {}
	for k,v in ipairs(self.show_field_type_list) do
		for m,n in pairs(self.daily_act_cfg) do
			if n.act_id == v then
				local open_time_list = Split(n.open_time, ":")
				table.insert(show_time_list, open_time_list)
			end
		end
	end
	return show_time_list
end

function CollectiveGoalsData:GetActiveTotalDay()
	return self.goals_cfg[1].open_server_day
end

function CollectiveGoalsData:GetAllRedPoint()
	local cfg = self:GetActiveCfg()
	for k,v in pairs(cfg) do
		local is_show_red = self:GetRedPointBySeq(v.act_sep)
		if is_show_red then
			return 1
		end
	end
	return 0
end

function CollectiveGoalsData:GetRedPointBySeq(act_sep)
	local goals_data = self:GetGoalsSingleCfg(act_sep)
	local can_get_flag = PersonalGoalsData.Instance:GetGolasRewardFlag()

	can_get_flag =  0 ~= bit:_and(can_get_flag, bit:_lshift(1, goals_data.field_type))
	local has_get_flag = PersonalGoalsData.Instance:GetGolasHasGetFlag()
	has_get_flag =  0 ~= bit:_and(has_get_flag, bit:_lshift(1, goals_data.field_type))
	if can_get_flag and not has_get_flag and goals_data.open_server_day == server_open_day then
		return true
	else
		return false
	end
end

function CollectiveGoalsData:IsGetRewardBySeq(act_sep)
	local goals_data = self:GetGoalsSingleCfg(act_sep)
	local has_get_flag = PersonalGoalsData.Instance:GetGolasHasGetFlag()
	has_get_flag =  0 ~= bit:_and(has_get_flag, bit:_lshift(1, goals_data.field_type))
	return has_get_flag
end

function CollectiveGoalsData:IsShowJumpIcon(act_sep)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if act_sep == server_open_day then
		return true
	end
	return false
end

function CollectiveGoalsData:GetNextTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if server_open_day > 4 then return end
	local server_time = os.date('*t', TimeCtrl.Instance:GetServerTime())
	local activity_time = self:GetActTimeList()[server_open_day]
	if not activity_time then
		return
	end
	local activity_hour, activity_min = activity_time[1], activity_time[2]
	local server_time = server_time.hour * 3600 + server_time.min * 60 + server_time.sec
	local activity_time = activity_hour * 3600 + activity_min * 60
	local next_time, time_str2 = 0, ""
	local is_flush = false
	if server_time <= activity_time then
		next_time = activity_time - server_time
		local the_flag = self.flag
		self.flag = 0
		is_flush = the_flag ~= self.flag
	else
		local the_flag = self.flag
		next_time, self.flag = 24*3600 + activity_time - server_time, 1
		is_flush = the_flag ~= self.flag
	end
	local time_str1 = self:FormatSecond(next_time, 3)
	if next_time > 3600 then
		time_str2 = self:FormatSecond(next_time, 2)
	else
		time_str2 = self:FormatSecond(next_time, 1)
	end
	if server_open_day == 4 and server_time > activity_time then
		time_str1 = ""
		time_str2 = ""
		self.flag = 0
		is_flush = true
	end
	return time_str1, time_str2, self.flag
end

function CollectiveGoalsData:FormatSecond(time, model)
	local s = ""
	if time > 0 then
		local hour = math.floor(time / 3600)
		local minute = math.floor((time / 60) % 60)
		local second = math.floor(time % 60)
		if 1 == model then
			s = string.format("%02d:%02d", minute, second)
		elseif 2 == model then
			s = string.format("%02d时%02d分", hour, minute)
		else
			s = string.format("%02d时%02d分%02d秒", hour, minute, second)
		end
	else
		if 2 == model then
			s = string.format("%02d:%02d", 0, 0)
		elseif 3 == model then
			s = string.format("%02d:%02d:%02d", 0, 0, 0)
		end
	end

	return s
end
