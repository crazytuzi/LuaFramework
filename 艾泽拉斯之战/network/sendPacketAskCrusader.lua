-- 请求远征关卡信息

function sendAskCrusader(stageIndex)
	networkengine:beginsend(112);
-- 关卡索引，从0开始
	networkengine:pushInt(stageIndex);
	networkengine:send();
end

