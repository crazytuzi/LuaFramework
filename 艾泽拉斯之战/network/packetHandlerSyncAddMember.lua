function SyncAddMemberHandler( member )
	
	dataManager.guildData:onAddMember(member);
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
	
end
