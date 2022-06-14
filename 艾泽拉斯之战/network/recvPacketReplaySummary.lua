-- 录像信息

function packetHandlerReplaySummary()
	local tempArrayCount = 0;
	local replays = {};

-- 录像信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		replays[i] = ParseReplayInfo();
	end

	ReplaySummaryHandler( replays );
end

