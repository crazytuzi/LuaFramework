function SyncDelMemberHandler( member )
	
	dataManager.guildData:onDelMember(member);
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
	
end
