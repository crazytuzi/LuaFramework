--[[
Wan平台
lizhuangzhuang
2015年9月16日17:15:11
]]

_G.WanVersion = BaseVersion:new(VersionConsts.Wan);

function WanVersion:OnStart()
	_G.gateServerAddress = _sys:getGlobal("gsAddress");
	_G.crossGateServerAddres = _sys:getGlobal("crossAddress");
end

--登录
function WanVersion:Login()
	local msg = ReqConnSrvMsg:new();
	msg.accountID = _sys:getGlobal("uid");
	msg.platform = "wan";
	msg.game_name = "dqy";
	msg.server_id = toint(_sys:getGlobal("skey"));
	msg.time = toint(_sys:getGlobal("time"));
	msg.is_adult = toint(_sys:getGlobal("is_adult"));
	msg.exts = "";   							--扩展信息
	msg.sign = _sys:getGlobal("sign");
	msg.version = _G.MsgBuildVersion
	msg.mac = _sys.macAddress
	msg.virtualIP = 0;
	MsgManager:Send(msg);
end

function WanVersion:Charge(amount)
	amount = amount or 10;
	if UIFirstRechargeWindow:Open(amount) then
		return;
	end
	
	local url = WanCfg.chargeUrl;  --充值url
	-- string.gsub(param1,param2,param3)
	-- param1: 源字符串
	-- param2: 待替换之模式串
	-- param3: 替换为param3
	url = string.gsub(url,"{qid}",_G.loginInfo.uid);
	url = string.gsub(url,"{skey}",_G.loginInfo.skey);
	_sys:browse(url);
end

function WanVersion:IsOpenVPlan()
	return true;
end

function WanVersion:VPlanBrowse()
	_sys:browse(WanCfg.vplanWebsite);
end

function WanVersion:VPlanMRecharge()
	local url = WanCfg.vplanMrecharge;
	_sys:browse(url);
end

function WanVersion:VPlanYRecharge()
	local url = WanCfg.vplanYrecharge;
	_sys:browse(url);
end

function WanVersion:IsOpenWanSpeed()
	return true;
end

function WanVersion:Is360Game()
	if _sys:getGlobal("is360Game") and _sys:getGlobal("is360Game")=="true" then
		return true;
	end
	return false;
end

function WanVersion:IsShow360Game()
	return true;  --暂时屏蔽掉wan平台的游戏大厅功能
end

function WanVersion:Download360Game()
	local url = WanCfg.down360GameUrl;
	_sys:browse(url);
end

function WanVersion:IsShowHd360()
	return true;
end

function WanVersion:Hd360Browse()
	local url = WanCfg.hd360Url;
	_sys:browse(url);
end

function WanVersion:IsQQReward()
	return true;
end

function WanVersion:GetQQNum()
	return 497500094;
end

function WanVersion:QQRewardBrowse()
	_sys:browse("http://shang.qq.com/wpa/qunwpa?idkey=3e9ce07346e50835e85f464f6c6c53d57811ed703ca4e992140b9ae4d289fd80");
end

function WanVersion:FangChenMiBrowse()
	local url = WanCfg.fangChenMiUrl;
	_sys:browse(url);
end

function WanVersion:IsYXLaXin()
	return true;
end

function WanVersion:LaXinBrowse()
	local url = WanCfg.laXinUrl;
	if not url then return; end
	_sys:browse(url);
end

function WanVersion:IsShowGirlTV()
	return true;
end

function WanVersion:GirlTVBrowse()
	local url = WanCfg.girlTVUrl;
	if not url then return; end
	_sys:browse(url);
end

function WanVersion:IsShowPhoneApp()
	return true;
end

function WanVersion:IsShowWanChannelGame( )
	return true;
end


function WanVersion:DownPhoneAppAndroid()
	local url = WanCfg.appAndroidUrl;
	if not url then return; end
	if url == "" then return; end
	_sys:browse(url);
end

function WanVersion:DownPhoneAppIOS()
	local url = WanCfg.appIOSUrl;
	if not url then return; end
	if url == "" then return; end
	_sys:browse(url);
end

function WanVersion:GetParams(filter)
	local params = {};
	params.uid = _sys:getGlobal("uid");
	params.platform = 'wan';
	params.gkey = _sys:getGlobal("gkey");
	params.skey = 'S'..toint(_sys:getGlobal("skey"));
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

function WanVersion:IsShowRechargeButton()
	return true;
end

-- 判断是不是wan平台特殊渠道
function WanVersion:IsWeiShi()
	return self:GetChannel() == 521870014;
end

function WanVersion:GetFirstCharge(amount)
	amount = amount or 10;
	local url = WanCfg.firstCharge;
	local params = self:GetParams({'sign'});
	params.amount = amount;
	url = url..'?'..GetURLParams(params);
	return url;
end

function WanVersion:GetMClientURL()
	return "http://res.w360.dqy.ate.cn/mclients/wan/dqy.exe";
end
function WanVersion:GetMChecksum()
	return "9b30b874f86906f2ec7c1b5d7e3e56ae"
end