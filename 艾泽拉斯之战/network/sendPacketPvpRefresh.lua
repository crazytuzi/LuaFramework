-- 刷新pvp的候选对手

function sendPvpRefresh()
	networkengine:beginsend(60);
	networkengine:send();
end

