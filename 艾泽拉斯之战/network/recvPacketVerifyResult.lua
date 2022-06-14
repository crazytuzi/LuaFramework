-- 请求服务器验证凭证的结果

function packetHandlerVerifyResult()
	local tempArrayCount = 0;
	local verifyResult = nil;
	local transaction_id = nil;

-- 邮件操作结果类型,具体见typedef的VERIFY_RESULT枚举
	verifyResult = networkengine:parseInt();

	print("packetHandlerVerifyResult");
	print(verifyResult);
	-- 验证成功后的交易id
	local strlength = networkengine:parseInt();
	print(strlength);

if strlength > 0 then
		transaction_id = networkengine:parseString(strlength);
else
		transaction_id = "";
end
	
	print(transaction_id);
	VerifyResultHandler( verifyResult, transaction_id );
end

