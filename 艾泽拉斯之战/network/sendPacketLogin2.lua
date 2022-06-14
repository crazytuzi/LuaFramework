-- µÇÂ½°ü2

function sendLogin2(data)
	networkengine:beginsend(90);
-- Êý¾Ý
	networkengine:pushInt(string.len(data));
	networkengine:pushString(data, string.len(data));
	networkengine:send();
end

