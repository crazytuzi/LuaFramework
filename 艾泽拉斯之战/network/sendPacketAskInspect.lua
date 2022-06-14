-- 观察其他玩家请求

function sendAskInspect(playerID)
	networkengine:beginsend(101);
-- 玩家ID
	networkengine:pushInt(playerID);
	networkengine:send();
end

