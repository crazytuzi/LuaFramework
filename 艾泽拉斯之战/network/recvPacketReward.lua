-- 战斗奖励

function packetHandlerReward()
	local tempArrayCount = 0;
	local battleType = nil;
	local firstWin = nil;
	local firstWinReward = {};
	local reward = {};
	local randomRewards = {};

-- 战斗类型 回包确认
	battleType = networkengine:parseInt();
-- 如果是打副本，代表是否首通 回包确认
	firstWin = networkengine:parseBool();
-- 首通奖励
	firstWinReward = ParseRewardList();
-- 必得奖励
	reward = ParseRewardList();
-- 随机奖励
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		randomRewards[i] = ParseRewardList();
	end

	RewardHandler( battleType, firstWin, firstWinReward, reward, randomRewards );
end

