
require("gamenet/msgadapter")
require("protocolcommon/baseprotocolstruct")
require("protocolcommon/protocol_struct")
require("protocolcommon/userprotocol/user_protocol")

GameNet = GameNet or BaseClass()
GameNet.DISCONNECT_REASON_MULTI_LOGIN = "multi_login"
GameNet.DISCONNECT_REASON_NORMAL = "normal"

local ConnectState = {
	Disconnect = 0,
	Connecting = 1,
	Connected = 2,
}

function GameNet:__init()
	if GameNet.Instance ~= nil then
		print_error("[GameNet] attempt to create singleton twice!")
		return
	end
	GameNet.Instance = self

	ProtocolPool.New()

	-- login server 的链接信息
	self:ResetLoginServer()
	self.login_server_host_name = ""
	self.login_server_host_port = 0

	-- game server 的链接信息
	self:ResetGameServer()
	self.game_server_host_name = ""
	self.game_server_host_port = 0

	-- cross server 的链接信息
	self:ResetCrossServer()
	self.cross_server_host_name = ""
	self.cross_server_host_port = 0

	self.no_recv_time = 0							-- 最后收消息时间
	self.block_disconnect = false
	self.cur_net = nil

	self.msg_operate_table = {}						-- 协议处理函数表

	self.loginserver_connect_cache = {
		is_delay_connect = false,
		next_can_connect_time = 0,
		timeout = 0}

	self.gameserver_connect_cache = {
		is_delay_connect = false,
		next_can_connect_time= 0,
		timeout = 0}

	self.crossserver_connect_cache = {
		is_delay_connect = false,
		next_can_connect_time= 0,
		timeout = 0}

	self.disconnect_reason = GameNet.DISCONNECT_REASON_NORMAL

	Runner.Instance:AddRunObj(self, 6)
end

function GameNet:__delete()
	Runner.Instance:RemoveRunObj(self)

	ProtocolPool.Instance:DeleteMe()

	self:DisconnectLoginServer()
	self:ClearLoginServerListen()
	self.login_server_net = nil

	self:DisconnectGameServer()
	self:ClearGameServerListen()
	self.game_server_net = nil

	self:DisconnectCrossServer()
	self:ClearCrossServerListen()
	self.cross_server_net = nil

	self.msg_operate_table = {}

	GameNet.Instance = nil
end

function GameNet:Update(now_time, elapse_time)
	if self.cur_net == self.game_server_net or
		self.cur_net == self.cross_server_net then
		if elapse_time > 1.0 then
			self.no_recv_time = self.no_recv_time + 1.0
		else
			self.no_recv_time = self.no_recv_time + elapse_time
		end

		if self.no_recv_time >= 15 and not UnityEngine.Debug.isDebugBuild then
			self.block_disconnect = true
			self.cur_net:Disconnect()
			self.block_disconnect = false
			self:OnDisconnect(self.cur_net)
			self.no_recv_time = 0
		end
	end

	if self.loginserver_connect_cache.is_delay_connect and
		Status.NowTime > self.loginserver_connect_cache.next_can_connect_time then
		print_log("执行延迟登陆服的连接")
		self:ClearLoginServerConnectCache()
		self:ResetLoginServer()
		self:AsyncConnectLoginServer(self.loginserver_connect_cache.timeout)
	end

	if self.gameserver_connect_cache.is_delay_connect and
		Status.NowTime > self.gameserver_connect_cache.next_can_connect_time then
		print_log("执行延迟游戏服的连接")
		self:ClearGameServerConnectCache()
		self:ResetGameServer()
		self:AsyncConnectGameServer(self.gameserver_connect_cache.timeout)
	end

	if self.crossserver_connect_cache.is_delay_connect and
		Status.NowTime > self.crossserver_connect_cache.next_can_connect_time then
		print_log("执行延迟跨服的连接")
		self:ClearCrossServerConnectCache()
		self:ResetCrossServer()
		self:AsyncConnectCrossServer(self.crossserver_connect_cache.timeout)
	end
end

function GameNet:GetCurNet()
	return self.cur_net
end

