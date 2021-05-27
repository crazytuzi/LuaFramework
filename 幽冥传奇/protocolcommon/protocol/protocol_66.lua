
-- 符文注灵(返回 66 1)
CSUpFuwenReq = CSUpFuwenReq or BaseClass(BaseProtocolStruct)
function CSUpFuwenReq:__init()
	self:InitMsgType(66, 1)
end

function CSUpFuwenReq:Encode()
	self:WriteBegin()
end

-- 装上符文碎片(返回 66 2)
CSFuwenEquipReq = CSFuwenEquipReq or BaseClass(BaseProtocolStruct)
function CSFuwenEquipReq:__init()
	self:InitMsgType(66, 2)
	self.guid = 0
end

function CSFuwenEquipReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.guid)
end

-- 卸下符文碎片(返回 66 3)
-- CSFuwenTakeOffReq = CSFuwenTakeOffReq or BaseClass(BaseProtocolStruct)
-- function CSFuwenTakeOffReq:__init()
-- 	self:InitMsgType(66, 3)
-- 	self.boss_index = 0
-- 	self.fuwen_index = 0
-- end

-- function CSFuwenTakeOffReq:Encode()
-- 	self:WriteBegin()
-- 	MsgAdapter.WriteUChar(self.boss_index)
-- 	MsgAdapter.WriteUChar(self.fuwen_index)
-- end

-- 获取符文信息(返回 66 4)
CSGetFuwenInfoReq = CSGetFuwenInfoReq or BaseClass(BaseProtocolStruct)
function CSGetFuwenInfoReq:__init()
	self:InitMsgType(66, 4)
end

function CSGetFuwenInfoReq:Encode()
	self:WriteBegin()
end

-- 获取符文套状态(返回 66 5)
CSGetFuwenStateReq = CSGetFuwenStateReq or BaseClass(BaseProtocolStruct)
function CSGetFuwenStateReq:__init()
	self:InitMsgType(66, 5)
end

function CSGetFuwenStateReq:Encode()
	self:WriteBegin()
end

--===================================下发==================================

-- 符文注灵结果
SCUpFuwenResultAck = SCUpFuwenResultAck or BaseClass(BaseProtocolStruct)
function SCUpFuwenResultAck:__init()
	self:InitMsgType(66, 1)
	self.fuwen_index = 0
	self.level = 0
	self.result = 0
end

function SCUpFuwenResultAck:Decode()
	self.fuwen_index = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadUChar()
	self.result = MsgAdapter.ReadUChar()
end

-- 装上结果
SCFuwenEquipResultAck = SCFuwenEquipResultAck or BaseClass(BaseProtocolStruct)
function SCFuwenEquipResultAck:__init()
	self:InitMsgType(66, 2)
	self.fuwen_index = 0
	self.item = CommonStruct.ItemDataWrapper()
end

function SCFuwenEquipResultAck:Decode()
	self.fuwen_index = MsgAdapter.ReadUChar()
	self.item = CommonReader.ReadItemData()
	self.item.fuwen_index = fuwen_index
end

-- 卸下结果
-- SCFuwenTakeOffResultAck = SCFuwenTakeOffResultAck or BaseClass(BaseProtocolStruct)
-- function SCFuwenTakeOffResultAck:__init()
-- 	self:InitMsgType(66, 3)
-- 	self.guid = 0
-- 	self.boss_index = 0
-- 	self.fuwen_index = 0
-- end

-- function SCFuwenTakeOffResultAck:Decode()
-- 	self.guid = CommonReader.ReadSeries()
-- 	self.boss_index = MsgAdapter.ReadUChar()
-- 	self.fuwen_index = MsgAdapter.ReadUChar()
-- end

-- 获取符文结果
SCFuwenInfo = SCFuwenInfo or BaseClass(BaseProtocolStruct)
function SCFuwenInfo:__init()
	self:InitMsgType(66, 4)
	self.zhuling_data = {}
	self.fuwen_list = {}
end

function SCFuwenInfo:Decode()
	self.zhuling_data = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.zhuling_data[i] = {
			fuwen_index = MsgAdapter.ReadUChar(),
			level = MsgAdapter.ReadUChar(),
		}
	end

	self.fuwen_list = {}
	for i = 1, MsgAdapter.ReadUChar() do	
		local index = MsgAdapter.ReadUChar()
		local item = CommonReader.ReadItemData()
		item.fuwen_index = index
		self.fuwen_list[index] = item
	end
end

-- 符文套状态结果
SCFuwenStatetAck = SCFuwenStatetAck or BaseClass(BaseProtocolStruct)
function SCFuwenStatetAck:__init()
	self:InitMsgType(66, 5)
	self.state = 0 	--符文套状态, 1激活, 0失效
end

function SCFuwenStatetAck:Decode()
	self.state = MsgAdapter.ReadUChar()
end