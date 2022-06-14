-- Í¬²½playerID

function packetHandlerSyncPlayerID()
	local tempArrayCount = 0;
	local playerID = nil;

-- playerµÄdatabase ID
	playerID = networkengine:parseInt();

	SyncPlayerIDHandler( playerID );
end

