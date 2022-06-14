speedChallegeRankData = class("speedChallegeRankData")

function speedChallegeRankData:ctor()
	
end

function speedChallegeRankData:destroy()
	
end

function speedChallegeRankData:init()
	
	self.rankInfo = {};
	
	for i=1, 50 do
		self.rankInfo[i] = {};
	end
	
	self.myRank = -1;
	self.myScore = -1;
	
end

function speedChallegeRankData:setMyRank(rank)

	self.myRank = rank;
	
end

function speedChallegeRankData:getMyRank()
	return self.myRank;
end

function speedChallegeRankData:setMyScore(score)
	self.myScore = score;
end

function speedChallegeRankData:getMyBattleRound()
	
	if dataManager.playerData:isSpeedChallegeSuccess() then
		return dataManager.playerData:getSpeedChallegeRound();
	end
	
	return nil;
end

-- 设置排行榜的信息
function speedChallegeRankData:setRankData(rank, playerRankInfo)
	
	self.rankInfo[rank] = playerRankInfo;
	
end

function speedChallegeRankData:getRankData()
	return self.rankInfo;
end

function speedChallegeRankData:getRankReward()
	
	local rank = self:getMyRank();
	
	local rewardInfo = {};
	local size = #dataConfig.configs.challengeSpeedConfig;
	if rank <= 0 or rank > dataConfig.configs.challengeSpeedConfig[size].rank then
		return rewardInfo;
	end
	
	local findIndex = nil;
	for k, v in ipairs (dataConfig.configs.challengeSpeedConfig)	do
		if rank <=  tonumber(v.rank) then
			findIndex = k;
			break;
		end
	end
	
	if findIndex then
		
		local reward  = dataConfig.configs.challengeSpeedConfig[findIndex];
		for k, v in ipairs(reward.rewardType) do
			table.insert(rewardInfo, dataManager.playerData:getRewardInfo(v, reward.rewardID[k], reward.rewardCount[k]));
		end
	end
	
	return rewardInfo;
	
end
