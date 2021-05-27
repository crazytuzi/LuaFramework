
-- 协议基类
BaseProtocolStruct = BaseProtocolStruct or BaseClass()
function BaseProtocolStruct:__init()
	self.msg_type = 0
	self.sys_id = 0
	self.cmd_id = 0
end

function BaseProtocolStruct:InitMsgType(sys_id, cmd_id)
	self.msg_type = bit:_lshift(cmd_id, 8) + sys_id
	self.sys_id = sys_id
	self.cmd_id = cmd_id
end

function BaseProtocolStruct:GetSysId()
	return self.sys_id
end

function BaseProtocolStruct:GetCmdId()
	return self.cmd_id
end

function BaseProtocolStruct:WriteBegin()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 编码
function BaseProtocolStruct:Encode()
end

-- 解码
function BaseProtocolStruct:Decode()
end

function BaseProtocolStruct:Send(net_id)
	MsgAdapter.Send(net_id)
end

function BaseProtocolStruct:EncodeAndSend(net_id)
	self:Encode()
	LogT("Send[" .. self.sys_id .. "  " .. self.cmd_id .. "]")
	MsgAdapter.Send(net_id)
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

-- 只需要注册C->S协议
function ProtocolPool:Register(protocol)
	if nil == protocol then
		ErrorLog("尝试注册的协议protocol 为 nil 值")
		return
	end

	local reg_protocol = protocol.New()
	if nil ~= self.protocol_list_by_type[reg_protocol.msg_type] then
		ErrorLog("协议重复注册 msg_type:" .. reg_protocol.msg_type)
		reg_protocol:DeleteMe()
		return -1
	end

	self.protocol_list[protocol] = reg_protocol
	self.protocol_list_by_type[reg_protocol.msg_type] = reg_protocol
	return reg_protocol.msg_type
end

function ProtocolPool:GetProtocolByType(msg_type)
	return self.protocol_list_by_type[msg_type]
end

function ProtocolPool:GetProtocol(protocol)
	return self.protocol_list[protocol] or self:AddProtoaol(protocol)
end

function ProtocolPool:AddProtoaol(protocol)
	self.protocol_list[protocol] = protocol.New()
	return self.protocol_list[protocol]
end
