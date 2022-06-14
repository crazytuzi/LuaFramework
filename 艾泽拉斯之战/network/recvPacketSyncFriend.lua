-- 好友

function packetHandlerSyncFriend()
	local tempArrayCount = 0;
	local friends = {};

-- player的friends信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		friends[i] = ParseFriendInfo();
	end

	SyncFriendHandler( friends );
end