local msg_type_times = {}
local maxTimes = 0
local maxMsgType = 0
function GameNet:OnRecvMsg(net, pack_data)
	MsgAdapter.InitReadMsg(pack_data)
	local msg_type = MsgAdapter.ReadUShort()
	MsgAdapter.ReadUShort()

	if LogActTypeCustom.DecodeProtocol == "True" then
		if not next(msg_type_times) then
			GlobalTimerQuest:AddDelayTimer(function()
				print_log("目前最高次数为：" .. maxTimes)
				print_log("协议号为" .. maxMsgType)
			end,15)
		end
		if msg_type_times[msg_type] then
			msg_type_times[msg_type] = msg_type_times[msg_type] + 1
			if msg_type_times[msg_type] > maxTimes then
				maxTimes = msg_type_times[msg_type]
				maxMsgType = msg_type
			end
		else
			msg_type_times[msg_type] = 1
		end
		print_log("Decode:", msg_type .. ",次数:" .. msg_type_times[msg_type])
	end

	self.no_recv_time = 0
	self.cur_net = net

	if nil ~= self.delay_disconnect_timer then
		GlobalTimerQuest:CancelQuest(self.delay_disconnect_timer)
		self.delay_disconnect_timer = nil
	end

	local oper_func = self.msg_operate_table[msg_type]
	if oper_func then
		local protocol = ProtocolPool.Instance:GetProtocolByType(msg_type)
		if protocol then
			protocol:Decode()
			oper_func(protocol)
		else
			print_log("Unknow protocol:[" .. msg_type .. "]")
		end
	end
end

function GameNet:OnDisconnect(net)
	if self.block_disconnect then
		return
	end

	if self.login_server_net == net then
		print_log("disconnect from login server!")
		self.login_connect_state = ConnectState.Disconnect
		self:ClearLoginServerConnectCache()
		self:ResetLoginServer()
		GlobalEventSystem:Fire(LoginEventType.LOGIN_SERVER_DISCONNECTED, self.disconnect_reason)
	elseif self.game_server_net == net then
		print_log("disconnect from game server!")
		self.game_connect_state = ConnectState.Disconnect
		self:ClearGameServerConnectCache()
		self:ResetGameServer()
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, self.disconnect_reason)
	elseif self.cross_server_net == net then
		print_log("disconnect from cross server!")
		self.cross_connect_state = ConnectState.Disconnect
		self:ClearCrossServerConnectCache()
		self:ResetCrossServer()
		GlobalEventSystem:Fire(LoginEventType.CROSS_SERVER_DISCONNECTED, self.disconnect_reason)
	end
	self.disconnect_reason = GameNet.DISCONNECT_REASON_NORMAL
end

function GameNet:RegisterMsgOperate(msg_type, msg_oper_func)		-- 注册协议处理函数
	self.msg_operate_table[msg_type] = msg_oper_func
end

function GameNet:UnRegisterMsgOperate(msg_type)
	self.msg_operate_table[msg_type] = nil
end

--------------------------------------------------------------------------------------
function GameNet:ResetLoginServer()
	self:ClearLoginServerListen()
	self.login_server_net = NetClient.New()
	self.login_listen_handle = self.login_server_net:ListenDisconnect(
		BindTool.Bind(self.OnDisconnect, self, self.login_server_net))
	self.login_recv_handle = self.login_server_net:ListenMessage(
		BindTool.Bind(self.OnRecvMsg, self, self.login_server_net))

	self.login_connect_state = ConnectState.Disconnect
end

function GameNet:ClearLoginServerListen()
	if self.login_server_net and self.login_listen_handle and self.login_recv_handle then
		self.login_server_net:UnlistenDisconnect(self.login_listen_handle)
		self.login_server_net:UnlistenMessage(self.login_recv_handle)
		self.login_listen_handle = nil
		self.login_recv_handle = nil
	end
end

function GameNet:DisconnectLoginServer(reason)
	if self.login_connect_state == ConnectState.Connected then
		self.login_connect_state = ConnectState.Disconnect
		self.disconnect_reason = reason or GameNet.DISCONNECT_REASON_NORMAL
		self.login_server_net:Disconnect()
	end
end

function GameNet:SetLoginServerInfo(host_name, host_port)
	self.login_server_host_name = host_name
	self.login_server_host_port = host_port
end

function GameNet:IsLoginServerConnected()
	return self.login_connect_state == ConnectState.Connected
end

function GameNet:IsLoginServerInAsyncConnect()
	return self.login_connect_state == ConnectState.Connecting
end

