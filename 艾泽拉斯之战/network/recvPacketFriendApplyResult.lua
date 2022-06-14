-- 申请好友反馈

function packetHandlerFriendApplyResult()
	local tempArrayCount = 0;
	local targetID = nil;
	local param = nil;

-- 申请的目标id
	targetID = networkengine:parseInt();
-- 参数信息,1申请成功,2申请成功并且互相成好友
	param = networkengine:parseInt();

	FriendApplyResultHandler( targetID, param );
end

