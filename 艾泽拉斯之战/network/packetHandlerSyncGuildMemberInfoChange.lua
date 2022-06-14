function SyncGuildMemberInfoChangeHandler( __optional_flag__, id, warScore  )

	if __optional_flag__:isSetbit(0) then
		-- 个人积分
		
		local player = dataManager.guildData:getPlayerByID(id);
		player:setWarScore(warScore);
		
	end
	
end
