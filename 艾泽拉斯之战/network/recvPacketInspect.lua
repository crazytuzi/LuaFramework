-- 观察其他玩家的信息

function packetHandlerInspect()
	local tempArrayCount = 0;
	local player = {};

-- 玩家信息
	player = ParseLadderPlayer();

	InspectHandler( player );
end

