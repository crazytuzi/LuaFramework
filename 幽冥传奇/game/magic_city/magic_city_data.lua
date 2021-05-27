
MagicCityData = MagicCityData or BaseClass()
MagicCityRankingListData_TYPE = {
	Magic_city_type = 1, -- 魔幻迷城
	XuKong_type = 2, 	-- 虚空试练
	Battle_Boss = 3, 	-- boss战场
	CombineServerArena = 4, -- 合服擂台
	CombineServerBattle = 5, -- 合服大乱斗
	AnswerQuestionTadayRanking = 6, -- 今日排行榜
	AnswerQuestionYesturadayRanking = 7, -- 昨日排行榜
	JIZhanBossRanking = 8, 	
	BabelRanking = 10, 				--通天塔
}

function MagicCityData:__init()
	if MagicCityData.Instance then
		ErrorLog("[MagicCityData] attempt to create singleton twice!")
		return
	end
	MagicCityData.Instance = self
	self.magic_data = MagicCityData.Instance:GetMagicCfg()
	self.rank_type = 1
	self.rankinglist_data = {}
	self.my_rank = 0
	self.my_score = 0
	self.data_t = self:ShengChengCfgByListType()
	self:InitHeroesFightAwarData()
	self:InitHeroesFightScoreRankData()
	self.my_ranking = 0
	self.my_score = 0
	self.reward_state = 0
	self.ranking_info = {}
	self.ranking_cfg = self:GetRankingCfg()
end

function MagicCityData:__delete()
end

function MagicCityData:GetTime(page)
	local data = MagicCityCfg.cities[page]
	return data.fubenTime  or 600
end

-- 得到通关星星数
function MagicCityData:GetstarNum(page, time)
	local n = 0 
	local data = MagicCityCfg.cities[page]
	local use_time = data.star[1] - time
	if use_time < data.star[3] then
		n = 3
	elseif use_time >= data.star[3] and use_time < data.star[2] then
		n = 2
	elseif use_time >= data.star[2] and use_time < data.star[1] then
		n = 1 
	end
	return n
end

function MagicCityData:GetMagicCfg()
	local magic_data = {}
	for k, v in pairs(MagicCityCfg.cities) do
		magic_data[k] = {
			fuben_name = v.cityName or "", 
			owner_name = "",
			scene_id = v.sceneId, 
			fuben_id = fubenId, 
			open = v.openDay,
			Level_Limit = v.enenterLevelLimit,
			rewards = v.starAwards,
			owner_reward = v.cityOwnerAwards,		--楼主奖励
			star = 0,
			time = 0,
			my_last_time = 0,
			my_score = 0,
			chapter_id = v.cityIdx,
			dailyBuyTimes = v.dailyBuyTimes,
			enter_consumes = v.enterConsume,
			buy_consumes = v.buyEnterTimesConsumes,
			show_reward = v.showAwards,
			first_star_reward = v.firstFullStarAwards,
			level_limit = v.enterLevelLimit,
			my_max_num = 0,
			my_enter_num = 0,
			buy_num = 0,
			conusme_data = v.buyEnterTimesConsumes,
			openday = v.openServerDay
		}
	end
	return magic_data 
end

function MagicCityData:GetReward(chapter, stars)
	local data = self.magic_data[chapter] and self.magic_data[chapter].rewards or {}
	local rewards = data[stars] or {}
	return rewards
end

function MagicCityData:GetMagicData()
	return self.magic_data
end

function MagicCityData:SetOwnerData(protocol)
	for k, v in pairs(self.magic_data) do
		for k1, v1 in pairs(protocol.chapter_data) do
			if v.chapter_id == v1.chapter_id then
				v.owner_name = v1.owner_name
				v.time = v1.quicky_time
				v.star = protocol.max_star
			end
		end		
	end
end

function MagicCityData:SetMyCheaperData(protocol)
	for k, v in pairs(self.magic_data) do
		if v.chapter_id == protocol.chapter_id then
			v.star = protocol.max_star 
			v.my_last_time = protocol.my_last_time
			v.my_score = protocol.my_last_sorce
		end
	end
end

function MagicCityData:SetMyCheaperEnterData(protocol)
	for k,v in pairs(self.magic_data) do
		for k1, v1 in pairs(protocol.my_chaper_data) do
			if v.chapter_id == v1.chapter_id then
				v.my_enter_num = v1.enter_num
				v.my_max_num = v1.max_num
				v.buy_num  = v1.buy_num
			end
		end
	end
end

