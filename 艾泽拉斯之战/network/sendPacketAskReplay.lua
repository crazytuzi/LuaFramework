-- ÇëÇóÂ¼Ïñ

function sendAskReplay(id)
	networkengine:beginsend(74);
-- Â¼Ïñid
	networkengine:pushInt(id);
	networkengine:send();
end

