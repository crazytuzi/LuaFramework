-- 好友申请者

function packetHandlerSyncFriendApplicants()
	local tempArrayCount = 0;
	local friends = {};

-- player的friends信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		friends[i] = ParseFriendApplicant();
	end

	SyncFriendApplicantsHandler( friends );
end

