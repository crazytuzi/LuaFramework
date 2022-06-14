-- 请求穿卸装备

function sendEquip(opcode, srcBagType, srcPosition, destBagType, destPosition)
	networkengine:beginsend(21);
-- 操作类型0,穿。1卸
	networkengine:pushInt(opcode);
-- 物品源包裹
	networkengine:pushInt(srcBagType);
-- 物品源包裹里的位置
	networkengine:pushInt(srcPosition);
-- 目标包裹类型
	networkengine:pushInt(destBagType);
-- 目标包裹中的位置
	networkengine:pushInt(destPosition);
	networkengine:send();
end

