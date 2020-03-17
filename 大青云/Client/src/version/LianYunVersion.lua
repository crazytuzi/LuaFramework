--[[
联运平台
lizhuangzhuang
2015年11月10日23:23:41
]]

_G.LianYunVersion = {};

function LianYunVersion:new(versionName)
	if BaseVersion.allVersion[versionName] then
		print("Error:重复的联运平台版本.Version:",versionName);
		return;
	end
	local obj = {};
	obj.name = versionName;
	for k,v in pairs(BaseVersion) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	for k,v in pairs(LianYunVersion) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	BaseVersion.allVersion[versionName] = obj;
	return obj;
end

function LianYunVersion:IsLianYun()
	return true;
end

function LianYunVersion:Start(versionName)
	if BaseVersion.allVersion[versionName] then
		Version = BaseVersion.allVersion[versionName];
		Version:OnStart();
		print("联运平台版本启动.Special.",versionName);
		return true;
	end
	local lianyunVersion = self:new(versionName);
	if not lianyunVersion then
		return false;
	end
	BaseVersion.allVersion[versionName] = lianyunVersion;
	Version = lianyunVersion;
	Version:OnStart();
	print("联运平台版本启动.Init.",versionName);
	return true;
end

function LianYunVersion:StartTest(versionName)
	if BaseVersion.allVersion[versionName] then
		Version = BaseVersion.allVersion[versionName];
		Version.Login = TestVersion.Login;
		print("联运平台版本启动.Special.",versionName);
		return true;
	end
	local lianyunVersion = self:new(versionName);
	if not lianyunVersion then
		return false;
	end
	BaseVersion.allVersion[versionName] = lianyunVersion;
	Version = lianyunVersion;
	Version.Login = TestVersion.Login;
	print("联运平台版本启动.Init.",versionName);
	return true;
end

function LianYunVersion:OnStart()
	_G.gateServerAddress = _sys:getGlobal("gsAddress");
	_G.crossGateServerAddres = _sys:getGlobal("crossAddress");
end

function LianYunVersion:Login()
	local msg = ReqConnSrvMsg:new();
	msg.accountID = _sys:getGlobal("uid");
	msg.platform = _sys:getGlobal("platform");
	msg.game_name = _sys:getGlobal("gkey");
	msg.server_id = toint(_sys:getGlobal("skey"));
	msg.time = toint(_sys:getGlobal("time"));
	msg.is_adult = toint(_sys:getGlobal("is_adult"));
	msg.exts = _sys:getGlobal("exts");
	msg.sign = _sys:getGlobal("sign");
	msg.version = _G.MsgBuildVersion
	msg.mac = _sys.macAddress
	msg.virtualIP = 0;
	MsgManager:Send(msg);
end

function LianYunVersion:Charge(amount)
	local cfg = LianYunCfg[self.name];
	if not cfg then 
		print("未找到版本配置",self.name);
		return;
	end
	local url = cfg.chargeUrl;
	if not url then
		print("未找到充值链接",self.name);
		return;
	end
	url = string.gsub(url,"{uid}",function()
		return string.enurl(_G.loginInfo.uid);
	end);
	url = string.gsub(url,"{skey}",_G.loginInfo.skey);
	_sys:browse(url);
end

function LianYunVersion:FangChenMiBrowse()
	local cfg = LianYunCfg[self.name];
	if not cfg then
		print("未找到版本配置",self.name);
		return;
	end
	local url = cfg.fangChenMiUrl;
	if not url then
		print("未找到充值链接",self.name);
		return;
	end
	url = string.gsub(url,"{uid}",function()
		return string.enurl(_G.loginInfo.uid);
	end);
	url = string.gsub(url,"{skey}",_G.loginInfo.skey);
	_sys:browse(url);
end
