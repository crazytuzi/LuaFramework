function GuildWarInfoHandler( postsInfo )

	dataManager.guildWarData:initSpotInfoFromServerData(postsInfo)
	eventManager.dispatchEvent({name = global_event.GUILDWAR_UPDATE});
	
end
