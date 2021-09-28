FestivalActivityBianShenData = FestivalActivityBianShenData or BaseClass(BaseEvent)

function FestivalActivityBianShenData:__init()
	if nil ~= FestivalActivityBianShenData.Instance then
		return
	end

	FestivalActivityBianShenData.Instance = self
end

function FestivalActivityBianShenData:__delete()
	FestivalActivityBianShenData.Instance = nil
end

------------------------------ 变身榜、被变身榜 ------------------------------
function FestivalActivityBianShenData:SetSpecialAppearanceInfo(protocol)
	self.special_appearance_role_change_times = protocol.role_change_times
	self.special_appearance_rank_count = protocol.rank_count
	self.special_appearance_rank_list = protocol.rank_list

	if self.special_appearance_rank_count > 10 then
		self.special_appearance_rank_count = 10
	end

	table.sort(self.special_appearance_rank_list, SortTools.KeyUpperSorters("change_num", "m_capablity"))
end

function FestivalActivityBianShenData:SetSpecialAppearancePassiveInfo(protocol)
	self.role_change_times = protocol.role_change_times
	self.rank_count = protocol.rank_count
	self.bei_bianshen_rank_list = protocol.rank_list

	if self.rank_count > 10 then
		self.rank_count = 10
	end

	table.sort(self.bei_bianshen_rank_list, SortTools.KeyUpperSorters("change_num", "m_capablity"))
end

function FestivalActivityBianShenData:GetSpecialAppearanceRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK)
	return cfg[1].special_appearance_rank_join_reward
end

function FestivalActivityBianShenData:GetSpecialAppearancePassiveRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK)
	return cfg[1].special_appearance_passive_rank_join_reward
end

function FestivalActivityBianShenData:GetSpecialAppearanceRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_rank
end

function FestivalActivityBianShenData:GetSpecialAppearancePassiveRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_passive_rank
end

function FestivalActivityBianShenData:GetSpecialAppearanceRoleChangeTimes()
	return self.special_appearance_role_change_times or 0
end

function FestivalActivityBianShenData:GetSpecialAppearancePassiveRoleChangeTimes()
	return self.role_change_times or 0
end

function FestivalActivityBianShenData:GetSpecialAppearanceRankCount()
	return self.special_appearance_rank_count or 0
end

function FestivalActivityBianShenData:GetSpecialAppearancePassiveRankCount()
	return self.rank_count or 0
end

function FestivalActivityBianShenData:GetSpecialAppearanceRankList()
	return self.special_appearance_rank_list or {}
end

function FestivalActivityBianShenData:GetSpecialAppearancePassiveRankList()
	return self.bei_bianshen_rank_list or {}
end

function FestivalActivityBianShenData:GetMySpecialAppearanceRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == self.special_appearance_rank_list then
		return 0
	end
	for i,v in ipairs(self.special_appearance_rank_list) do
		if main_role_vo.role_id == v.uid then
			return i
		end
	end
	return -1
end

function FestivalActivityBianShenData:GetMySpecialAppearancePassiveRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == self.bei_bianshen_rank_list then
		return 0
	end
	for i,v in ipairs(self.bei_bianshen_rank_list) do
		if main_role_vo.role_id == v.uid then
			return i
		end
	end
	return -1
end
