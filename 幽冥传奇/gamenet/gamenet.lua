
require("scripts/gamenet/msgadapter")
require("scripts/protocolcommon/baseprotocolstruct")
require("scripts/protocolcommon/common_reader")
-- require("scripts/protocolcommon/userprotocol/user_protocol")
require("scripts/protocolcommon/protocol/protocol")

GameNet = GameNet or BaseClass()
GameNet.DISCONNECT_REASON_SILENT_LOGIN = "silent_login"
GameNet.DISCONNECT_REASON_MULTI_LOGIN = "multi_login"
GameNet.DISCONNECT_REASON_BE_DEL = "be_delete"
GameNet.DISCONNECT_REASON_NORMAL = "normal"
GameNet.DISCONNECT_REASON_CROSSLOGIN = "crosslogin"
GameNet.DISCONNECT_REASON_KICKOUT = "kickout"

function GameNet:__init()
	if GameNet.Instance ~= nil then
		ErrorLog("[GameNet] attempt to create singleton twice!")
		return
	end
	GameNet.Instance = self

	ProtocolPool.New()
	
	self.net_manager = GameNetManager:getInstance()
	self.msg_handler = MsgHandler:getInstance()

	-- game server 的链接信息
	self.is_game_server_connected = false
	self.is_game_server_in_asyc_connect = false
	self.game_server_async_handle = -1
	self.game_server_net_id = 0xffffffff
	self.is_game_server_info_set = false
	self.game_server_host_name = nil
	self.game_server_host_port = nil
	self.is_enter_role_suc = false

	self.last_recv_time = 0							-- 最后收消息时间
	self.recv_msg_net_id = 0 						-- 当前指令来自的net_id
	self.msg_operate_table = {}						-- 协议处理函数表
	self.show_reconnect_time = 0

	self.enter_background_time = 0

	self.net_manager:setRecvHandler(LUA_CALLBACK(self, self.OnRecvMsg))
	self.net_manager:setDisconnectHandler(LUA_CALLBACK(self, self.OnDisconnect))
	self.net_manager:setConnectHandler(LUA_CALLBACK(self, self.OnAsyncConnected))

	self.disconnect_reason = GameNet.DISCONNECT_REASON_NORMAL

	Runner.Instance:AddRunObj(self, 6)

	self.delay_time = 10 		--网络延迟时间
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	GlobalEventSystem:Bind(AppEventType.ENTER_BACKGROUND, BindTool.Bind1(self.EnterBackground, self))
	GlobalEventSystem:Bind(AppEventType.ENTER_FOREGROUND, BindTool.Bind1(self.EnterForeground, self))
end

function GameNet:__delete()
	Runner.Instance:RemoveRunObj(self)
	ProtocolPool.Instance:DeleteMe()
	self:DisconnectGameServer()
	self.msg_operate_table = {}
	self.net_manager = nil
	GameNet.Instance = nil
end

-- 设置网络延迟
function GameNet:SetDelayTime(delay_time)
	self.delay_time = delay_time
	if nil ~= self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function() self.delay_time = 10 end, 10)
end

-- 获取网络延迟
function GameNet:GetDelayTime()
	return self.delay_time
end

-- 进入后台
function GameNet:EnterBackground()
	self.enter_background_time = Status.NowTime
end

-- 进入前台
function GameNet:EnterForeground()
end

function GameNet:Update(now_time, elapse_time)
	if self.enter_background_time > 0 then
		self.last_recv_time = self.last_recv_time + (now_time - self.enter_background_time)
		self.enter_background_time = 0
	end

	if IS_IOS_OR_ANDROID and now_time > self.show_reconnect_time + 1 and now_time > self.last_recv_time + 30 then
		if self.is_game_server_connected and self.is_enter_role_suc then
			if now_time > self.last_recv_time + 60 then
				self.last_recv_time = now_time
				GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_NORMAL)
				return
			end
			local quick_reconnect = AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT")
			if quick_reconnect ~= "true" then
				self.show_reconnect_time = now_time
				SystemHint.Instance:ShowNetUnstableTips()
			else
				self.is_game_server_connected = false
			end
		end
	end
end

