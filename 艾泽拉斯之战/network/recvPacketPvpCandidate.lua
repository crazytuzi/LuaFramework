-- 向client发送离线pvp的候选人

function packetHandlerPvpCandidate()
	local tempArrayCount = 0;
	local candidates = {};

-- 离线pvp候选人
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		candidates[i] = ParseLadderPlayer();
	end

	PvpCandidateHandler( candidates );
end

