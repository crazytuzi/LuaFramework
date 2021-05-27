CrossServerMatchData = CrossServerMatchData or BaseClass()

function CrossServerMatchData:__init()
	if CrossServerMatchData.Instance then
		ErrorLog("[CrossServerMatchData]:Attempt to create singleton twice!")
	end
	CrossServerMatchData.Instance = self

	self:InitMatchRankData()
end

function CrossServerMatchData:__delete()
	CrossServerMatchData.Instance = nil
end

-- 排行榜信息
function CrossServerMatchData:InitMatchRankData()
	self.ranging_info = {}
	self.my_rank = 0 
	self.my_score = 0
	self.high_times = 0 
	self.low_times = 0 
	self.my_reward_state = 0
	self.enroll_state = 0 
	self.my_enroll_state = 0
	self.my_paiming = 0
	self.reward_state = 0
	self.is_tips = 0
end

function CrossServerMatchData:OnCrossServerMatchInfo(protocol)
	self.ranging_info = protocol.ranging_info
	self.my_rank = protocol.my_rank
	self.my_score = protocol.my_score
	self.high_times = protocol.high_times
	self.low_times = protocol.low_times
	self.my_reward_state = protocol.my_reward_state
	self.enroll_state = protocol.enroll_state
end

function CrossServerMatchData:GetCrossServerMatchRankData()
	return self.ranging_info
end

function CrossServerMatchData:GetRoleInfo()
	return self.my_score, self.high_times, self.low_times, self.enroll_state
end

function CrossServerMatchData:GetMyBattleRank()
	return self.my_rank
end

-- 报名信息
function CrossServerMatchData:OnEnrollInfo(protocol)
	self.my_enroll_state = protocol.my_enroll_state
	self.is_tips = protocol.is_tips
end

function CrossServerMatchData:GetMyEnrollState()
	return self.my_enroll_state
end

function CrossServerMatchData:OnRewardInfo(protocol)
	self.reward_state = protocol.reward_state
end

function CrossServerMatchData:GetMyRewardState()
	return self.my_reward_state
end

function CrossServerMatchData:GetIsEnrollTips()
	return self.is_tips
end


function CrossServerMatchData:SetMatchRankGift(index)
	for k, v in pairs(CrossLeagueMatchesCfg.rankAwards) do
		if index >= v.cond[1] and index <= v.cond[2] then
			return v.awards[1]
		end
	end
end