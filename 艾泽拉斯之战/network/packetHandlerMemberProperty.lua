function MemberPropertyHandler( memberID, property )
	
	local player = dataManager.guildData:getPlayerByID(memberID);
	
	if player then
		
		player:setRight(property);
		eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
		
	end
end
