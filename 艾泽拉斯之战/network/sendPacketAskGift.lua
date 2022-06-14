-- 礼品码领取礼品

function sendAskGift(code)
	networkengine:beginsend(124);
-- 礼品码
	networkengine:pushInt(string.len(code));
	networkengine:pushString(code, string.len(code));
	networkengine:send();
end

