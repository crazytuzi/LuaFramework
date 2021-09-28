SenderWatcher = {};

local _alertDelay = 0.5;
local _timeOut = 10;

local _connectingPanel = nil;
local _timeOutPanel = nil;
local _sendCount = 0;

function SenderWatcher.GetSendCount()
	return _sendCount;
end

function SenderWatcher._ShowConnecting()
        if _connectingPanel == nil then
                _connectingPanel = PanelManager.BuildPanel(ResID.UI_ALERT_OK, Alert:New());
                _connectingPanel:SetContent(OTManager.Get("alert_connecting"));
	end
end

function SenderWatcher._HideConnecting()
	if _connectingPanel ~= nil then
		PanelManager.RecyclePanel(_connectingPanel);
		_connectingPanel = nil;
	end
end

function SenderWatcher._HideTimeOut()
        if _timeOutPanel ~= nil then
                PanelManager.RecyclePanel(_timeOutPanel);
                _timeOutPanel = nil;
	end
end

function SenderWatcher._TryAgain()
        _sendCount = 0;
	SenderWatcher._HideTimeOut();
        SimpleSender.ReSend();
end

function SenderWatcher._ShowTimeOut()
	if _timeOutPanel == nil then
		_timeOutPanel = PanelManager.BuildPanel(ResID.UI_ALERT_OK, Alert:New());
        _timeOutPanel:SetContent(OTManager.Get("alert_call_timeout"));
		_timeOutPanel:SetAutoCloseFlag(false);
		_timeOutPanel:RegistListener(SenderWatcher._TryAgain);
	end
end

function SenderWatcher._WaitTimeOut()
	Scene.disableTouch = true;
	local time = 0;
	while _sendCount > 0 do
		time = time + Timer.deltaTime;
		if time > _timeOut then
			SenderWatcher._ShowTimeOut();
			SenderWatcher._HideConnecting();
			break;
		elseif time >= _alertDelay then
			SenderWatcher._ShowConnecting();
		end
		coroutine.wait(Timer.deltaTime);
	end
	Scene.disableTouch = false;
end

function SenderWatcher.OnSend()
	_sendCount = _sendCount + 1;
	if _sendCount <= 1 then
		coroutine.start(SenderWatcher._WaitTimeOut);
	end
end

function SenderWatcher.Clear()
	_sendCount = 0;
end

function SenderWatcher.OnReceive()
	_sendCount = _sendCount - 1;
	if _sendCount <= 0 then
		SenderWatcher._HideConnecting();
		SenderWatcher._HideTimeOut();
	end
end