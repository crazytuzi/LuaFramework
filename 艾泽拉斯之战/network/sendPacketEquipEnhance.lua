-- 装备强化

function sendEquipEnhance(bagType, position, enhanceType)
	networkengine:beginsend(22);
-- 包裹类型
	networkengine:pushInt(bagType);
-- 在源包裹中的位置
	networkengine:pushInt(position);
-- 强化类型,ENHANCE_TYPE
	networkengine:pushInt(enhanceType);
	networkengine:send();
end

