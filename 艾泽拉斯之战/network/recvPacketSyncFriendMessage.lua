-- 好友留言

function packetHandlerSyncFriendMessage()
	local tempArrayCount = 0;
	local senderID = nil;
	local messages = {};

-- 发送者id
	senderID = networkengine:parseInt();
-- 留言信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		messages[i] = ParseFriendMessage();
	end

	SyncFriendMessageHandler( senderID, messages );
end

