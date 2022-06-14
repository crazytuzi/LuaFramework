-- 邮件操作请求

function sendAskMail(opcode, param, param2)
	networkengine:beginsend(29);
-- 请求类型
	networkengine:pushInt(opcode);
-- 参数
	networkengine:pushInt(param);
-- 参数2
	networkengine:pushInt(param2);
	networkengine:send();
end

