-- 好友操作

function sendFriendsOp(opcode, targetID)
	networkengine:beginsend(95);
-- 请求操作类型
	networkengine:pushInt(opcode);
-- 目标的id
	networkengine:pushInt(targetID);
	networkengine:send();
end

