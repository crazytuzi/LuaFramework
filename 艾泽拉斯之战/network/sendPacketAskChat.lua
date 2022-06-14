-- 聊天请求

function sendAskChat(channel, chatType, content, params)
	networkengine:beginsend(92);
-- 频道
	networkengine:pushInt(channel);
-- 聊天类型
	networkengine:pushInt(chatType);
-- 内容
	networkengine:pushInt(string.len(content));
	networkengine:pushString(content, string.len(content));
-- 参数
	local arrayLength = #params;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(params) do
		networkengine:pushInt(v);
	end

	networkengine:send();
end

