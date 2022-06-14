-- 据点详细信息的回复

function packetHandlerGuildWarBattleResult()
	local tempArrayCount = 0;
	local resultType = nil;
	local index = nil;

-- 突破或者下一波
	resultType = networkengine:parseInt();
-- 第几波
	index = networkengine:parseInt();

	GuildWarBattleResultHandler( resultType, index );
end

