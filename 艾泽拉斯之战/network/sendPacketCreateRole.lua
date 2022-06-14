-- 创建角色

function sendCreateRole(icon, name)
	networkengine:beginsend(77);
-- 头像ID
	networkengine:pushInt(icon);
-- 角色名字
	networkengine:pushInt(string.len(name));
	networkengine:pushString(name, string.len(name));
	networkengine:send();
end

