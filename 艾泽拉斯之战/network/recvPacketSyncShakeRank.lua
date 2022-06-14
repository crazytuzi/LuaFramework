-- 伤害排名

function packetHandlerSyncShakeRank()
	local tempArrayCount = 0;
	local rankInfo = {};

-- 排行榜类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		rankInfo[i] = ParseShakeRankInfo();
	end

	SyncShakeRankHandler( rankInfo );
end

