
-- 通过物品序列号星魂一件物品
CSPutOnConstellation = CSPutOnConstellation or BaseClass(BaseProtocolStruct)
function CSPutOnConstellation:__init()
	self:InitMsgType(42, 1)
	self.series = 0
end

function CSPutOnConstellation:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 根据星魂位置脱下星魂
CSTakeOffConstellationBySeat = CSTakeOffConstellationBySeat or BaseClass(BaseProtocolStruct)
function CSTakeOffConstellationBySeat:__init()
	self:InitMsgType(42, 2)
	self.slot_idx = 0
end

function CSTakeOffConstellationBySeat:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.slot_idx)
end

-- 强化槽位
CSStrengthenSlot = CSStrengthenSlot or BaseClass(BaseProtocolStruct)
function CSStrengthenSlot:__init()
	self:InitMsgType(42, 3)
	self.slot_idx = 0
	self.item_list = {}

end

function CSStrengthenSlot:Encode()
	self:WriteBegin()
	MsgAdapter.WriteChar(self.slot_idx)
	MsgAdapter.WriteChar(#self.item_list)
	
	for _, v in pairs(self.item_list) do
		MsgAdapter.WriteUShort(v.count) --ushort: 当前物品的消耗数量
		CommonReader.WriteSeries(v.series) --int64: 物品guid
	end
end

-- 收藏请求
CSCollect = CSCollect or BaseClass(BaseProtocolStruct)
function CSCollect:__init()
	self:InitMsgType(42, 4)
	self.series = 0
	self.type = 0
	self.grid_idx = 0
	self.item = CommonStruct.ItemDataWrapper()
end

function CSCollect:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteChar(self.type)
	MsgAdapter.WriteChar(self.grid_idx)
end

-- 取消收藏请求
CSCancelCollect = CSCancelCollect or BaseClass(BaseProtocolStruct)
function CSCancelCollect:__init()
	self:InitMsgType(42, 5)
	self.type = 0
	self.grid_idx = 0
end

function CSCancelCollect:Encode()
	self:WriteBegin()
	 MsgAdapter.WriteChar(self.type)
	 MsgAdapter.WriteChar(self.grid_idx)
end

----------------------------------------------------------------------
-- 下发星魂一件物品
SCPutOnConstellation = SCPutOnConstellation or BaseClass(BaseProtocolStruct)
function SCPutOnConstellation:__init()
	self:InitMsgType(42, 1)
	self.slot_idx = -1
	self.constellation = CommonStruct.ItemDataWrapper()
end

function SCPutOnConstellation:Decode()
	self.slot_idx = MsgAdapter.ReadInt()
	self.constellation = CommonReader.ReadItemData()
end

-- 脱下一件星魂
SCTakeOffOneConstellation = SCTakeOffOneConstellation or BaseClass(BaseProtocolStruct)
function SCTakeOffOneConstellation:__init()
	self:InitMsgType(42, 2)
	self.slot_idx = -1
end

function SCTakeOffOneConstellation:Decode()
	self.slot_idx = MsgAdapter.ReadInt()
end

-- 升级槽位结果
SCStrengthenSlot = SCStrengthenSlot or BaseClass(BaseProtocolStruct)
function SCStrengthenSlot:__init()
	self:InitMsgType(42, 3)
	self.slot_idx = -1
	self.slot_level = 0
	self.slot_exp = 0
end

function SCStrengthenSlot:Decode()
	self.slot_idx = MsgAdapter.ReadChar()
	self.slot_level = MsgAdapter.ReadInt()
	self.slot_exp = MsgAdapter.ReadInt()
end

-- 收藏结果
SCCollect = SCCollect or BaseClass(BaseProtocolStruct)
function SCCollect:__init()
	self:InitMsgType(42, 4)
	self.type = 0
	self.grid_idx = 0
	self.item = CommonStruct.ItemDataWrapper()
end

function SCCollect:Decode()
	self.type = MsgAdapter.ReadChar()
	self.grid_idx = MsgAdapter.ReadChar()
	self.item = CommonReader.ReadItemData()
end

-- 取消收藏结果
SCCancelCollect = SCCancelCollect or BaseClass(BaseProtocolStruct)
function SCCancelCollect:__init()
	self:InitMsgType(42, 5)
	self.type = 0
	self.grid_idx = 0
end

function SCCancelCollect:Decode()
	self.type = MsgAdapter.ReadChar()
	self.grid_idx = MsgAdapter.ReadChar()
end

-- 所有星魂信息
SCHoroscopeInfo = SCHoroscopeInfo or BaseClass(BaseProtocolStruct)
function SCHoroscopeInfo:__init()
	self:InitMsgType(42, 6)
	self.item_list = {}
	self.slot_list = {}
end

function SCHoroscopeInfo:Decode()
	self.item_list = {}
	local count = MsgAdapter.ReadChar()
	for i = 1, count do
		local horoscope_slot = MsgAdapter.ReadChar()
		self.item_list[horoscope_slot] = CommonReader.ReadItemData()
	end
	local slot_count = MsgAdapter.ReadChar()
	self.slot_list = {}
	for i = 0, slot_count - 1 do
		self.slot_list[i] = {
			level = MsgAdapter.ReadUInt(),
			exp = MsgAdapter.ReadUInt(),
		}
	end
end

-- 所有收藏信息
SCCollectionInfo = SCCollectionInfo or BaseClass(BaseProtocolStruct)
function SCCollectionInfo:__init()
	self:InitMsgType(42, 7)
	self.collection_list = {}
end

function SCCollectionInfo:Decode()
	local collection_count = MsgAdapter.ReadInt()
	self.collection_list = {}
	for i = 1, collection_count do
		self.collection_list[i] = {
			type = MsgAdapter.ReadChar(),
			grid_idx = MsgAdapter.ReadChar(),
			item = CommonReader.ReadItemData(),
		}
	end
end