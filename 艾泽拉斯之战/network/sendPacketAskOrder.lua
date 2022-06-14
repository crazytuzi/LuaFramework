-- 请求支付订单

function sendAskOrder(rechargeID)
	networkengine:beginsend(106);
-- 充值id
	networkengine:pushInt(rechargeID);
	networkengine:send();
end

