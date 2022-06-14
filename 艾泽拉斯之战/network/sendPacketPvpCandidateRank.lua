-- pvp候选人的排名

function sendPvpCandidateRank(index)
	networkengine:beginsend(62);
-- 候选人的index
	networkengine:pushInt(index);
	networkengine:send();
end

