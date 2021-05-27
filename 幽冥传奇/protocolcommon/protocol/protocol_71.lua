--================================请求================================
-- 龙珠提炼(返回71 2)
CSDragonBallRefiningReq = CSDragonBallRefiningReq or BaseClass(BaseProtocolStruct)
function CSDragonBallRefiningReq:__init()
	self:InitMsgType(71, 1)
	self.type = 0 -- 星珠类型（从0开始）
end

function CSDragonBallRefiningReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 龙珠吸收提炼(返回71 2)
CSDragonBallAbsorbReq = CSDragonBallAbsorbReq or BaseClass(BaseProtocolStruct)
function CSDragonBallAbsorbReq:__init()
	self:InitMsgType(71, 2)
	self.type = 0 -- 星珠类型（从0开始）
end

function CSDragonBallAbsorbReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

--================================下发================================

-- 接收龙珠所有数据
SCDragonBallInfo = SCDragonBallInfo or BaseClass(BaseProtocolStruct)
function SCDragonBallInfo:__init()
	self:InitMsgType(71, 1)
	self.count = 0
	self.info = {}
end

function SCDragonBallInfo:Decode()
	self.count = MsgAdapter.ReadUChar()
	for i = 1, self.count do
		self.info[i] = {
			phase = MsgAdapter.ReadUShort(),
			level = MsgAdapter.ReadUShort(),
		}
	end
end

-- 接收提炼与吸收操作结果
SCDragonBallResult = SCDragonBallResult or BaseClass(BaseProtocolStruct)
function SCDragonBallResult:__init()
	self:InitMsgType(71, 2)
	self.type = 0
	self.phase = 0
	self.level = 0
end

function SCDragonBallResult:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.phase = MsgAdapter.ReadUShort()
	self.level = MsgAdapter.ReadUShort()
end