-- 战斗结算

function packetHandlerBattleSettlement()
	local tempArrayCount = 0;
	local battleType = nil;
	local win = nil;

-- 战斗类型 回包确认
	battleType = networkengine:parseInt();
-- 自己是否胜利
	win = networkengine:parseBool();

	BattleSettlementHandler( battleType, win );
end

