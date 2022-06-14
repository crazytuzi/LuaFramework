-- 仇人信息

function packetHandlerSyncRevengeTarget()
	local tempArrayCount = 0;
	local revengeTarget = {};

-- 仇家具体信息
	revengeTarget = ParseLadderPlayer();

	SyncRevengeTargetHandler( revengeTarget );
end

