function SyncGuildInfoChangeHandler( __optional_flag__, id, notice, warScore  )
	
	if __optional_flag__:isSetbit(0) then
		
		dataManager.guildData:setNotice(notice);
		
	end
	
	if __optional_flag__:isSetbit(1) then
		
		dataManager.guildData:setWarScore(warScore);
		
	end
		
end
