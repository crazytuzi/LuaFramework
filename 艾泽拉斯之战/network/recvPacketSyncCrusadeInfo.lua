-- 同步玩家的远征数据

function packetHandlerSyncCrusadeInfo()
	local tempArrayCount = 0;
	local level = nil;
	local food = nil;
	local power = nil;
	local attr = {};

-- 玩家等级
	level = networkengine:parseInt();
-- 平均人口
	food = networkengine:parseInt();
-- 战斗力
	power = networkengine:parseInt();
-- 船的信息
	attr = ParseShipAttrBase();

	SyncCrusadeInfoHandler( level, food, power, attr );
end

