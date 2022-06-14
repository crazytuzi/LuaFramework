-- regist

function sendRegist(name, password, phoneNum, version, mac, serverID)
	networkengine:beginsend(165);
-- 账号名称
	networkengine:pushInt(string.len(name));
	networkengine:pushString(name, string.len(name));
-- 密码
	networkengine:pushInt(string.len(password));
	networkengine:pushString(password, string.len(password));
-- phoneNum
	networkengine:pushInt(string.len(phoneNum));
	networkengine:pushString(phoneNum, string.len(phoneNum));
-- 协议版本号
	networkengine:pushInt(version);
-- 设备唯一标识
	networkengine:pushInt(string.len(mac));
	networkengine:pushString(mac, string.len(mac));
-- serverID
	networkengine:pushInt(serverID);
	networkengine:send();
end

