-- 呼吸协议

function sendTick(verifyCode)
	networkengine:beginsend(80);
-- 校验码，当前随便填写
	networkengine:pushInt(verifyCode);
	networkengine:send();
end

