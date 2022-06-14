-- 仇人列表

function packetHandlerSyncRevengeSummary()
	local tempArrayCount = 0;
	local revengers = {};

-- 仇人列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		revengers[i] = ParseRevenge();
	end

	SyncRevengeSummaryHandler( revengers );
end

