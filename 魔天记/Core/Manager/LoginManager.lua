local WWW = UnityEngine.WWW
local json = require "cjson"

LoginManager = {}
local serverListConfig = {}
LoginManager.myServer = {};
LoginManager.serverDict = {};
local curentServer = nil
LoginManager.serverListUrl = GameConfig.instance.serverlistUrl
LoginManager.loginUrl = GameConfig.instance.loginUrl
LoginManager.checkServerUrl = GameConfig.instance
LoginManager.LOGINSUCCESS = "LOGINSUCCESS"
LoginManager.LOGINFAILD = "LOGINFAILD"
local token = nil
function LoginManager.Init()
	math.randomseed(os.time())
	SDKHelper.instance:SetLoginHandler(LoginManager.LoginSuccess, LoginManager.LoginFail)
end

function LoginManager.GetToken()
	return token
end

function LoginManager.SetToken(v)
	token = v
end

function LoginManager.LoginSuccess()
	MessageManager.Dispatch(LoginManager, LoginManager.LOGINSUCCESS)
end

function LoginManager.LoginFail()
	MessageManager.Dispatch(LoginManager, LoginManager.LOGINFAILD)
end

function LoginManager.LoadServerList()
	coroutine.start(LoginHttp.GetServerList, LoginManager._CallBackLoadServerInfo, LoginManager._CallBackLoadServerInfoError)
end

function LoginManager.GetServerListConfig()
	return serverListConfig
end
--[[-- 通过传入一个zoneId判断zone在列表中的下标
function LoginManager.GetZoneIndex(zoneId)
    for k, v in ipairs(serverListConfig) do
        if v.id == zoneId then
            return k
        end
    end
    return 1
end

function LoginManager.GetServerIndex(serverId)
    for k, v in ipairs(serverListConfig) do
        for k1, v1 in ipairs(v.serverList) do
            if v1.id == serverId then
                return k1
            end
        end
    end
    return 1
end

function LoginManager.GetServerCfg(serverId)
    for k, v in ipairs(serverListConfig) do
        for k1, v1 in ipairs(v.serverList) do
            if v1.id == serverId then
                return {k, k1};
            end
        end
    end
    return {1, 1};
end
]]
function LoginManager._CallBackLoadServerInfo(content)
	 
	serverListConfig = content.l
	local _insert = table.insert
	for k, v in ipairs(serverListConfig) do		 
		if(v and v.l and #v.l > 1) then
			local serverList = {}
			for i = #v.l, 1, - 1 do			 
				_insert(serverList, v.l[i])
			end
			v.l = serverList
		end
		
		for k1, v1 in ipairs(v.l) do
			LoginManager.serverDict[v1.id] = v1
		end
	end
	
	local curSvr = nil;
	if Util.HasKey("loginServerId") then
		-- 找到上一次登录的服务器.
		local lastSvrId = Util.GetInt("loginServerId");
		
		curSvr = LoginManager.GetServer(lastSvrId);
		
		if curSvr then
			LoginProxy.currentZoneIndex = "0";
			LoginProxy.currentServerIndex = lastSvrId;
		end
	end
	
	local tempServer = {}
	
	if curSvr == nil then
		for k, v in ipairs(serverListConfig) do
			for k1, v1 in ipairs(v.l) do			 
				if(v1.icon == 2) then
					_insert(tempServer, {currentZoneIndex = v.id, currentServerIndex = v1.id})
				end
			end
		end
		
		if table.getCount(tempServer) > 0 then			 
			local temprand = math.Random(1, table.getCount(tempServer))
			local rand = math.round(temprand)
			
			LoginProxy.currentZoneIndex = tempServer[rand].currentZoneIndex
			LoginProxy.currentServerIndex = tempServer[rand].currentServerIndex
		else
			LoginProxy.currentZoneIndex = serverListConfig[1].id;
			LoginProxy.currentServerIndex = serverListConfig[1].l[1].id;
		end
	end
	
	-- 设置默认的服务器.
	-- if curSvr == nil then
	-- 	LoginProxy.currentZoneIndex = serverListConfig[1].id;
	-- 	LoginProxy.currentServerIndex = serverListConfig[1].l[1].id;
	-- end
	LoginManager.SetCurrentServer(LoginManager.GetServer(LoginProxy.currentServerIndex))
	MessageManager.Dispatch(LoginNotes, LoginNotes.UPDATE_GOTOGAME_PANEL);
	
	if GameConfig.instance.autoLogin then
		LoginProxy.TryConnect()
	end
end

function LoginManager._CallBackLoadServerInfoError(content)
	
	-- tangping
	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {
		title = Reconnect.connectErrorTitle,
		msg = Reconnect.connectErrorMsg,
		hander = LoginManager.LoadServerList
	});
end

function LoginManager.SaveLoginServer(id)
	Util.SetInt("loginServerId", id);
end

function LoginManager.InitMySvr(data)
	-- data = {{si = 1,pi = 10000, kind = 1,lv = 25}};
	LoginManager.myServer = {};
	if(data) then
		for i, d in ipairs(data) do
			LoginManager.myServer[d.si] = d;
		end
	end
end

function LoginManager.GetSvrRole(svrId)
	if LoginManager.myServer[svrId] then
		return LoginManager.myServer[svrId];
	end
	return nil;
end

function LoginManager.GetServer(svrId)
	
	return LoginManager.serverDict[svrId];
end

local insert = table.insert
function LoginManager.GetServerList(zoneId)
	local zone = tonumber(zoneId);
	if zone == 0 then
		local tmp = {};
		for k, v in pairs(LoginManager.myServer) do
			insert(tmp, LoginManager.GetServer(k));
		end
		return tmp;
	end
	
	for i, z in ipairs(serverListConfig) do
		if z.id == zoneId then
			return z.l;
		end
	end
	return {};
end

function LoginManager.SetCurrentServer(server)
	curentServer = server
end

function LoginManager.GetCurrentServer()
	return curentServer
end

function LoginManager.CheckServerStatus(sucCallBack, faildCallBack)
	coroutine.start(LoginHttp.CheckServerStatus, curentServer.id, sucCallBack, faildCallBack)
end 