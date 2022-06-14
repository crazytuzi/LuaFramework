-- 当前据点的阵型

function packetHandlerSyncGuildWarPlans()
	local tempArrayCount = 0;
	local plans = {};

-- 该据点的防守阵型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		plans[i] = networkengine:parseInt();
	end

	SyncGuildWarPlansHandler( plans );
end

