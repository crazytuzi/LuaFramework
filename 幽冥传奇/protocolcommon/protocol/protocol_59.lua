--================================请求================================
-- 请求校验
CSWaiguaCheckReq = CSWaiguaCheckReq or BaseClass(BaseProtocolStruct)
function CSWaiguaCheckReq:__init()
	self:InitMsgType(59, 1)
end

function CSWaiguaCheckReq:Encode()
	self:WriteBegin()
end

--================================下发================================

--下发校验
SCWaiguaCheckAck = SCWaiguaCheckAck or BaseClass(BaseProtocolStruct)
function SCWaiguaCheckAck:__init()
	self:InitMsgType(59, 1)
	self.Interval_time = 0
end

function SCWaiguaCheckAck:Decode()
	self.Interval_time = MsgAdapter.ReadInt()
end