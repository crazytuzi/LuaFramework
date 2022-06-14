-- 退出公会

function packetHandlerSyncDelMember()
	local tempArrayCount = 0;
	local member = nil;

-- 退出公会的成员id
	member = networkengine:parseInt();

	SyncDelMemberHandler( member );
end

