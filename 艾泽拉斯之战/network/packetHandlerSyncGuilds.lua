function SyncGuildsHandler( guilds )
	
	dump(guilds);
	
	dataManager.guildListData:onServerData(guilds);
	
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
	
end