function MagicCityData:SetRankingData(protocol)
	self.ranking_type = protocol.rankinglist_type
	self.rankinglist_data = self.rankinglist_data or {}
	local data = self.data_t[self.ranking_type]
	self.rankinglist_data[self.ranking_type] = {}
	for k,v in pairs(protocol.rankinglist_Data) do
		self.rankinglist_data[self.ranking_type][k] = {role_data = {}, item_data = {}}
		self.rankinglist_data[self.ranking_type][k].role_data = v
		self.rankinglist_data[self.ranking_type][k].item_data = self:GetRankingReward(data, v.rank)
	end

end

function MagicCityData:GetRankingList(ranking_type)
	return self.rankinglist_data[ranking_type] or {}
end

function MagicCityData:SetMyRankingData(protocol)
	self.my_rank = protocol.my_rank
	self.my_score = protocol.my_score
end

function MagicCityData:SetMyArenaRankingData(protocol)
	self.my_arena_rank = protocol.my_rank
	self.my_arena_score = protocol.my_score
end

function MagicCityData:GetMyArenaRankingData()
	return self.my_arena_rank, self.my_arena_score
end

function MagicCityData:GetMyRankingData()
	return self.my_rank, self.my_score
end

function MagicCityData:ShowEffect(chapter)
	local data = self.magic_data[chapter]
	local data_1 = self.magic_data[chapter - 1]
	if data_1 == nil and data.star == 0 then
		return true
	else
		if (data_1 and data_1.star or 0) > 0 and (data and data.star or 0) == 0 then
			return true 	
		else
			return false
		end
	end
	return false
end

function MagicCityData:CanEnterFuben(chapter)
	local data = self.magic_data[chapter]
	local data_1 = self.magic_data[chapter - 1]
	if data_1 == nil or (data and data.star or 0) > 0 then
		return true
	else
		if (data_1 and data_1.star or 0) > 0 or (data and data.star or 0) > 0 then
			return true 
		else
			return false
		end
	end
	return false
end

function MagicCityData:GetConsumeYuanbao(chapter, buy_num)
	local consume_list = self.magic_data[chapter] and self.magic_data[chapter].conusme_data or {}
	local consume_data = consume_list[buy_num]
	return consume_data
end

function MagicCityData:GetStarPercent(page)
	local data = MagicCityCfg.cities[page]
	local percent_1 =  0
	local percent_2 =  (data.star[1] -  data.star[2])/ (data.star[1] or 1) or 0.6
	local percent_3 =  (data.star[1] -  data.star[3])/ (data.star[1] or 1) or 0.7
	return {percent_1, percent_2, percent_3}
end

function MagicCityData:GetBuyItem()
	return SpaceTrialCfg.buyItemInStore
end

--===================跨服联盟begin========================
function MagicCityData:InitHeroesFightAwarData()
	--个人奖励数据
	self.heroes_personal_awar_data = {}
	for k, v in ipairs(CrossUnionWarCfg.Awards) do
		local data = {}
		data.condition = v.condition
		data.awards = v.award
		data.fetch_state = 0

		table.insert(self.heroes_personal_awar_data, data)
	end
	-- 阵营奖励数据
	self.heroes_team_awar_data = {}
	self.heroes_team_awar_data.score = 0
	self.heroes_team_awar_data.fetch_state = 0
	self.heroes_team_awar_data.awards = CrossUnionWarCfg.winnerAwards
end

function MagicCityData:ResetHeroesPersonalAwarData()
	for k, v in ipairs(self.heroes_personal_awar_data) do
		v.fetch_state = 0
	end
end

function MagicCityData:SetHeroesFightAwarData(protocol)
	self:ResetHeroesPersonalAwarData()
	for k, v in ipairs(self.heroes_personal_awar_data) do
		if v.condition[1] <= protocol.my_rank and v.condition[2] >= protocol.my_rank then
			v.fetch_state = protocol.my_fetch_state
		end
	end

	self.heroes_team_awar_data.score = protocol.team_score
	self.heroes_team_awar_data.fetch_state = protocol.my_team_fetch_state
end

function MagicCityData:GetHeroesFightAwarData()
	return self.heroes_personal_awar_data,self.heroes_team_awar_data
end

function MagicCityData:InitHeroesFightScoreRankData()
	self.heroes_fight_team_info = {}
	self.heroes_fight_my_rank = 0
	self.heroes_fight_my_score = 0
	self.my_team_id = 0
	self.heroes_fight_rank_list_info = {}
end

function MagicCityData:SetHeroesFightRankData(protocol)
	self.heroes_fight_team_info = protocol.team_info
	self.heroes_fight_my_rank = protocol.my_rank
	self.heroes_fight_my_score = protocol.my_score
	self.my_team_id = protocol.my_team_id
	self.heroes_fight_rank_list_info = protocol.rank_list_info
