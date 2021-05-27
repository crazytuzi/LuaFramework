CrossEatChickenData = CrossEatChickenData or BaseClass()

function CrossEatChickenData:__init()
	if CrossEatChickenData.Instance then
		ErrorLog("[CrossEatChickenData]:Attempt to create singleton twice!")
	end
	CrossEatChickenData.Instance = self
	self.my_info = {}
	self.rank_list = {}
	self.need_join_cnt = 0
	self:InitDropRangeList()
end

function CrossEatChickenData:__delete()
	CrossEatChickenData.Instance = nil
end

function CrossEatChickenData:InitDropRangeList()
	self.drop_range_list = {}
	for k, v in ipairs(CrossEatChickenCfg.Range) do
		local tmp = {
						name = v.rangeName,
					}
		self.drop_range_list[v.rangeId] = tmp
	end
end

-- 获取匹配开放人数条件
function CrossEatChickenData.GetOpenGameMatchCnt()
	return CrossEatChickenCfg.openGameCount
end

function CrossEatChickenData:GetDropRangeList(range_id)
	if range_id then
		return self.drop_range_list[range_id]
	else
		return self.drop_range_list
	end

end

function CrossEatChickenData:GetRestCnt()
	if self.my_info.today_used_cnt then
		return (CrossEatChickenCfg.dailyCount - self.my_info.today_used_cnt)
	end
	return CrossEatChickenCfg.dailyCount
end

function CrossEatChickenData.GetAwardCfgByRank(rank)
	for k, v in pairs(CrossEatChickenCfg.Awards) do
		if v.cond[1] <= rank and v.cond[2] >= rank then
			return v.award[1]
		end
	end
end

function CrossEatChickenData:GetMyInfo(key)
	if key then
		return self.my_info[key]
	else
		return self.my_info
	end
end

function CrossEatChickenData:GetRankList()
	return self.rank_list
end

function CrossEatChickenData:SetCrossEatChickenRankInfo(protocol)
	self.my_info = protocol.my_info
	self.rank_list = protocol.rank_list_info
	self.need_join_cnt = protocol.need_join_cnt
	self:ResetRemindTipState()
end

function CrossEatChickenData:GetNeedJoinCnt()
	return self.need_join_cnt
end

function CrossEatChickenData:SetEnrollInfo(protocol)
	self.my_info.my_enroll_state = protocol.my_enroll_state
	self.my_info.remind_state = protocol.remind_state
end

function CrossEatChickenData:ResetRemindTipState()
	self.my_info.remind_state = 0
end

function CrossEatChickenData:GetRemindTipState()
	return self.my_info.remind_state or 0
end

function CrossEatChickenData:SetDropRange(protocol)
	self.my_info.my_drop_range = protocol.my_drop_range
end

function CrossEatChickenData:SetRewardInfo(protocol)
	self.my_info.my_rank = protocol.my_rank
	self.my_info.my_score = protocol.my_score
	self.my_info.my_awar_state = protocol.my_awar_state
end

function CrossEatChickenData:SetMatchPlayerCnt(protocol)
	self.my_info.cur_match_player_cnt = protocol.cur_match_player_cnt
end