-- 好友推荐

function packetHandlerFriendRecommend()
	local tempArrayCount = 0;
	local friendRecommends = {};

-- player的friends信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		friendRecommends[i] = ParseFriendInfo();
	end

	FriendRecommendHandler( friendRecommends );
end

