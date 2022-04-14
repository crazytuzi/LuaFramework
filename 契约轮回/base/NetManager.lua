--
-- Author: LaoY
-- Date: 2018-06-28 17:36:34
-- 网络管理器

NetManager = NetManager or class("NetManager", BaseManager)

local networkMgr = networkMgr
local Time = Time
local print = print
local unpack = unpack
local tostring = tostring
local tonumber = tonumber
local string_sub = string.sub
local table_insert = table.insert
local string_len = string.len
local ByteBuffer = ByteBuffer
local table_concat = table.concat
local string_format = string.format

NetManager.HandleMsg = nil
function NetManager:ctor()
	NetManager.Instance = self

	self.proto_list = list()
	self.proto_funs = {}

	self.last_handler_time = Time.time
	self.curr_frame_receive_count = 0
	self:AddEvents()

	self.register_list = {}

	self.err_net = false
	self.is_pause = false

	if AppConfig.Debug then
		self.protoNameTab = table.transfer(proto)
	end

	-- FixedUpdateBeat:Add(self.Update, self, 1)
	UpdateBeat:Add(self.Update, self, 1)
end

function NetManager:GetProtoName(id)
	if self.protoNameTab and self.protoNameTab[id] then
		return self.protoNameTab[id], id
	else
		return "", id
	end
end

function NetManager:dctor()
end

function NetManager:GetInstance()
	if not NetManager.Instance then
		NetManager.new()
	end
	return NetManager.Instance
end

-- C# 层返回信息 勿改
--Socket消息--
function NetManager.OnSocket(key, data)
	GlobalEvent:Brocast(key, data)
end
-- C# 层返回信息 勿改

function NetManager:AddEvents()
	local function ConnectFunc()
		self:OnConnect()
	end
	local function ExceptionFunc(str)
		self:OnException(str)
	end
	local function DisconnectFunc()
		self:OnDisconnect()
	end
	local function MessageFunc(msg)
		self:OnMessage(msg)
	end
	GlobalEvent:AddListener(Constant.Protocal.Connect, ConnectFunc)
	GlobalEvent:AddListener(Constant.Protocal.Exception, ExceptionFunc)
	GlobalEvent:AddListener(Constant.Protocal.Disconnect, DisconnectFunc)
	GlobalEvent:AddListener(Constant.Protocal.Message, MessageFunc)
end

function NetManager:StartConnect(address, port)
	LoginModel.IP 	= tostring(address) or "192.168.31.133"
	LoginModel.Port = tonumber(port) or 9310
	AppConst.SocketAddress = LoginModel.IP
	AppConst.SocketPort = LoginModel.Port

	networkMgr:SendConnect()

	LoginModel:GetInstance():CheckExamine()
end

function NetManager:CloseConnect()
	logError("close connect")
	self.err_net = true
	networkMgr:CloseConnect()
end

function NetManager:Update()
	-- if self.err_net then
	-- 	return
	-- end
	-- local n = 0
	while self.proto_list:next(self.proto_list) do
		-- n = n + 1
		local msg = self.proto_list:shift()
		self:HandleMessage(msg)
	end
	self.curr_frame_receive_count = 0
end

function NetManager:SendMessage(proto_id, fmts, ...)
	if (self.err_net or self.is_pause) and not LoginModel:GetInstance().is_reconnect then
		return
	end

	-- if not LoginModel:GetInstance().is_reconnect then
	-- 	Yzprint('--LaoY NetManager.lua,line 113--',data)
	-- end
	
	local buffer = ByteBuffer.New()
	buffer:WriteUint(proto_id)
	local args = {...}
	if type(fmts) ~= "table" then
		fmts = {fmts}
	end
	for i = 1, #fmts do
		local fmt = fmts[i]
		self:WriteFMT(buffer, fmt, args[i])
	end
	networkMgr:SendMessage(buffer)
	if proto_id == 1200005 then
		--log(string_format('------->>>>发送协议：%s',proto_id))
	else
		--if AppConfig.Debug then
			log(string_format("------->>>>发送协议：%s @ %s", self:GetProtoName(proto_id)))
		--end
	end
end

--[[
协议格式标识说明,有符号的必须手写或者传方法名字进去
    8:   8位无符号整数		
    16:  16位无符号整数		ReadShort/WriteShort
    32:  32位无符号整数		ReadInt/WriteInt
    64:  64位无符号整数		ReadLong/WriteLong
    s:   字符串
    p:   protobuf 数据
]]
function NetManager:WriteFMT(buffer, fmt_str, value)
	fmt_str = tostring(fmt_str)
	local tab = {
		["8"] = buffer.WriteByte,
		["16"] = buffer.WriteUshort,
		["32"] = buffer.WriteUint,
		["64"] = buffer.WriteUlong,
		["s"] = buffer.WriteString,
		["p"] = buffer.WriteBuffer,
		["f"] = buffer.WriteFloat,
		["d"] = buffer.WriteDouble
	}
	if tab[fmt_str] then
		tab[fmt_str](buffer, value)
	elseif buffer[fmt_str] then
		buffer[fmt_str](buffer, value)
	else
		logError("the fmt_str is nil", fmt_str)
	end
end

