-- 公会信息

function packetHandlerSyncGuilds()
	local tempArrayCount = 0;
	local guilds = {};

-- 所有的公会信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		guilds[i] = ParseGuildInfo();
	end

	SyncGuildsHandler( guilds );
end

