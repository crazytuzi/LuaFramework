-- 请求攻击xx据点

function sendAskGuildWarPost(postID)
	networkengine:beginsend(155);
-- 据点id
	networkengine:pushInt(postID);
	networkengine:send();
end

