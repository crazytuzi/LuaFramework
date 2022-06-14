-- 物品合成与使用等操作

function sendUseItem(opcode, position)
	networkengine:beginsend(55);
-- 操作枚举
	networkengine:pushInt(opcode);
-- 在包裹中的位置
	networkengine:pushInt(position);
	networkengine:send();
end

