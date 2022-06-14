function SyncGuildApplicantsHandler( members )
	
	print("SyncGuildApplicantsHandler");
	
	dataManager.guildData:initApplyListFromServerData(members);
	
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
	eventManager.dispatchEvent({name = global_event.MAIN_UI_GUILD_STATE});
	
end
