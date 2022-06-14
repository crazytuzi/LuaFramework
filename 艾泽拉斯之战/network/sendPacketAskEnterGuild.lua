-- 请求加入公会

function sendAskEnterGuild(guildID)
	networkengine:beginsend(135);
-- 公会id
	networkengine:pushInt(guildID);
	networkengine:send();
end

