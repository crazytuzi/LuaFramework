-- 穿卸装备

function packetHandlerEquipResult()
	local tempArrayCount = 0;
	local bagTypeA = nil;
	local positionA = nil;
	local bagTypeB = nil;
	local positionB = nil;

-- 背包类型
	bagTypeA = networkengine:parseInt();
-- 物品所在位置
	positionA = networkengine:parseInt();
-- 背包类型
	bagTypeB = networkengine:parseInt();
-- 物品所在位置
	positionB = networkengine:parseInt();

	EquipResultHandler( bagTypeA, positionA, bagTypeB, positionB );
end

