-- 强化装备

function packetHandlerEquipEnhanceResult()
	local tempArrayCount = 0;
	local isEnhanceToMax = nil;

-- 是否升级到当前最大等级
	isEnhanceToMax = networkengine:parseInt();

	EquipEnhanceResultHandler( isEnhanceToMax );
end

