-- 离线pvp复仇

function sendPvpRevenge(playerID)
	networkengine:beginsend(88);
-- 被复仇方的playerID
	networkengine:pushInt(playerID);
	networkengine:send();
end

