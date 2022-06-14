-- 请求根据包裹类型与位置删除物品

function sendAskDelItem(destBagType, position)
	networkengine:beginsend(19);
-- 包裹类型
	networkengine:pushInt(destBagType);
-- 在包裹中的位置
	networkengine:pushInt(position);
	networkengine:send();
end

