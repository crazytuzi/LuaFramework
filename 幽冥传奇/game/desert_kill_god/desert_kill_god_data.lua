--------------------------------------------------------
--荒漠杀神相关数据
--------------------------------------------------------
DesertKillGodData = DesertKillGodData or BaseClass()
function DesertKillGodData:__init()
	if DesertKillGodData.Instance then
		ErrorLog("[DesertKillGodData] Attemp to create a singleton twice !")
	end
	
	DesertKillGodData.Instance = self
	self:InitRankAwardData()
end

function DesertKillGodData:__delete()
	DesertKillGodData.Instance = nil
end

function DesertKillGodData:InitRankAwardData()
	self.rank_award_data = {
								rank_max = MoZunConfig.RankMax,
								rank_awards_t = {},
							}
	for k, v in ipairs(MoZunConfig.RankAwards) do
		local temp_t = {
							rank_range = {v.rankMin, v.rankMax,},
							awards = {}
						}

		for _, v2 in ipairs(v.awards) do
			table.insert(temp_t.awards, v2)
		end
		table.insert(self.rank_award_data.rank_awards_t, temp_t)
	end
end

function DesertKillGodData:GetRankAwardData()
	return self.rank_award_data.rank_awards_t
end