function NetManager:ReadMessage(fmts, buffer)
	buffer = buffer or NetManager.HandleMsg
	-- ReadShort
	local tab = {
		["8"] = buffer.ReadByte,
		["16"] = buffer.ReadUshort,
		["32"] = buffer.ReadUint,
		["64"] = buffer.ReadUlong,
		["s"] = buffer.ReadString,
		["p"] = buffer.ReadBuffer,
		["f"] = buffer.ReadFloat,
		["d"] = buffer.ReadDouble
	}

	if type(fmts) ~= "table" then
		fmts = {fmts}
	end
	local len = #fmts
	local t = {}
	for i = 1, len do
		local fmt = tostring(fmts[i])
		if tab[fmt] then
			t[#t + 1] = tab[fmt](buffer)
		elseif buffer[fmt] then
			t[#t + 1] = buffer[fmt](buffer)
		end
	end
	return unpack(t)
end
NetManager.NOT_PRINT_MESSAGE_ID_TABLE = {
    [1200005] = true,
    [1000005] = true,
    [1000002] = true,
}
function NetManager:OnMessage(msg)
	if msg.len < 8 then
		logError("==OnMessage====",msg.len)
		self.proto_list:clear()
		self.err_net = true
		Notify.ShowText("Network exception")
		return
	end
	self.err_net = false
	local proto_id = msg:ReadUint()
    if not self.NOT_PRINT_MESSAGE_ID_TABLE[proto_id] then
        log(string_format("+++++++<<<<收到协议：%s @ %s", self:GetProtoName(proto_id)))
    end

    if proto_id == 1000002 then
    	Yzprint('--LaoY NetManager.lua,line 207--',msg.len)
    end
	local data = {proto_id = proto_id, msg = msg}
	if (self.proto_list.length == 0 and (Time.time - self.last_handler_time > 0.02)) 
		-- 时间同步协议直接执行
		or proto_id == proto.GAME_TIME then
		self:HandleMessage(data)
	else
		self.curr_frame_receive_count = self.curr_frame_receive_count + 1
		-- if self.curr_frame_receive_count > 10 then

		-- end
		self.proto_list:push(data)
	end
end

function NetManager:HandleMessage(data)
	NetManager.HandleMsg = nil
	if not data then
		return
	end
	self.last_handler_time = Time.time
	local proto_id = data.proto_id
	local msg = data.msg
	if self.register_list[proto_id] then
		NetManager.HandleMsg = msg
		self.register_list[proto_id]()
	else
		log("handle un-register proto " .. proto_id)
	end
	NetManager.HandleMsg = nil
end

function NetManager:Register(proto_id, func)
	if not proto_id and AppConfig.Debug then
		logError("协议号是空！")
	end
	self.register_list[proto_id] = func
end

--当连接建立时--
function NetManager:OnConnect()
	log("Game Server connected!!!!!!!!!!")
	self.err_net = false
	-- print('--LaoY NetManager.lua,line 106-- data=',data)
	GlobalEvent:Brocast(EventName.ConnectSuccess)
	LoginModel:GetInstance():SetQuit(nil)
end

--异常断线--
function NetManager:OnException(str)
	logError("OnException------->>>>" , str)
	self.err_net = true
end

--连接中断，或者被踢掉--
function NetManager:OnDisconnect()
	logError("OnDisconnect------->>>>")
	self.err_net = true
end

--每秒检测断线重连
function NetManager:StartReConnectSchedule()
	local loginModel = LoginModel:GetInstance()
	--logError("start reconnect")
	if self.schedule_id then
		return
	end

	local loop, max_loop = 0, 15
	local function loop_func()
		if not self.err_net then
			loop = 0
			return
		end
		loginModel:SetReConnect()
		loop = loop + 1
		logError("reconnect ............" .. loop)
		if loop < max_loop then
			networkMgr:SendConnect()
		else
			self:ReconnectWindow()
		end
	end
	self.schedule_id = GlobalSchedule:Start(loop_func, 1)
end

function NetManager:StopReConnect()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function NetManager:ReconnectWindow()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	local function ok_func()
		self:StartReConnectSchedule()
	end
	local function cancel_func()
		if not AppConfig.Debug then
            PlatformManager:GetInstance():logout()
        end
		GlobalEvent:Brocast(EventName.GameReset)
		self:CloseConnect()
		LoginController:GetInstance():RequestLeaveGame(true)
		GlobalEvent:Brocast(LoginEvent.OpenLoginPanel)
	end
	Dialog.ShowTwo("Reconnection failed","Your network is unstable. Auto reconnection failed, please check your network!","Reconnect",ok_func,10,"Return to log in page",cancel_func)
end

function NetManager:Quit()
	GlobalEvent:Brocast(EventName.GameReset)
	local loginModel = LoginModel:GetInstance()
	local quit_number = loginModel.quit_number
	if self.schedule_id then
		logError("stop reconnect")
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	local function btn_func()
		if not AppConfig.Debug then
            PlatformManager:GetInstance():logout()
        end
		self:CloseConnect()
		GlobalEvent:Brocast(LoginEvent.OpenLoginPanel)
	end
	local msg = "Disconnected, returning to the login page"
	if quit_number == 1000012 then
		msg = "You have been banned by the admin"
	elseif quit_number == 1000002 then
		msg = "Server under maintenance, returning to the login page"
	elseif quit_number == 1000004 then
		msg = "We found that you are using an accelerator such unfair gameplay will lead you to a forced disconnection."
		local function btn_func2()
			Application.Quit()
		end
		Dialog.ShowOne("Tip",msg,"Confirm",btn_func2,10, btn_func2)
		return
	elseif quit_number == 1000010 then
		msg = "Your account is logged in on another device, returning to the login page"
	elseif quit_number == 1000021 then
		msg = "Minors or users without real-name authentication are forbidden to log in from 22 pm to 8 am the next day. Please arrange your game time reasonably. If you are an adult, please complete real-name authentication!"
	elseif quit_number == 1000022 then
		msg = "Minors or unauthenticated users are limited in their daily online time. Your online time today has exceeded the limit and you will be forced offline. If you are an adult, please complete real-name authentication!"
	end
	Dialog.ShowOne("Tip", msg, "Confirm", btn_func, 10, btn_func)
end

