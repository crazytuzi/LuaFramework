-- require "Core.Module.Login.LoginProxy"
require "Core.Manager.ModuleManager"
require "net/CmdType"
require "net/SocketClientLua"
require "Core.Manager.PlayerManager"
require "Core.Manager.GameSceneManager"

Reconnect = {};

Reconnect.connectSucceed = LanguageMgr.Get("Reconnect/connectSucceed")
Reconnect.connectErrorTitle = LanguageMgr.Get("common/notice")
Reconnect.connectErrorMsg = LanguageMgr.Get("Reconnect/connectErrorMsg")
Reconnect.exitGame = LanguageMgr.Get("Reconnect/exitGame")
ReconnectState = {reconnect = 1, reconnected = 2, reconnectEnd = 3}

Reconnect.MESSAGE_CONNECTSUCCEED = "MESSAGE_CONNECTSUCCEED";



function Reconnect.SocketConnectState(statu, err)
	Warning("Reconnect.SocketConnectState : " .. statu);
	if statu == SocketClientLua.EVENT_CONNECTION_SUCCEED then
		Reconnect.TrySend(LoginManager.GetToken());
	elseif statu == SocketClientLua.EVENT_RECONNECTION_SUCCEED then
		MsgUtils.ShowTips(nil, nil, nil, Reconnect.connectSucceed);
		Reconnect.TrySend(LoginManager.GetToken());
	else
		Reconnect.OnDisConnection();
		Warning("Reconnect.SocketConnectState 重新连接失败 " .. statu);
		AppSplitDownProxy.OnDisConnection()
		--AssetsBehaviour.Alert(Reconnect.connectErrorTitle, Reconnect.connectErrorMsg, Reconnect.TryConnect, true)
	    AssetsBehaviour.Confirm(Reconnect.connectErrorTitle, Reconnect.connectErrorMsg
            ,"" , Reconnect.TryConnect, Application.Quit, true, nil, Reconnect.exitGame)
    --[[        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {
            title = Reconnect.connectErrorTitle,
            msg = Reconnect.connectErrorMsg,
            hander = Reconnect.TryConnect
        } );--]]
	end
end

--掉线前的预处理
function Reconnect.OnDisConnection()
	if(HeroController.GetInstance() ~= nil) then
		HeroController.GetInstance():StopCurrentActAndAI()
	end
	GuideManager.Stop();
	GameSceneManager.goingToScene = false;
	PlayerManager.RemoveListener();
end

function Reconnect.TrySend(data)
	if(data) then
		Warning("Reconnect.TrySend:token=" .. tostring(data));
		local loginData = {}
		loginData.token = data
		local deviceInfo = LogHttp.GetDeviceInfo()
		if(deviceInfo) then
			for k, v in pairs(deviceInfo) do
				if(k == "group_id") then
					loginData[k] = tonumber(v)
				else
					loginData[k] = v
				end
			end
			loginData.platform_tag = GameConfig.instance.strPlatformId
			loginData.channel_id = LogHelp.instance.channel_id
			loginData.app_ver = LogHelp.instance.app_ver
			loginData.device_screen = Screen.width .. "*" .. Screen.height;
			loginData.network = LogHelp.instance:GetNetworkState();
		end
		
		SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Login_Game, Reconnect.OnLogin);
		SocketClientLua.Get_ins():SendMessage(CmdType.Login_Game, loginData);
	else
		Warning("Reconnect.TrySend data is nil");
	end
end

function Reconnect.OnLogin(cmd, data)
	Warning("Reconnect.OnLogin:");
	local tk = Reconnect.token;
	PlayerManager.SetMyToken(tk);
	PlayerManager.SetPlayerInfo(data);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Login_Game, Reconnect.OnLogin);
	Reconnect.TryInGame();
end

function Reconnect.TryInGame()
	if PlayerManager.hero then
		SocketClientLua.Get_ins():AddDataPacketListener(CmdType.In_Game, Reconnect.DataInHandler);
		Warning("Reconnect.TryInGame:" .. PlayerManager.hero.id);
		SocketClientLua.Get_ins():SendMessage(CmdType.In_Game, {id = PlayerManager.hero.id});
	else
		Warning("PlayerManager.hero Is nil");
	end
end

function Reconnect.DataInHandler(cmd, data)
	Warning("Reconnect.DataInHandler:");
	PlayerManager.SetCurPlayerData(data);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.In_Game, Reconnect.DataInHandler);
	
	-- 跳转场景进入游戏
	--    GameSceneManager.InitGameScene();
	local toScene = {};
	toScene.sid = data.scene.sid;
	toScene.fid = data.scene.fid;
	toScene.position = Convert.PointFromServer(data.scene.x, data.scene.y, data.scene.z);
	-- GameSceneManager.to = toScene
	GameSceneManager.GotoScene(toScene.sid, nil, toScene);
	Reconnect.ConnectSuccess()
end

function Reconnect.TryConnect()
	Warning("Reconnect.TryConnect");
	Reconnect.state = ReconnectState.reconnect
	AssetsBehaviour.instance:RecheckUpdate(Reconnect.Connect)
end
function Reconnect.Connect()
	if Reconnect.state == ReconnectState.reconnect then Reconnect.state = ReconnectState.reconnected end
	local ip = LoginProxy:GetCurrentServerInfo().host;
	local port = LoginProxy:GetCurrentServerInfo().port;
	SocketClientLua.Get_ins():Connect(ip, port, Reconnect.SocketConnectState);
end

function Reconnect.ConnectSuccess()
	SocketClientLua.Get_ins():SendMessage(CmdType.Get_MinorData, {});
	
	MessageManager.Dispatch(Reconnect, Reconnect.MESSAGE_CONNECTSUCCEED);
	
end 