PingManager = {
	--ONE_FRAME_TIME = 1 / GameConfig.FRAME_RATE,
	PING_INTERVAL = 50,
	SOCKET_TIME_OUT = 8,
	CHECK_INTERVAL = 2
};

local _tickTime = 0;
local _lastPingPongTime = 0.0;
local _checkTimeOutTime = 0;

function PingManager.Init()
	--TODO：处理Logout协议
	ProtocolManager.AddListener(PtType.PING, _OnPingComplete);
	ProtocolManager.RegistSendHandler(_OnSend);
	ProtocolManager.RegistReceiveHandler(_OnReceive);
	
	coroutine.start(_OnCoroutine)
end

function _OnCoroutine()
	while true do
		coroutine.wait(PingManager.CHECK_INTERVAL);
		_tickTime = _tickTime + PingManager.CHECK_INTERVAL;
		if SocketManager.instance.client.Connected then
			_checkTimeOutTime = _checkTimeOutTime + PingManager.CHECK_INTERVAL;
			if SenderWatcher.GetSendCount() > 0 and _tickTime > _lastPingPongTime + PingManager.SOCKET_TIME_OUT then
				_lastPingPongTime = _tickTime;
				SocketManager.instance.Close();
			elseif _checkTimeOutTime >= PingManager.PING_INTERVAL then
				--TODO:需要增加在线判断
				ProtocolManager.SendMessage(PtType.PING);
				_checkTimeOutTime = 0;
			end
		else
			_checkTimeOutTime = 0;
		end	
	end
end

local function _OnPingComplete(errCode, down)
	--TODO:
end

local function _OnSend(code)
	_lastPingPongTime = _tickTime;
end

local function _OnReceive(code)
    _lastPingPongTime = _tickTime;
end