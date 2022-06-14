-- 测试小包

function sendTestSmall(value)
	networkengine:beginsend(13);
-- 测试数据
	networkengine:pushInt(value);
	networkengine:send();
end

