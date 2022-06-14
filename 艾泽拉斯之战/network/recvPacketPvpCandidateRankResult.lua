-- 向client返回指定index的pvp候选人的rank

function packetHandlerPvpCandidateRankResult()
	local tempArrayCount = 0;
	local player = {};

-- 更新后候选人的信息
	player = ParseLadderPlayer();

	PvpCandidateRankResultHandler( player );
end

