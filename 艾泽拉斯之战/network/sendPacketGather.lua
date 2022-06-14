-- 从各类建筑中收集

function sendGather(buildType)
	networkengine:beginsend(4);
-- 建筑类型
	networkengine:pushInt(buildType);
	networkengine:send();
end

