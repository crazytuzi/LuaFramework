-- 请求创建公会

function sendAskCreateGuild(name)
	networkengine:beginsend(134);
-- 公会名称
	networkengine:pushInt(string.len(name));
	networkengine:pushString(name, string.len(name));
	networkengine:send();
end

