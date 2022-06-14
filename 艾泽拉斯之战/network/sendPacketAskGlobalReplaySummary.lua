-- 请求攻略录像最牛B玩家名字

function sendAskGlobalReplaySummary(battleType, progressID)
	networkengine:beginsend(126);
-- 战斗类型
	networkengine:pushInt(battleType);
-- 第几关
	networkengine:pushInt(progressID);
	networkengine:send();
end

