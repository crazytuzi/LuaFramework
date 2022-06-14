-- 请求guild操作

function sendGuildOp(opcode, targetID)
	networkengine:beginsend(149);
-- 请求类型
	networkengine:pushInt(opcode);
-- 玩家id
	networkengine:pushInt(targetID);
	networkengine:send();
end

