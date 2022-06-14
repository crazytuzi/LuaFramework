-- 好友申请者

function packetHandlerSyncApplyGuilds()
	local tempArrayCount = 0;
	local guilds = {};

-- player申请过的公会列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		guilds[i] = networkengine:parseInt();
	end

	SyncApplyGuildsHandler( guilds );
end

