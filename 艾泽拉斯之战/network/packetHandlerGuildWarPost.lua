function GuildWarPostHandler( index, inspireCount, step, fighting, precent, players )
	
	local spotInstance = dataManager.guildWarData:getSpot(index+1);
	
	dump(players);
	dump(fighting);
	dump(precent);
	
	if spotInstance then
		spotInstance:setSpotDetailInfo(step, fighting, inspireCount, precent, players);
		
		eventManager.dispatchEvent({name = global_event.GUILDWARLIST_UPDATE});
		eventManager.dispatchEvent({name = global_event.GUILDWARINFO_UPDATE});
	end
end
