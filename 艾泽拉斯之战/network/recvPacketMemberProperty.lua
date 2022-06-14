-- 公告某个玩家的权限的变更

function packetHandlerMemberProperty()
	local tempArrayCount = 0;
	local memberID = nil;
	local property = nil;

-- 成员id
	memberID = networkengine:parseInt();
-- 权限
	property = networkengine:parseInt();

	MemberPropertyHandler( memberID, property );
end

