-- 国王属性同步

function packetHandlerSyncKing()
	local tempArrayCount = 0;
	local icon = nil;
	local name = nil;
	local miracle = nil;
	local intelligence = nil;
	local force = nil;
	local level = nil;
	local mp = nil;
	local maxMP = nil;
	local costRatio = nil;

-- 国王图标
	icon = networkengine:parseInt();
-- 国王名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		name = networkengine:parseString(strlength);
else
		name = "";
end
-- 国王奇迹等级
	miracle = networkengine:parseInt();
-- 智力
	intelligence = networkengine:parseInt();
-- 攻守方
	force = networkengine:parseInt();
-- 等级
	level = networkengine:parseInt();
-- mp
	mp = networkengine:parseInt();
-- 最大mp
	maxMP = networkengine:parseInt();
-- 魔法消耗比率
	costRatio = networkengine:parseInt();

	SyncKingHandler( icon, name, miracle, intelligence, force, level, mp, maxMP, costRatio );
end

