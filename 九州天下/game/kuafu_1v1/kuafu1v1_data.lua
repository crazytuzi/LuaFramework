KuaFu1v1Data = KuaFu1v1Data or BaseClass()
local MIN_RANK_TYPE = 1
local MAX_RANK_TYPE = 7
local MIN_RANK_INDEX = 5
local MAX_RANK_INDEX = 1

function KuaFu1v1Data:__init()
	if KuaFu1v1Data.Instance then
		print_error("[KuaFu1v1Data] Attempt to create singleton twice!")
		return
	end
	KuaFu1v1Data.Instance = self

	self.role_data = {
		cross_honor = 0,
		cross_score_1v1 = 0,
		cross_1v1_left_hp = 0,
		cross_week_win_1v1_count = 0,
		cross_week_lose_1v1_count = 0,
		cross_day_win_1v1_count = 0,
		cross_day_lose_1v1_count = 0,
		cross_1v1_day_match_fail_count = 0,
		cross_dur_win_1v1_max_count = 0,
		cross_dur_win_1v1_count = 0,
		cross_dur_lose_1v1_count = 0,
		cross_1v1_xiazhu_seq = 0,
		cross_1v1_xiazhu_gold = 0,
		cross_1v1_curr_activity_add_honor = 0,								--跨服1v1本场活动增加的荣誉
		cross_1v1_curr_activity_add_score = 0,								--跨服1v1本场活动增加的威望
		cross_1v1_max_score = 0,
		cross_1v1_score_reward_flag = 0,
	}

	self.result = 0
	self.match_end_left_time = 0

	self.record = {
		win_this_week = 0,
		lose_this_week = 0,
		kf_1v1_news = {},
	}

	self.rank_list = {}

	self.match_result = {
		result = 0,
		side = 0,
		oppo_plat_type =  0,
		oppo_sever_id =  0,
		role_id = 0,
		oppo_name = "",
		fight_start_time = 0,
		prof = 0,
		sex = 0,
		camp = 0,
		level = 0,
		fight_end_time = 0,
		capability = 0,
	}

	self.fight_result = {
		result = 0,
		week_win_times = 0,
		week_lose_times =  0,
		week_score = 0,
		this_honor = 0,
		this_score = 0,
		dur_win_count = 0,
		max_dur_win_count = 0,
		oppo_dur_win_count = 0,
		self_hp_per = 0,
		oppo_hp_per = 0,
	}

	self.pre_cross_score_1v1 = -1
	self.cur_cross_score_1v1 = -1
	self.rank_level_up = false
	self.is_out_from_1v1_scene = false
end

function KuaFu1v1Data:__delete()
	KuaFu1v1Data.Instance = nil
end

function KuaFu1v1Data:SetRoleData(info)
	if nil == info then
		return
	end

	for k,v in pairs(info) do
		self.role_data[k] = v
	end

	if -1 == self.pre_cross_score_1v1 or -1 == self.cur_cross_score_1v1 then
		self.pre_cross_score_1v1 = info.cross_score_1v1
		self.cur_cross_score_1v1 = info.cross_score_1v1
	else
		self.pre_cross_score_1v1 = self.cur_cross_score_1v1
		self.cur_cross_score_1v1 = info.cross_score_1v1
	end
end

function KuaFu1v1Data:IsKuaFuRankLevelUp()
	local pre_config = self:GetRankByScore(self.pre_cross_score_1v1)
	local cur_config = self:GetRankByScore(self.cur_cross_score_1v1)

	if nil == pre_config and nil == cur_config then
		return false
	end

	if nil == pre_config and nil ~= cur_config then
		return true
	end

	if nil ~= pre_config and nil ~= cur_config then
		local pre_rank_type = pre_config.rank_type or MIN_RANK_TYPE
		local pre_rank_index = pre_config.rank_index or MIN_RANK_INDEX
		local cur_rank_type = cur_config.rank_type or MIN_RANK_TYPE
		local cur_rank_index = cur_config.rank_index or MIN_RANK_INDEX
		if 	pre_rank_type < cur_rank_type then
			return true
		end

		if pre_rank_type == cur_rank_type and pre_rank_index > cur_rank_index then
			return true
		end

		return false
	end

	return false
end

function KuaFu1v1Data:GetRoleData()
	return self.role_data
end

function KuaFu1v1Data:SetMatchAck(info)
	if info then
		self.result = info.result
		self.match_end_left_time = info.match_end_left_time
	end
end

function KuaFu1v1Data:SetRecord(info)
	if info then
		for k,v in pairs(info) do
			self.record[k] = v
		end
	end
end

function KuaFu1v1Data:SetRankList(info)
	if info then
		self.rank_list = info
	end
end

function KuaFu1v1Data:SetMatchResult(info)
	if info then
		self.match_result = {}
		for k,v in pairs(info) do
			self.match_result[k] = v
		end
	end
end

function KuaFu1v1Data:SetFightResult(info)
	if info then
		for k,v in pairs(info) do
			self.fight_result[k] = v
		end
	end
end

function KuaFu1v1Data:GetMatchAck()
	return self.result, self.match_end_left_time
