-- 请求播放录像

function sendAskReplaySummary(count)
	networkengine:beginsend(75);
-- 录像数量
	networkengine:pushInt(count);
	networkengine:send();
end

