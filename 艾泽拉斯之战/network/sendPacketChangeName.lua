-- 改名

function sendChangeName(name)
	networkengine:beginsend(78);
-- 新名字
	networkengine:pushInt(string.len(name));
	networkengine:pushString(name, string.len(name));
	networkengine:send();
end

