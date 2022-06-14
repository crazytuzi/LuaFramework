-- 请求兑换微信红包

function sendAskWeixinBonus(count)
	networkengine:beginsend(129);
-- 兑换数量
	networkengine:pushInt(count);
	networkengine:send();
end

