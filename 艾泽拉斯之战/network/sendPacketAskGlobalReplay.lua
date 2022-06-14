-- 请求攻略录像

function sendAskGlobalReplay(battleType, progressID)
	networkengine:beginsend(125);
-- 战斗类型
	networkengine:pushInt(battleType);
-- 第几关
	networkengine:pushInt(progressID);
	networkengine:send();
end

