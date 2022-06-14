-- 设置指引标示

function sendGuide(guides)
	networkengine:beginsend(91);
-- 客户端请求设置新手指引标志位
	local arrayLength = #guides;
	if arrayLength > 32 then arrayLength = 32 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(guides) do
		sendPushGuideInfo(v);
	end

	networkengine:send();
end

