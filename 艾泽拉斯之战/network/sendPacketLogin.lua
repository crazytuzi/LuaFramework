-- 登陆包

function sendLogin(name, password, version, mac, serverID)
	networkengine:beginsend(6);
-- 账号名称
	networkengine:pushInt(string.len(name));
	networkengine:pushString(name, string.len(name));
-- 密码
	networkengine:pushInt(string.len(password));
	networkengine:pushString(password, string.len(password));
-- 协议版本号
	networkengine:pushInt(version);
-- 设备唯一标识
	networkengine:pushInt(string.len(mac));
	networkengine:pushString(mac, string.len(mac));
-- serverID
	networkengine:pushInt(serverID);
	networkengine:send();
end

