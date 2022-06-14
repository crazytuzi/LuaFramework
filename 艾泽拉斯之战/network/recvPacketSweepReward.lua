-- Õ½¶·½±Àø

function packetHandlerSweepReward()
	local tempArrayCount = 0;
	local randomRewards = {};

-- Ëæ»ú½±Àø
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		randomRewards[i] = ParseRewardList();
	end

	SweepRewardHandler( randomRewards );
end

