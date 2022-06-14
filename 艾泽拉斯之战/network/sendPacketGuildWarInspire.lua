-- guildWar鼓舞

function sendGuildWarInspire(type, postID)
	networkengine:beginsend(144);
-- 鼓舞类型
	networkengine:pushInt(type);
-- 如果是公会鼓舞,指明鼓舞的是哪个据点
	networkengine:pushInt(postID);
	networkengine:send();
end

