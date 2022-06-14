-- 公会申请成员信息

function packetHandlerSyncGuildApplicants()
	local tempArrayCount = 0;
	local members = {};

-- 所有的公会成员信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		members[i] = ParseGuildApplicantInfo();
	end

	SyncGuildApplicantsHandler( members );
end