end

function KuaFu1v1Data:GetRecord()
	return self.self.record
end

function KuaFu1v1Data:GetRankList()
	return self.rank_list
end

function KuaFu1v1Data:GetMatchResult()
	return self.match_result
end


function KuaFu1v1Data:ClearMatchResult()
	self.match_result = nil
end

function KuaFu1v1Data:GetFightResult()
	return self.fight_result
end

function KuaFu1v1Data:GetFightTime()
	if self.match_result then
		return self.match_result.fight_end_time - self.match_result.fight_start_time
	end
	return 60
end

function KuaFu1v1Data:GetRankByScore(score)
	if not score then return end
	local rank_config = self:GetRankConfig()
	if rank_config then
		local current_config = nil
		local next_config = nil
		for k,v in pairs(rank_config) do
			current_config = v
			if score < v.rank_score then
				next_config = v
				current_config = rank_config[k - 1]
				break
			end
		end
		return current_config, next_config
	end
end

function KuaFu1v1Data:GetRankByIndex(rank_type, rank_index)
	local rank_config = self:GetRankConfig()
	if rank_config then
		for k,v in pairs(rank_config) do
			if rank_index == v.rank_index and rank_type == v.rank_type then
				return v
			end
		end
	end
end

function KuaFu1v1Data:GetRankCountByType(rank_type)
	local count = 0
	local rank_config = self:GetRankConfig()
	if rank_config then
		for k,v in pairs(rank_config) do
			if rank_type == v.rank_type then
				count = count + 1
			end
		end
	end
	return count
end

function KuaFu1v1Data:GetRankConfig()
	if not self.rank_config then
		self.rank_config = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto").rank_cfg
	end
	return self.rank_config
end

function KuaFu1v1Data:GetHistoryConfig()
	if not self.history_config then
		self.history_config = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto").history_cfg
	end
	return self.history_config
end

function KuaFu1v1Data:GetIndexByScore(score)
	score = score or 0
	local index = -1
	local history_cfg = self:GetHistoryConfig()
	if history_cfg then
		for k,v in ipairs(history_cfg) do
			if v.score <= score then
				index = v.index - 1
			else
				break
			end
		end
	end
	return index
end

function KuaFu1v1Data:GetRewardFlagByIndex(index)
	if index < 0 then
		return false
	end
	local flag = self.role_data.cross_1v1_score_reward_flag
	local list = bit:d2b(flag) or {}
	return list[32 - index] == 0
end

function KuaFu1v1Data:GetShiZhuangId()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto")
	if cfg then
		return cfg.show_cfg[1].index
	end
end

function KuaFu1v1Data:GetShiZhuangInfo()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto")
	if cfg then
		return cfg.rank_show
	end
end


function KuaFu1v1Data:GetTitleId()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto")
	if cfg then
		return cfg.show_cfg[1].title_id
	end
end

function KuaFu1v1Data:GetGuajiXY()
	local cfg = ConfigManager.Instance:GetAutoConfig("kuafu_onevone_auto")
	if nil ~= cfg and nil ~= cfg.show_cfg[1] then
		return cfg.show_cfg[1].guaji_x, cfg.show_cfg[1].guaji_y
	end

	return nil, nil
end

-- 红点
function KuaFu1v1Data:GetReminder()
	local num = 0
	local history_cfg = self:GetHistoryConfig() or {}
	for i = 0, #history_cfg - 1 do
		if self:GetRewardFlagByIndex(i) then
			local cfg = KuaFu1v1Data.Instance:GetHistoryCfgByIndex(i + 1) or {}
			local need_score = cfg.score or 0
			if self.role_data.cross_1v1_max_score >= need_score then
				num = 1
				break
			end
		end
	end
	return num
end

function KuaFu1v1Data:GetHistoryCfgByIndex(index)
	local history_cfg = self:GetHistoryConfig() or {}
	for k,v in pairs(history_cfg) do
		if v.index == index then
			return v
		end
	end
end

function KuaFu1v1Data:GetIsOutFrom1v1Scene()
	return self.is_out_from_1v1_scene
end

function KuaFu1v1Data:SetIsOutFrom1v1Scene(flag)
	self.is_out_from_1v1_scene = flag
end

function KuaFu1v1Data:GetRankRewardAndIndex(rank)
	local cfg = self:GetShiZhuangInfo()
	if nil == cfg or nil == rank then
		return nil, nil
	end

	for i, v in ipairs(cfg) do
		if rank <= v.rank then
			return v, i
		end
	end

	return cfg[#cfg], #cfg
end

function KuaFu1v1Data:GetRankLevelByType(rand_type)
	local tab = {}
	if rand_type == nil then
		return tab
	end

	for k,v in pairs(self:GetRankConfig()) do
		if v.rank_type == rand_type then
			tab[v.index] = v
		end
	end

	return tab
end

function KuaFu1v1Data:GetRankBtnCfg()
	local tab = {}

	for k,v in pairs(self:GetRankConfig()) do
		if v.rank_index == 1 then
			tab[v.rank_type] = v
		end
	end

	return tab
end