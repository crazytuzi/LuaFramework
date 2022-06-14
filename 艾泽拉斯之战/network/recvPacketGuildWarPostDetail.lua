-- 据点详细信息的回复

function packetHandlerGuildWarPostDetail()
	local tempArrayCount = 0;
	local player = {};

-- 玩家信息
	player = ParseLadderPlayer();

	GuildWarPostDetailHandler( player );
end

