function SyncGuildWarRankHandler( guilds )
	
	dataManager.guildWarData:setRankData(guilds);
	eventManager.dispatchEvent( {name  = global_event.RANKINGLIST_UPDATE});
	
end
