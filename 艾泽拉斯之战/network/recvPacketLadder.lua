-- 天梯摘要信息

function packetHandlerLadder()
	local tempArrayCount = 0;
	local players = {};

-- 玩家信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		players[i] = ParseLadderPlayerSummary();
	end

	LadderHandler( players );
end

