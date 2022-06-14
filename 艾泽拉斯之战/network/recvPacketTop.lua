-- 天梯摘要信息

function packetHandlerTop()
	local tempArrayCount = 0;
	local topType = nil;
	local palyers = {};

-- 排行榜类型，参照typedef的TYPE_DEF枚举
	topType = networkengine:parseInt();
-- 玩家信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		palyers[i] = ParseTopSummary();
	end

	TopHandler( topType, palyers );
end

