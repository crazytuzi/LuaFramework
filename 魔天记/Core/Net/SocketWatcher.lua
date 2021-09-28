SocketWatcher = {};
local _alertDelay = 0.5;
local _timeOut = 2;

local _socketConnected = {};--内部存储回调函数
local _isConnecting = false;

local _connectingPanel = nil;
local _timeOutPanel = nil;

function SocketWatcher.Init()
--	EventManager.AddListener(SocketManager.instance, SOCKET_CONNECT, "SocketWatcher._OnSocketConnect", SocketWatcher._OnSocketConnect);
--	EventManager.AddListener(SocketManager.instance, SOCKET_CLOSE, "SocketWatcher._OnSocketError", SocketWatcher._OnSocketError);
--	EventManager.AddListener(SocketManager.instance, SOCKET_ERROR, "SocketWatcher._OnSocketError", SocketWatcher._OnSocketError);
end

function SocketWatcher.Clear()
--	EventManager.RemoveListener(SocketManager.instance, SOCKET_CONNECT, "SocketWatcher._OnSocketConnect");
--	EventManager.RemoveListener(SocketManager.instance, SOCKET_CLOSE, "SocketWatcher._OnSocketError");
--	EventManager.RemoveListener(SocketManager.instance, SOCKET_ERROR, "SocketWatcher._OnSocketError");
end

function SocketWatcher._ShowConnecting()
    if _connectingPanel == nil then
        _connectingPanel = PanelManager.BuildPanel(ResID.UI_ALERT_OK, Alert:New());
        _connectingPanel:SetContent(OTManager.Get("alert_connecting"));
	end
end

function SocketWatcher._HideConnecting()
	if _connectingPanel ~= nil then
		PanelManager.RecyclePanel(_connectingPanel);
		_connectingPanel = nil;
	end
end

function SocketWatcher._ContinueConnect()
	_timeOutPanel = nil;
    SocketWatcher._Reconnect();
end

function SocketWatcher._ShowTimeOut()
	if _timeOutPanel == nil then
		SocketManager.instance:Close();
		_isConnecting = false;
		_timeOutPanel = PanelManager.BuildPanel(ResID.UI_ALERT_OK, Alert:New());
        _timeOutPanel:SetContent(OTManager.Get("alert_socket_reconnect"));
		_timeOutPanel:SetAutoCloseFlag(true);
		_timeOutPanel:RegistListener(SocketWatcher._ContinueConnect);
	end
end

function SocketWatcher._WaitTimeOut(isAgain)
	Scene.disableTouch = true;
	local time = (isAgain and _alertDelay) or 0;
	while _isConnecting do
		time = time + Timer.deltaTime;
		if time > _timeOut then 
			SocketWatcher._ShowTimeOut();
			SocketWatcher._HideConnecting();
			break;
		elseif time >= _alertDelay then
			SocketWatcher._ShowConnecting();
		end
		coroutine.step(1);
	end
	Scene.disableTouch = false;
end

function SocketWatcher.RegisterSocketConnected(socketConnected)
	table.insert(_socketConnected, socketConnected);
end

function SocketWatcher.RemoveSocketConnected(socketConnected)
	for i,v in ipairs(_socketConnected) do
		if v == socketConnected then
			table.remove(_socketConnected, i);
		end
	end
end

function SocketWatcher.Connect(ip, port)
	_isConnecting = true;
	coroutine.start(SocketWatcher._WaitTimeOut, false);
	
	SocketManager.instance:Connect(ip, port);
end

function SocketWatcher.Reconnect()
	SocketWatcher._Reconnect();
end

function SocketWatcher._Reconnect()
	_isConnecting = true;
	coroutine.start(SocketWatcher._WaitTimeOut, true);

    SocketManager.instance:Reconnect();
end

function SocketWatcher._OnSocketError()
	--Do nothing
end

function SocketWatcher._OnSocketConnect()
	_isConnecting = false;
    SocketWatcher._HideConnecting();
	for _,v in ipairs(_socketConnected) do
		v();
	end
end