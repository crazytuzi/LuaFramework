-- 新加成员

function packetHandlerSyncAddMember()
	local tempArrayCount = 0;
	local member = {};

-- 新增加的成员
	member = ParseGuildMemberInfo();

	SyncAddMemberHandler( member );
end

