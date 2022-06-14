-- 请求摇红包

function sendAskShake(type)
	networkengine:beginsend(130);
-- 标注是摇红包，还是分享增加次数 enum_shake_type
	networkengine:pushInt(type);
	networkengine:send();
end

