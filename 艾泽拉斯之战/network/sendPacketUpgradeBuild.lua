-- 请求升级建筑

local UPGRADE = 0;-- 请求升级
local CANCEL = 1;-- 取消升级
local IMMEDIATE_UPGRADE = 2;-- 立即升级

function sendUpgradeBuild(operation, buildType)
	networkengine:beginsend(16);
-- 请求类型
	networkengine:pushInt(operation);
-- 建筑类型
	networkengine:pushInt(buildType);
	networkengine:send();
end