function GameNet:OnRecvMainRoleInfo()
	self.is_enter_role_suc = true
end

function GameNet:OnAsyncConnected(is_suc, handle, net_id)
	local is_suc_b = (1 == is_suc) 
	if handle == self.game_server_async_handle then
		self.is_game_server_in_asyc_connect = false
		self.is_game_server_connected = is_suc_b
		self.game_server_net_id = net_id
		self.last_recv_time = Status.NowTime
		self.recv_msg_net_id = net_id

		Log("Async Connect to game server Ret: status " .. tostring(is_suc_b) .. "  net_id:" .. net_id)
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_CONNECTED, is_suc_b)
	else
		self.net_manager:disconnect(net_id)
	end
end

function GameNet:OnRecvMsg(msg_type, net_id)
	self.last_recv_time = Status.NowTime
	self.recv_msg_net_id = net_id

	local oper_func = self.msg_operate_table[msg_type]
	if oper_func then
		local protocol = ProtocolPool.Instance:GetProtocolByType(msg_type)
		if protocol then
			LogT("OnRecvMsg[" .. protocol:GetSysId() .. "  " .. protocol:GetCmdId() .. "]")
			protocol:Decode()
			oper_func(protocol)
		else
			local sys_id = msg_type % 256
			local cmd_id = bit:_rshift(msg_type, 8)
			Log("====Unknow protocol:[" .. sys_id .. "  " .. cmd_id .. "]!" .. msg_type)
		end
	else
		local sys_id = msg_type % 256
		local cmd_id = bit:_rshift(msg_type, 8)
		Log("====Unknow protocol:[" .. sys_id .. "  " .. cmd_id .. "]." .. msg_type)
	end
end

function GameNet:OnDisconnect(net_id)
	print(self.game_server_net_id)
	print(net_id)
	if self.game_server_net_id == net_id then
		self.is_game_server_connected = false
		self.is_enter_role_suc = false
		self.game_server_net_id = 0xffffffff
		Log("disconnect from role server!")
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, self.disconnect_reason)
	end
	self.disconnect_reason = GameNet.DISCONNECT_REASON_NORMAL
end

function GameNet:RegisterMsgOperate(msg_type, msg_oper_func)		-- 注册协议处理函数
	self.msg_operate_table[msg_type] = msg_oper_func
end

--------------------------------------------------------------------------------------
function GameNet:DisconnectGameServer(reason)
	if self.is_game_server_connected then
		self.is_game_server_connected = false
		self.is_enter_role_suc = false
		self.disconnect_reason = reason or GameNet.DISCONNECT_REASON_NORMAL 
		self.net_manager:disconnect(self.game_server_net_id)
	end
	if self.is_game_server_in_asyc_connect then
		self.is_game_server_in_asyc_connect = false
		self.game_server_async_handle = -1
	end
end

function GameNet:SetGameServerInfo(host_name, host_port)
	self.is_game_server_info_set = true
	self.game_server_host_name = host_name
	self.game_server_host_port = host_port
end

function GameNet:IsGameServerConnected()
	return self.is_game_server_connected
end

function GameNet:IsGameServerInAsyncConnect()
	return self.is_game_server_in_asyc_connect
end

function GameNet:AsyncConnectGameServer(timeout, is_game_server_in_asyc_connect)
	if is_game_server_in_asyc_connect ~= nil then
		self.is_game_server_in_asyc_connect = is_game_server_in_asyc_connect
	end
	
	if self.is_game_server_connected or self.is_game_server_in_asyc_connect then
		Log("重复连接游戏服")
		return false
	end
	
	if not self.is_game_server_info_set then
		Log("Please set game server info before async connect!")
		return
	end

	self.game_server_async_handle = self.net_manager:connectAsyn(self.game_server_host_name, self.game_server_host_port, timeout * 1000)
	
	if self.game_server_async_handle == -1 then
		Log("ConnectAsyn failed in GameNet:AsyncConnectRoleServer")
		self.is_game_server_connected = false
		return false
	end

	self.is_game_server_in_asyc_connect = true
	return true
end

function GameNet:GetGameServerNetId()
	return self.game_server_net_id
end
