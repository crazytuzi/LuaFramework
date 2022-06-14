-- 申请被拒绝

function packetHandlerFriendReject()
	local tempArrayCount = 0;
	local targetID = nil;

-- 申请的目标id
	targetID = networkengine:parseInt();

	FriendRejectHandler( targetID );
end

