--===================================请求==================================

-- 开始或者停止挂机(好像只在前端处理)
CSGuajiReq = CSGuajiReq or BaseClass(BaseProtocolStruct)
function CSGuajiReq:__init()
	self:InitMsgType(18, 4)
	self.is_stop = 0 -- 0开始, 1停止
end

function CSGuajiReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.is_stop)
end

--===================================下发==================================

-- 开始或者停止挂机(好像只在前端处理)
SCGuajiChange = SCGuajiChange or BaseClass(BaseProtocolStruct)
function SCGuajiChange:__init()
	self:InitMsgType(18, 4)
	self.is_stop = 0 -- 0开始, 1停止
end

function SCGuajiChange:Decode()
	self.is_stop = MsgAdapter.ReadUInt()
end