end

function MagicCityData:GetHeroesFightRankData()
	return self.heroes_fight_my_score, self.heroes_fight_my_rank, self.heroes_fight_team_info, self.heroes_fight_rank_list_info, self.my_team_id
end

--===================跨服联盟end========================

--根据类型的生成一份排行榜数据
function MagicCityData:ShengChengCfgByListType()
	local data = {
		[1] = MagicCityCfg.weekRank.rankAwards or {},
		[2] = SpaceTrialCfg.weekRank.rankAwards or {},
		[3] = BossBattleFieldCfg.battleRank.rankAwards or {},
		[6] = AnswerRankAwardConfig.dailyRank.rankAwards or {},
		[8] = BloodFightCfg.weekRank.rankAwards or {}, 
	}
	return data
end

function MagicCityData:GetRankingReward(data, rank)
	data = data or {}
	local open_days = OtherData.Instance:GetOpenServerDays()
	for k, v in pairs(data) do
		if rank >= v.cond[1] and rank <= v.cond[2] then
			for k1,v1 in pairs(v.awards) do
				if v1.openServerDay[1] <= open_days and v1.openServerDay[2] >= open_days then
					return v1.award
				end
			end
		end
	end
	return {}
end
--===============-----------
function MagicCityData:SetMineralContentionData(protocol)
	self.my_ranking = protocol.my_rank
	self.my_score = protocol.my_score
	self.reward_state = protocol.reward_state
	self.ranking_info = {}
	for k, v in pairs(protocol.ranking_info) do
		self.ranking_info[k] = {
			reward = {},
			player_name = "", 
			score = 0,
			fetch_reward = 0,
			is_can_reward = 0,
		}
		self.ranking_info[k].player_name = v.player_name
		self.ranking_info[k].score = v.activity_jifen
		self.ranking_info[k].reward = self:GetDataRewed(k)
		if k == self.my_ranking then
			self.ranking_info[k].fetch_reward = 1
			self.ranking_info[k].is_can_reward = self.reward_state
		end
	end
end

function MagicCityData:GetDataRewed(index)
	local open_days = OtherData.Instance:GetOpenServerDays()
	for k, v in pairs(CrossGatherCrystalCfg.rankAwards) do
		if v.cond[1] <= index and v.cond[2] >= index then
			return v.awards
		end
	end
end

function MagicCityData:SetMyMineralContentionData(protocol)
	self.my_ranking = protocol.my_rank
	self.my_score = protocol.my_score
	self.reward_state = protocol.reward_state
	for k,v in pairs(self.ranking_info) do
		if k == self.my_ranking then
			v.is_can_reward = self.reward_state
			v.score = self.my_score
		end
	end
end

function  MagicCityData:GetRankingCfg()
	local data = {}
	local  index = 1
	for k, v in pairs(CrossGatherCrystalCfg.ExchangeItems) do
		data[index] = v
		index = index + 1
	end
	
	return data
end

function MagicCityData:GetMyData()
	return self.my_score, self.my_ranking, self.reward_state
end

function MagicCityData:GetRankingInfoData()
	return self.ranking_info
end

function MagicCityData:GetMyRankingCfg()
	return self.ranking_cfg
end

function MagicCityData:GetCanYUJiang()
	local open_days = OtherData.Instance:GetOpenServerDays()
	local cfg = CrossGatherCrystalCfg.rankAwards
	local data = cfg[#cfg]
	return data.awards
end

--===================全服争霸=====================
function MagicCityData:GetAllSerFightAwards()
	if not self.all_ser_fight_awards_s then
		self.all_ser_fight_awards_s = {}
		local cfg = ServerPKConfig.Awards
		local data = cfg[1]
		local idx = 1
		while idx < 11 do
			for k, v in ipairs(cfg) do
				if idx >= v.condition[1] and idx <= v.condition[2] then
					data = cfg[k]
					self.all_ser_fight_awards_s[idx] = ItemData.AwardsToItems(data.awards)
					break
				end
			end
			idx = idx + 1
		end
	end
	return self.all_ser_fight_awards_s
end

function MagicCityData:GetAllSerFightRealAwards()
	return self.all_ser_fight_awards
end

function MagicCityData:SetAllSerFightInfo(protocol)
	self.all_ser_fight_infos = protocol.infos
	self.all_ser_fight_awards = protocol.awards
end

function MagicCityData:GetAllSerFightInfoByIdx(idx)
	return self.all_ser_fight_infos and self.all_ser_fight_infos[idx]
end