-- 请求攻击xx据点详细信息

function sendAskGuildWarPostDetail(postID, playerID)
	networkengine:beginsend(158);
-- 据点id
	networkengine:pushInt(postID);
-- 据点的id玩家的详细信息
	networkengine:pushInt(playerID);
	networkengine:send();
end

