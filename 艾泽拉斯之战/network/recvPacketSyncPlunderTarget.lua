-- 掠夺对象刷新

function packetHandlerSyncPlunderTarget()
	local tempArrayCount = 0;
	local plunderTargets = {};

-- 掠夺对象候选人
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		plunderTargets[i] = ParseLadderPlayer();
	end

	SyncPlunderTargetHandler( plunderTargets );
end

