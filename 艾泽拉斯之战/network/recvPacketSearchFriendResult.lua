-- 查找好友结果

function packetHandlerSearchFriendResult()
	local tempArrayCount = 0;
	local friends = {};

-- 查找得出的信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		friends[i] = ParseFriendSearchInfo();
	end

	SearchFriendResultHandler( friends );
end

