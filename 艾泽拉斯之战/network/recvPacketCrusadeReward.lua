-- Ô¶Õ÷½±Àø

function packetHandlerCrusadeReward()
	local tempArrayCount = 0;
	local rewardRatio = nil;

-- Ô¶Õ÷½±ÀøÏµÊı
	rewardRatio = networkengine:parseFloat();

	CrusadeRewardHandler( rewardRatio );
end

