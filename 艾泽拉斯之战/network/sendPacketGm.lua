-- gmÖ¸Áî

function sendGm(script)
	networkengine:beginsend(5);
-- ÃüÁîÎÄ±¾
	networkengine:pushInt(string.len(script));
	networkengine:pushString(script, string.len(script));
	networkengine:send();
end

