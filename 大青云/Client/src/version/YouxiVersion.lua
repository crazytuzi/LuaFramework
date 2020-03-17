--[[
游戏平台
lizhuangzhuang
2015年9月16日17:14:50
]]

_G.YouxiVersion = BaseVersion:new(VersionConsts.YouXi);

function YouxiVersion:OnStart()
	_G.gateServerAddress = _sys:getGlobal("gsAddress");
	_G.crossGateServerAddres = _sys:getGlobal("crossAddress");
end

--登录
function YouxiVersion:Login()
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

function YouxiVersion:Charge(amount)
	amount = amount or 10;
	if UIFirstRechargeWindow:Open(amount) then
		return;
	end
	
	local url = YouxiCfg.chargeUrl;   
	url = string.gsub(url,"{uid}",_G.loginInfo.uid);
	url = string.gsub(url,"{skey}",_G.loginInfo.skey);
	_sys:browse(url);
end

function YouxiVersion:IsOpenVPlan()
	return true;--临时屏蔽
end

function YouxiVersion:VPlanBrowse()
	_sys:browse(YouxiCfg.vplanWebsite);
end

function YouxiVersion:VPlanMRecharge()
	local url = YouxiCfg.vplanMrecharge;
	url = string.gsub(url,"{uid}",_G.loginInfo.uid);
	_sys:browse(url);
end

function YouxiVersion:VPlanYRecharge()
	local url = YouxiCfg.vplanYrecharge;
	url = string.gsub(url,"{uid}",_G.loginInfo.uid);
	_sys:browse(url);
end

function YouxiVersion:IsOpenPhoneBinding()
	return true;
end

function YouxiVersion:PhoingBindBrowse()
	_sys:browse(YouxiCfg.phoneBindingUrl);
end

function YouxiVersion:IsQQReward()
	return true;
end

function YouxiVersion:GetQQNum()
	return 313628783;
end

function YouxiVersion:QQRewardBrowse()
	_sys:browse("http://shang.qq.com/wpa/qunwpa?idkey=645f39bca9b9f0a9b3ac8eeabf21efd304bfa63ea3d4af214fd918eaf849d8f5");
end

function YouxiVersion:FangChenMiBrowse()
	local url = YouxiCfg.fangChenMiUrl;
	_sys:browse(url);
end

function YouxiVersion:IsYXLaXin()
	return true
end

function YouxiVersion:LaXinBrowse()
	local url = YouxiCfg.laXinUrl;
	if not url then return; end
	_sys:browse(url);
end

function YouxiVersion:IsShowGirlTV()
	return true;
end

function YouxiVersion:GirlTVBrowse()
	local url = YouxiCfg.girlTVUrl;
	if not url then return; end
	_sys:browse(url);
end

function YouxiVersion:IsShowPhoneApp()
	return true;
end

function YouxiVersion:DownPhoneAppAndroid()
	local url = YouxiCfg.appAndroidUrl;
	if not url then return; end
	if url == "" then return; end
	_sys:browse(url);
end

function YouxiVersion:DownPhoneAppIOS()
	local url = YouxiCfg.appIOSUrl;
	if not url then return; end
	if url == "" then return; end
	_sys:browse(url);
end

--显示天降惊喜
function YouxiVersion:IsShowTianJiangjingxi()
	return false;
end
--天降惊喜
function YouxiVersion:IsShowTianJiangjingxiUrl()
	local url = YouxiCfg.tjjxUrl;
	if not url then return; end
	_sys:browse(url);
end

function YouxiVersion:GetParams(filter)
	local params = {};
	params.uid = _sys:getGlobal("uid");
	params.platform = _sys:getGlobal("platform");
	params.gkey = _sys:getGlobal("gkey");
	params.skey = toint(_sys:getGlobal("skey"));
	params.time = toint(_sys:getGlobal("time"));
	params.is_adult = toint(_sys:getGlobal("is_adult"));
	params.exts = _sys:getGlobal("exts");
	params.sign = _sys:getGlobal("sign");
	if filter then
		for index,name in ipairs(filter) do
			params[name] = nil;
		end
	end
	return params;
end

function YouxiVersion:IsShowRechargeButton()
	return true;
end

function YouxiVersion:GetFirstCharge(amount)
	amount = amount or 10;
	local url = YouxiCfg.firstCharge;
	local params = self:GetParams({'sign'});
	params.amount = amount;
	url = url..'?'..GetURLParams(params);
	return url;
end

function YouxiVersion:GetMClientURL()
	return "http://res.dqy.g.yx-g.cn/mclients/youxi/dqy.exe";
end
function YouxiVersion:GetMChecksum()
	return "89812f068751ed443529028cb140a88c"
end