-- ²éÕÒºÃÓÑ

function sendSearchFriend(content)
	networkengine:beginsend(96);
-- ÄÚÈİ
	networkengine:pushInt(string.len(content));
	networkengine:pushString(content, string.len(content));
	networkengine:send();
end

