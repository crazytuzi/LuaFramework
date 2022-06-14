-- 伤害排名

function packetHandlerSyncTopRank()
	local tempArrayCount = 0;
	local topType = nil;
	local rank = nil;

-- 排行榜类型
	topType = networkengine:parseInt();
-- 排名,-1代表无排名
	rank = networkengine:parseInt();

	SyncTopRankHandler( topType, rank );
end

