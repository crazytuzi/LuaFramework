-- 请求加入guild操作

function sendApplyGuild(guildID)
	networkengine:beginsend(153);
-- 请求guildID
	networkengine:pushInt(guildID);
	networkengine:send();
end

