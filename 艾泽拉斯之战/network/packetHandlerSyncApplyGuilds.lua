function SyncApplyGuildsHandler( guilds )
	
	dataManager.guildListData:setApplyedGuild(guilds);
	
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
	
end
