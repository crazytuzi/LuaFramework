BossBattleData = BossBattleData or BaseClass()
function BossBattleData:__init()
	if BossBattleData.Instance then
		ErrorLog("[BossBattleData] Attemp to create a singleton twice !")
	end
	
	BossBattleData.Instance = self
	--self:InitRankBossBattledData()
end

function BossBattleData:__delete()
	BossBattleData.Instance = nil
end


function BossBattleData:GetBossRankData()
	self.reward_data_boss_rank = {}
	local open_days = OtherData.Instance:GetOpenServerDays()
	for k, v in pairs(BossBattleFieldCfg.battleRank.rankAwards) do
		self.reward_data_boss_rank[k] = {
			rank_range = {v.cond[1], v.cond[2]},
			awards = {},
		}
		for k1, v1 in pairs(v.awards) do
			if v1.openServerDay[1] <= open_days and v1.openServerDay[2] >= open_days then
				self.reward_data_boss_rank[k].awards = v1.award
			end
		end
	end
	return self.reward_data_boss_rank
end

-- function BossBattleData:GetBossRankData()
-- 	return self.reward_data_boss_rank
-- end