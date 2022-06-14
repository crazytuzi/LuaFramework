-- 请求同步建筑数据

function sendAskSyncBuild(buildType)
	networkengine:beginsend(0);
-- 建筑类型
	networkengine:pushInt(buildType);
	networkengine:send();
end

