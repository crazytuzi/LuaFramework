-- 请求掠夺对象

function sendAskRevengeTarget(revengeID)
	networkengine:beginsend(117);
-- 请求的愁人列表的dbid，注意不是仇家的playerID。
	networkengine:pushInt(revengeID);
	networkengine:send();
end

