
-- 图鉴请求
CSCardHandleInfoReq = CSCardHandleInfoReq or BaseClass(BaseProtocolStruct)
function CSCardHandleInfoReq:__init()
	self:InitMsgType(68, 1)
end

function CSCardHandleInfoReq:Encode()
	self:WriteBegin()
end

-- 激活请求
CSCardFireReq = CSCardFireReq or BaseClass(BaseProtocolStruct)
function CSCardFireReq:__init()
	self:InitMsgType(68, 2)
	self.series = 0
end

function CSCardFireReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 升级请求
CSCardUpLevelReq = CSCardUpLevelReq or BaseClass(BaseProtocolStruct)
function CSCardUpLevelReq:__init()
	self:InitMsgType(68, 3)
	self.type_index = 0
	self.caowei_index = 0
end

function CSCardUpLevelReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type_index)
	MsgAdapter.WriteUChar(self.caowei_index)
end

-- 图鉴分解
CSDecomposeCardReq = CSDecomposeCardReq or BaseClass(BaseProtocolStruct)
function CSDecomposeCardReq:__init()
	self:InitMsgType(68, 4)
	self.equip_t = {}
end

function CSDecomposeCardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(#self.equip_t)
	for k, v in pairs(self.equip_t) do
		MsgAdapter.WriteUChar(v.cfg_index)
		CommonReader.WriteSeries(v.series)
	end
end


-- 下发图鉴数据
SCCardHandleInfo = SCCardHandleInfo or BaseClass(BaseProtocolStruct)
function SCCardHandleInfo:__init()
	self:InitMsgType(68, 1)
	self.card_type_count = 0 --套系数量
	self.card_count = 0	--图鉴数量
	self.card_list = {}
end

function SCCardHandleInfo:Decode()
	self.card_type_count = MsgAdapter.ReadUShort()
	self.card_list = {}
	for i = 1, self.card_type_count do
		self.card_count = MsgAdapter.ReadUShort()
		for i = 1, self.card_count do	
			local type_index = MsgAdapter.ReadUChar()
			local caowei_index = MsgAdapter.ReadUChar()
			local card_level = MsgAdapter.ReadUChar()
			self.card_list[type_index] = self.card_list[type_index] or {}
			self.card_list[type_index][caowei_index] = card_level
		end
	end
end

-- 下发激活结果
SCCardFireResult = SCCardFireResult or BaseClass(BaseProtocolStruct)
function SCCardFireResult:__init()
	self:InitMsgType(68, 2)
	self.type_index = 0
	self.caowei_index = 0
	self.card_level = 0
end

function SCCardFireResult:Decode()
	self.type_index = MsgAdapter.ReadUChar()
	self.caowei_index = MsgAdapter.ReadUChar()
	self.card_level = MsgAdapter.ReadUChar()
end

-- 下发升级结果
SCCardUpLevelResult = SCCardUpLevelResult or BaseClass(BaseProtocolStruct)
function SCCardUpLevelResult:__init()
	self:InitMsgType(68, 3)
	self.type_index = 0
	self.caowei_index = 0
	self.card_level = 0
end

function SCCardUpLevelResult:Decode()
	self.type_index = MsgAdapter.ReadUChar()
	self.caowei_index = MsgAdapter.ReadUChar()
	self.card_level = MsgAdapter.ReadUChar()
end

-- 图鉴分解结果
SCDecomposeCardResult = SCDecomposeCardResult or BaseClass(BaseProtocolStruct)
function SCDecomposeCardResult:__init()
	self:InitMsgType(68, 4)
	self.exp = 0
	self.num = 0
end

function SCDecomposeCardResult:Decode()
	self.exp = MsgAdapter.ReadUInt()
	self.num = MsgAdapter.ReadUChar()
end
