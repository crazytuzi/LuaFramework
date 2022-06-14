-- 天梯摘要信息

function packetHandlerLadderDetail()
	local tempArrayCount = 0;
	local player = {};

-- 玩家信息
	player = ParseLadderPlayer();

	LadderDetailHandler( player );
end

