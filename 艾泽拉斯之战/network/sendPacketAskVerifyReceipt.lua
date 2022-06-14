-- 请求验证支付凭证，然后发放道具

function sendAskVerifyReceipt(rechargeID, receipt)
	networkengine:beginsend(166);

	print("sendAskVerifyReceipt");
-- 充值ID
	networkengine:pushInt(rechargeID);
	print("rechargeID "..rechargeID);
-- base64之后的凭证
	networkengine:pushInt(string.len(receipt));
	print("receipt "..receipt);
	networkengine:pushString(receipt, string.len(receipt));
	networkengine:send();
end

