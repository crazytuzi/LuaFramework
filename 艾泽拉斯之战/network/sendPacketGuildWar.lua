-- 请求guildWar

function sendGuildWar(postIndex)
	networkengine:beginsend(143);
-- 请求攻击哪一个据点
	networkengine:pushInt(postIndex);
	networkengine:send();
end

