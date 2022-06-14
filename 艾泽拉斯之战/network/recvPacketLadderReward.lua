-- pvp天梯奖励

function packetHandlerLadderReward()
	local tempArrayCount = 0;
	local oldBestRank = nil;
	local newBestRank = nil;
	local reward = nil;

-- 老的最佳排名
	oldBestRank = networkengine:parseInt();
-- 新的最佳排名
	newBestRank = networkengine:parseInt();
-- 奖励钻石数量
	reward = networkengine:parseInt();

	LadderRewardHandler( oldBestRank, newBestRank, reward );
end

