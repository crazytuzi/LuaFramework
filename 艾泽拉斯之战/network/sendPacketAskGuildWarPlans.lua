-- 请求guildWar阵型

function sendAskGuildWarPlans(postID)
	networkengine:beginsend(143);
-- 据点id
	networkengine:pushInt(postID);
	networkengine:send();
end

