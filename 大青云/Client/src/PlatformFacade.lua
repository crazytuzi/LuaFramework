
_G.PlatformFacade = {};

_G.backLoginPage = function()
	if _G.ismclient then
		_sys:invoke( 'back_login', 'desk' )
	else
		_sys:invoke( 'back_login', 'web' )
	end
end

_G.GetCommandParam = function(name)
	local param = _sys:getGlobal(name);
	if not param or param == '' or param == 'undefined' then
		return nil;
	end
	return param;
end

function PlatformFacade:Start()
	if isPublic then
		--必须的登录信息. uid,skey,platform
		_G.loginInfo = {};
		_G.loginInfo.uid = _sys:getGlobal("uid");  			--用户id
		_G.loginInfo.platform = _sys:getGlobal("platform"); --平台
		_G.loginInfo.skey = _sys:getGlobal("skey");
		LogManager.reportUrl = _sys:getGlobal("reporturl");
		LogManager.tp = toint(_sys:getGlobal("tp"));
		LogManager.net = _sys:getGlobal("net");
		LogManager.i = _sys:getGlobal("i");
--		if LogManager.reportUrl and LogManager.reportUrl~="" then
--			LogManager.reportUrl = LogManager.reportUrl.."?uid=".._G.loginInfo.uid.."&sid=".._G.loginInfo.skey..'&platform='.._G.loginInfo.platform;
--		end
		local clickurl = _sys:getGlobal("clickurl");
		print("html clickurl:" .. clickurl);
		if clickurl and clickurl~="" then
			clickurl = clickurl.."?uid=".._G.loginInfo.uid.."&sid=".._G.loginInfo.skey..'&platform='.._G.loginInfo.platform..'&pf='.._G.loginInfo.platform;
			ClickLog:SetUrl(clickurl);
		end
	else
		--本地开发版,修改默认窗口大小
		_rd.w = UIManager.MinWidth 
		_rd.h = UIManager.MinHeight
	end
end

function PlatformFacade:InitPlatform()
	--根据平台启动不同版本
	local versionName = "test";
	if isPublic then
		versionName = GetCommandParam("platform");
		IsPlatform = true;
		if not versionName then
			IsPlatform = GetCommandParam("uid") and true or false;
			versionName = "test";
		end
		
		local gateServer = GetCommandParam("gsAddress");
		local crossServer = GetCommandParam("crossAddress");
		if gateServer and crossServer then
			_G.gateServerAddress = gateServer;
			_G.crossGateServerAddres = crossServer;
		end
		
		local nDebug = GetCommandParam("debug") or false;
		if nDebug then
			if nDebug == '1' or nDebug == 'true' then
				isDebug = true;
			end
		end
	end
	if isDebug and _G.testVersionName and _G.testVersionName~="" then
		--模拟平台测试
		versionName = _G.testVersionName;
		if _G.testVersionLianYun then
			LianYunVersion:StartTest(versionName);
		else
			BaseVersion:StartTest(versionName);
		end
	else
		if _sys:getGlobal("isLianYun") then
			if not LianYunVersion:Start(versionName) then
				print("Error:Platform start error.",versionName);
			end
		else
			if not BaseVersion:Start(versionName) then
				print("Error:Platform start error.",versionName);
			end
		end
	end
end


