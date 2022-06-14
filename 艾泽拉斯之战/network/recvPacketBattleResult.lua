-- 发起战斗

function packetHandlerBattleResult()
	local tempArrayCount = 0;
	local value = {};

-- 战斗记录数组
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		value[i] = BattleResultParseRecordPtr();
	end

	BattleResultHandler( value );
end

