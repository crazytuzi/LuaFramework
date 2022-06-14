-- 删除好友通知

function packetHandlerSyncFriendDel()
	local tempArrayCount = 0;
	local friendID = nil;

-- 好友id
	friendID = networkengine:parseInt();

	SyncFriendDelHandler( friendID );
end

