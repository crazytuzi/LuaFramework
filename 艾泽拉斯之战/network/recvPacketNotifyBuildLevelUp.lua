-- 金矿升级通知

function packetHandlerNotifyBuildLevelUp()
	local tempArrayCount = 0;
	local buildType = nil;
	local level = nil;

-- 建筑类型
	buildType = networkengine:parseInt();
-- 建筑升级后的等级
	level = networkengine:parseInt();

	NotifyBuildLevelUpHandler( buildType, level );
end

