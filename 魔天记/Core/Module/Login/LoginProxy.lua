require "Core.Module.Pattern.Proxy"

require "net/CmdType"
require "net/SocketClientLua"
require "Core.Manager.PlayerManager"
require "Core.Net.Reconnect";

LoginProxy = Proxy:New()

LoginProxy.currentZoneIndex = "1";
LoginProxy.currentServerIndex = "1";
LoginProxy.userId = "0";
function LoginProxy:OnRegister()
	
end

function LoginProxy:OnRemove()
	
end

function LoginProxy.GetCurrentServerInfo()
	return LoginManager.GetServer(LoginProxy.currentServerIndex);
end


function LoginProxy.TryConnect()
	
	if not LoginManager.GetToken() then return end
	local currentServer = LoginProxy.GetCurrentServerInfo()
	if(currentServer) then
		LoginManager.CheckServerStatus(LoginProxy.CallBackCheckServerStatusSuc)
	else
		MsgUtils.ShowTips("LoginProxy/notLoadServerList")
	end
end

function LoginProxy.CallBackCheckServerStatusSuc(content)
	if(content) then
		if(content.flag == 1) then
			local currentServer = LoginProxy.GetCurrentServerInfo()
			local ip = currentServer.host;
			local port = currentServer.port;
			SocketClientLua.Get_ins():Connect(ip, port, LoginProxy.SocketConnectState);			
		else
			if(content.close_prompt) then
				ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {msg = content.close_prompt});		
			end
		end
	end
end

function LoginProxy.SocketConnectState(statu, err) 
	if statu == SocketClientLua.EVENT_CONNECTION_SUCCEED then
		LoginProxy.TrySend(LoginManager.GetToken());
		LoginManager.SaveLoginServer(LoginProxy:GetCurrentServerInfo().id);
	elseif statu == SocketClientLua.EVENT_RECONNECTION_SUCCEED then
		MsgUtils.ShowTips(nil, nil, nil, Reconnect.connectSucceed);		
		LoginProxy.TrySend(LoginManager.GetToken());
	else
		Warning("LoginProxy.SocketConnectState 连接失败 " .. statu);
		--AssetsBehaviour.Alert(Reconnect.connectErrorTitle, Reconnect.connectErrorMsg, LoginProxy.TryConnect, true)
	    AssetsBehaviour.Confirm(Reconnect.connectErrorTitle, Reconnect.connectErrorMsg
            ,"" ,LoginProxy.TryConnect, Application.Quit, true, nil, Reconnect.exitGame)
	--[[        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {
            title = Reconnect.connectErrorTitle,
            msg = Reconnect.connectErrorMsg,
            hander = LoginProxy.TryConnect
        } );--]]
	end
end

function LoginProxy.TrySend(data)
	LoginProxy.GetServerTime()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Login_Game, LoginProxy.DataInHandler);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.InterBreak, LoginProxy.InterBreak);
	local loginData = {}
	loginData.token = data
	loginData.server_id = LoginProxy.currentServerIndex
	local deviceInfo = LogHttp.GetDeviceInfo()
	if(deviceInfo) then
		for k, v in pairs(deviceInfo) do
			loginData[k] = v
		end
		loginData.platform_tag = GameConfig.instance.strPlatformId
		loginData.channel_id = LogHelp.instance.channel_id
		loginData.app_ver = LogHelp.instance.app_ver
		loginData.device_screen = Screen.width .. "*" .. Screen.height;
		loginData.network = LogHelp.instance:GetNetworkState();		
	end
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Login_Game, loginData);
end

function LoginProxy.DataInHandler(cmd, data)
	if(data == nil or data.errCode) then return end
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Login_Game, LoginProxy.DataInHandler);
	--防治在选角界面断线重连
	ModuleManager.SendNotification(SelectRoleNotes.CLOSE_CREATEROLEPANEL)
	if(data and data.errCode == nil) then
		LoginProxy.userId = data.un;
		PlayerManager.SetPlayerInfo(data);
		local len = table.getn(data.pl);
		if len <= 0 then
			ModuleManager.SendNotification(LoginNotes.CLOSE_GOTOGAME_PANEL);
			ModuleManager.SendNotification(SelectRoleNotes.OPEN_CREATEROLEPANEL);
		else
			ModuleManager.SendNotification(LoginNotes.CLOSE_GOTOGAME_PANEL);
			-- ModuleManager.SendNotification(SelectRoleNotes.OPEN_SELECTROLE_PANEL);
			local func = function() ModuleManager.SendNotification(SelectRoleNotes.OPEN_SELECTROLE_PANEL); end;
			GameSceneManager.SetMap(700001, func);
		end
	end
end

function LoginProxy.GetServerTime()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetServerTime, LoginProxy.GetServerTimeed);
	SocketClientLua.Get_ins():SendMessage(CmdType.GetServerTime);
end
function LoginProxy.GetServerTimeed(cmd, data)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetServerTime, LoginProxy.GetServerTimeed);
	-- log(tostring(cmd) .. "____" .. os.date("%Y-%m-%d %H:%M:%S:%s", data.d) .. type(data.d) .. tonumber(data.d))
	SetServerTime(data.d,data.off)
end

function LoginProxy.InterBreak(cmd, data)
	SocketClientLua.Get_ins():Close()
	if data.t == 1 then
		MsgUtils.ShowTips(nil, nil, nil, data.m .. "")
		return
	end
	AssetsBehaviour.Alert(LanguageMgr.Get("common/notice"),
	data.m .. "", ReStartGame, true)
end
