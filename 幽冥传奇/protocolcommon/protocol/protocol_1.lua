
-- 走路请求
CSMoveReq = CSMoveReq or BaseClass(BaseProtocolStruct)
function CSMoveReq:__init()
	self:InitMsgType(1, 1)
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function CSMoveReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_y)
	MsgAdapter.WriteUShort(self.dir)
	MsgAdapter.WriteUInt(Status.NowTime)
end

-- 跑步请求
CSRunReq = CSRunReq or BaseClass(BaseProtocolStruct)
function CSRunReq:__init()
	self:InitMsgType(1, 2)
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function CSRunReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.pos_x)
	MsgAdapter.WriteUShort(self.pos_y)
	MsgAdapter.WriteUShort(self.dir)
	MsgAdapter.WriteUInt(Status.NowTime)
end
