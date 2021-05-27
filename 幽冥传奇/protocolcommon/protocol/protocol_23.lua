--===================================请求==================================
--获取仓库的物品列表
CSStorageListReq = CSStorageListReq or BaseClass(BaseProtocolStruct)
function CSStorageListReq:__init()
	self:InitMsgType(23, 1)
	self.storage_id = 0 -- (从1开始), 目前只设置最多3个仓库
end

function CSStorageListReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.storage_id)
end

--把一个物品从背包拖放到仓库
CSMoveItemToStorageFromBag = CSMoveItemToStorageFromBag or BaseClass(BaseProtocolStruct)
function CSMoveItemToStorageFromBag:__init()
	self:InitMsgType(23, 2)
	self.storage_id = 0
	self.item_series = 0
end

function CSMoveItemToStorageFromBag:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.storage_id)
	CommonReader.WriteSeries(self.item_series)
end

--把一个物品从仓库拖放到背包
CSMoveItemToBagFromStorage = CSMoveItemToBagFromStorage or BaseClass(BaseProtocolStruct)
function CSMoveItemToBagFromStorage:__init()
	self:InitMsgType(23, 3)
	self.storage_id = 0
	self.item_series = 0
end

function CSMoveItemToBagFromStorage:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.storage_id)
	CommonReader.WriteSeries(self.item_series)
end

--获取仓库的租用信息(返回 23 5)
CSStorageRentInfoReq = CSStorageRentInfoReq or BaseClass(BaseProtocolStruct)
function CSStorageRentInfoReq:__init()
	self:InitMsgType(23, 4)
end

function CSStorageRentInfoReq:Encode()
	self:WriteBegin()
end

--删除仓库物品
CSRemoveStorageItem = CSRemoveStorageItem or BaseClass(BaseProtocolStruct)
function CSRemoveStorageItem:__init()
	self:InitMsgType(23, 5)
	self.storage_id = 0
	self.item_series = 0
end

function CSRemoveStorageItem:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.storage_id)
	CommonReader.WriteSeries(self.item_series)
end

--仓库锁操作
CSStorageLockReq = CSStorageLockReq or BaseClass(BaseProtocolStruct)
function CSStorageLockReq:__init()
	self:InitMsgType(23, 6)
	self.req_type = 0
	self.password = ""
	self.n_password = ""
end

function CSStorageLockReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
	if self.req_type ~= LOCK_OP_ID.OP_LOCK then
		MsgAdapter.WriteStr(self.password)
		if self.req_type == LOCK_OP_ID.OP_CHG_LOCK then
			MsgAdapter.WriteStr(self.n_password)
		end
	end
end

--请求密码锁状态
CSStorageLockTypeReq = CSStorageLockTypeReq or BaseClass(BaseProtocolStruct)
function CSStorageLockTypeReq:__init()
	self:InitMsgType(23, 7)
end

function CSStorageLockTypeReq:Encode()
	self:WriteBegin()
end

--仓库金钱操作
CSStorageMoneyReq = CSStorageMoneyReq or BaseClass(BaseProtocolStruct)
function CSStorageMoneyReq:__init()
	self:InitMsgType(23, 8)
	self.type = 0 		--1存入, 2取出
	self.money_type = 0
	self.money_num = 0
end

function CSStorageMoneyReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	MsgAdapter.WriteUChar(self.money_type)
	MsgAdapter.WriteInt(self.money_num)
end

--购买格子
CSStorageBuyCell = CSStorageBuyCell or BaseClass(BaseProtocolStruct)
function CSStorageBuyCell:__init()
	self:InitMsgType(23, 10)
	self.cell_id = 0  --从1开始, 每个仓库的容量42, 最大仓库数量3个
end

function CSStorageBuyCell:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.cell_id)
end

--===================================下发==================================

-- 下发仓库的物品的列表
SCStorageList = SCStorageList or BaseClass(BaseProtocolStruct)
function SCStorageList:__init()
	self:InitMsgType(23, 1)
	self.storage_id = 0
	self.count = 0
	self.storage_list = {}
end

function SCStorageList:Decode()
	self.storage_id = MsgAdapter.ReadUChar()
	self.count = MsgAdapter.ReadUChar()
	self.storage_list = {}
	local begin_index = BagData.STORAGE_PAGE_COUNT * (self.storage_id - 1)
	for i = begin_index, begin_index + self.count - 1 do
		self.storage_list[i] = CommonReader.ReadItemData()
		self.storage_list[i].storage_id = self.storage_id
	end
end

-- 仓库获得物品
SCStorageAddItem = SCStorageAddItem or BaseClass(BaseProtocolStruct)
function SCStorageAddItem:__init()
	self:InitMsgType(23, 2)
	self.storage_id = 0 --仓库背包的编号,从1开始, 到(enDepotMax-1), 查看(enum enDepotType)
	self.item = CommonStruct.ItemDataWrapper()
end

function SCStorageAddItem:Decode()
	self.storage_id = MsgAdapter.ReadUChar()
	self.item = CommonReader.ReadItemData()
	self.item.storage_id = self.storage_id
end

-- 仓库删除物品
SCStorageRemoveItem = SCStorageRemoveItem or BaseClass(BaseProtocolStruct)
function SCStorageRemoveItem:__init()
	self:InitMsgType(23, 3)
	self.storage_id = 0 --仓库背包的编号,从1开始, 到(enDepotMax-1), 查看(enum enDepotType)
	self.item_series = 0
end

function SCStorageRemoveItem:Decode()
	self.storage_id = MsgAdapter.ReadUChar()
	self.item_series = CommonReader.ReadSeries()
end

-- 设置一个仓库的过期时间
SCStorageDeadline = SCStorageDeadline or BaseClass(BaseProtocolStruct)
function SCStorageDeadline:__init()
	self:InitMsgType(23, 4)
	self.storage_id = 0 --仓库背包的编号,从1开始, 到(enDepotMax-1), 查看(enum enDepotType)
	self.deadline = 0
end

function SCStorageDeadline:Decode()
	self.storage_id = MsgAdapter.ReadUChar()
	self.deadline = MsgAdapter.ReadUInt()
end

-- 下发几个仓库的租用信息
SCStoragRentInfo = SCStoragRentInfo or BaseClass(BaseProtocolStruct)
function SCStoragRentInfo:__init()
	self:InitMsgType(23, 5)
	self.storage_count = 0
	self.rant_info = {}
end

function SCStoragRentInfo:Decode()
	self.storage_count = MsgAdapter.ReadUChar()
	for i = 1, self.storage_count do
		self.rant_info[i] = MsgAdapter.ReadUInt()
	end
end

-- 玩家的物品的数量发生改变
SCStoragItemNumchange = SCStoragItemNumchange or BaseClass(BaseProtocolStruct)
function SCStoragItemNumchange:__init()
	self:InitMsgType(23, 6)
	self.storage_id = 0
	self.item_series = 0
	self.item_change_num = 0
end

function SCStoragItemNumchange:Decode()
	self.storage_id = MsgAdapter.ReadUChar()
	self.item_series = CommonReader.ReadSeries()
	self.item_change_num = MsgAdapter.ReadUShort()
end

-- 下发密码锁状态
SCStoragLockType = SCStoragLockType or BaseClass(BaseProtocolStruct)
function SCStoragLockType:__init()
	self:InitMsgType(23, 7)
	self.lock_type = 0
end

function SCStoragLockType:Decode()
	self.lock_type = MsgAdapter.ReadUChar()
end