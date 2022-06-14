-- 请求伤害排行榜

function sendAskTop(topType, startRank, endRank)
	networkengine:beginsend(69);
-- 参看typedef中的TOP_TYPE枚举
	networkengine:pushInt(topType);
-- 起始排名
	networkengine:pushInt(startRank);
-- 末尾排名
	networkengine:pushInt(endRank);
	networkengine:send();
end

