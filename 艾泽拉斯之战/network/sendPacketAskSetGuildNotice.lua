-- 请求设置公会公告

function sendAskSetGuildNotice(notice)
	networkengine:beginsend(138);
-- 设置公会公告
	networkengine:pushInt(string.len(notice));
	networkengine:pushString(notice, string.len(notice));
	networkengine:send();
end

