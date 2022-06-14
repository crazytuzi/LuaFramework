-- 请求天梯

function sendAskLadder(startRank, endRank)
	networkengine:beginsend(64);
-- 起始排名
	networkengine:pushInt(startRank);
-- 末尾排名
	networkengine:pushInt(endRank);
	networkengine:send();
end