function GameNet:AsyncConnectLoginServer(timeout)
	if self.login_connect_state ~= ConnectState.Disconnect then
		print_log("重复连接登录服")
		return false
	end

	if "" == self.login_server_host_name or 0 == self.login_server_host_port then
		print_log("Please set login server info before async connect!")
		return false
	end

	if Status.NowTime < self.loginserver_connect_cache.next_can_connect_time then
		self.loginserver_connect_cache.is_delay_connect = true
		print_log("连接登录服务器频率过高，将延迟连接")
		return false
	end

	self.loginserver_connect_cache.timeout = timeout
	self.loginserver_connect_cache.is_delay_connect = false
	self.loginserver_connect_cache.next_can_connect_time = Status.NowTime + timeout

	self.login_connect_state = ConnectState.Connecting

	local has_receive = false
	local connet_call_back = function(is_succ)
		if has_receive then
			return
		end
		has_receive = true

		if nil == self.login_server_net then
			GlobalEventSystem:Fire(LoginEventType.LOGIN_SERVER_CONNECTED, false)
			print_error("login_server_net is nil!!!!")
			return
		end

		if is_succ then
			IS_ON_CROSSSERVER = false
			self:ClearLoginServerConnectCache()
			self.cur_net = self.login_server_net
			self.login_server_net:StartReceive()
			self.login_connect_state = ConnectState.Connected
		else
			self.login_connect_state = ConnectState.Disconnect
		end

		print_log("Async Connect to login server Ret: status ", is_succ)
		GlobalEventSystem:Fire(LoginEventType.LOGIN_SERVER_CONNECTED, is_succ)
	end

	self.login_server_net:Connect(self.login_server_host_name, self.login_server_host_port, connet_call_back)

	GlobalTimerQuest:AddDelayTimer(function ()
		connet_call_back(false)
	end, 5)

	return true
end

function GameNet:ClearLoginServerConnectCache()
	self.loginserver_connect_cache.is_delay_connect = false
	self.loginserver_connect_cache.next_can_connect_time = 0
	self.loginserver_connect_cache.timeout = 0
end

function GameNet:GetLoginNet()
	return self.login_server_net
end

--------------------------------------------------------------------------------------
function GameNet:ResetGameServer()
	self:ClearGameServerListen()
	self.game_server_net = NetClient.New()
	self.game_listen_handle = self.game_server_net:ListenDisconnect(
		BindTool.Bind(self.OnDisconnect, self, self.game_server_net))
	self.game_recv_handle = self.game_server_net:ListenMessage(
		BindTool.Bind(self.OnRecvMsg, self, self.game_server_net))

	self.game_connect_state = ConnectState.Disconnect
end

function GameNet:ClearGameServerListen()
	if self.game_server_net and self.game_listen_handle and self.game_recv_handle then
		self.game_server_net:UnlistenDisconnect(self.game_listen_handle)
		self.game_server_net:UnlistenMessage(self.game_recv_handle)
		self.game_listen_handle = nil
		self.game_recv_handle = nil
	end
end

function GameNet:DisconnectGameServer(reason)
	if self.game_connect_state == ConnectState.Connected then
		self.game_connect_state = ConnectState.Disconnect
		self.disconnect_reason = reason or GameNet.DISCONNECT_REASON_NORMAL
		self.game_server_net:Disconnect()
	end
end

function GameNet:SetGameServerInfo(host_name, host_port)
	self.game_server_host_name = host_name
	self.game_server_host_port = host_port
end

function GameNet:IsGameServerConnected()
	return self.game_connect_state == ConnectState.Connected
end

function GameNet:IsGameServerInAsyncConnect()
	return self.game_connect_state == ConnectState.Connecting
end

function GameNet:AsyncConnectGameServer(timeout)
	if self.game_connect_state ~= ConnectState.Disconnect then
		print_log("重复连接游戏服")
		return false
	end

	if "" == self.game_server_host_name or 0 == self.game_server_host_port then
		print_log("Please set game server info before async connect!")
		return
	end

	if Status.NowTime < self.gameserver_connect_cache.next_can_connect_time then
		self.gameserver_connect_cache.is_delay_connect = true
		print_log("连接游戏服务器频率过高，将延迟连接")
		return
	end

	self.gameserver_connect_cache.timeout = timeout
	self.gameserver_connect_cache.is_delay_connect = false
	self.gameserver_connect_cache.next_can_connect_time = Status.NowTime + timeout

	self.game_connect_state = ConnectState.Connecting

	local has_receive = false
	local connet_call_back = function(is_succ)
		if has_receive then
			return
		end

		if nil == self.game_server_net then
			GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_CONNECTED, false)
			print_error("game_server_net is nil!!!!")
			return
		end

		has_receive = true

		if is_succ then
			self:ClearGameServerConnectCache()
			self.cur_net = self.game_server_net
			self.no_recv_time = 0
			self.game_server_net:StartReceive()
			self.game_connect_state = ConnectState.Connected
			Scene.Instance:ResetIsEnterScene()
		else
			self.game_connect_state = ConnectState.Disconnect
		end

		print_log("Async Connect to game server Ret: status ", is_succ)
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_CONNECTED, is_succ)
	end
	self.game_server_net:Connect(self.game_server_host_name, self.game_server_host_port, connet_call_back)

	GlobalTimerQuest:AddDelayTimer(function ()
		connet_call_back(false)
	end, 5)

	return true
