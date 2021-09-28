-- 协议基类
BaseProtocolStruct = BaseProtocolStruct or BaseClass()
function BaseProtocolStruct:__init()
	self.msg_type = 0
end

-- 编码
function BaseProtocolStruct:Encode()
end

-- 解码
function BaseProtocolStruct:Decode()
end

function BaseProtocolStruct:Send(net)
	MsgAdapter.Send(net)
end

local msg_type_times = {}
local maxTimes = 0
local maxMsgType = 0
function BaseProtocolStruct:EncodeAndSend(net)
	if (GameNet.Instance.is_login_server_in_asyc_connect or GameNet.Instance.is_login_server_connected) and net ~= GameNet.Instance:GetLoginNet() then
		print_log("BaseProtocolStruct:EncodeAndSend fail", self.msg_type)
		return
	end

	if (GameNet.Instance:IsGameServerInAsyncConnect() or GameNet.Instance:IsLoginServerConnected() and  net ~= GameNet.Instance:GetLoginNet()) then
		-- print_error("ConnectState", GameNet.Instance.login_connect_state, GameNet.Instance:IsLoginServerConnected())
		return
	end

	if LogActTypeCustom.SendProtocol == "True" then
		if not next(msg_type_times) then 
			GlobalTimerQuest:AddDelayTimer(function()
				print_log("目前最高次数为：" .. maxTimes)
				print_log("协议号为" .. maxMsgType)
			end,15)
		end
		if msg_type_times[self.msg_type] then
			msg_type_times[self.msg_type] = msg_type_times[self.msg_type] + 1
			if msg_type_times[self.msg_type] > maxTimes then
				maxTimes = msg_type_times[self.msg_type]
				maxMsgType = self.msg_type
			end
		else
			msg_type_times[self.msg_type] = 1
		end
		print_log("Send:", self.msg_type .. ",次数:" .. msg_type_times[self.msg_type])
	end
	
	if BaseProtocolStruct.PRINT then
		print_warning("ab>>>>>>>>>>>>>>", self.msg_type)
	end
	self:Encode()
	MsgAdapter.Send(net)
end

-- 协议池
ProtocolPool = ProtocolPool or BaseClass()
function ProtocolPool:__init()
	ProtocolPool.Instance = self
	self.protocol_list = {}
	self.protocol_list_by_type = {}
end

function ProtocolPool:__delete()
	self.protocol_list = {}
	self.protocol_list_by_type = {}
end

function ProtocolPool:Register(protocol)
	local reg_protocol = protocol.New()
	if nil ~= self.protocol_list_by_type[reg_protocol.msg_type] then
		print_error("协议重复注册 msg_type:" .. reg_protocol.msg_type)
		reg_protocol:DeleteMe()
		return -1
	end

	self.protocol_list[protocol] = reg_protocol
	self.protocol_list_by_type[reg_protocol.msg_type] = reg_protocol
	return reg_protocol.msg_type
end

function ProtocolPool:UnRegister(protocol, msg_type)
	local reg_protocol = self.protocol_list_by_type[msg_type]
	if nil ~= reg_protocol then
		reg_protocol:DeleteMe()

		self.protocol_list[protocol] = nil
		self.protocol_list_by_type[msg_type] = nil
	end
end

function ProtocolPool:GetProtocol(protocol)
	return self.protocol_list[protocol] or self:AddProtocol(protocol)
end

function ProtocolPool:GetProtocolByType(msg_type)
	return self.protocol_list_by_type[msg_type]
end

function ProtocolPool:AddProtocol(protocol)
	self.protocol_list[protocol] = protocol.New()
	return self.protocol_list[protocol]
end
