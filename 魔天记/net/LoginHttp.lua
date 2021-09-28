-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local json = require "cjson"
local pf = GameConfig.instance.platformId
local sdkToken = nil
local userId = ""
local game = ""
local sdkun = ""
LoginHttp = {};

function LoginHttp.GetSdkToken()
	return sdkToken
end

-- 检查测试码
function LoginHttp.CheckTestCode(result_handler)
	local userName = SDKHelper.instance:GetSdkUserName()
	local form = WWWForm.New()
	local md = Util.Md5Sum(userName .. GameConfig.clientSecret)
	local url = GameConfig.instance.host .. "user/test_code"
	md = string.lower(md)
	form:AddField("username", userName)
	form:AddField("sign", md)
	
	local www = WWW(url, form);
	coroutine.www(www)
	
	if(www.error ~= nil) then
		MsgUtils.ShowTips(nil, nil, nil, "连接服务器出错");
		if result_handler ~= nil then
			result_handler(false);
		end
		
	else
		
		local txt = json.decode(www.text)
		
		if txt.err == nil then
			-- LoginCtrlManager.SetToken = www.text
			if result_handler ~= nil then
				local need = json.decode(www.text);
				result_handler(need);
			end
			
			
			
			
			
			
			
			
			
			-- end if 
		else
			MsgUtils.ShowTips(nil, nil, nil, txt.err);
			if result_handler ~= nil then
				result_handler(nil);
			end
		end
	end
end
function LoginHttp.TryLogin(userName, passWord, testCode)
	LoginHttp.tryToLogin(LoginManager.loginUrl, userName, passWord, LoginHttp.LoginCallBack, testCode);
end

function LoginHttp.SetIsLoginCallBack(v)	
	isLoginCallBack = v
end

local isLoginCallBack = false
function LoginHttp.LoginCallBack(data)	
	 
	if data then
		if(not isLoginCallBack) then
			local tk = data.token;
			-- 重新构建token.
			LoginManager.SetToken(tk)
			LoginManager.LoadServerList()
			LoginManager.InitMySvr(data.l);
			ModuleManager.SendNotification(LoginNotes.CLOSE_TESTCODE_PANEL)
			ModuleManager.SendNotification(LoginNotes.CLOSE_LOGIN_PANEL);
			ModuleManager.SendNotification(LoginNotes.OPEN_GOTOGAME_PANEL);
			
			if(data.notice and data.notice ~= "") or(data.bug_notice and data.bug_notice ~= "") then
				ModuleManager.SendNotification(NoticeNotes.OPEN_NOTICE_PANEL2, data)
			end
			LoginHttp.SetIsLoginCallBack(true)			 
		end
	end
end

function LoginHttp.tryToLogin(url, userName, passWord, result_handler, testCode)
	sdkToken = SDKHelper.instance:GetSDKToken()
	userId = SDKHelper.instance:GetUserId()
	if(userId == "") then
		userId = "0"
	end
	sdkun = SDKHelper.instance:GetSdkUserName()
	game = SDKHelper.instance:GetGameStr()
	
	userName = userName or ""
	passWord = passWord or ""
	local form = WWWForm.New()
	local md = Util.Md5Sum(sdkToken .. userName .. passWord .. pf .. GameConfig.clientSecret)
	md = string.lower(md)
	form:AddField("sid", sdkToken);
	form:AddField("uid", userId)
	form:AddField("sdkun", sdkun);
	form:AddField("game", game)
	
	if(userName ~= "") then
		form:AddField("un", userName)
	end
	if(passWord ~= "") then
		form:AddField("pw", passWord)
	end
	
	form:AddField("uid", userId)
	
	if(testCode) then
		form:AddField("code", testCode)
	end
	form:AddField("pf", tostring(pf))
	form:AddField("sign", md)
	
	local deviceInfo = LogHttp.GetDeviceInfo()
	
	if(deviceInfo ~= nil and table.getCount(deviceInfo) > 0) then
		if(table.getCount(LogHttp.deviceInfo)) then
			for k, v in pairs(LogHttp.deviceInfo) do
				if(k == "group_id") then
					form:AddField(tostring(k), tonumber(v))
				else
					form:AddField(tostring(k), v)
				end
			end
		end
	end
	
	form:AddField("platform_tag", GameConfig.instance.strPlatformId);
	form:AddField("channel_id", LogHelp.instance.channel_id);
	form:AddField("network", LogHelp.instance:GetNetworkState());
	form:AddField("app_ver", LogHelp.instance.app_ver);
	
	
	local www = WWW(url, form);
	coroutine.www(www)
	
	if(www.error ~= nil) then
		Error("校验错误" .. tostring(www.error))
		MsgUtils.ShowTips(nil, nil, nil, Reconnect.connectErrorMsg);
		if result_handler ~= nil then
			result_handler(nil);
		end
		
	else
		local txt = json.decode(www.text)
		if txt.err == nil then
			if result_handler ~= nil then
				local token = txt;
				result_handler(token);
			end
		else
			MsgUtils.ShowTips(nil, nil, nil, txt.err);
			if result_handler ~= nil then
				result_handler(nil);
			end
		end
	end
end

function LoginHttp.GetServerList(callBack, errorCallBack)
	local form = WWWForm.New()
	local md = Util.Md5Sum(LoginManager.GetToken() .. GameConfig.clientSecret)
	md = string.lower(md)
	
	form:AddField("token", LoginManager.GetToken());
	if(LogHelp.instance.app_ver ~= "") then
		form:AddField("ver", LogHelp.instance.app_ver);
	end
	form:AddField("sign", md);
	
	local www = WWW(LoginManager.serverListUrl, form)
	coroutine.www(www)
	if(www.error ~= nil) then
		if(errorCallBack ~= nil) then
			errorCallBack(www.error)
		end
	else
		local txt = json.decode(www.text)
		if txt.err == nil then
			if(callBack ~= nil) then
				callBack(txt)
			end
		else
			MsgUtils.ShowTips(nil, nil, nil, txt.err);
			if result_handler ~= nil then
				callBack(nil);
			end
		end
	end
end

function LoginHttp.CheckServerStatus(id, callBack)
	local token = LoginManager.GetToken()
	local md = Util.Md5Sum(token .. GameConfig.clientSecret)
	local form = WWWForm.New()
	md = string.lower(md)
	
	form:AddField("sign", md)
	form:AddField("token", token)
	form:AddField("serverId", id)
	local url = GameConfig.instance.host .. "server/server_status"
	local www = WWW(url, form)
	coroutine.www(www)
	if(www.error ~= nil) then
		MsgUtils.ShowTips(nil, nil, nil, www.error);
	else
		local txt = json.decode(www.text)
		if txt.err == nil then
			if(callBack ~= nil) then
				callBack(txt)
			end
		else
			MsgUtils.ShowTips(nil, nil, nil, txt.err);
			if result_handler ~= nil then
				callBack(nil);
			end
		end
	end
	
	
end

