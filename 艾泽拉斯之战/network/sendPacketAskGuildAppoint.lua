-- 请求公会任命

function sendAskGuildAppoint(playerID, property)
	networkengine:beginsend(135);
-- 任命玩家的id
	networkengine:pushInt(playerID);
-- 任命的权限
	networkengine:pushInt(property);
	networkengine:send();
end

