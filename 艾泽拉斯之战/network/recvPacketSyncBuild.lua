-- 建筑同步

function packetHandlerSyncBuild()
	local tempArrayCount = 0;
	local buildType = nil;
	local level = nil;
	local gatherTime = nil;
	local upgradeTime = nil;
	local stack = nil;
	local meditatePoint = nil;

-- 建筑类型
	buildType = networkengine:parseInt();
-- 建筑当前等级
	level = networkengine:parseInt();
-- 上次收集时间
	gatherTime = networkengine:parseUInt64();
-- 升级开始时间
	upgradeTime = networkengine:parseUInt64();
-- 建筑内资源积存量
	stack = networkengine:parseInt();
-- 冥想点数
	meditatePoint = networkengine:parseInt();

	SyncBuildHandler( buildType, level, gatherTime, upgradeTime, stack, meditatePoint );
end

