--[[
自动触发断线重连机制
ProtocolManager的一种发送器
]]--
require "Core.Net.PtType";
require "Core.Net.SocketWatcher";

SimpleSender = {};
local _waitSends = {};--{[pos]={code, up}}
local _sendings = {};--{[pos]={code, up}}
local _isConnecting = false;

local _ignorePtTypes = {
	[1] = PtType.PING
};

function SimpleSender.ExistWaitPackage()
	return table.getn(_waitSends) > 0;
end

function SimpleSender._OnReceive(code)
	for i,v in ipairs(_sendings) do
		if v.code == code then
			table.remove(_sendings, i);
			--SenderWatcher.instance.OnReceive();
			break;
		end
	end
	
	if isDebug then
		local unreceives = "have not receive: ";
		for i,v in ipairs(_sendings) do
			unreceives = unreceives .. tostring(v.code) .. ", ";
		end
		log(unreceives);
	end
end

function SimpleSender._OnReconnect(code)
	if code == 0 then
		--TODO：登陆成功后数据同步
		SenderWatcher.Clear();
        SimpleSender.ReSend();
	else
		Error("重连失败");
		--TODO：弹出重连失败提示
		
		Scene.ResetDisableTouch();
		local alert = PanelManager.BuildPanel(ResID.UI_ALERT_OK, Alert:New());
		alert.SetContent(OTManager.Get("alert_relogin"));        
		alert.RegistListener(Application.Quit);
	end
end

function SimpleSender.Init()
	ProtocolManager.RegistReceiveHandler(SimpleSender._OnReceive);
	ProtocolManager.AddListener(PtType.RECONNECT, SimpleSender._OnReconnect);
	
	SocketWatcher.Init();
end

function SimpleSender._SendPackage()
	if SocketManager.instance.client.Connected then
		SimpleSender._Send();
	elseif table.getn(_waitSends) > 0 then
		--网络未通, 忽略心跳包等非即时数据包 或 等待网络连通后发送数据
		for i=table.getn(_waitSends),1,-1 do
			if SimpleSender._IsIgnorePackage(_waitSends[i].code) then
				table.remove(_waitSends, i);
			end
		end
		if (table.getn(_waitSends) > 0) and (not _isConnecting) then
			--网络未进行连接则立即连接网络
			_isConnecting = true;
			SocketWatcher.RegisterSocketConnected(SimpleSender._OnSocketConnected);
			SocketWatcher.Reconnect();
		end
	end
end

function SimpleSender.Send(code, up)
	for _,v in ipairs(_waitSends) do
		if v.code == code then
			return;
		end
	end
	table.insert(_waitSends, {code=code, up=up});
	SimpleSender._SendPackage();
end

function SimpleSender.Resend()
	for _,v in ipairs(_sendings) do
		local flag = false;
		for _,w in ipairs(_waitSends) do
			if w.code == v.code then
				flag = true;
			end
		end
		if not flag then
			--有可能发送中断线，那么_sendingPkgs不为空，_pkgOuts为空
            --也有可能发送前断线，那么_sendingPkgs为空，_pkgOuts为空
			table.insert(_waitSends, v);
		end
	end
	
	_sendings = {};
	SimpleSender._SendPackage();
end

function SimpleSender._OnSocketConnected()
	SocketWatcher.RemoveSocketConnected(SimpleSender._OnSocketConnected);
	_isConnecting = false;
	
	SimpleSender._ReLogin();
end

function SimpleSender._ReLogin()
	--TODO: 如果已经登陆成功则发送重连协议，如果未登陆成功则直接发送数据包
	local flag = false;
	if flag then
		--TODO:
	else
		SimpleSender.Resend();
	end
end

function SimpleSender._Send()
	for i=table.getn(_waitSends),1,-1 do
		if SimpleSender._IsIgnorePackage(_waitSends[i].code) then
			table.insert(_sendings, _waitSends[i]);
			SenderWatcher.OnSend();
		end
		
		ProtocolManager.SendPackage(_waitSends[i].code, _waitSends[i].up);
		table.remove(_waitSends, i);
	end
end

function SimpleSender._IsIgnorePackage(code)
	for _,v in ipairs(_ignorePtTypes) do
		if v==code then
			return true;
		end
	end
	return false;
end

function SimpleSender.Clear()
	_waitSends = {};
	
	SocketWatcher.Clear();
	SenderWatcher.Clear();
end