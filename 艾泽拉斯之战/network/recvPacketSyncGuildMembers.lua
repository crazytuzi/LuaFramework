-- 公会成员信息

function packetHandlerSyncGuildMembers()
	local tempArrayCount = 0;
	local name = nil;
	local notice = nil;
	local warScore = nil;
	local members = {};

-- name
	local strlength = networkengine:parseInt();
if strlength > 0 then
		name = networkengine:parseString(strlength);
else
		name = "";
end
-- 公告
	local strlength = networkengine:parseInt();
if strlength > 0 then
		notice = networkengine:parseString(strlength);
else
		notice = "";
end
-- 战斗得分数
	warScore = networkengine:parseInt();
-- 所有的公会成员信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		members[i] = ParseGuildMemberInfo();
	end

	SyncGuildMembersHandler( name, notice, warScore, members );
end

