function SyncGuildMembersHandler(  name, notice, warScore, members )
	
	dump(members);
	print("notice "..notice);
	print("name "..name);
	dataManager.guildData:setName(name);
	dataManager.guildData:setNotice(notice);
	dataManager.guildData:setWarScore(warScore);
	
	dataManager.guildData:initPlayerFromServerData(members);
	
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
end
