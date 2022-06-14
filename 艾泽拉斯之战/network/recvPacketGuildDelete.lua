-- 公会解散

function packetHandlerGuildDelete()
	local tempArrayCount = 0;
	local guildID = nil;

-- 公会ID
	guildID = networkengine:parseInt();

	GuildDeleteHandler( guildID );
end

