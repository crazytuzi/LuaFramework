-- 请求天梯详细数据

function sendAskLadderDetail(playerID, rank)
	networkengine:beginsend(72);
-- 玩家的id
	networkengine:pushInt(playerID);
-- 排名.当id=-1（即目标位robot的时候），使用rank查找
	networkengine:pushInt(rank);
	networkengine:send();
end

