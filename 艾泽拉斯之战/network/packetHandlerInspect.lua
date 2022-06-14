function InspectHandler( player )
	
	local pos = dataManager.chatData:getCilckPosition();
	
	dataManager.pvpData:onCheckChatPlayer(player, {left = pos.x , top = pos.y });
	
end
