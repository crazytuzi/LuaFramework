function SyncGuildWarPlansHandler( plans )

	dataManager.guildWarData:setPlayerInGuard(plans);
	eventManager.dispatchEvent({name = global_event.GUILDWARLIST_UPDATE});
	
end
