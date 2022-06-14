-- 邮件操作结果

function packetHandlerMailResult()
	local tempArrayCount = 0;
	local mailResult = nil;
	local param1 = nil;
	local param2 = nil;

-- 邮件操作结果类型,具体见typedef的MAIL_RESULT_TYPE枚举
	mailResult = networkengine:parseInt();
-- 具体见typedef的MAIL_RESULT_TYPE枚举
	param1 = networkengine:parseInt();
-- 具体见typedef的MAIL_RESULT_TYPE枚举
	param2 = networkengine:parseInt();

	MailResultHandler( mailResult, param1, param2 );
end

