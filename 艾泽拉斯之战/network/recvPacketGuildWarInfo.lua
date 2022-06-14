-- 公会战所有据点的信息

function packetHandlerGuildWarInfo()
	local tempArrayCount = 0;
	local postsInfo = {};

-- 据点的信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		postsInfo[i] = ParseGuildWarPlanInfo();
	end

	GuildWarInfoHandler( postsInfo );
end

