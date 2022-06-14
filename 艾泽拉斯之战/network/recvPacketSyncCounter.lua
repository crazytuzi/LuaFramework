-- 统计计数同步

function packetHandlerSyncCounter()
	local tempArrayCount = 0;
	local syncCounterType = nil;
	local arrayType = nil;
	local index = nil;
	local value = nil;

-- 1,统计计数 2,数组计数 3,活动计数
	syncCounterType = networkengine:parseInt();
-- 如果counterType=2 数组计数枚举
	arrayType = networkengine:parseInt();
-- index代表索引
	index = networkengine:parseInt();
-- 值
	value = networkengine:parseInt();

	SyncCounterHandler( syncCounterType, arrayType, index, value );
end