end

function GameNet:ClearGameServerConnectCache()
	self.gameserver_connect_cache.is_delay_connect = false
	self.gameserver_connect_cache.next_can_connect_time = 0
	self.gameserver_connect_cache.timeout = 0
end

function GameNet:GetGameServerNet()
	return self.game_server_net
end

--------------------------------------------------------------------------------------
function GameNet:ResetCrossServer()
	self:ClearCrossServerListen()
	self.cross_server_net = NetClient.New()
	self.cross_listen_handle = self.cross_server_net:ListenDisconnect(
		BindTool.Bind(self.OnDisconnect, self, self.cross_server_net))
	self.cross_recv_handle = self.cross_server_net:ListenMessage(
		BindTool.Bind(self.OnRecvMsg, self, self.cross_server_net))

	self.cross_connect_state = ConnectState.Disconnect
end

function GameNet:ClearCrossServerListen()
	if self.cross_server_net and self.cross_listen_handle and self.cross_recv_handle then
		self.cross_server_net:UnlistenDisconnect(self.cross_listen_handle)
		self.cross_server_net:UnlistenMessage(self.cross_recv_handle)
		self.cross_listen_handle = nil
		self.cross_recv_handle = nil
	end
end

function GameNet:DisconnectCrossServer(reason)
	if self.cross_connect_state == ConnectState.Connected then
		self.cross_connect_state = ConnectState.Disconnect
		self.disconnect_reason = reason or GameNet.DISCONNECT_REASON_NORMAL
		self.cross_server_net:Disconnect()
	end
end

function GameNet:SetCrossServerInfo(host_name, host_port)
	self.cross_server_host_name = host_name
	self.cross_server_host_port = host_port
end

function GameNet:IsCrossServerConnected()
	return self.cross_connect_state == ConnectState.Connected
end

function GameNet:IsCrossServerInAsyncConnect()
	return self.cross_connect_state == ConnectState.Connecting
end

function GameNet:AsyncConnectCrossServer(timeout)
	print(self.cross_connect_state, ConnectState.Disconnect)
	if self.cross_connect_state ~= ConnectState.Disconnect then
		print_log("重复连接游戏服")
		return false
	end

	if "" == self.cross_server_host_name or 0 == self.cross_server_host_port then
		print_log("Please set cross server info before async connect!")
		return
	end

	if Status.NowTime < self.crossserver_connect_cache.next_can_connect_time then
		self.crossserver_connect_cache.is_delay_connect = true
		print_log("连接游戏服务器频率过高，将延迟连接")
		return
	end

	self.crossserver_connect_cache.timeout = timeout
	self.crossserver_connect_cache.is_delay_connect = false
	self.crossserver_connect_cache.next_can_connect_time = Status.NowTime + timeout

	self.cross_connect_state = ConnectState.Connecting

	local has_receive = false
	local connet_call_back = function(is_succ)
		if has_receive then
			return
		end

		has_receive = true

		if nil == self.cross_server_net then
			GlobalEventSystem:Fire(LoginEventType.CROSS_SERVER_CONNECTED, false)
			print_error("cross_server_net is nil!!!!")
			return
		end

		if is_succ then
			IS_ON_CROSSSERVER = true
			self:ClearCrossServerConnectCache()
			self.cur_net = self.cross_server_net
			self.no_recv_time = 0
			self.cross_server_net:StartReceive()
			self.cross_connect_state = ConnectState.Connected
		else
			self.cross_connect_state = ConnectState.Disconnect
		end

		print_log("Async Connect to cross server Ret: status ", is_succ)
		GlobalEventSystem:Fire(LoginEventType.CROSS_SERVER_CONNECTED, is_succ)
	end
	self.cross_server_net:Connect(self.cross_server_host_name, self.cross_server_host_port, connet_call_back)

	GlobalTimerQuest:AddDelayTimer(function ()
		connet_call_back(false)
	end, 5)

	return true
end

function GameNet:ClearCrossServerConnectCache()
	self.crossserver_connect_cache.is_delay_connect = false
	self.crossserver_connect_cache.next_can_connect_time = 0
	self.crossserver_connect_cache.timeout = 0
end

function GameNet:GetCrossServerNet()
	return self.cross_server_net
end